import { Context } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit'; // 添加日志模块

const PREFERENCES_NAME = 'deposit.db';
const TAG = 'PreferenceDeposit';

class PreferenceDeposit {
  private preferenceDeposit: preferences.Preferences | null = null;
  private isInitialized = false; // 初始化状态标志

  // 改为显式初始化方法
  async init(context: Context): Promise<void> {
    try {
      this.preferenceDeposit = await preferences.getPreferences(context, PREFERENCES_NAME);
      this.isInitialized = true;
      hilog.info(0x0000, TAG, 'Preferences initialized');
    } catch (err) {
      hilog.error(0x0000, TAG, `Init failed: code=${err.code}, message=${err.message}`);
    }
  }

  // 操作前增加状态校验
  private checkInitialized() {
    if (!this.isInitialized || !this.preferenceDeposit) {
      throw new Error("Preferences not initialized");
    }
  }

  async putPreference(key: string = 'deposit', value: string) {
    this.checkInitialized();
    this.preferenceDeposit!.putSync(key, value);
    this.preferenceDeposit!.flushSync();
  }

  async getPreference(key: string = 'deposit', defaultVal:String = '') {
    this.checkInitialized();
    return this.preferenceDeposit!.getSync(key, defaultVal);
  }

  // 增强资源释放
  async destroy(context: Context) {
    if (this.preferenceDeposit) {
      try {
        await preferences.deletePreferences(context, PREFERENCES_NAME);
        hilog.info(0x0000, TAG, 'Preferences deleted');
      } catch (err) {
        const error = err as BusinessError;
        hilog.error(0x0000, TAG, `Delete failed: code=${error.code}, message=${error.message}`);
      } finally {
        this.preferenceDeposit = null;
        this.isInitialized = false;
      }
    }
  }
}

// 创建单例实例
const preferenceDeposit = new PreferenceDeposit();

export default preferenceDeposit
