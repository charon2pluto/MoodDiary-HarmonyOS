import { router } from '@kit.ArkUI';
import MoodDB from '../utils/MoodDB';
import MoodData from '../model/MoodData';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

// 1. 初始化持久化数据
PersistentStorage.persistProp('dailyQuoteDate', '');
PersistentStorage.persistProp('dailyQuoteContent', '');

interface MoodItem {
  icon: string;
  name: string;
}

@Entry
@Component
struct Index {
  // --- 数据源 ---
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

  // 语录库
  private quotes: string[] = [
    "心若向阳，无畏悲伤。",
    "生活原本沉闷，但跑起来就有风。",
    "万物皆有裂痕，那是光照进来的地方。",
    "热爱可抵岁月漫长。",
    "保持热爱，奔赴山海。",
    "星光不问赶路人，时光不负有心人。",
    "你若盛开，蝴蝶自来。",
    "好好生活，慢慢相遇。",
    "凡是过往，皆为序章。",
    "人生没有白走的路，每一步都算数。"
  ];

  // --- 状态变量 ---
  @State currentDate: string = '';
  @State selectedMoodIndex: number = -1;
  @State moodScore: number = 5;
  @State reasonText: string = '';

  @State miniChartPoints: number[][] = [];
  @State hasHistory: boolean = false;

  // --- 语录相关状态 ---
  @StorageLink('dailyQuoteDate') appQuoteDate: string = '';
  @StorageLink('dailyQuoteContent') appQuoteContent: string = '';
  @State todayQuote: string = '';

  aboutToAppear() {
    const date = new Date();
    this.currentDate = `${date.getMonth() + 1}月${date.getDate()}日`;

    let context = getContext(this) as common.UIAbilityContext;
    MoodDB.init(context).then(() => {
      console.log('🎉 主页：数据库连接成功！');
      this.loadMiniChart();
    }).catch((err: Error) => {
      console.error('😭 主页：数据库连接失败', err);
    });

    // 生成今日语录
    this.generateDailyQuote();
  }

  onPageShow() {
    this.loadMiniChart();
  }

  // ★★★ 修改点1：逻辑改为“每次都刷新” ★★★
  generateDailyQuote() {
    // 之前我们判断了日期，现在直接移除判断，每次进来都随机
    const index = Math.floor(Math.random() * this.quotes.length);
    const newQuote = this.quotes[index];

    // 更新显示
    this.todayQuote = newQuote;

    // 顺便更新一下本地存储（虽然现在不依赖它来“锁住”语录了，但保持数据最新也不错）
    this.appQuoteContent = newQuote;
    this.appQuoteDate = new Date().toDateString();
  }

  loadMiniChart() {
    MoodDB.queryAll().then((data) => {
      if (data.length > 0) {
        this.hasHistory = true;
        let recent = data.slice(0, 7).reverse();

        let width = 300;
        let height = 50;
        let stepX = width / (recent.length - 1 || 1);

        this.miniChartPoints = recent.map((item, index) => {
          let x = index * stepX;
          let y = height - (item.moodScore / 10 * height);
          return [x, y];
        });
      } else {
        this.hasHistory = false;
      }
    });
  }

  build() {
    Column() {
      // 1. 顶部日期与设置
      Column() {
        Row() {
          Text(this.currentDate)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')

          Blank()

          Text('⚙️')
            .fontSize(24)
            .onClick(() => {
              router.pushUrl({ url: 'pages/SettingsPage' });
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Text('今天过得怎么样？')
          .fontSize(16)
          .fontColor('#666')
          .margin({ top: 5 })
          .width('100%')
      }
      .padding({ top: 50, left: 24, right: 24, bottom: 20 })

      // 2. 核心内容区
      Scroll() {
        Column() {

          // --- 卡片: 今日语录 ---
          Stack({ alignContent: Alignment.TopStart }) {
            // 装饰用的双引号 (配合米色背景，换成淡金色或淡棕色)
            Text('“')
              .fontSize(60)
              .fontColor('rgba(200, 180, 150, 0.4)') // 淡金棕色，更有质感
              .position({ x: 10, y: -10 })
              .fontFamily('HarmonyOS Sans')

            Text(this.todayQuote)
              .fontSize(15)
              .fontColor('#5D4037') // ★ 文字换成深褐色，比纯黑更柔和，像打印的字
              .fontStyle(FontStyle.Italic)
              .lineHeight(24)
              .width('100%')
              .padding({ left: 40, right: 20, top: 15, bottom: 15 })
          }
          .width('90%')
          // ★★★ 修改点：换成温暖米杏色 ★★★
          .backgroundColor('#FEF9E7')
          .borderRadius(16)
          .margin({ bottom: 20 })
          // 阴影也换成暖色调，显得很暖
          .shadow({ radius: 10, color: 'rgba(200, 180, 150, 0.3)', offsetY: 5 })
          .border({ width: 1, color: '#FFF' }) // 加个白边，像卡片一样

          // --- 卡片 A: 心情趋势小预览 ---
          if (this.hasHistory) {
            Column() {
              Row() {
                Text('情绪走势').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333')
                Blank()
                Text('最近7条').fontSize(12).fontColor('#999')
              }.width('100%').margin({ bottom: 10 })

              Stack({ alignContent: Alignment.Center }) {
                Divider().color('rgba(0,0,0,0.05)').width('100%')

                Polyline()
                  .points(this.miniChartPoints)
                  .fill('none')
                  .stroke('#7B61FF')
                  .strokeWidth(2)
                  .width('100%')
                  .height(50)
              }
              .height(50)
              .width('100%')
            }
            .width('90%')
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [['#E3F2FD', 0.0], ['#F3E5F5', 1.0]]
            })
            .borderRadius(16)
            .padding(15)
            .margin({ bottom: 15 })
          }

          // --- 卡片 B: Emoji 选择网格 ---
          Column() {
            Grid() {
              ForEach(this.moods, (item: MoodItem, index: number) => {
                GridItem() {
                  Column() {
                    Text(item.icon).fontSize(32)
                    Text(item.name).fontSize(12).fontColor(this.selectedMoodIndex === index ? '#7B61FF' : '#999').margin({ top: 5 })
                  }
                  .width(60)
                  .height(70)
                  .justifyContent(FlexAlign.Center)
                  .borderRadius(12)
                  .backgroundColor(this.selectedMoodIndex === index ? '#F2EFFF' : 'transparent')
                  .border({ width: 1, color: this.selectedMoodIndex === index ? '#7B61FF' : 'transparent' })
                  .scale(this.selectedMoodIndex === index ? { x: 1.1, y: 1.1 } : { x: 1, y: 1 })
                  .animation({ duration: 300, curve: Curve.EaseOut })
                  .onClick(() => {
                    this.selectedMoodIndex = index;
                  })
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .rowsGap(10)
            .height(170)
            .width('100%')
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(24)
          .padding(15)
          .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.08)', offsetY: 5 })
          .border({ width: 1, color: '#F0F0F0' })

          // --- 卡片 C: 详细记录区 ---
          if (this.selectedMoodIndex !== -1) {
            Column() {
              Row() {
                Text('强度').fontSize(14).fontColor('#666')
                Blank()
                Text(this.moodScore.toFixed(0)).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#7B61FF')
              }.width('100%').margin({ bottom: 5 })

              Slider({
                value: this.moodScore,
                min: 1,
                max: 10,
                step: 1,
                style: SliderStyle.OutSet
              })
                .blockColor('#7B61FF')
                .trackColor('#E0E0E0')
                .selectedColor('#7B61FF')
                .showSteps(true)
                .onChange((value: number) => {
                  this.moodScore = value;
                })
                .width('100%')

              Divider().margin({ top: 15, bottom: 15 }).color('#F5F5F5')

              TextInput({ placeholder: '写一句简短的原因...' })
                .placeholderColor('#CCC')
                .fontSize(14)
                .caretColor('#7B61FF')
                .width('100%')
                .height(40)
                .backgroundColor('transparent')
                .onChange((value) => {
                  this.reasonText = value;
                })

              Button('✨ 记录此刻', { type: ButtonType.Capsule })
                .width('100%')
                .height(45)
                .backgroundColor('#7B61FF')
                .margin({ top: 20 })
                .shadow({ radius: 10, color: 'rgba(123, 97, 255, 0.4)', offsetY: 5 })
                .onClick(() => {
                  this.saveData();
                })
            }
            .width('90%')
            .backgroundColor('#FFFFFF')
            .borderRadius(24)
            .padding(20)
            .margin({ top: 15 })
            .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.08)', offsetY: 5 })
            .border({ width: 1, color: '#F0F0F0' })
            .transition({ type: TransitionType.Insert, opacity: 0, translate: { y: 20 } })
          }

          Blank().height(100)
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)

      // 3. 底部悬浮按钮栏
      Row() {
        // 写日记按钮
        Column() {
          Button({ type: ButtonType.Circle }) {
            Text('✍️')
              .fontSize(28)
              .fontColor('#FFF')
          }
          .width(56)
          .height(56)
          .backgroundColor('#FF9800')
          .shadow({ radius: 10, color: 'rgba(255, 152, 0, 0.4)', offsetY: 5 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/DiaryEdit' });
          })
          Text('写日记').fontSize(11).fontColor('#666').margin({ top: 4 })
        }.margin({ right: 60 })

        // 看足迹按钮
        Column() {
          Button({ type: ButtonType.Circle }) {
            Text('📅')
              .fontSize(26)
              .fontColor('#FFF')
          }
          .width(56)
          .height(56)
          .backgroundColor('#00BCD4')
          .shadow({ radius: 10, color: 'rgba(0, 188, 212, 0.4)', offsetY: 5 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/MoodHistory' });
          })
          Text('看足迹').fontSize(11).fontColor('#666').margin({ top: 4 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: 20 })
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  saveData() {
    let newMood = new MoodData(
      0,
      MoodDB.currentUserId,
      new Date().getTime(),
      this.selectedMoodIndex,
      this.moodScore,
      this.reasonText,
      '',
      ''
    );

    MoodDB.insert(newMood).then((id) => {
      AlertDialog.show({ message: '✨ 记录成功！' });
      this.loadMiniChart();
      this.selectedMoodIndex = -1;
      this.reasonText = '';
      this.moodScore = 5;
    }).catch((err: BusinessError) => {
      AlertDialog.show({ message: '保存失败: ' + err.message });
    });
  }
}