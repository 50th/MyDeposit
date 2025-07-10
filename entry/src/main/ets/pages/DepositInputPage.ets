import { BusinessError } from '@kit.BasicServicesKit';
import preferenceDeposit from '../common/utils/PreferenceUtils'
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0002;

@Entry
@Component
struct AmountInputPage {
  @State formattedAmount: string = "";  // 格式化后显示值
  @State private rawAmount: string = "";  // 原始输入值
  controller: TextInputController = new TextInputController();

  // 页面标题
  private title: Resource = $r('app.string.amount_input_title');

  async onPageShow() {
    this.rawAmount = (await preferenceDeposit.getPreference('deposit')).toString();
    hilog.info(DOMAIN, 'depositTag', 'rawAmount: %{public}s', this.rawAmount);
    if (this.rawAmount) {
      this.handleAmountChange(this.rawAmount);
    }
  }

  async putPreference(data: string) {
    if (preferenceDeposit !== null) {
      await preferenceDeposit.putPreference('deposit', data);
      let uiContext: UIContext = this.getUIContext();
      let router = uiContext.getRouter();
      try {
        // 返回首页
        router.back()
        console.info('Succeeded in returning to the index page.')
      } catch (err) {
        let code = (err as BusinessError).code;
        let message = (err as BusinessError).message;
        console.error(`Failed to return to the index page. Code is ${code}, message is ${message}`)
      }
    }
  }

  build() {
    Column() {
      // 标题栏
      Text(this.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 30 })

      // 输入区域
      Column() {
        // 输入框标签
        Text($r('app.string.amount_label'))
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin({ bottom: 8 })
          .alignSelf(ItemAlign.Start)

        // 金额输入框
        TextInput({ controller: this.controller, text: $$this.formattedAmount })
          .type(InputType.Number)         // 数字键盘
          .onChange((newVal: string) => {
            this.handleAmountChange(newVal);
          })
          .inputFilter('[0-9.,]')          // 仅允许数字和小数点
          .height(50)
          .width('90%')
          .borderRadius(8)
          .padding(10)
          .backgroundColor(Color.White)
          .fontColor(Color.Black)
          .fontSize(18)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F5F5F5')
      .borderRadius(12)
      .margin({ bottom: 30 })

      // 格式化结果展示
      Column() {
        // 原始数据展示
        Text($r('app.string.raw_value_label'))
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin({ bottom: 8 })

        Text(this.rawAmount || '0')
          .fontSize(18)
          .fontColor(Color.Blue)
          .margin({ bottom: 20 })

        // 格式化后数据展示
        Text($r('app.string.formatted_value_label'))
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin({ bottom: 8 })

        Text(this.formattedAmount || '0')
          .fontSize(18)
          .fontColor(Color.Green)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F5F5F5')
      .borderRadius(12)

      // 底部操作按钮
      Button($r('app.string.confirm_button'))
        .width('80%')
        .height(50)
        .margin(30)
        .fontSize(18)
        .onClick(() => {
          if (this.rawAmount) {
            this.putPreference(this.rawAmount);
          } else {
            console.error('请输入存款');
          }
        })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#F0F8FF')
  }

  // 金额变化处理
  private handleAmountChange(newVal: string) {
    let cleaned = newVal.replace(/[^\d.]/g, '');
    // 1. 保存原始值（不含逗号）
    this.rawAmount = cleaned;

    // 2. 执行格式化
    this.formattedAmount = this.formatAmount(this.rawAmount);

    // 3. 调整光标位置
    this.adjustCaretPosition();
  }

  // 金额格式化逻辑
  private formatAmount(value: string): string {
    if (!value) return "";

    // 移除非数字和小数点
    let cleaned = value.replace(/[^\d.]/g, '');
    let integer = '';
    let decimal = '';
    // 处理首位小数点
    if (cleaned.startsWith('.')) cleaned = '0' + cleaned;
    if (cleaned.indexOf('.') < 0) {
      integer = cleaned
    } else {
      // 处理多个小数
      const decimalParts = cleaned.split('.');

      if (decimalParts.length > 2) {
        cleaned = decimalParts[0] + '.' + decimalParts.slice(1).join('');
      }

      // 分割整数和小数部分
      let cleanedList = cleaned.split('.');
      integer = cleanedList[0];
      decimal = cleanedList[1];
      decimal = decimal ? '.' + decimal.substring(0, 2) : '.';
    }

    // 添加千分位分隔符
    integer = integer.replace(/\B(?=(\d{3})+(?!\d))/g, ',');

    return integer + decimal;
  }

  // 光标位置调整
  private adjustCaretPosition() {
    // 计算逗号数量差（新旧值对比）
    const commaDiff = (this.formattedAmount.match(/,/g) || []).length - (this.rawAmount.match(/,/g) || []).length;

    // 根据逗号增减调整光标位置
    const newPosition = Math.max(0, this.controller.getCaretOffset().index + commaDiff);
    this.controller.caretPosition(newPosition);
  }
}
