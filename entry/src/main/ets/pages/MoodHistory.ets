import { router } from '@kit.ArkUI';
import MoodDB from '../utils/MoodDB';
import MoodData from '../model/MoodData';

interface MoodItem {
  icon: string;
  name: string;
}

@Entry
@Component
struct MoodHistory {
  @State historyList: MoodData[] = []; // 原始完整数据
  @State filteredList: MoodData[] = []; // 搜索筛选后的数据
  @State searchText: string = ''; // 搜索关键词

  private moods: MoodItem[] = [
    { icon: '😄', name: '开心' },
    { icon: '😐', name: '平静' },
    { icon: '😰', name: '焦虑' },
    { icon: '😢', name: '伤心' },
    { icon: '😡', name: '生气' },
    { icon: '😴', name: '疲惫' },
    { icon: '🤩', name: '兴奋' },
    { icon: '🤯', name: '烦躁' }
  ];

  onPageShow() {
    this.loadData();
  }

  loadData() {
    MoodDB.queryAll().then((data) => {
      this.historyList = data;
      this.applyFilter(); // 加载后立即应用筛选（默认为全部）
    });
  }

  // ★ 核心逻辑：执行筛选
  applyFilter() {
    if (this.searchText.trim() === '') {
      this.filteredList = this.historyList;
    } else {
      const keyword = this.searchText.toLowerCase();
      this.filteredList = this.historyList.filter(item =>
      // 搜索范围：原因文字 或 日记正文
      item.reason.toLowerCase().includes(keyword) ||
      item.diaryContent.toLowerCase().includes(keyword)
      );
    }
  }

  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${month}月${day}日 ${hours}:${minutes}`;
  }

  getScoreColor(score: number): string {
    if (score >= 8) return '#FF9800';
    if (score >= 5) return '#2196F3';
    return '#9E9E9E';
  }

  build() {
    Column() {
      // --- 1. 顶部导航栏 ---
      Row() {
        Column() {
          Text('👈').fontSize(24)
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => router.back())

        Text('心情时光轴')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('📊')
          .fontSize(24)
          .width(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: 'pages/MoodStatistics' })
          })
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 15, bottom: 10 })
      .backgroundColor('#FFFFFF')

      // --- 2. ★ 新增：搜索框区域 ---
      Search({ value: this.searchText, placeholder: '搜索心情原因或日记...' })
        .width('90%')
        .height(40)
        .backgroundColor('#FFF')
        .margin({ bottom: 15, top: 5 })
        .onChange((value: string) => {
          this.searchText = value;
          this.applyFilter(); // 输入变化时实时筛选
        })

      // --- 3. 列表区域 ---
      if (this.filteredList.length === 0) {
        Column() {
          Text(this.searchText ? '🔍' : '📭').fontSize(60).margin({ bottom: 20 })
          Text(this.searchText ? '没有找到相关记录' : '还没有记录，快去写一篇吧~').fontColor('#999')
        }.width('100%').margin({ top: 100 })
      } else {
        List({ space: 15 }) {
          ForEach(this.filteredList, (item: MoodData) => {
            ListItem() {
              Column() {
                // 顶部：日期 + 分数
                Row() {
                  Text(this.formatDate(item.date))
                    .fontSize(14)
                    .fontColor('#999')
                  Blank()
                  Text(item.moodScore + '分')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.getScoreColor(item.moodScore))
                }
                .width('100%')
                .margin({ bottom: 10 })

                // 中间：Emoji + 原因
                Row() {
                  Text(this.moods[item.moodType] ? this.moods[item.moodType].icon : '❓')
                    .fontSize(40)
                    .margin({ right: 15 })

                  if (item.reason) {
                    Text(item.reason)
                      .fontSize(16)
                      .fontColor('#333')
                      .backgroundColor('#F5F7F9')
                      .padding(10)
                      .borderRadius(10)
                      .layoutWeight(1)
                  }
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)

                // 日记摘要
                if (item.diaryContent) {
                  Text(item.diaryContent)
                    .fontSize(15)
                    .fontColor('#555')
                    .margin({ top: 10 })
                    .lineHeight(22)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                }
              }
              .width('100%')
              .padding(15)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .shadow({ radius: 10, color: '#08000000', offsetY: 2 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/MoodDetail',
                  params: item
                });
              })
            }
          })
        }
        .width('95%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F5F5F5')
  }
}