import { router } from '@kit.ArkUI';
import MoodDB from '../utils/MoodDB';
import MoodData from '../model/MoodData';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct DiaryEdit {
  @State diaryContent: string = '';
  @State selectedImages: string[] = []; // 暂未实现真实相册，预留

  // ★ 新增状态：今天的多条心情
  @State todayMoods: MoodData[] = [];
  @State currentMood: MoodData | null = null; // 当前选中的那一条
  @State selectedIndex: number = 0; // 下拉框选中的索引

  // 映射 Emoji 用于显示
  private moodIcons: string[] = ['😄', '😐', '😰', '😢', '😡', '😴', '🤩', '🤯'];

  aboutToAppear() {
    this.loadTodayMoods();
  }

  loadTodayMoods() {
    // 改用 queryTodayAll 获取所有记录
    MoodDB.queryTodayAll().then((list) => {
      this.todayMoods = list;

      if (list.length > 0) {
        // 默认选中第一条（最新的）
        this.selectMood(0);
      }
    });
  }

  // 切换心情记录时的逻辑
  selectMood(index: number) {
    this.selectedIndex = index;
    this.currentMood = this.todayMoods[index];
    // ★ 关键：切换时，要把这条心情里已有的日记内容填进去
    this.diaryContent = this.currentMood.diaryContent || '';
  }

  // 格式化时间显示 (例如 10:30)
  formatTime(timestamp: number): string {
    let date = new Date(timestamp);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  build() {
    Column() {
      // 1. 顶部导航
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#666')
          .onClick(() => router.back())

        Text('写日记')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Text('保存')
          .fontSize(16)
          .fontColor('#7B61FF')
          .onClick(() => this.saveDiary())
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)
      .backgroundColor('#FFF')

      // 2. ★ 核心改进：心情选择区
      if (this.todayMoods.length > 0) {
        Row() {
          Text('关联记录：').fontSize(14).fontColor('#666')

          // 下拉选择框
          Select(this.todayMoods.map((item) => {
            // 构建选项文本： 10:30 😄 (8分)
            let text = `${this.formatTime(item.date)} ${this.moodIcons[item.moodType] || '❓'} (${item.moodScore}分)`;
            return { value: text } as SelectOption;
          }))
            .selected(this.selectedIndex)
            .value(
              this.currentMood
                ? `${this.formatTime(this.currentMood.date)} ${this.moodIcons[this.currentMood.moodType]} (${this.currentMood.moodScore}分)`
                : '请选择'
            )
            .font({ size: 14 })
            .fontColor('#333')
            .selectedOptionFont({ size: 14 })
            .optionFont({ size: 14 })
            .onSelect((index: number) => {
              this.selectMood(index);
            })
            .layoutWeight(1)
            .margin({ left: 10 })
        }
        .width('90%')
        .padding(10)
        .backgroundColor('#F0F0F0')
        .borderRadius(8)
        .margin({ top: 10, bottom: 10 })
      } else {
        // 如果今天还没打卡
        Column() {
          Text('⚠️ 今天还没有心情打卡').fontColor('#FF9800').fontSize(14)
          Text('请先去首页记录心情，再来写日记关联哦~').fontColor('#999').fontSize(12).margin({ top: 5 })
        }
        .width('90%')
        .padding(15)
        .backgroundColor('#FFF3E0')
        .borderRadius(8)
        .margin({ top: 10, bottom: 10 })
      }

      // 3. 编辑区域
      Column() {
        TextArea({ text: this.diaryContent, placeholder: '今天发生了什么值得记录的事？...' })
          .height(300)
          .width('100%')
          .fontSize(16)
          .backgroundColor('transparent')
          .padding(15)
          .margin({ top: 10 })
          .onChange((value) => {
            this.diaryContent = value;
          })
          // 如果没选心情，禁用输入，防止数据没地儿存
          .enabled(this.todayMoods.length > 0)
      }
      .width('90%')
      .layoutWeight(1)

    }
    .height('100%')
    .width('100%')
    .backgroundColor('#FFF')
  }

  saveDiary() {
    if (!this.currentMood) {
      AlertDialog.show({ message: '请先选择一条心情记录来关联日记！' });
      return;
    }

    // 更新当前选中的那个 Mood 对象
    this.currentMood.diaryContent = this.diaryContent;
    // 图片字段预留，暂不更新

    // 调用数据库更新
    MoodDB.update(this.currentMood).then(() => {
      AlertDialog.show({ message: '✅ 日记保存成功' });
      // 延迟一点返回，体验更好
      setTimeout(() => {
        router.back();
      }, 500);
    }).catch((err: BusinessError) => {
      AlertDialog.show({ message: '保存失败: ' + err.message });
    });
  }
}