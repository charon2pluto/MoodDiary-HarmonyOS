\# 📱 Mood Diary (HarmonyOS Next Native App)



!\[HarmonyOS](https://img.shields.io/badge/HarmonyOS-Next-0a59f7?style=flat\&logo=huawei)

!\[ArkTS](https://img.shields.io/badge/Language-ArkTS-blue)

!\[ArkUI](https://img.shields.io/badge/UI-ArkUI-green)



> \*\*项目背景\*\*: 本项目是基于 \*\*HarmonyOS Next (API 9+)\*\* 架构开发的纯血鸿蒙原生应用。旨在探索 \*\*ArkTS 声明式开发范式\*\* 与 \*\*一次开发，多端部署\*\* 的最佳实践，紧跟国产操作系统生态发展。



\## 📖 项目简介 (Introduction)



Mood Diary 是一款专注于极简体验的情绪追踪应用。不同于传统的 Android/iOS 开发，本项目完全采用鸿蒙原生的 ArkUI 框架构建，抛弃了 Web 跨端方案，以追求极致的性能与系统级交互体验。



\*\*核心特性 (Key Features):\*\*

\- 🎭 \*\*沉浸式 UI\*\*: 基于 ArkUI 的声明式组件，实现了高帧率的动画交互与深色模式适配。

\- 📅 \*\*热力图统计\*\*: 手写算法实现“GitHub 风格”的情绪热力图组件，直观展示情绪趋势。

\- 💾 \*\*本地持久化\*\*: 封装 \*\*RelationalStore (SQLite)\*\*，实现日记与图片路径的离线安全存储，支持复杂查询。

\- 📱 \*\*多端适配\*\*: 利用弹性布局 (Flex/Grid) 完美适配直板机与折叠屏形态。



\## 🛠️ 技术栈 (Tech Stack)



| 模块 | 技术选型 | 亮点 |

| :--- | :--- | :--- |

| \*\*核心框架\*\* | \*\*ArkTS + ArkUI\*\* | 鸿蒙官方推荐的声明式开发范式 (类似 SwiftUI/Compose) |

| \*\*状态管理\*\* | \*\*@State / @Link / @Provide\*\* | 响应式数据流，实现组件间的高效通信 |

| \*\*数据存储\*\* | \*\*RelationalStore (SQLite)\*\* | 封装 RdbStore 实现高性能本地数据持久化 (DAO Pattern) |

| \*\*构建工具\*\* | \*\*Hvigor\*\* | 鸿蒙系统的高性能构建系统 |



\## 📂 目录结构 (Structure)



```text

entry/src/main/ets/

├── entryability/    # 应用入口 (生命周期管理)

├── pages/           # 页面视图 (Index, MoodDetail, History...)

├── model/           # 数据模型定义

├── utils/           # 工具类 (MoodDB - 数据库封装, DateUtil)

└── resources/       # 静态资源 (多语言, 深色模式配置)

