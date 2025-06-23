// Index.ets
import { BusinessError } from '@kit.BasicServicesKit';
import preferenceDeposit from '../common/preferenceUtils/preferenceDeposit'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Router } from '@kit.ArkUI';

const INDEX = 0x0001;

@Entry
@Component
struct Index {
  @State message: string = '欢迎使用';
  @State deposit: string = '-';
  router: Router | null = null;

  async onPageShow() {
    // 获取 UIContext 和 router
    let uiContext: UIContext = this.getUIContext();
    this.router = uiContext.getRouter();
    this.deposit = (await preferenceDeposit.getPreference('deposit')).toString();
    hilog.info(INDEX, 'indexTag', 'deposit: %{public}s', this.deposit);
    if (! this.deposit) {
      this.router?.pushUrl({ url: 'pages/DepositInputPage' })
    }
  }

  build() {
    Row() {
      Column() {
        Text(`初始存款：${this.deposit}`)
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
        // 添加按钮，以响应用户点击
        Button() {
          Text('输入初始')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({
          top: 20
        })
        .backgroundColor('#0D9FFB')
        .width('50%')
        .height('6%')
        // 跳转按钮绑定onClick事件，点击时跳转到第二页
        .onClick(() => {
          // 跳转到第二页
          this.router?.pushUrl({ url: 'pages/DepositInputPage' }).then(() => {
            console.info('Succeeded in jumping to the second page.')
          }).catch((err: BusinessError) => {
            console.error(`Failed to jump to the second page. Code is ${err.code}, message is ${err.message}`)
          })
        })
      }
      .width('100%')
    }
    .height('100%')
  }
}