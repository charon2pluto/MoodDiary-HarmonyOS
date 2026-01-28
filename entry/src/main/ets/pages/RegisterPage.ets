import { router } from '@kit.ArkUI';
import MoodDB from '../utils/MoodDB';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';

  aboutToAppear() {
    // 确保数据库已初始化 (以防直接跳到注册页)
    let context = getContext(this) as common.UIAbilityContext;
    MoodDB.init(context);
  }

  build() {
    Column() {
      // 标题
      Text('注册账号')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .margin({ top: 80, bottom: 50 })

      // 输入框区域
      Column({ space: 15 }) {
        TextInput({ placeholder: '请输入用户名' })
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
          .onChange((value) => this.username = value)

        TextInput({ placeholder: '请输入密码' })
          .type(InputType.Password)
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
          .onChange((value) => this.password = value)

        TextInput({ placeholder: '确认密码' })
          .type(InputType.Password)
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
          .onChange((value) => this.confirmPassword = value)
      }
      .width('85%')

      // 注册按钮
      Button('立即注册', { type: ButtonType.Capsule })
        .width('85%')
        .height(50)
        .backgroundColor('#7B61FF')
        .margin({ top: 40 })
        .onClick(() => {
          this.handleRegister();
        })

      // 返回登录
      Text('已有账号？去登录')
        .fontColor('#7B61FF')
        .margin({ top: 20 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  handleRegister() {
    if (this.username === '' || this.password === '') {
      AlertDialog.show({ message: '用户名或密码不能为空' });
      return;
    }
    if (this.password !== this.confirmPassword) {
      AlertDialog.show({ message: '两次密码输入不一致' });
      return;
    }

    MoodDB.registerUser(this.username, this.password).then(() => {
      AlertDialog.show({ message: '注册成功！请登录' });
      router.back(); // 返回登录页
    }).catch((err: Error) => {
      AlertDialog.show({ message: '注册失败: ' + err.message });
    });
  }
}