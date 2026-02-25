# Speckit 命令系统架构 — 完整依赖关系图

## 一、核心命令流（主干管线）

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Speckit 命令执行管线 (Pipeline)                    │
│                                                                     │
│   ┌──────────────────────┐                                          │
│   │ speckit.constitution │  ◄── 基础层（可选但强烈推荐先行）          │
│   │ 项目宪法             │                                          │
│   └──────────┬───────────┘                                          │
│              │ 提供原则基准                                           │
│              ▼                                                      │
│   ┌──────────────────────┐      ┌───────────────────┐               │
│   │  speckit.specify     │─────►│  speckit.clarify  │               │
│   │  功能规格说明         │◄─────│  需求澄清         │               │
│   └──────────┬───────────┘      └───────────────────┘               │
│              │ spec.md 就绪                                          │
│              ▼                                                      │
│   ┌──────────────────────┐      ┌───────────────────┐               │
│   │  speckit.plan        │─────►│ speckit.checklist  │              │
│   │  实施计划             │      │ 需求质量检查       │              │
│   └──────────┬───────────┘      └───────────────────┘               │
│              │ plan.md + 设计文档就绪                                 │
│              ▼                                                      │
│   ┌──────────────────────┐      ┌───────────────────┐               │
│   │  speckit.tasks       │─────►│  speckit.analyze  │               │
│   │  任务分解             │      │  一致性分析(只读)  │               │
│   └──────────┬───────────┘      └───────────────────┘               │
│              │ tasks.md 就绪                                         │
│              ▼                                                      │
│   ┌──────────────────────┐      ┌─────────────────────┐             │
│   │  speckit.implement   │─────►│ speckit.taskstoissues│            │
│   │  执行实施             │      │ 同步到 GitHub Issues │            │
│   └──────────┬───────────┘      └─────────────────────┘             │
│              │ 代码实施完成                                          │
│              ▼                                                      │
│   ┌──────────────────────┐                                          │
│   │  speckit.codereview   │  ◄── 代码审查（推荐）                     │
│   │  代码审查             │                                          │
│   └──────────┬───────────┘                                          │
│              │ 审查通过                                              │
│              ▼                                                      │
│   ┌──────────────────────┐                                          │
│   │  speckit.summarize   │                                          │
│   │  功能摘要归档         │                                          │
│   └──────────────────────┘                                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 二、命令间依赖关系矩阵

```
                      ┌─ 前置依赖 ──────────────────────────────────┐
                      │                                             │
命令                  │ constitution  spec.md  plan.md  tasks.md    │
─────────────────────┼──────────────────────────────────────────────┤
constitution         │     -           -        -        -         │
specify              │   推荐          -        -        -         │
clarify              │   推荐        必需       -        -         │
plan                 │   必需        必需       -        -         │
checklist            │   推荐        必需     可选       -         │
tasks                │   必需        必需     必需       -         │
analyze              │   必需        必需     必需     必需        │
implement            │   必需        必需     必需     必需        │
codereview           │   可选        必需     必需     必需        │
taskstoissues        │     -         必需     必需     必需        │
summarize            │     -         必需     必需     必需        │
                      └─────────────────────────────────────────────┘

图例: 必需 = 缺少则报错  推荐 = 缺少会警告  可选 = 有则参考  - = 无依赖
```

---

## 三、每个命令的输入/输出/脚本依赖

### ① speckit.constitution — 项目宪法

- **用途**: 创建或更新项目的核心原则文件
- **输入**: 用户描述的项目原则
- **模板**: `.specify/templates/constitution-template.md`
- **脚本**: 无
- **输出**: `.specify/memory/constitution.md`（带语义化版本号）
- **关键行为**:
  - 填充模板中的占位符 `[ALL_CAPS_IDENTIFIER]`
  - 执行一致性传播检查（确保所有模板与宪法对齐）
  - 生成同步影响报告（HTML 注释形式）
  - 遵循语义化版本：MAJOR/MINOR/PATCH
- **Handoff**: 可交接给 `speckit.specify`

### ② speckit.specify — 功能规格说明

- **用途**: 从自然语言描述创建功能规格文件
- **输入**: 用户的功能描述文本
- **模板**: `.specify/templates/spec-template.md`
- **脚本**: `create-new-feature.sh`（创建分支和 `specs/###-feature-name/` 目录）
- **输出**:
  - 新的 Git 分支 `###-feature-name`
  - `specs/###-feature-name/spec.md`（功能规格）
  - `specs/###-feature-name/checklists/requirements.md`（规格质量检查清单）
- **关键行为**:
  - 自动生成 2-4 词的简短分支名
  - 检查远端/本地/specs 目录确定下一个编号
  - 聚焦 WHAT 和 WHY，禁止 HOW（不含技术实现细节）
  - 最多 3 个 `[NEEDS CLARIFICATION]` 标记
  - 内置规格质量验证循环（最多 3 次迭代）
- **Handoff**: 可交接给 `speckit.plan` 或 `speckit.clarify`

### ③ speckit.clarify — 需求澄清

- **用途**: 交互式识别和解决规格中的模糊点
- **输入**: 用户可选的重点领域描述
- **脚本**: `check-prerequisites.sh --json --paths-only`
- **输出**: 更新后的 `spec.md`（含 `## Clarifications` 章节）
- **关键行为**:
  - 按 10 个维度分类扫描模糊性（功能范围、数据模型、UX 流程、非功能性需求等）
  - **逐个提问**（非一次全部），最多 5 个问题
  - 每个问题提供**推荐选项**和原因
  - 每次回答后立即原子化写入 spec 文件
  - 支持早期终止信号（"done"、"stop"）
- **Handoff**: 可交接给 `speckit.plan`

### ④ speckit.plan — 实施计划

- **用途**: 生成技术实施计划和设计文档
- **输入**: 用户的技术栈等补充信息
- **模板**: `.specify/templates/plan-template.md`
- **脚本**: `setup-plan.sh --json`、`update-agent-context.sh`
- **输出**:
  - `specs/###-feature-name/plan.md`（实施计划）
  - `specs/###-feature-name/research.md`（Phase 0 研究输出）
  - `specs/###-feature-name/data-model.md`（Phase 1 数据模型）
  - `specs/###-feature-name/contracts/`（Phase 1 API 契约）
  - `specs/###-feature-name/quickstart.md`（Phase 1 快速入门）
  - 更新 AI Agent 上下文文件
- **关键行为**:
  - Phase 0: 研究和解决所有 `NEEDS CLARIFICATION`
  - Phase 1: 设计数据模型、API 契约、快速入门指南
  - 宪法检查门控（Phase 0 前和 Phase 1 后各一次）
  - 调用 `update-agent-context.sh codebuddy` 同步 Agent 上下文
- **Handoff**: 可交接给 `speckit.tasks` 或 `speckit.checklist`

### ⑤ speckit.tasks — 任务分解

- **用途**: 生成按用户故事组织的、可执行的任务清单
- **输入**: 用户的补充上下文
- **模板**: `.specify/templates/tasks-template.md`
- **脚本**: `check-prerequisites.sh --json`
- **输出**: `specs/###-feature-name/tasks.md`
- **关键行为**:
  - 严格检查清单格式: `- [ ] [TaskID] [P?] [Story?] Description with file path`
  - 按用户故事组织（US1, US2, US3...），每个故事可独立实现和测试
  - Phase 结构: Setup → Foundational → User Stories (P1→P2→P3) → Polish
  - 标记并行任务 `[P]`
  - 测试任务**可选**（仅按需）
  - 支持 MVP 优先、增量交付、并行团队三种实施策略
- **Handoff**: 可交接给 `speckit.analyze` 或 `speckit.implement`

### ⑥ speckit.checklist — 需求质量检查清单

- **用途**: 生成验证需求文档质量的清单
- **输入**: 用户指定的检查领域（如 UX、安全、API、性能等）
- **模板**: `.specify/templates/checklist-template.md`
- **脚本**: `check-prerequisites.sh --json`
- **输出**: `specs/###-feature-name/checklists/[domain].md`
- **关键行为**:
  - **核心理念**: 测试"需求写得好不好"，而非"系统运行对不对"
  - 最多 3 个初始澄清问题，最多 5 个跟进问题
  - 按需求质量维度分类（完整性、清晰性、一致性、可测量性、覆盖度等）
  - 80%+ 条目必须包含可追溯引用 `[Spec §X.Y]` 或 `[Gap]`
  - 每次运行创建新文件，不覆盖
  - **禁止**: 以"验证/测试/确认"开头的实现测试项

### ⑦ speckit.analyze — 一致性分析

- **用途**: 只读分析 spec.md、plan.md、tasks.md 之间的一致性和质量
- **输入**: 用户可选的分析重点
- **脚本**: `check-prerequisites.sh --json --require-tasks --include-tasks`
- **输出**: 结构化 Markdown 分析报告（**不写入文件**，仅输出到对话）
- **关键行为**:
  - 6 种检测通道: 重复检测、模糊检测、欠缺检测、宪法对齐、覆盖缺口、不一致性
  - 严重级别: CRITICAL > HIGH > MEDIUM > LOW
  - 宪法违规自动标记为 CRITICAL
  - 最多 50 个发现项
  - 提供覆盖率统计和下一步行动建议
  - **严格只读**，不修改任何文件

### ⑧ speckit.implement — 执行实施

- **用途**: 按 tasks.md 逐步执行代码实施
- **输入**: 用户的补充指令
- **脚本**: `check-prerequisites.sh --json --require-tasks --include-tasks`
- **输出**: 实际的代码文件 + tasks.md 标记完成 `[X]`
- **关键行为**:
  - 先检查检查清单完成状态，未完成则询问是否继续
  - 自动创建/验证 `.gitignore`、`.dockerignore` 等忽略文件
  - 按阶段执行: Setup → Tests → Core → Integration → Polish
  - 遵循 TDD（测试先行）
  - 完成任务后在 tasks.md 中标记 `[X]`
  - 错误处理: 顺序任务失败则停止，并行任务继续

### ⑨ speckit.codereview — 代码审查

- **用途**: 实施完成后，对代码进行结构化审查
- **输入**: 用户可选的审查重点（如"关注安全"、"只检查 API 路由"）
- **脚本**: `check-prerequisites.sh --json --require-tasks --include-tasks`
- **输出**: 结构化审查报告（**不写入文件**，仅输出到对话）
- **关键行为**:
  - 读取 spec.md、plan.md、tasks.md 等设计文档作为审查基准
  - 扫描 tasks.md 中已完成任务引用的所有代码文件
  - 6 个审查维度: 规格符合度、计划遵循度、代码质量、安全性、一致性、宪法对齐
  - 严重级别: CRITICAL > HIGH > MEDIUM > LOW
  - 最多 30 个发现项
  - 判定结论: PASS / PASS WITH WARNINGS / NEEDS FIXES
  - **严格只读**，不修改任何文件
- **Handoff**: 可交接给 `speckit.summarize`（归档）或 `speckit.implement`（修复）

### ⑩ speckit.taskstoissues — 任务转 GitHub Issues

- **用途**: 将 tasks.md 中的任务转为 GitHub Issues
- **输入**: 用户的补充说明
- **工具**: 使用 `github/github-mcp-server/issue_write` MCP 工具
- **脚本**: `check-prerequisites.sh --json --require-tasks --include-tasks`
- **输出**: GitHub Issues（通过 MCP 工具创建）
- **关键行为**:
  - 仅在远端为 GitHub URL 时才执行
  - 严格限制只在匹配远端 URL 的仓库中创建 Issues

### ⑪ speckit.summarize — 功能摘要归档

- **用途**: 实施完成后，将功能成果结构化沉淀到 Feature Registry
- **输入**: 用户的补充说明
- **模板**: `.specify/templates/registry-template.md`
- **脚本**: `check-prerequisites.sh --json --require-tasks --include-tasks`
- **输出**:
  - `specs/REGISTRY.md`（功能注册表，追加或更新条目）
  - `CODEBUDDY.md`（更新 Completed Features 段）
- **关键行为**:
  - 读取 spec.md、plan.md、data-model.md、contracts/、tasks.md 提取元数据
  - 扫描实际代码目录提取核心路径
  - 分析 tasks.md 完成率确定功能状态
  - 未完成时警告用户并确认是否继续
  - 追加 Changelog 条目（只追加不修改已有记录）
  - 幂等：相同输入重复执行产出一致
- **Handoff**: 可交接给 `speckit.specify`（开始新功能）

---

## 四、Shell 脚本层级依赖

```
┌───────────────────────────────────────────────────────┐
│                Shell 脚本依赖树                        │
│                                                       │
│  common.sh (公共函数库)                                │
│  ├── get_repo_root()       # 获取仓库根目录             │
│  ├── get_current_branch()  # 获取当前分支              │
│  ├── get_feature_paths()   # 获取特性目录路径           │
│  └── validate_branch()     # 验证分支格式              │
│       │                                               │
│       ├──► create-new-feature.sh                      │
│       │    ├── 创建 Git 分支                           │
│       │    ├── 创建 specs/###-feature/ 目录             │
│       │    └── 复制 spec-template.md                   │
│       │    被调用方: speckit.specify                    │
│       │                                               │
│       ├──► setup-plan.sh                              │
│       │    ├── 复制 plan-template.md                   │
│       │    └── 初始化 plan.md                          │
│       │    被调用方: speckit.plan                       │
│       │                                               │
│       ├──► check-prerequisites.sh                     │
│       │    ├── 验证分支/目录/文件                       │
│       │    ├── 报告可用文档清单                          │
│       │    └── 支持参数:                                │
│       │        --json         # JSON 格式输出          │
│       │        --paths-only   # 仅输出路径              │
│       │        --require-tasks # 要求 tasks.md 存在    │
│       │        --include-tasks # 包含任务内容           │
│       │    被调用方: clarify, tasks, checklist,         │
│       │            analyze, implement, codereview,      │
│       │            taskstoissues, summarize              │
│       │                                               │
│       └──► update-agent-context.sh                    │
│            ├── 解析 plan.md 技术栈                      │
│            └── 更新 18+ 种 AI Agent 上下文文件           │
│            被调用方: speckit.plan                       │
│                                                       │
└───────────────────────────────────────────────────────┘
```

---

## 五、文件系统产出物全景

```
项目根目录/
├── .specify/
│   ├── memory/
│   │   └── constitution.md          ◄── speckit.constitution 产出
│   ├── templates/                   ◄── 所有命令的骨架模板
│   │   ├── constitution-template.md
│   │   ├── spec-template.md
│   │   ├── plan-template.md
│   │   ├── tasks-template.md
│   │   ├── checklist-template.md
│   │   ├── registry-template.md
│   │   └── agent-file-template.md
│   └── scripts/bash/               ◄── 命令运行时调用的脚本
│       ├── common.sh
│       ├── create-new-feature.sh
│       ├── setup-plan.sh
│       ├── check-prerequisites.sh
│       └── update-agent-context.sh
│
├── .codebuddy/commands/             ◄── 11 个命令定义
│   ├── speckit.constitution.md
│   ├── speckit.specify.md
│   ├── speckit.clarify.md
│   ├── speckit.plan.md
│   ├── speckit.tasks.md
│   ├── speckit.checklist.md
│   ├── speckit.analyze.md
│   ├── speckit.implement.md
│   ├── speckit.codereview.md
│   ├── speckit.taskstoissues.md
│   └── speckit.summarize.md
│
└── specs/                           ◄── 每个功能特性的文档集
    ├── REGISTRY.md                  ◄── speckit.summarize (功能注册表)
    └── ###-feature-name/
        ├── spec.md                  ◄── speckit.specify
        ├── plan.md                  ◄── speckit.plan
        ├── research.md              ◄── speckit.plan (Phase 0)
        ├── data-model.md            ◄── speckit.plan (Phase 1)
        ├── quickstart.md            ◄── speckit.plan (Phase 1)
        ├── contracts/               ◄── speckit.plan (Phase 1)
        ├── tasks.md                 ◄── speckit.tasks
        └── checklists/
            ├── requirements.md      ◄── speckit.specify (自动)
            └── [domain].md          ◄── speckit.checklist (按需)
```

---

## 六、典型工作流时序

```
开发者                    Speckit 命令                    产出物
  │                           │                            │
  │── 1. 定义项目原则 ────────►│ constitution               │
  │                           │──────────────────────────►│ constitution.md
  │                           │                            │
  │── 2. 描述功能需求 ────────►│ specify                    │
  │                           │──────────────────────────►│ Git 分支 + spec.md
  │                           │                            │
  │── 3. (可选) 澄清模糊点 ──►│ clarify                    │
  │   ◄── AI 逐个提问 ────────│                            │
  │── 回答 ──────────────────►│──────────────────────────►│ spec.md (更新)
  │                           │                            │
  │── 4. 补充技术栈 ─────────►│ plan                       │
  │                           │── Phase 0: 研究 ─────────►│ research.md
  │                           │── Phase 1: 设计 ─────────►│ plan.md
  │                           │                           ►│ data-model.md
  │                           │                           ►│ contracts/
  │                           │                           ►│ quickstart.md
  │                           │                            │
  │── 5. (可选) 检查质量 ────►│ checklist                  │
  │                           │──────────────────────────►│ checklists/[domain].md
  │                           │                            │
  │── 6. 生成任务清单 ────────►│ tasks                      │
  │                           │──────────────────────────►│ tasks.md
  │                           │                            │
  │── 7. (可选) 一致性检查 ──►│ analyze                    │
  │   ◄── 分析报告 ──────────│ (只读，不写文件)             │
  │                           │                            │
  │── 8. 开始实施 ───────────►│ implement                  │
  │                           │── 逐任务执行 ────────────►│ 代码文件
  │                           │── 标记完成 ──────────────►│ tasks.md [X]
  │                           │                            │
  │── 9. (推荐) 代码审查 ────►│ codereview                   │
  │   ◄── 审查报告 ──────────│ (只读，不写文件)             │
  │                           │                            │
  │── 10. (可选) 同步 Issues ►│ taskstoissues              │
  │                           │──────────────────────────►│ GitHub Issues
  │                           │                            │
  │── 11. 功能摘要归档 ───────►│ summarize                  │
  │                           │──────────────────────────►│ specs/REGISTRY.md
  │                           │──────────────────────────►│ CODEBUDDY.md (更新)
  │                           │                            │
```

---

## 七、关键架构特征总结

| 特征 | 说明 |
|------|------|
| **管线式架构** | 命令按 constitution → specify → plan → tasks → implement → codereview → summarize 严格排序 |
| **可选分支** | clarify、checklist、analyze、taskstoissues 可在任意时机插入；codereview 推荐但可跳过 |
| **门控机制** | plan 命令内含 Constitution Check 门控（Phase 0 前 + Phase 1 后） |
| **脚本复用** | `common.sh` 被所有脚本 source；`check-prerequisites.sh` 被 8 个命令调用 |
| **只读命令** | analyze 和 codereview 是不写入文件的命令 |
| **渐进产出** | 每个命令产出独立文件，后续命令读取前序产出物 |
| **Agent 同步** | plan 命令自动通过 `update-agent-context.sh` 同步 18+ 种 AI Agent 上下文 |
| **功能归档** | summarize 命令维护 specs/REGISTRY.md 作为全局功能索引 |
