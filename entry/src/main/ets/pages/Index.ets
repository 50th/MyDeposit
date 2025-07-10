// Index.ets
import { BusinessError } from '@kit.BasicServicesKit';
import preferenceDeposit from '../common/utils/PreferenceUtils'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Router } from '@kit.ArkUI';

const DOMAIN = 0x0001;

@Entry
@Component
struct Index {
  @State message: string = '欢迎使用';
  @State deposit: string = '-';
  router: Router | null = null;
  lastedDetailsList = [1, 2, 3, 4, 5];

  async onPageShow() {
    hilog.info(DOMAIN, 'indexTag', 'onPageShow');
    // 获取 UIContext 和 router
    let uiContext: UIContext = this.getUIContext();
    this.router = uiContext.getRouter();
    this.deposit = (await preferenceDeposit.getPreference('deposit')).toString();
    hilog.info(DOMAIN, 'indexTag', 'deposit: %{public}s', this.deposit);
    if (!this.deposit) {
      hilog.info(DOMAIN, 'indexTag', 'push DepositInputPage');
      this.router?.pushUrl({ url: 'pages/DepositInputPage' })
    }
  }

  build() {
    Column() {
      Row() {
        Text(`初始存款：${this.deposit}`)
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
      }

      // 跳转按钮绑定onClick事件，点击时跳转到初始化页面
      if (!this.deposit) {
        Button($r('app.string.enter_init_button'))
          .width('80%')
          .height(50)
          .fontSize(18)
          .type(ButtonType.Capsule)
          .backgroundColor('#0D9FFB')
          .margin({
            top: 25
          })
          .onClick(() => {
            // 跳转到第二页
            this.router?.pushUrl({ url: 'pages/DepositInputPage' }).then(() => {
              console.info('Succeeded in jumping to the second page.')
            }).catch((err: BusinessError) => {
              console.error(`Failed to jump to the second page. Code is ${err.code}, message is ${err.message}`)
            })
          })
      }

      // 明细
      Column() {
        // 原始数据展示
        Text($r('app.string.income_and_expenses_details_latest'))
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin({ bottom: 8 })

        List() {
          ForEach(this.lastedDetailsList, (item: number) => {
            ListItem () {
              Text(String(item))
                .fontSize(18)
                .fontColor(Color.Blue)
                .margin({ bottom: 20 })
            }
          })
        }
        .backgroundColor('#F5F5F5')
      }
      .width('100%')
      .padding(16)
      .borderRadius(12)
      .margin({
        top: 25
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }
}