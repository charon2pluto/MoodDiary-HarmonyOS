import { router } from '@kit.ArkUI';
import MoodData from '../model/MoodData';

interface MoodItem {
  icon: string;
  name: string;
}

@Entry
@Component
struct MoodDetail {
  // 接收从上一页传过来的数据
  @State moodData: MoodData = router.getParams() as MoodData;

  // 心情配置 (用于显示图标和名字)
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

  // 格式化日期：2025年12月26日 星期五 08:30
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const dateStr = `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
    const timeStr = `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    return `${dateStr} ${timeStr}`;
  }

  // 获取分数颜色
  getScoreColor(score: number): string {
    if (score >= 8) return '#FF9800'; // 橙
    if (score >= 5) return '#2196F3'; // 蓝
    return '#9E9E9E'; // 灰
  }

  build() {
    Column() {
      // 1. 顶部导航栏 (透明背景)
      Row() {
        // 返回按钮
        Column() {
          Text('👈').fontSize(24)
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.back();
        })

        Text('日记详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(40) // 占位，保持标题居中
      }
      .width('100%')
      .padding({ top: 10, bottom: 10, left: 10, right: 10 })

      // 2. 内容滚动区
      Scroll() {
        Column() {
          // --- A. 头部卡片 (日期+心情) ---
          Column() {
            Text(this.formatDate(this.moodData.date))
              .fontSize(14)
              .fontColor('#666')
              .margin({ bottom: 15 })

            Row() {
              // 左边：大表情
              Column() {
                Text(this.moods[this.moodData.moodType].icon).fontSize(60)
                Text(this.moods[this.moodData.moodType].name)
                  .fontSize(16)
                  .fontColor('#666')
                  .margin({ top: 5 })
              }

              Blank().width(30)

              // 右边：强度分数
              Column() {
                Text(this.moodData.moodScore.toString())
                  .fontSize(40)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getScoreColor(this.moodData.moodScore))
                Text('心情指数')
                  .fontSize(12)
                  .fontColor('#999')
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 20 })

            // 原因气泡
            if (this.moodData.reason) {
              Text(this.moodData.reason)
                .fontSize(16)
                .fontColor('#333')
                .backgroundColor('rgba(0,0,0,0.05)')
                .padding({ left: 15, right: 15, top: 10, bottom: 10 })
                .borderRadius(20)
            }
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(24)
          .padding(20)
          .shadow({ radius: 20, color: 'rgba(0,0,0,0.05)', offsetY: 10 })
          .margin({ top: 10, bottom: 20 })

          // --- B. 完整日记内容 ---
          if (this.moodData.diaryContent) {
            Column() {
              Text('📝 日记内容')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .margin({ bottom: 15 })

              // 这里的 Text 会自动换行，显示完整内容
              Text(this.moodData.diaryContent)
                .fontSize(16)
                .fontColor('#333')
                .lineHeight(26) // 增加行高，阅读更舒服
                .width('100%')
            }
            .width('90%')
            .backgroundColor('#FFFFFF')
            .borderRadius(24)
            .padding(20)
            .shadow({ radius: 20, color: 'rgba(0,0,0,0.05)', offsetY: 10 })
            .margin({ bottom: 20 })
          }

          // --- C. 图片展示区 ---
          if (this.moodData.images && this.moodData.images.length > 0) {
            Column() {
              Text('📷 照片回忆')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .margin({ bottom: 15 })

              ForEach(this.moodData.images.split(',').filter(p => p !== ''), (img: string) => {
                Image(img)
                  .width('100%')
                  .borderRadius(12)
                  .margin({ bottom: 10 })
                  .objectFit(ImageFit.Cover)
              })
            }
            .width('90%')
            .backgroundColor('#FFFFFF')
            .borderRadius(24)
            .padding(20)
            .shadow({ radius: 20, color: 'rgba(0,0,0,0.05)', offsetY: 10 })
            .margin({ bottom: 40 })
          }
        }
        .width('100%')
      }
      .layoutWeight(1) // 占满剩余空间
      .scrollBar(BarState.Off)
    }
    .height('100%')
    .width('100%')
    // 保持统一的渐变背景
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [['#E3F2FD', 0.0], ['#F3E5F5', 1.0]]
    })
  }
}