import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import MoodData from '../model/MoodData';

export default class MoodDB {
  private static rdbStore: relationalStore.RdbStore | undefined = undefined;
  // ★ 新增：用来存当前登录用户的 ID
  public static currentUserId: number = -1;

  // 1. 修改建表语句：给 MOOD_TABLE 加上 userId 字段
  private static readonly SQL_CREATE_MOOD =
    'CREATE TABLE IF NOT EXISTS MOOD_TABLE (id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, date INTEGER, moodType INTEGER, moodScore INTEGER, reason TEXT, diaryContent TEXT, images TEXT)';

  private static readonly SQL_CREATE_USER =
    'CREATE TABLE IF NOT EXISTS USER_TABLE (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)';

  static init(context: common.UIAbilityContext): Promise<void> {
    if (MoodDB.rdbStore) return Promise.resolve();

    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'MoodDiary.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };

    return new Promise((resolve, reject) => {
      relationalStore.getRdbStore(context, STORE_CONFIG, (err, store) => {
        if (err) { reject(err); return; }
        if (store) {
          store.executeSql(MoodDB.SQL_CREATE_MOOD);
          store.executeSql(MoodDB.SQL_CREATE_USER);
          MoodDB.rdbStore = store;
          resolve();
        }
      });
    });
  }

  // --- 用户功能 ---

  static async registerUser(username: string, password: string): Promise<number> {
    if (!MoodDB.rdbStore) return Promise.reject('DB Error');
    // 查重
    let predicates = new relationalStore.RdbPredicates('USER_TABLE');
    predicates.equalTo('username', username);
    let resultSet = await MoodDB.rdbStore.query(predicates);
    if (resultSet.rowCount > 0) {
      resultSet.close();
      return Promise.reject(new Error('用户已存在'));
    }
    resultSet.close();

    const valueBucket: relationalStore.ValuesBucket = { 'username': username, 'password': password };
    return MoodDB.rdbStore.insert('USER_TABLE', valueBucket);
  }

  // 登录：成功后记录 UserID
  static async loginUser(username: string, password: string): Promise<boolean> {
    if (!MoodDB.rdbStore) return Promise.reject('DB Error');

    let predicates = new relationalStore.RdbPredicates('USER_TABLE');
    predicates.equalTo('username', username);
    predicates.equalTo('password', password);

    let resultSet = await MoodDB.rdbStore.query(predicates);
    if (resultSet.goToFirstRow()) {
      // ★ 登录成功，把 ID 记下来！
      MoodDB.currentUserId = resultSet.getLong(resultSet.getColumnIndex('id'));
      resultSet.close();
      return true;
    }
    resultSet.close();
    return false;
  }

  // --- 日记功能 (都加上 userId 限制) ---

  static async insert(mood: MoodData): Promise<number> {
    if (!MoodDB.rdbStore) return Promise.reject(new Error('DB not init'));

    // 强制使用当前登录用户的 ID
    const valueBucket: relationalStore.ValuesBucket = {
      'userId': MoodDB.currentUserId, // ★ 存入 ID
      'date': mood.date,
      'moodType': mood.moodType,
      'moodScore': mood.moodScore,
      'reason': mood.reason,
      'diaryContent': mood.diaryContent,
      'images': mood.images
    };
    return MoodDB.rdbStore.insert('MOOD_TABLE', valueBucket);
  }

  static async update(mood: MoodData): Promise<number> {
    if (!MoodDB.rdbStore) return Promise.reject(new Error('DB not init'));
    const valueBucket: relationalStore.ValuesBucket = {
      'moodType': mood.moodType,
      'moodScore': mood.moodScore,
      'reason': mood.reason,
      'diaryContent': mood.diaryContent,
      'images': mood.images
    };
    let predicates = new relationalStore.RdbPredicates('MOOD_TABLE');
    predicates.equalTo('id', mood.id);
    return MoodDB.rdbStore.update(valueBucket, predicates);
  }

  static queryToday(): Promise<MoodData | null> {
    if (!MoodDB.rdbStore) return Promise.resolve(null);
    let predicates = new relationalStore.RdbPredicates('MOOD_TABLE');
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0).getTime();
    const endOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59).getTime();

    predicates.between('date', startOfDay, endOfDay);
    predicates.equalTo('userId', MoodDB.currentUserId); // ★ 只查自己的
    predicates.orderByDesc('date');

    return new Promise((resolve) => {
      MoodDB.rdbStore!.query(predicates).then((resultSet) => {
        if (resultSet.goToFirstRow()) {
          resolve(MoodDB.parseResultSet(resultSet));
        } else {
          resultSet.close();
          resolve(null);
        }
      }).catch(() => resolve(null));
    });
  }

  // ★ 新增：查询今天所有的心情记录 (为了让用户自己选)
  static queryTodayAll(): Promise<Array<MoodData>> {
    if (!MoodDB.rdbStore) return Promise.resolve([]);

    let predicates = new relationalStore.RdbPredicates('MOOD_TABLE');
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0).getTime();
    const endOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59).getTime();

    predicates.between('date', startOfDay, endOfDay);
    predicates.equalTo('userId', MoodDB.currentUserId);
    predicates.orderByDesc('date'); // 按时间倒序，最新的排前面

    return new Promise((resolve) => {
      MoodDB.rdbStore!.query(predicates).then((resultSet) => {
        let list = new Array<MoodData>();
        while (resultSet.goToNextRow()) {
          list.push(MoodDB.parseResultSet(resultSet));
        }
        resultSet.close();
        resolve(list);
      }).catch(() => resolve([]));
    });
  }

  static queryAll(): Promise<Array<MoodData>> {
    let predicates = new relationalStore.RdbPredicates('MOOD_TABLE');
    predicates.equalTo('userId', MoodDB.currentUserId); // ★ 只查自己的
    predicates.orderByDesc('date');

    return new Promise((resolve) => {
      if (!MoodDB.rdbStore) { resolve([]); return; }
      MoodDB.rdbStore.query(predicates).then((resultSet) => {
        let moodList = new Array<MoodData>();
        while (resultSet.goToNextRow()) {
          moodList.push(MoodDB.parseResultSet(resultSet));
        }
        resultSet.close();
        resolve(moodList);
      }).catch(() => resolve([]));
    });
  }

  // ★ 新增功能：清空当前用户的所有日记数据
  static async clearUserData(): Promise<void> {
    if (!MoodDB.rdbStore) return Promise.reject(new Error('DB not init'));

    let predicates = new relationalStore.RdbPredicates('MOOD_TABLE');
    predicates.equalTo('userId', MoodDB.currentUserId); // 只删自己的，别删别人的

    // 删除符合条件的行
    await MoodDB.rdbStore.delete(predicates);
  }

  // 辅助方法：解析数据 (这个必须在 class 内部)
  private static parseResultSet(resultSet: relationalStore.ResultSet): MoodData {
    // 注意：这里需要根据新的表结构取值
    return new MoodData(
      resultSet.getLong(resultSet.getColumnIndex('id')),
      resultSet.getLong(resultSet.getColumnIndex('userId')), // 取出 userId
      resultSet.getLong(resultSet.getColumnIndex('date')),
      resultSet.getLong(resultSet.getColumnIndex('moodType')),
      resultSet.getLong(resultSet.getColumnIndex('moodScore')),
      resultSet.getString(resultSet.getColumnIndex('reason')),
      resultSet.getString(resultSet.getColumnIndex('diaryContent')),
      resultSet.getString(resultSet.getColumnIndex('images'))
    );
  }
}