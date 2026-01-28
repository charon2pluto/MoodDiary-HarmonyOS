# 📱 Mood Diary (HarmonyOS Next Native)

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-Next_API_9+-0a59f7?style=flat&logo=huawei&logoColor=white)
![Language](https://img.shields.io/badge/ArkTS-Declarative-blue)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-green)
![Status](https://img.shields.io/badge/Status-Active_Development-orange)

> **🚀 项目背景**: 旨在深入探索 **HarmonyOS Next** 架构，实践 **ArkTS 声明式开发范式** 与 **一次开发，多端部署** 的最佳实践。

## 📖 项目简介 (Introduction)

**Mood Diary** 是一款基于 **纯血鸿蒙 (HarmonyOS Next)** 构建的情绪追踪应用。与传统的安卓开发不同，本项目完全抛弃 Java/XML 体系，采用华为最新的 **ArkUI** 框架进行构建，追求极致的系统级性能与交互体验。

**核心亮点 (Key Features):**
- 🎨 **声明式 UI 架构**: 使用 ArkTS + ArkUI 构建现代化界面，实现类似 SwiftUI/Flutter 的高效开发体验。
- 💾 **企业级数据存储**: 不同于简单的键值对存储，本项目封装了 **RelationalStore (SQLite)**，实现了完整的 CRUD 操作与复杂查询能力。
- 📊 **可视化统计**: 手写算法实现情绪热力图与统计图表，直观展示用户心理变化趋势。
- 🌗 **系统级适配**: 完美适配鸿蒙系统深色模式 (Dark Mode) 与弹性布局。

## 🛠️ 技术栈 (Tech Stack)

| 模块 | 技术选型 | 核心价值 (对标鸿蒙原生标准) |
| :--- | :--- | :--- |
| **UI Framework** | **ArkUI (ArkTS)** | 鸿蒙官方推荐的声明式开发范式，实现高性能渲染。 |
| **State Mgmt** | **@State / @Link** | 响应式数据流设计，确保视图与数据源的实时同步。 |
| **Persistence** | **RelationalStore (RDB)** | 基于 SQLite 的关系型数据库，处理复杂的日记结构化数据。 |
| **Toolchain** | **DevEco Studio / Hvigor** | 掌握鸿蒙生态标准的构建与调试工具链。 |

## 📂 工程结构 (Architecture)

严格遵循鸿蒙官方推荐的 Feature/Module 模块化结构：

```text
entry/src/main/ets/
├── entryability/    # 全局生命周期管理 (Ability Lifecycle)
├── pages/           # 视图层 (View) - Index, Detail, Edit
├── model/           # 数据模型 (Model) - MoodData 结构定义
├── utils/           # 逻辑层 (ViewModel/Utils) 
│   ├── MoodDB.ets   # 核心数据库封装 (Singleton Pattern)
│   └── DateUtil.ets # 工具类
└── resources/       # 静态资源 (适配 Dark/Light 模式)
