// dbManager.ts
import { relationalStore } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

// 定义表结构SQL
const STUDENT_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS student (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    age INTEGER
  )`;

const COURSE_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS course (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_name TEXT NOT NULL
  )`;

class DBManager {
  private rdbStore: relationalStore.RdbStore | null = null;
  private isReady = false;

  // 初始化数据库和表结构
  init(context: Context, callback: (success: boolean) => void) {
    const config: relationalStore.StoreConfig = {
      name: 'MyDeposit.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    relationalStore.getRdbStore(context, config, (err, store) => {
      if (err) {
        console.error(err.message);
        console.error(`数据库初始化失败: ${err.code}, ${err.message}`);
        callback(false);
        return;
      }
      this.rdbStore = store;
      this.createTables(callback);
    });
  }

  // 创建数据表
  private createTables(callback: (success: boolean) => void) {
    if (!this.rdbStore) {
      return;
    }

    const sqlStatements = [STUDENT_TABLE_SQL, COURSE_TABLE_SQL];
    let completedCount = 0;
    let hasError = false;

    sqlStatements.forEach(sql => {
      this.rdbStore!.executeSql(sql, [], (err) => {
        if (err) {
          console.error(`建表失败: ${err.code}, ${err.message}`);
          hasError = true;
        }
        completedCount++;

        // 所有SQL执行完成后回调
        if (completedCount === sqlStatements.length) {
          this.isReady = !hasError;
          callback(!hasError);
        }
      });
    });
  }

  // 检查数据库就绪状态
  checkReady(callback: (ready: boolean) => void): void {
    if (this.isReady) {
      callback(true);
    } else {
      setTimeout(() => this.checkReady(callback), 100);
    }
  }
}

// 创建单例实例
const dbManager = new DBManager();

export default dbManager;
