import { router } from '@kit.ArkUI';
import MoodDB from '../utils/MoodDB';
import MoodData from '../model/MoodData';

// 1. 定义类 (解决 Object literal 报错)
class MoodConfig {
  icon: string;
  name: string;
  color: string;

  constructor(icon: string, name: string, color: string) {
    this.icon = icon;
    this.name = name;
    this.color = color;
  }
}

class MoodRank {
  name: string;
  count: number;
  percent: number;
  color: string;

  constructor(name: string, count: number, percent: number, color: string) {
    this.name = name;
    this.count = count;
    this.percent = percent;
    this.color = color;
  }
}

@Entry
@Component
struct MoodStatistics {
  // --- 状态变量 ---
  @State points: number[][] = [];
  @State chartData: MoodData[] = [];
  @State allData: MoodData[] = [];
  @State averageScore: string = '0.0';
  @State timeRange: number = 7;

  @State bestDay: string = '暂无';
  @State topMoodEmoji: string = '❓';
  @State topMoodName: string = '暂无';
  @State topMoodCount: number = 0;

  // 使用定义好的类
  @State moodRanks: MoodRank[] = [];

  chartHeight: number = 180;
  chartWidth: number = 300;

  // 使用 new 类实例的方式初始化
  private moodConfig: MoodConfig[] = [
    new MoodConfig('😄', '开心', '#FF9800'),
    new MoodConfig('😐', '平静', '#2196F3'),
    new MoodConfig('😰', '焦虑', '#607D8B'),
    new MoodConfig('😢', '伤心', '#9C27B0'),
    new MoodConfig('😡', '生气', '#F44336'),
    new MoodConfig('😴', '疲惫', '#795548'),
    new MoodConfig('🤩', '兴奋', '#E91E63'),
    new MoodConfig('🤯', '烦躁', '#FF5722')
  ];

  aboutToAppear() {
    MoodDB.queryAll().then((data) => {
      this.allData = data;
      this.refreshData();
    });
  }

  refreshData() {
    let targetData = this.allData.slice(0, this.timeRange).reverse();
    this.chartData = targetData;

    if (targetData.length === 0) {
      this.resetStats();
      return;
    }

    // 计算平均分
    let totalScore = targetData.reduce((sum, item) => sum + item.moodScore, 0);
    this.averageScore = (totalScore / targetData.length).toFixed(1);

    // 计算折线图坐标
    let stepX = this.chartWidth / (targetData.length - 1 || 1);
    this.points = targetData.map((item, index) => {
      let x = index * stepX;
      let y = this.chartHeight - (item.moodScore / 10 * this.chartHeight);
      return [x, y];
    });

    this.calculateBestStats(targetData);
    this.calculateMoodRanks(targetData);
  }

  calculateBestStats(data: MoodData[]) {
    // A. 找分最高的日子
    let maxScoreItem = data.reduce((prev, curr) => curr.moodScore > prev.moodScore ? curr : prev, data[0]);
    let date = new Date(maxScoreItem.date);
    this.bestDay = `${date.getMonth() + 1}月${date.getDate()}日`;

    // B. 找出现最多的情绪 (使用数组代替对象)
    let counts: number[] = [0, 0, 0, 0, 0, 0, 0, 0]; // 对应8种情绪
    data.forEach(item => {
      if (item.moodType >= 0 && item.moodType < 8) {
        counts[item.moodType]++;
      }
    });

    let maxType = -1;
    let maxCount = 0;

    // 使用标准 for 循环代替 for...in
    for (let i = 0; i < counts.length; i++) {
      if (counts[i] > maxCount) {
        maxCount = counts[i];
        maxType = i;
      }
    }

    if (maxType !== -1 && this.moodConfig[maxType]) {
      this.topMoodEmoji = this.moodConfig[maxType].icon;
      this.topMoodName = this.moodConfig[maxType].name;
      this.topMoodCount = maxCount;
    }
  }

  calculateMoodRanks(data: MoodData[]) {
    // 统计频次
    let counts: number[] = [0, 0, 0, 0, 0, 0, 0, 0];
    data.forEach(item => {
      if (item.moodType >= 0 && item.moodType < 8) {
        counts[item.moodType]++;
      }
    });

    let result: MoodRank[] = [];
    let total = data.length;

    // 遍历数组
    for (let i = 0; i < counts.length; i++) {
      if (counts[i] > 0) {
        result.push(new MoodRank(
          this.moodConfig[i].name,
          counts[i],
          Math.round((counts[i] / total) * 100),
          this.moodConfig[i].color
        ));
      }
    }

    // 排序并取前 3 名
    this.moodRanks = result.sort((a, b) => b.count - a.count).slice(0, 3);
  }

  resetStats() {
    this.points = [];
    this.averageScore = '0.0';
    this.bestDay = '-';
    this.topMoodEmoji = '❓';
    this.topMoodName = '-';
    this.moodRanks = [];
  }

  @Builder
  TabButton(days: number, text: string) {
    Button(text)
      .layoutWeight(1)
      .height(40)
      .fontSize(14)
      .backgroundColor(this.timeRange === days ? '#333' : '#FFF')
      .fontColor(this.timeRange === days ? '#FFF' : '#666')
      .onClick(() => {
        this.timeRange = days;
        this.refreshData();
      })
      .animation({ duration: 200 })
  }

  build() {
    Column() {
      // --- 标题栏 ---
      Row() {
        Text('👈').fontSize(24).onClick(() => router.back())
        Text('情绪趋势报告').fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 15 })
      }
      .width('100%')
      .padding(20)

      Scroll() {
        Column() {
          // --- 1. 时间切换栏 ---
          Row() {
            this.TabButton(7, '近7天')
            Blank().width(15)
            this.TabButton(30, '近30天')
          }
          .width('90%')
          .margin({ bottom: 20 })

          // --- 2. 核心概览卡片 ---
          Row() {
            Column() {
              Text('平均分').fontSize(12).fontColor('rgba(255,255,255,0.7)')
              Text(this.averageScore).fontSize(32).fontWeight(FontWeight.Bold).fontColor('#FFF')
            }
            Blank()
            Column() {
              Text('记录数').fontSize(12).fontColor('rgba(255,255,255,0.7)')
              Text(this.chartData.length + ' 条').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFF')
            }
          }
          .width('90%')
          .padding(25)
          .backgroundColor('#7B61FF')
          .borderRadius(20)
          .shadow({ radius: 10, color: 'rgba(123, 97, 255, 0.4)', offsetY: 5 })
          .margin({ bottom: 20 })

          if (this.chartData.length > 1) {
            // --- 3. 折线图卡片 ---
            Column() {
              Text('情绪波动').fontSize(16).fontWeight(FontWeight.Bold).width('100%').margin({ bottom: 20 })

              Stack({ alignContent: Alignment.TopStart }) {
                Column() {
                  Divider().color('#F0F0F0')
                  Blank()
                  Divider().color('#F0F0F0')
                  Blank()
                  Divider().color('#F0F0F0')
                }.height(this.chartHeight).width('100%')

                Polyline()
                  .points(this.points)
                  .fill('none')
                  .stroke('#FF9800')
                  .strokeWidth(3)
                  .width(this.chartWidth)
                  .height(this.chartHeight)

                ForEach(this.points, (point: number[]) => {
                  Row().width(8).height(8).borderRadius(4).backgroundColor('#FF9800')
                    .border({ width: 2, color: '#FFF' })
                    .position({ x: point[0] - 4, y: point[1] - 4 })
                })
              }
              .width(this.chartWidth)
              .height(this.chartHeight)
            }
            .width('90%')
            .padding(20)
            .backgroundColor('#FFF')
            .borderRadius(20)
            .margin({ bottom: 20 })

            // --- 4. 情绪之最 ---
            Row() {
              Column() {
                Text('最佳状态').fontSize(12).fontColor('#999').margin({ bottom: 5 })
                Text('📅 ' + this.bestDay).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
              }
              .layoutWeight(1)
              .padding(15)
              .backgroundColor('#FFF')
              .borderRadius(16)
              .alignItems(HorizontalAlign.Start)

              Blank().width(10)

              Column() {
                Text('主导情绪').fontSize(12).fontColor('#999').margin({ bottom: 5 })
                Row() {
                  Text(this.topMoodEmoji).fontSize(20).margin({ right: 5 })
                  Text(this.topMoodName).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
                  Text(` (${this.topMoodCount})`).fontSize(12).fontColor('#999')
                }
              }
              .layoutWeight(1)
              .padding(15)
              .backgroundColor('#FFF')
              .borderRadius(16)
              .alignItems(HorizontalAlign.Start)
            }
            .width('90%')
            .margin({ bottom: 20 })

            // --- 5. 情绪成分表 ---
            Column() {
              Text('情绪成分分析').fontSize(16).fontWeight(FontWeight.Bold).width('100%').margin({ bottom: 15 })

              ForEach(this.moodRanks, (item: MoodRank) => {
                Row() {
                  Text(item.name).width(40).fontSize(14).fontColor('#666')

                  Stack({ alignContent: Alignment.Start }) {
                    Row().width('100%').height(8).backgroundColor('#F5F5F5').borderRadius(4)
                    Row()
                      .width(`${item.percent}%`)
                      .height(8)
                      .backgroundColor(item.color)
                      .borderRadius(4)
                      .animation({ duration: 500 })
                  }
                  .layoutWeight(1)
                  .margin({ left: 10, right: 10 })

                  Text(`${item.percent}%`).fontSize(12).fontColor('#999').width(30)
                }
                .width('100%')
                .margin({ bottom: 12 })
              })
            }
            .width('90%')
            .padding(20)
            .backgroundColor('#FFF')
            .borderRadius(20)
            .margin({ bottom: 30 })

          } else {
            Column() {
              Text('📊').fontSize(60)
              Text('记录太少，无法生成报告').fontColor('#999').margin({ top: 10 })
            }.margin({ top: 50 })
          }
        }
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F5F7F9')
  }
}