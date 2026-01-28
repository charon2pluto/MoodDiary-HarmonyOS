// 文件位置: entry/src/main/ets/model/MoodData.ets
export default class MoodData {
  id: number | null = null;
  userId: number;       // ★ 新增：用户ID
  date: number;         // 记录日期的时间戳
  moodType: number;     // 心情类型
  moodScore: number;    // 心情强度
  reason: string;       // 简短原因
  diaryContent: string; // 日记正文
  images: string;       // 图片路径

  // ★ 修改：构造函数增加 userId 参数，一共 8 个参数
  constructor(id: number, userId: number, date: number, moodType: number, moodScore: number, reason: string, diaryContent: string, images: string) {
    this.id = id;
    this.userId = userId; // ★ 赋值
    this.date = date;
    this.moodType = moodType;
    this.moodScore = moodScore;
    this.reason = reason;
    this.diaryContent = diaryContent;
    this.images = images;
  }
}