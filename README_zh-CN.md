# Skills Master 🧰

> **AI  Skills 管理器**
>
> 跨项目和 IDE 管理、分发和标准化 AI 技能。Skills-Master希望你可以通过自然语言调用skills，让GPT完成你大部分需求。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/skills-master)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**Skills Master** 是一个“元技能”（Meta-Skill），旨在充当 AI 技能生态系统的包管理器。它允许开发者轻松安装、更新和管理一系列“标准技能库”（如 `auto-committer`、`code-explainer`、`skill-creator`），并跨不同的项目和开发环境（Trae、VS Code、Cursor 等）使用。

[English](README.md) | [中文版](README_zh-CN.md)

---

## 🚀 特性

*   **📦 集中式技能仓库**：精选的标准技能集合，即装即用。
*   **🛠️ 通用兼容性**：旨在跨不同 IDE 工作，移除了环境特定的依赖。
*   **🔄 易于安装**：简单的脚本即可为你的环境引导必要的 AI 能力。
*   **🧩 可扩展架构**：轻松将你自己的自定义技能添加到主库中。
*   **🤖 自动化就绪**：包含用于自动化 Git 工作流、代码分析和文档生成的技能。

---

## 📦 包含的技能

| 技能名称 | 描述 |
| :--- | :--- |
| **auto-committer** | 自动化 Git 提交，包含变更日志更新和语义化消息。 |
| **code-explainer** | 为复杂逻辑生成结构化的代码分析报告。 |
| **project-analyzer** | 为新项目或遗留项目引导“上下文优先”的文档。 |
| **skill-creator** | 一个工具，用于轻松创建具有标准目录结构的新技能。 |
| **add-in-skills-master** | Adds or updates skill templates in the skills-master library. Invoke when user wants to contribute a new skill to the master library. |
| **context-aware-coding** | 管理 `AI_README.md` 并强制执行架构上下文。 |
| **spec-kit-workflow** | 将 [Spec-Kit](https://github.com/Start-With-Spec/Spec-Kit) 方法论（明确需求 -> 计划 -> 任务 -> 实现）集成到你的工作流中的技能。它包含用于规范驱动开发的模板和指南。 |
| **git-diff-requirement** | Analyzes git diff HEAD to evaluate code changes against business requirements, detects defects, and generates structured analysis reports. Invoke when reviewing code changes or validating requirement implementation. |
| **subagent-creator** | 专门用于生成子智能体的 skill，通过交互式问答收集信息并生成标准化的子智能体配置文档 |
| **code-review** | Code review skill. Triggered when user says 'I have completed this requirement, please review my code'. Analyzes git diff HEAD changes, checks business correctness against requirement documents, identifies logic defects or implementation errors, and provides detailed review feedback and suggestions. |
| **requirements-analysis** | 需求分析文档创建技能。当用户告知"需要开始一个新需求"时触发。该技能会创建 .requirementsAnalysis 文件夹、更新 .gitignore、按序号命名创建需求目录，并生成包含需求背景、需求内容、代码实施计划的需求文档。完成后与用户确认内容，确认后开始代码实施。 |

---

## 🛠️ 安装

### 先决条件

*   Python 3.6+
*   Git

### 快速开始
**克隆仓库**（或复制 `skills-master` 目录）到你IDE的 skills 目录。

    ```bash
    git clone https://github.com/lone-yu-cmd/skills-master.git .skills/skills-master
    ```

打开IDE的SKILL能力，在聊天窗口告诉GPT: "当前Skill-master有哪些技能？" 或者 "调用skill-master帮我安装auto-committer"

### 💡 现有项目的推荐工作流

如果你正在将 Skills Master 集成到现有项目中：

1.  **使用 Project Analyzer 引导**：首先，使用 `skills-master` 安装 **project-analyzer**。这将生成必要的文档以帮助 AI 理解你的项目结构。
2.  **AI 辅助开发**：我们 **强烈推荐** 安装 **auto-committer** 和 **context-aware-coding**。这些技能对于在使用 AI 助手（如 GPT）时提供上下文和自动化任务至关重要。
3.  **自定义**：根据你的具体开发需求安装其他技能。

---

## 📖 使用指南

安装后，每个技能都驻留在其自己的目录中（例如 `skills/auto-committer`），并附带其自己的 `SKILL.md` 文档。

### 示例：创建一个新技能

使用 **skill-creator**（安装后）生成一个新的技能模板

### 示例：自动化提交

使用 **auto-committer** 处理你的 git 工作流

## 🤝 贡献

我们欢迎贡献！如果你有一个有用的技能想与社区分享，请遵循以下步骤：

1.  **Fork 本仓库**。
2.  **创建你的技能**，使用 `skill-creator`。
3.  **将其添加到主库**，使用 `add-in-skills-master`
4.  **提交 Pull Request**。

### 指南
*   保持技能独立在其自己的目录中。
*   包含一个带有清晰使用说明的 `SKILL.md`。
*   避免硬编码路径（使用相对路径）。
*   确保脚本跨平台兼容。

---

## 📄 许可证

本项目基于 MIT 许可证开源 - 详情请参阅 [LICENSE](LICENSE) 文件。

---

<p align="center">Made with ❤️ for the AI Developer Community</p>
