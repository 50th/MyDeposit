// dbManager.ts
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { User } from '../../viewmodel/UserInfo';
import { CommonConstants } from '../constants/CommonConstants';

const DOMAIN = 0x0003;

// 定义表结构SQL
const DEPOSIT_DETAILS_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS deposit_details (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount INTEGER NOT NULL,
    time INTEGER NOT NULL,
    remarks text
  )`;


let store: relationalStore.RdbStore | undefined = undefined;
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'MyDeposit.db',
  securityLevel: relationalStore.SecurityLevel.S1
};
const COLUMN_TYPE_MAP = [
  ['username', 'varchar(30)'],
  ['account', 'varchar(30)'],
  ['nickname', 'varchar(30)'],
  ['age', 'varchar(30)']
];

export class DBUtils {
  /**
   * Creating a User Table.
   */
  createDB() {
    relationalStore.getRdbStore(uiContext?.getHostContext(), STORE_CONFIG,
      (err: BusinessError, rdbStore: relationalStore.RdbStore) => {
        if (err) {
          hilog.error(DOMAIN, 'db', `Failed to get database: %{public}s`, err.message);
          return;
        }
        store = rdbStore;
        (store as relationalStore.RdbStore).executeSql(DEPOSIT_DETAILS_TABLE_SQL, (err) => {
          if (err) {
            hilog.error(DOMAIN, 'db', 'Failed to init database: %{public}s', err.message);
            return;
          }
          hilog.info(DOMAIN, 'db', 'Database initialized and table created.');
          this.insertData();
        })
      })
  }

  /**
   * Initializing User Table Data.
   */
  insertData() {
    if (store !== undefined) {
      (store as relationalStore.RdbStore).executeSql(CommonConstants.SQL_INIT_USER_TABLE).then(() => {
        hilog.info(DOMAIN, 'db', 'insert data table done.');
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, 'db', `ExecuteSql failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }

  /**
   * Querying User Table Information.
   */
  async queryData(flags: number[]): Promise<User> {
    let res: User = new User();
    if (store !== undefined) {
      (store as relationalStore.RdbStore).querySql(CommonConstants.SQL_QUERY_USER_TABLE, (err, resultSet) => {
        if (err) {
          hilog.error(DOMAIN, 'db', `Query failed, code is ${err.code},message is ${err.message}`);
          return;
        }
        hilog.info(DOMAIN, 'db',
          `ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
        while (resultSet.goToNextRow()) {
          let id = resultSet.getString(resultSet.getColumnIndex("id"));
          res.setId(id);
          let name = '';
          let account = ''
          let nickname = '';
          let age = '';
          try {
            if (flags[0] > 0) {
              name = resultSet.getString(resultSet.getColumnIndex(COLUMN_TYPE_MAP[0][0]));
              res.setName(name);
            }
            if (flags[1] > 0) {
              account = resultSet.getString(resultSet.getColumnIndex(COLUMN_TYPE_MAP[1][0]));
              res.setAccount(account);
            }
            if (flags[2] > 0) {
              nickname = resultSet.getString(resultSet.getColumnIndex(COLUMN_TYPE_MAP[2][0]));
              res.setNickName(nickname);
            }
            if (flags[3] > 0) {
              age = resultSet.getString(resultSet.getColumnIndex(COLUMN_TYPE_MAP[3][0]));
              res.setAge(age);
            }
          } catch (error) {
            hilog.error(DOMAIN, 'db', `ExecuteSql failed, code is ${error.code},message is ${error.message}`);
            resultSet.close();
            return res;
          }
          resultSet.close();
          return res;
        }
        resultSet.close();
        return res;
      })
    }
    return res;
  }

  /**
   * Modifying the User Table Information.
   */
  updateData(index: number, content: string) {
    if (store !== undefined) {
      (store as relationalStore.RdbStore).executeSql("update user_info set " +
      COLUMN_TYPE_MAP[index][0] + " = '" + content + "' where id = 1")
        .then(() => {
          hilog.info(DOMAIN, 'db', 'update data done.');
        })
        .catch((err: BusinessError) => {
          hilog.error(DOMAIN, 'db', `ExecuteSql failed, code is ${err.code},message is ${err.message}`);
        })
    }
  }

  /**
   * Used for database transactional rollback.
   */
  rollback() {
    if (store !== undefined) {
      store.rollBack();
    }
  }

  /**
   * Used to commit database transactions.
   */
  commit() {
    if (store !== undefined) {
      store.commit();
    }
  }

  /**
   * Modifying the User Table Structure.
   */
  async updateTable(index: number, content: string) {
    let updateTableSql = "alter table user_info add column " +
    COLUMN_TYPE_MAP[index][0] + " " + COLUMN_TYPE_MAP[index][1];
    if (store !== undefined) {
      store.beginTransaction();
      (store as relationalStore.RdbStore).executeSql(updateTableSql, (err) => {
        if (err) {
          hilog.error(DOMAIN, 'db', `ExecuteSql failed, code is ${err.code},message is ${err.message}`);
          return;
        }
        hilog.info(DOMAIN, 'db', 'update table done.');
        this.updateData(index, content);
      })
    }
  }

  /**
   * Modifying the User Table Information.
   */
  async backup(callback: () => void) {
    if (store !== undefined) {
      (store as relationalStore.RdbStore).backup('dbBackup.db', (err) => {
        if (err) {
          hilog.error(DOMAIN, 'db', `Failed to backup data. Code:${err.code},message:${err.message}`);
          return;
        }
        hilog.info(DOMAIN, 'db', 'Succeeded in backuping data.');
        callback();
      })
    }
  }

  /**
   * Modifying the User Table Information.
   */
  async restore(callback: () => void) {
    if (store !== undefined) {
      (store as relationalStore.RdbStore).restore('dbBackup.db', (err) => {
        if (err) {
          hilog.error(DOMAIN, 'db', `Failed to restore data. Code:${err.code},message:${err.message}`);
          return;
        }
        hilog.info(DOMAIN, 'db', 'Succeeded in restoring data.');
        callback();
      })
    }
  }
}

let dbUtils = new DBUtils();

export default dbUtils as DBUtils;
