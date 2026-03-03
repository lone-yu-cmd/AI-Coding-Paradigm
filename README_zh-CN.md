# AI-Coding-Paradigm 🚀

> **AI 辅助开发的综合框架**
>
> 通过三大核心模块：技能管理、规则生成和子智能体系统，标准化、自动化并增强你的 AI 驱动开发工作流。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/ai-coding-paradigm)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**AI-Coding-Paradigm** 是一个综合性框架，通过提供三个集成的核心模块，彻底改变 AI 辅助开发的方式。它使开发者能够管理可重用的技能、生成标准化的规则，并在不同的项目和开发环境（Trae、VS Code、Cursor 等）中部署专业化的子智能体。

## 🎯 项目概述

该框架由三个平等且互补的核心模块组成：

- **🧰 Skills-Master**：通用的 AI 能力技能管理系统
- **📋 Rule-Master**：标准化的规则生成和管理
- **🤖 Subagents-Master**：专业化的子智能体创建和部署

这些模块共同构成了一个完整的生态系统，用于构建、管理和扩展 AI 辅助开发工作流。

[English](README.md) | [中文版](README_zh-CN.md)

---

## 🏗️ 核心模块

### 🧰 Skills-Master

**通用的 AI 辅助开发技能管理器**

Skills-Master 作为 AI 技能生态系统的包管理器，允许开发者轻松地在不同项目中安装、更新和管理"标准技能"库。

**核心特性：**
- 📦 **集中式技能仓库**：精选的13+标准技能集合，即装即用
- 🛠️ **通用兼容性**：跨不同 IDE 工作（Trae、VS Code、Cursor）
- 🔄 **易于安装**：简单的脚本即可引导环境
- 🧩 **可扩展架构**：轻松将自定义技能添加到库中
- 🤖 **自动化就绪**：包含 Git 工作流、代码分析和文档生成技能

**位置**：`skills-master/`

### 📋 Rule-Master

**标准化的规则生成和管理系统**

Rule-Master 提供了一种系统化的方法来定义和管理开发规则、编码标准和 AI 交互指南。

**核心特性：**
- 📝 **规则模板**：预定义的常见开发场景模板
- 🎯 **标准化**：确保团队间的一致编码实践
- 🔧 **可定制**：根据项目特定需求调整规则
- 📚 **规则库**：11+标准规则定义（角色、技术栈、编码风格等）
- 🤝 **AI 集成**：指导 AI 助手理解项目的规则

**位置**：`rule-master/`

### 🤖 Subagents-Master

**专业化的子智能体创建和部署系统**

Subagents-Master 使你能够创建和管理专业化的 AI 子智能体，处理特定的、复杂的任务并具有领域专业知识。

**核心特性：**
- 🎭 **专业化智能体**：为特定领域创建聚焦的智能体（如 code-mysql-converter）
- 🔄 **交互式创建**：引导式的子智能体生成工作流
- 📦 **标准化结构**：一致的配置和部署格式
- 🧠 **领域专业知识**：在特定领域具有深度知识的智能体
- 🔌 **易于集成**：无缝集成到现有工作流

**位置**：`subagents-master/`

---

## 🔗 模块协作

这三个模块共同工作，创建了一个强大的 AI 开发生态系统：

```
┌─────────────────┐
│  Skills-Master  │ ← 提供可重用的能力
└────────┬────────┘
         │
         ├
         │         
┌────────▼────────┐ 
│ Subagents-Master│ ← 定义标准和指南，可以通过skill进行添加
└─────────────────┘
         
                    
┌─────────────────────┐
│  Rules-Master       │ ← 指导AI行为
└─────────────────────┘
```

- **Skills** 为常见任务提供构建块
- **Rules** 确保一致性并指导 AI 行为
- **Sub-agents** 处理复杂的、领域特定的挑战

---

## 📦 Skills-Master：包含的技能

| 技能名称 | 描述 |
| :--- | :--- |
| **auto-committer** | 自动化 Git 提交，包含变更日志更新和语义化消息。 |
| **context-code-explainer** | 生成结构化的代码分析报告，具备 AI_CONTEXT 感知能力。 |
| **context-project-analyzer** | 为新项目或遗留项目引导 AI_CONTEXT 文档初始化。 |
| **skill-creator** | 一个工具，用于轻松创建具有标准目录结构的新技能。 |
| **add-in-skills-master** | Adds or updates skill templates in the skills-master library. Invoke when user wants to contribute a new skill to the master library. |
| **context-aware-coding** | 管理 `AI_README.md` 并强制执行架构上下文。 |
| **git-diff-requirement** | Analyzes git diff HEAD to evaluate code changes against business requirements, detects defects, and generates structured analysis reports. Invoke when reviewing code changes or validating requirement implementation. |
| **subagent-creator** | 专门用于生成子智能体的 skill，通过交互式问答收集信息并生成标准化的子智能体配置文档 |
| **git-diff-requirement** | 分析 git diff HEAD 评估代码变更与业务需求的匹配度，检测缺陷并生成结构化分析报告。 |
| **playwright-pro** | 增强版 Playwright 页面分析工具：通过 CDP 连接本地已运行的 Chrome，无需新开窗口，保留登录态和扩展，一键分析页面 DOM、样式和交互元素 |
| **context-ai-sync** | 智能 AI 上下文文档系统。使用 'AI Context Sync' 初始化项目文档或同步代码变更。 |
| **context-requirements-analysis** | 上下文感知需求分析技能。自动读取 AI 文档或 AI_CONTEXT 文档完成需求分析。 |
| **update-skills-master** | Pull latest skills-master from GitHub using sparse checkout. Auto-detects target directory and works universally across different project structures. |
| **codebuddy-speckit-summary** | Extends the Speckit pipeline with a Feature Registry system. This skill should be used when working with Speckit commands (speckit.specify, speckit.plan, speckit.implement) to maintain a centralized feature index. It adds a speckit.summarize command for archiving completed features and injects REGISTRY.md awareness into existing Speckit commands via a project rule. |
| **codebuddy-speckit-code-review** | Adds a speckit.codereview command to the Speckit pipeline for automated code review after implementation. Reviews code against the feature spec, plan, and best practices. Sits between implement and summarize in the pipeline. Trigger keywords include speckit, review, code review, CR. |
| **app-planner** | 交互式应用规划工具，生成 feature-list.json 供 dev-pipeline 使用。当用户想要规划应用、设计功能列表或准备自动化开发时触发。 |

### prizm-kit：全生命周期自进化开发工具包

**prizm-kit** 是一个全面、独立的 AI 开发工具包，包含 **28 个技能**，覆盖从项目启动到交付和维护的完整开发生命周期。内置通过模式学习实现的自我改进机制，能够接管任意项目。

**核心能力：**
- **规范驱动开发**：specify → clarify → plan → tasks → implement → code-review → summarize，完整的功能交付流水线
- **Prizm 文档系统**：AI 专用的渐进式上下文加载（`.prizm-docs/`），三级架构（L0 索引 / L1 模块 / L2 详情）
- **自进化记忆**：多层学习记忆（语义/情景/工作记忆），自动提取模式并进化技能
- **代码质量**：安全审计、依赖健康检查、技术债务追踪
- **运维部署**：CI/CD 生成、部署策略、数据库迁移、监控配置
- **调试排障**：错误分诊、日志分析、性能分析、Bug 复现
- **知识管理**：新人引导、API 文档、架构决策记录、知识提取

**快速开始：**
```bash
# 列出全部 28 个 prizm-kit 技能
python3 skills-master/assets/skill-templates/prizm-kit/scripts/install-prizmkit.py --list

# 安装全部技能（含钩子）
python3 skills-master/assets/skill-templates/prizm-kit/scripts/install-prizmkit.py --target .codebuddy/skills --hooks --project-root .

# 安装单个技能
python3 skills-master/assets/skill-templates/prizm-kit/scripts/install-prizmkit.py --skill prizmkit-init --target .codebuddy/skills
```

| 技能 | 类别 | 描述 |
| :--- | :--- | :--- |
| **prizmkit-init** | 基础 | 项目接管：扫描、评估、生成文档、初始化 |
| **prizmkit-memory** | 基础 | 多层学习记忆（语义/情景/工作记忆） |
| **prizmkit-evolution** | 基础 | 自进化引擎：从模式生成技能补丁 |
| **prizmkit-prizm-docs** | 文档 | AI 专用渐进式上下文加载框架 |
| **prizmkit-specify** | 规范驱动 | 从自然语言创建结构化功能规格 |
| **prizmkit-clarify** | 规范驱动 | 交互式需求澄清 |
| **prizmkit-plan** | 规范驱动 | 生成技术方案 + 数据模型 + API 契约 |
| **prizmkit-tasks** | 规范驱动 | 将方案拆解为可执行任务列表 |
| **prizmkit-implement** | 规范驱动 | 按 TDD 方式执行任务 |
| **prizmkit-code-review** | 规范驱动 | 对照规格和方案进行代码审查 |
| **prizmkit-summarize** | 规范驱动 | 将已完成功能归档到 REGISTRY.md |
| **prizmkit-committer** | 提交 | 提交时自动更新 Prizm 文档 |
| **prizmkit-retrospective** | 回顾 | 功能完成后提取经验教训 |
| **prizmkit-security-audit** | 质量 | 安全漏洞扫描 |
| **prizmkit-dependency-health** | 质量 | 依赖审计：版本、漏洞、兼容性 |
| **prizmkit-tech-debt-tracker** | 质量 | 技术债务识别与追踪 |
| **prizmkit-ci-cd-generator** | 运维 | 生成 CI/CD 流水线配置 |
| **prizmkit-deployment-strategy** | 运维 | 部署规划（蓝绿/金丝雀/滚动）+ 回滚 |
| **prizmkit-db-migration** | 运维 | 数据库迁移与回滚脚本 |
| **prizmkit-monitoring-setup** | 运维 | 监控、告警、日志采集配置 |
| **prizmkit-error-triage** | 调试 | 错误分类与根因分析 |
| **prizmkit-log-analyzer** | 调试 | 日志模式分析与异常检测 |
| **prizmkit-perf-profiler** | 调试 | 性能瓶颈识别 |
| **prizmkit-bug-reproducer** | 调试 | 生成最小复现脚本 |
| **prizmkit-onboarding-generator** | 知识 | 生成开发者入职指南 |
| **prizmkit-api-doc-generator** | 知识 | 自动生成 API 文档 |
| **prizmkit-adr-manager** | 知识 | 架构决策记录管理 |
| **prizmkit-knowledge-extractor** | 知识 | 从会话历史提取可复用模式 |

---

## 🛠️ 安装

### 通过 npx 快速安装（推荐）

使用 [npx skills](https://github.com/vercel-labs/skills) 一行命令将技能安装到你的 AI 编程助手中：

```bash
# 安装所有技能
npx skills add https://github.com/lone-yu-cmd/AI-Coding-Paradigm

# 安装指定技能
npx skills add https://github.com/lone-yu-cmd/AI-Coding-Paradigm --skill skills-master
npx skills add https://github.com/lone-yu-cmd/AI-Coding-Paradigm --skill playwright-pro
npx skills add https://github.com/lone-yu-cmd/AI-Coding-Paradigm --skill auto-committer
```

> 支持 40+ AI 编程助手，包括 **Cursor**、**Claude Code**、**CodeBuddy**、**Trae**、**Windsurf**、**GitHub Copilot**、**Gemini CLI** 等。

### 手动安装

#### 先决条件

*   Python 3.6+
*   Git

#### 克隆仓库

```bash
git clone https://github.com/lone-yu-cmd/ai-coding-paradigm.git
```

仓库结构：
```
ai-coding-paradigm/
├── skills-master/      # 技能管理系统
├── rule-master/        # 规则生成系统
├── subagents-master/   # 子智能体系统
└── docs/              # 文档
```

**对于 Skills-Master**：复制或符号链接 `skills-master` 目录到你的 IDE skills 目录，然后告诉 AI 助手："Skills-Master 有哪些技能？"或"调用 skills-master 帮我安装 auto-committer"。

**对于 Rule-Master**：使用规则生成工具为你的项目创建标准化规则。

**对于 Subagents-Master**：使用 `subagent-creator` 技能创建专业化的子智能体。

### 💡 现有项目的推荐工作流

如果你正在将 AI-Coding-Paradigm 集成到现有项目中：

1.  **初始化文档**：使用 **context-ai-sync** 技能生成 AI 上下文文档（`docs/AI_CONTEXT/`）。
2.  **定义规则**：使用 **rule-master** 建立编码标准和 AI 交互指南。
3.  **安装核心技能**：我们 **强烈推荐** 安装 **auto-committer** 和 **context-aware-coding** 用于自动化工作流。
4.  **创建子智能体**：使用 **subagent-creator** 为复杂的领域特定任务构建专业化智能体。
5.  **自定义**：根据你的具体需求添加更多技能和规则。

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
