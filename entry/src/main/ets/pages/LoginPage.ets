import { router } from '@kit.ArkUI';
import MoodDB from '../utils/MoodDB';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';

  aboutToAppear() {
    // 页面加载时初始化数据库
    let context = getContext(this) as common.UIAbilityContext;
    MoodDB.init(context).then(() => {
      console.log('Login: DB initialized');
    });
  }

  build() {
    Column() {
      // Logo 或标题
      Image($r('app.media.app_icon')) // 如果你刚才换了图标，这里会显示你的图标
        .width(80)
        .height(80)
        .margin({ top: 100, bottom: 20 })
        .borderRadius(20)

      Text('心情日记')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .margin({ bottom: 50 })

      // 输入框
      Column({ space: 15 }) {
        TextInput({ placeholder: '用户名' })
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
          .onChange((value) => this.username = value)

        TextInput({ placeholder: '密码' })
          .type(InputType.Password)
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
          .onChange((value) => this.password = value)
      }
      .width('85%')

      // 登录按钮
      Button('登录', { type: ButtonType.Capsule })
        .width('85%')
        .height(50)
        .backgroundColor('#7B61FF')
        .margin({ top: 40 })
        .onClick(() => {
          this.handleLogin();
        })

      // 注册入口
      Row() {
        Text('还没有账号？')
        Text('去注册')
          .fontColor('#7B61FF')
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            router.pushUrl({ url: 'pages/RegisterPage' });
          })
      }
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  handleLogin() {
    if (this.username === '' || this.password === '') {
      AlertDialog.show({ message: '请输入用户名和密码' });
      return;
    }

    MoodDB.loginUser(this.username, this.password).then((success) => {
      if (success) {
        // 登录成功，跳转到主页 (Index)
        // 使用 replaceUrl 防止用户按返回键回到登录页
        router.replaceUrl({ url: 'pages/Index' });
      } else {
        AlertDialog.show({ message: '用户名或密码错误' });
      }
    }).catch(() => {
      AlertDialog.show({ message: '登录出错，请重试' });
    });
  }
}