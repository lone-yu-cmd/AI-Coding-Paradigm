---
name: "ai-context-sync"
description: "Intelligent AI context documentation system for projects. Invoke with 'AI Context Sync' to initialize project docs or sync with code changes."
---

# AI Context Sync Skill

为任意项目维护一份"项目逻辑地图"，让 AI 在新对话中能够快速理解项目并上手工作。

## 触发方式

- **初始化项目**：`调用 AI Context Sync Skill 帮我初始化项目`
- **同步文档**：`调用 AI Context Sync Skill 帮我同步项目上下文文档`
- **快捷触发**：`AI Context Sync`

---

## 运行模式检测

执行以下检测逻辑以确定运行模式：

```
IF 项目根目录下存在 docs/AI_CONTEXT/ 目录
  THEN 进入【维护模式】
ELSE
  THEN 进入【初始化模式】
```

---

## 初始化模式

### 执行步骤

#### Step 1: 项目扫描

扫描当前项目，识别以下信息：

1. **技术栈识别**
   - 检查 `package.json`、`requirements.txt`、`pom.xml`、`go.mod`、`Cargo.toml` 等依赖文件
   - 识别主要编程语言和框架

2. **目录结构分析**
   - 识别源代码目录（src/、lib/、app/、pkg/ 等）
   - 识别配置目录（config/、conf/、settings/ 等）
   - 识别测试目录（test/、tests/、__tests__/ 等）

3. **模块发现**
   - 扫描主要功能模块
   - 识别入口文件和核心业务逻辑位置
   - 如果模块数量超过 20 个，询问用户是否需要筛选重点模块

##### 详细扫描策略

**技术栈检测规则表**

| 检测文件 | 技术栈 | 框架识别 |
|---------|-------|---------|
| `package.json` | JavaScript/TypeScript | 检查 dependencies: react/vue/angular/express/nest |
| `requirements.txt` / `pyproject.toml` | Python | 检查 django/flask/fastapi |
| `pom.xml` / `build.gradle` | Java | 检查 spring-boot/spring-cloud |
| `go.mod` | Go | 检查 gin/echo/fiber |
| `Cargo.toml` | Rust | 检查 actix/rocket/axum |
| `Gemfile` | Ruby | 检查 rails/sinatra |
| `composer.json` | PHP | 检查 laravel/symfony |

**模块识别规则**

```
模块识别优先级：
1. 显式模块目录（含 index.* 或 __init__.py 的目录）
2. 功能命名目录（auth、user、order、payment 等）
3. 分层架构目录（controller、service、model、repository）
4. 路由/API 定义文件所在目录
```

**入口文件识别**

```
常见入口文件模式：
- main.* / index.* / app.* / server.*
- src/main.* / src/index.*
- cmd/*/main.go（Go 项目）
- bin/* （可执行脚本）
```

**扫描排除规则**

默认排除以下目录（可通过 `.aicontextignore` 自定义）：
- 依赖目录：node_modules、vendor、.venv
- 构建产物：dist、build、out、target
- 缓存目录：.cache、__pycache__、.pytest_cache
- IDE 配置：.idea、.vscode

##### 生成阶段 Subagent（强制优先）

初始化模式的目标是“生成第一版可用的项目逻辑地图”。在多智能体协作流程中，若项目内存在生成阶段 Subagent（`context-bootstrapper`）且 `.aicontextrc.json` 未显式禁用，则主 Agent **必须**在初始化模式 **优先并强制** 委托该 Subagent 产出结构化方案；不得以“直接生成更快”等理由跳过。

**职责边界**
- `context-bootstrapper` 只负责基于代码现状提出“文档初始化方案”，不直接改写用户的业务代码
- 主 Agent 负责最终落盘（创建/更新文档文件）、冲突处理与用户交互确认

**输入**
- 项目目录结构（含关键目录的浅层文件清单）
- 依赖与运行入口线索（如 `package.json` / `go.mod` / `Cargo.toml` 等）
- 配置文件（如 `.aicontextrc.json`、`.aicontextignore`，若存在）

**输出**
- 技术栈结论与证据（命中哪些文件/依赖）
- 模块候选列表（模块名、路径、职责摘要、入口/路由/导出点线索）
- 初始化文档生成计划（将创建哪些文件、每个文件的主要章节与关键内容要点）
- 需要人工确认的点（不确定的模块职责、疑似废弃目录、扫描范围过大等）

**上下文管理规范（context-bootstrapper 强制遵守）**
- 目标读者：后续任意 AI/开发者在“新对话”中必须能用 1–3 分钟读懂项目
- 约束：结论必须可追溯到证据（文件路径、关键依赖名、入口文件名等），不允许纯猜测
- 输出必须稳定：同一项目多次生成的章节结构必须一致，便于增量维护与 diff 审阅
- 必须显式区分：事实（fact）/推断（inference）/待确认（needs_review）

**固定的项目目录理解格式（context-bootstrapper 输出中的 `doc_plan` 必须遵循）**
1. MAP.md（项目导航地图）必须包含：
   - Project Summary（1 段话说明做什么）
   - Tech Stack（语言/框架/运行时/关键依赖）
   - Directory Map（核心目录树 + 每个目录职责）
   - Entry Points（启动入口、路由入口、任务入口）
   - Module Index（模块表：模块名/路径/职责/入口或导出/依赖）
   - Key Contracts（对外 API/事件/任务/配置 Schema 的索引）
   - Runtime & Commands（常用启动/测试/构建命令线索，若可识别）
   - Risks / NEEDS_REVIEW（不确定点列表）
2. 每个模块的 `_AI_CONTEXT.md` 必须包含：
   - Scope（模块边界与不包含内容）
   - Public Interfaces（导出/对外 API/路由/事件）
   - Dependencies（上游/下游/关键依赖）
   - Data Flow（输入→处理→输出）
   - Config & Flags（本模块相关配置）
   - Tests（测试位置与覆盖范围线索）

#### Step 2: 创建目录结构

```
docs/AI_CONTEXT/
├── _RULES.md                    # AI 行为规范
├── MAP.md                       # 项目导航地图
└── [modules]/                   # 各模块的详情文档（可选）
```

#### Step 3: 生成核心文档

使用以下模板生成文档（模板位于 `assets/templates/` 目录）：

1. **_RULES.md** - 使用 `_RULES.template.md`
2. **MAP.md** - 使用 `MAP.template.md`
3. **模块文档** - 在对应模块目录下创建 `_AI_CONTEXT.md`，使用 `_AI_CONTEXT.template.md`

说明：本文档中所有以 `assets/` 开头的路径均相对本 Skill 的安装目录。

#### Step 4: 询问 Git Hook 安装

```
是否安装 Git pre-commit Hook 以便在提交时自动提醒文档同步？
- [Y] 是，安装 Hook（推荐）
- [N] 否，稍后手动安装
```

如果用户选择安装：
- 若当前仓库内存在 `scripts/install-hook.sh`，则执行该脚本
- 否则提示用户手动在 `.git/hooks/pre-commit` 中加入提醒逻辑（仅提示同步文档，不阻断提交）

---

## 维护模式

### 执行步骤

#### Step 1: 获取代码变更

执行以下命令获取变更信息：

```bash
# 获取未暂存的变更
git diff

# 获取已暂存的变更
git diff --cached
```

#### Step 2: 变更类型识别

分析变更内容，识别以下类型：

| 变更类型 | 识别特征 | 文档影响 |
|---------|---------|---------|
| 新增文件/模块 | 新文件出现在功能目录 | 创建新的 `_AI_CONTEXT.md` |
| 删除文件/模块 | 文件被完整删除 | 提示用户确认删除对应文档 |
| 修改函数签名 | 函数参数、返回值变化 | 更新接口文档 |
| 修改依赖关系 | import/require 语句变化 | 更新依赖关系图 |
| 重构/移动文件 | 文件路径变化 | 更新路径引用 |
| 配置变更 | 配置文件修改 | 更新配置说明 |
| 纯逻辑修改 | 仅内部实现变化 | 通常无需更新文档 |

##### 详细变更分析规则

**git diff 解析策略**

```bash
# 获取变更文件列表及状态
git diff --cached --name-status

# 状态码含义：
# A = 新增文件
# D = 删除文件
# M = 修改文件
# R = 重命名文件
# C = 复制文件
```

**文档更新决策树**

```
变更文件 →
├── 是否为代码文件？
│   ├── 否 → 检查是否为配置文件
│   │   ├── 是 → 更新 MAP.md 中的配置说明
│   │   └── 否 → 跳过
│   └── 是 →
│       ├── 是否新增模块？
│       │   ├── 是 → 创建新的 _AI_CONTEXT.md
│       │   └── 否 →
│       │       ├── 是否删除模块？
│       │       │   ├── 是 → 询问是否删除对应文档
│       │       │   └── 否 →
│       │       │       ├── 是否修改导出接口？
│       │       │       │   ├── 是 → 更新关键接口章节
│       │       │       │   └── 否 →
│       │       │       │       ├── 是否修改依赖？
│       │       │       │       │   ├── 是 → 更新依赖关系章节
│       │       │       │       │   └── 否 → 无需更新文档
```

**接口变更检测规则**

检测以下模式的变更：
- 函数/方法签名变化（参数、返回值）
- export/module.exports 语句变化
- public class/interface 定义变化
- API 路由定义变化
- 配置 schema 变化

**影响范围评估**

```
变更影响级别：
- 高影响：新增/删除模块、修改公共接口、架构重构
  → 需要更新 MAP.md + 相关 _AI_CONTEXT.md
  
- 中影响：修改函数签名、增删依赖
  → 需要更新对应 _AI_CONTEXT.md
  
- 低影响：内部实现变化、注释修改
  → 通常无需更新文档
```

#### Step 3: 智能更新文档

根据变更类型执行相应更新：

1. **仅更新 AUTO_SYNC 区块**
   - 查找 `<!-- AUTO_SYNC_START -->` 和 `<!-- AUTO_SYNC_END -->` 之间的内容
   - 保持 `<!-- MANUAL_START -->` 和 `<!-- MANUAL_END -->` 之间的内容不变

2. **增量更新策略**
   - 不重写整个文档，仅修改受影响的部分
   - 保留用户的手动编辑内容

3. **更新 MAP.md**（如果架构变更）
   - 更新模块职责表
   - 更新目录结构图

#### Step 4: 输出变更摘要

```
📝 AI Context Sync 执行摘要
================================
✅ 更新文件：
   - docs/AI_CONTEXT/MAP.md（模块结构更新）
   - src/auth/_AI_CONTEXT.md（新增接口说明）

⏭️ 跳过文件：
   - src/utils/_AI_CONTEXT.md（无相关变更）

⚠️ 需要人工确认：
   - src/legacy/_AI_CONTEXT.md（模块可能已废弃）
================================
```

---

## 三层级自动化方案

### 环境检测

执行以下检测确定可用的自动化级别：

```
检测顺序：
1. 检测 Subagent 可用性（Level 3）→ 检查 doc-maintainer Subagent（如存在）
2. 检测 AI CLI 工具（Level 2）→ 检测 `ai-cli` 或 `AI_CLI_PATH`
3. 回退到提示模式（Level 1）→ 默认方案
```

##### Subagent 配置机制

本 Skill 支持可选的 Subagent，但在多智能体协作流程中存在**强制调度规则**。为避免阶段职责混淆，将 Subagent 能力按阶段拆分：
- **生成阶段（初始化模式）**：`context-bootstrapper` 负责“从代码生成首版上下文文档方案”
- **维护阶段（维护模式）**：`doc-maintainer` 负责“基于变更增量更新文档方案”

**强制调度规则**
- 若 `useSubagent=true` 且存在 `context-bootstrapper`：初始化模式主 Agent **必须**调用该 Subagent；仅在“未安装/不可用/调用失败”时才允许回退
- 若 `useSubagent=true` 且存在 `doc-maintainer`：维护模式主 Agent **必须**调用该 Subagent；仅在“未安装/不可用/调用失败”时才允许回退
- 若 `useSubagent=false`：主 Agent **必须**跳过 Subagent，直接执行分析与编辑

| 配置项 | 值 | 说明 |
|--------|-----|------|
| name | `context-bootstrapper` | 生成阶段 Subagent 唯一标识 |
| description | 项目上下文初始化生成专用子智能体 | 职责说明 |
| trigger_condition | 大型项目或首次生成需高质量 | 何时触发 |
| fallback | 主 Agent 直接处理 | 不可用时的降级策略 |
| name | `doc-maintainer` | Subagent 唯一标识 |
| description | 文档分析和维护专用子智能体 | 职责说明 |
| trigger_condition | 大型项目或批量更新 | 何时触发 |
| fallback | 主 Agent 直接处理 | 不可用时的降级策略 |

##### 详细环境检测逻辑

**Subagent 可用性检测**
检查项目内是否存在所需 Subagent 配置，并以实际可检索结果为准

**环境变量支持**

| 环境变量 | 说明 | 示例 |
|---------|-----|-----|
| `SKIP_AI_CONTEXT_SYNC` | 跳过文档同步 | `SKIP_AI_CONTEXT_SYNC=1 git commit` |
| `AI_CLI_PATH` | 指定 CLI 路径 | `AI_CLI_PATH=/usr/local/bin/ai-cli` |
| `AI_CONTEXT_LEVEL` | 强制指定运行级别 | `AI_CONTEXT_LEVEL=1` |
| `AI_CONTEXT_DEBUG` | 启用调试输出 | `AI_CONTEXT_DEBUG=1` |

### Level 1: 提示模式（默认）

当用户未配置 Subagent 和 CLI 时：
- 由当前 AI 会话直接执行扫描和分析
- 用户需手动触发 Skill

**执行流程**
```
用户触发 Skill 
  → AI 读取 git diff 
  → AI 分析变更 
  → AI 更新文档 
  → 用户确认并提交
```

### Level 2: CLI 调用模式

当检测到 AI CLI 可用时：
- Git Hook 可自动调用 CLI 执行同步
- 支持 `--non-interactive` 参数用于 CI/CD

**CLI 调用参数**
```bash
ai-cli context-sync \
  --diff "$(git diff --cached)" \
  --timeout 30 \
  --non-interactive \
  --auto-stage        # 自动暂存更新的文档
```

**返回码说明**
| 返回码 | 含义 | 后续操作 |
|-------|-----|---------|
| 0 | 成功 | 继续 commit |
| 1 | 分析失败 | 警告后继续 |
| 2 | 需要确认 | 暂停并提示用户 |
| 124 | 超时 | 回退到 Level 1 |

### Level 3: Subagent 辅助模式

当项目内存在对应 Subagent 且 `useSubagent=true` 时，主 Agent **必须**按所处阶段选择并调用委托对象：
- **初始化模式**：**必须优先** 使用 `context-bootstrapper` 输出“首版文档生成方案”
- **维护模式**：**必须优先** 使用 `doc-maintainer` 输出“增量更新方案”

主 Agent 始终负责最终编辑与落盘，避免 Subagent 直接改写文档导致不可控覆盖。

##### 初始化模式委托流程（context-bootstrapper）

```
主 Agent 接收用户请求
  ↓
检查项目内是否存在 context-bootstrapper Subagent
  ↓
IF 可用 THEN
  委托其产出首版文档生成方案（结构化输出）
  主 Agent 根据方案创建 docs/AI_CONTEXT/ 下的文件
ELSE
  输出提示："Subagent context-bootstrapper 未安装，回退到主 Agent 处理"
  主 Agent 直接执行扫描并生成首版文档
```

##### 维护模式委托流程（doc-maintainer）

```
主 Agent 接收用户请求
  ↓
检查项目内是否存在 doc-maintainer Subagent
  ↓
IF 可用 THEN
  委托其产出增量更新建议（结构化输出）
  主 Agent 根据建议仅更新受影响的文档片段
ELSE
  输出提示："Subagent doc-maintainer 未安装，回退到主 Agent 处理"
  主 Agent 直接分析并更新文档
```

##### Subagent 输入输出约定

```
给 context-bootstrapper 的输入建议包含：
- 项目目录结构（按需截断）
- 关键依赖文件内容摘要（按需截断）
- 现有配置（.aicontextrc.json / .aicontextignore，如存在）

输出建议包含：
1. 技术栈结论与证据
2. 模块候选列表（路径、职责、入口/导出线索）
3. docs/AI_CONTEXT/ 生成计划（文件清单与每个文件要点）
4. NEEDS_REVIEW 列表（不确定点与原因）

给 doc-maintainer 的输入建议包含：
- 变更内容（优先 `git diff --cached`，必要时补充未暂存 diff）
- 现有文档结构（docs/AI_CONTEXT/ 目录与关键文件摘要）
- 配置信息（.aicontextrc.json，如存在）

返回建议包含：
1. 需要更新的文档列表
2. 每个文档的具体更新建议
3. 是否需要创建新文档
```

##### 阶段衔接方式

- 生成阶段（context-bootstrapper）输出的 `doc_plan` 由主 Agent 落盘为 docs/AI_CONTEXT/ 的首版文档，形成后续维护的“基线”
- 维护阶段（doc-maintainer）以该基线为输入之一，只对受影响文档做增量更新，并遵守 AUTO_SYNC / MANUAL 区块边界，避免覆盖人工编辑内容

##### 生成阶段缺失 Subagent 的风险与影响

生成阶段不配置 `context-bootstrapper` 也能工作，但在中大型项目中常见风险包括：
- 首版 MAP/_RULES 结构不稳，后续维护成本升高（需要反复重写而非增量更新）
- 模块边界与命名不一致，导致 `_AI_CONTEXT.md` 分布混乱、检索成本变高
- 扫描范围控制不当（漏掉关键目录或把大量非核心目录纳入），生成内容噪声大
- 不确定项未被集中标记，造成“看似完整但实际误导”的上下文，影响后续开发决策

##### doc-maintainer Subagent 规范

如需创建此 Subagent，应包含以下定义：

```yaml
# subagents-master/doc-maintainer/subagent.md
name: doc-maintainer
description: 专门用于文档分析和维护的子智能体，负责分析代码变更对文档的影响并提供更新建议
prompt: |
  你是一个专业的文档维护专家，专注于分析代码变更并维护项目上下文文档的一致性与可维护性。

  强制调度要求：
  - 在维护模式中，只要系统可调度你且未被显式禁用，你必须被调用；主 Agent 不得跳过你的分析直接改写文档

  你的职责（必须完成）：
  1. 解析 diff，识别变更类型与影响范围
  2. 对照现有 docs/AI_CONTEXT/，给出增量更新建议（禁止整文件重写作为默认方案）
  3. 强制区分 AUTO_SYNC 与 MANUAL：任何建议必须说明修改落点，且不得建议覆盖 MANUAL 区块
  4. 识别需要新增/拆分/归档的文档与原因，并给出可执行的更新步骤

  你必须关注（至少覆盖）：
  - 模块职责变化、公共接口/路由/导出变化
  - 依赖关系变化（新增/删除/替换依赖）
  - 文件结构调整（移动/重命名/删除）
  - 配置项变更（新增字段、默认值变化、schema 演进）

  输出必须是严格 JSON（不得输出 markdown），字段必须包含：
  - impact_level: "high"|"medium"|"low"
  - updates: [{ "file": "...", "action": "update"|"create"|"archive", "sections": ["..."], "summary": "...", "patch_hints": ["..."], "needs_review": ["..."] }]
  - skipped: [{ "file": "...", "reason": "..." }]
  - risks: ["..."]
  - questions: ["..."]
tools: []
mcp: []
knowledge: []
```

##### context-bootstrapper Subagent 规范

如需创建此 Subagent，应包含以下定义：

```yaml
# subagents-master/context-bootstrapper/subagent.md
name: context-bootstrapper
description: 专门用于初始化生成项目上下文文档方案的子智能体，负责扫描项目并产出结构化的首版文档生成计划
prompt: |
  你是一个专业的项目上下文建模专家，专注于从代码与目录结构中抽取“模块地图”和“关键契约”，用于初始化生成 AI 可读、可维护的项目上下文文档。

  强制调度要求：
  - 在初始化模式中，只要系统可调度你且未被显式禁用，你必须被调用；主 Agent 不得跳过你的方案直接生成首版文档

  上下文管理规范（必须遵守）：
  1. 你的输出必须面向“后续 AI 快速接手”：稳定结构、明确边界、可追溯证据
  2. 必须把结论分为：fact / inference / needs_review，并给出 evidence
  3. 必须产出固定的目录理解格式，确保 MAP.md 与模块文档结构一致

  你的职责（必须完成）：
  1. 识别技术栈与入口（启动入口/路由入口/任务入口），并提供证据
  2. 生成模块候选列表：模块职责、路径、入口/路由/导出点、上下游依赖
  3. 生成 docs/AI_CONTEXT/ 首版文档计划：文件清单 + 每个文件的章节要点（必须匹配模板结构）
  4. 输出 NEEDS_REVIEW：所有不确定点、风险、建议的确认方式

  输出必须是严格 JSON（不得输出 markdown），字段必须包含：
  - tech_stack: { "languages": [], "frameworks": [], "runtime": [], "evidence": [] }
  - entry_points: [{ "type": "app"|"router"|"worker"|"cli", "path": "...", "evidence": "..." }]
  - directory_map: [{ "path": "...", "role": "...", "notes": "...", "evidence": "..." }]
  - modules: [{ "name": "...", "path": "...", "responsibility": "...", "interfaces": [], "deps": [], "evidence": [], "needs_review": [] }]
  - doc_plan: [{ "file": "docs/AI_CONTEXT/MAP.md"|"docs/AI_CONTEXT/_RULES.md"|".../_AI_CONTEXT.md", "sections": ["..."], "key_points": ["..."] }]
  - needs_review: [{ "item": "...", "reason": "...", "how_to_verify": "..." }]
  - risks: ["..."]
tools: []
mcp: []
knowledge: []
```

### 降级策略

```
IF Level 3 失败 THEN 尝试 Level 2
IF Level 2 失败 THEN 回退 Level 1
```

**降级触发条件**

| 级别 | 降级条件 | 处理方式 |
|------|---------|----------|
| Level 3 → Level 2 | Subagent 未安装 / 调用超时 / 返回错误 | 输出提示后尝试 CLI 模式 |
| Level 2 → Level 1 | CLI 不存在 / 执行超时 / 返回错误码 | 输出提示后由主 Agent 处理 |

**降级提示格式**

```
⚠️ [Level X] 不可用，原因：<具体原因>
   正在回退到 [Level Y]...
```

**配置驱动的优势**

1. **职责可见**：生成与维护阶段的 Subagent 命名与输入输出约定在本文档中声明
2. **灵活调整**：可通过 `.aicontextrc.json` 的 `useSubagent` 开关禁用 Subagent
3. **自动检测**：无需修改核心逻辑，只需安装/卸载 Subagent 即可切换模式
4. **独立更新**：Subagent 可独立升级，不影响主 Skill 逻辑

---

## 错误处理

### 异常情况处理表

| 异常情况 | 处理策略 |
|---------|---------|
| 项目过大（>1000 文件）| 提示配置 `.aicontextignore` 排除非核心目录 |
| 无法识别项目类型 | 使用通用模板，提示用户手动补充 |
| Git 仓库未初始化 | 提示执行 `git init` |
| AUTO_SYNC 区块被手动修改 | 询问用户是否覆盖 |
| AI 分析不确定 | 生成 `<!-- NEEDS_REVIEW -->` 标记 |
| 执行中断 | 保留已完成更新，记录中断位置 |

### 详细错误处理指令

#### 项目过大处理

```
IF 文件数量 > 1000 THEN
  输出警告：
  "⚠️ 检测到项目包含超过 1000 个文件，建议：
   1. 创建 .aicontextignore 文件排除非核心目录
   2. 或在 .aicontextrc.json 中配置 modulePaths 限制扫描范围
   
   是否继续？这可能需要较长时间。[y/N]"
  
  IF 用户选择否 THEN 终止执行
```

#### 无法识别项目类型

```
IF 未找到任何已知的依赖文件 THEN
  输出提示：
  "ℹ️ 无法自动识别项目类型，将使用通用模板。
   
   检测到的文件类型：
   - .js/.ts 文件: X 个
   - .py 文件: Y 个
   - .go 文件: Z 个
   ...
   
   请在生成后手动补充项目特定信息。"
  
  使用 generic 模板继续执行
```

#### Git 仓库未初始化

```
IF NOT git rev-parse --is-inside-work-tree THEN
  输出错误：
  "❌ 当前目录不是 Git 仓库。
   
   请先执行：git init
   
   AI Context Sync 依赖 Git 来追踪代码变更。"
  
  终止执行
```

#### AUTO_SYNC 区块冲突

```
IF AUTO_SYNC 区块内容与原始生成内容不一致 THEN
  输出询问：
  "⚠️ 检测到 AUTO_SYNC 区块已被手动修改：
   
   文件：{{FILE_PATH}}
   
   手动修改内容可能会在下次同步时丢失。
   
   请选择：
   1. [O] 覆盖 - 使用新生成的内容替换
   2. [K] 保留 - 保持当前内容不变
   3. [M] 迁移 - 将手动内容移至 MANUAL 区块
   
   选择 [O/K/M]:"
```

#### 执行中断恢复

```
IF 检测到 .ai-context-sync.lock 文件存在 THEN
  读取 lock 文件内容（JSON 格式）：
  {
    "started_at": "2024-01-01T12:00:00Z",
    "completed_files": ["docs/AI_CONTEXT/_RULES.md", "docs/AI_CONTEXT/MAP.md"],
    "pending_files": ["src/auth/_AI_CONTEXT.md", "src/user/_AI_CONTEXT.md"],
    "current_file": "src/api/_AI_CONTEXT.md"
  }
  
  输出提示：
  "ℹ️ 检测到上次执行中断，是否从断点继续？
   
   已完成：{{COMPLETED_COUNT}} 个文件
   待处理：{{PENDING_COUNT}} 个文件
   
   [R] 从断点恢复 / [S] 重新开始 / [C] 取消"
```

### NEEDS_REVIEW 标记

当 AI 对某些内容不确定时，生成以下格式：

```markdown
<!-- NEEDS_REVIEW: [原因说明] -->
[AI 生成的内容]
<!-- /NEEDS_REVIEW -->
```

**触发 NEEDS_REVIEW 的条件**
- 模块职责描述可能不准确（缺乏足够上下文）
- 检测到循环依赖但无法确定是否正确
- 文件命名与内容不符
- 检测到废弃代码但不确定是否仍在使用
- 接口签名变化但找不到调用方

**NEEDS_REVIEW 格式示例**

```markdown
<!-- NEEDS_REVIEW: 无法确定此模块是否仍在使用 -->
### legacy-auth 模块

此模块似乎是遗留的认证实现，可能已被 new-auth 模块替代。
建议确认后删除或归档此文档。
<!-- /NEEDS_REVIEW -->
```

### 日志记录

所有执行过程记录到 `docs/AI_CONTEXT/.sync.log`：

```
[2024-01-01 12:00:00] [INFO] AI Context Sync 开始执行
[2024-01-01 12:00:01] [INFO] 模式: 维护模式
[2024-01-01 12:00:02] [INFO] 检测到 5 个变更文件
[2024-01-01 12:00:03] [INFO] 更新文件: docs/AI_CONTEXT/MAP.md
[2024-01-01 12:00:05] [WARN] AUTO_SYNC 区块冲突: src/auth/_AI_CONTEXT.md
[2024-01-01 12:00:10] [INFO] 执行完成，更新 2 个文件
```

---

## 配置文件

Skill 读取项目根目录下的 `.aicontextrc.json` 配置文件：

```json
{
  "useSubagent": true,
  "modulePaths": ["src/*", "lib/*"],
  "ignorePaths": ["node_modules", "dist", "build", ".git"],
  "docLanguage": "zh-CN",
  "autoSyncOnCommit": true,
  "maxModules": 20,
  "timeout": 30,
  "hookMode": "prompt",
  "cliPath": "",
  "blocking": false
}
```

上方为示例配置，可按项目规模与目录结构裁剪。

---

## 文档格式规范

### AUTO_SYNC 与 MANUAL 区块

```markdown
<!-- AUTO_SYNC_START -->
此区域由 AI 自动维护，请勿手动编辑
...自动生成的内容...
<!-- AUTO_SYNC_END -->

<!-- MANUAL_START -->
此区域供人工编辑，AI 不会覆盖
...手动编辑的内容...
<!-- MANUAL_END -->
```

### 文档大小限制

- `MAP.md` < 20KB
- `_AI_CONTEXT.md` < 10KB

超出限制时，应拆分为子文档或精简内容。

---

## 相关资源

- 模板文件：`assets/templates/`
