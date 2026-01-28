import { router, promptAction } from '@kit.ArkUI';
import MoodDB from '../utils/MoodDB';

// 初始化持久化存储，默认隐私开关是关闭的 (false)
PersistentStorage.persistProp('isPrivacyEnabled', false);

@Entry
@Component
struct SettingsPage {
  // 与本地存储双向绑定，App 重启后还在
  @StorageLink('isPrivacyEnabled') isPrivacyEnabled: boolean = false;

  build() {
    Column() {
      // 1. 顶部导航栏
      Row() {
        Column() {
          Text('👈').fontSize(24)
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => router.back())

        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(40)
      }
      .width('100%')
      .padding({ top: 15, bottom: 15, left: 10, right: 10 })
      .backgroundColor('#FFFFFF')

      // 2. 设置列表
      Column({ space: 15 }) {

        // --- 功能 A: 隐私加密开关 ---
        Row() {
          Column() {
            Text('隐私保护模式')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
            Text('开启后，启动App需要验证身份')
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 5 })
          }
          .alignItems(HorizontalAlign.Start)

          Toggle({ type: ToggleType.Switch, isOn: this.isPrivacyEnabled })
            .selectedColor('#7B61FF')
            .onChange((isOn: boolean) => {
              this.isPrivacyEnabled = isOn;
              // 这里可以加一个提示
              if (isOn) {
                promptAction.showToast({ message: '已开启隐私保护' });
              }
            })
        }
        .width('100%')
        .padding(15)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .justifyContent(FlexAlign.SpaceBetween)

        // --- 功能 B: 清空数据 ---
        Row() {
          Text('清空所有日记数据')
            .fontSize(16)
            .fontColor('#FF4444') // 红色警示色

          Text('🗑️').fontSize(20)
        }
        .width('100%')
        .padding(15)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.handleClearData();
        })

        // --- 功能 C: 退出登录 ---
        Button('退出登录', { type: ButtonType.Normal })
          .width('100%')
          .height(50)
          .backgroundColor('#F5F5F5')
          .fontColor('#666')
          .borderRadius(16)
          .margin({ top: 30 })
          .onClick(() => {
            // 1. 清除当前用户状态
            MoodDB.currentUserId = -1;
            // 2. 跳转回登录页 (不可返回)
            router.replaceUrl({ url: 'pages/LoginPage' });
          })

      }
      .width('90%')
      .margin({ top: 20 })

      // 底部版本号
      Blank()
      Text('Version 1.0.0')
        .fontSize(12)
        .fontColor('#CCC')
        .margin({ bottom: 20 })
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F5F7F9') // 浅灰背景
  }

  // 处理清空数据的逻辑
  handleClearData() {
    AlertDialog.show({
      title: '⚠️ 危险操作',
      message: '确定要删除所有的心情日记吗？删除后无法恢复！',
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确认删除',
        fontColor: '#FF0000',
        action: () => {
          MoodDB.clearUserData().then(() => {
            promptAction.showToast({ message: '所有数据已清空' });
          });
        }
      }
    });
  }
}