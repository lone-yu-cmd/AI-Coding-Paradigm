# AI 文档撰写规范（基于 Prizm Spec）

来源：`PRIZM-SPEC-DOC.md`

## 一、核心定位

- **受众**：仅面向 AI Agent，不面向人类
- **目标**：减少 AI 幻觉、降低 token 消耗、确保 AI 始终拥有准确的项目知识
- **文件格式**：`.prizm` 扩展名，存放在 `.prizm-docs/` 目录下

## 二、六大核心原则

1. **Token 效率优先** — 不追求人类可读性，追求信息密度
2. **渐进式披露** — 只加载当前任务需要的内容，不一次全加载
3. **自更新** — 每次 commit 前自动同步文档与源代码
4. **仅追加历史** — DECISIONS 和 CHANGELOG 永不删除，只追加
5. **大小强制** — 超出限制则压缩、拆分或归档
6. **懒生成 L2** — 初始化时不生成 L2 详情文档，首次修改文件时才创建

## 三、文档格式规范

### 3.1 基本语法

| 元素 | 格式 | 示例 |
|------|------|------|
| 标题 | 全大写后跟冒号 | `MODULE:`, `FILES:`, `RESPONSIBILITY:` |
| 键值对 | `KEY: value`（冒号后一个空格） | `LANG: Go` |
| 列表项 | `- ` 前缀 | `- MUST: 所有接口必须返回错误码` |
| 指针 | `->` 指向其他 `.prizm` 文件 | `-> .prizm-docs/internal/logic.prizm` |
| 日期 | 方括号括住 | `[2026-03-02]` |
| 子键 | 缩进 2 空格 | `  - runtime: Go 1.22` |
| 变更日志分隔 | 竖线 `\|` | `- 2026-03-02 \| module \| add: 描述` |
| 注释 | **不允许** | 每一行都必须承载信息 |

### 3.2 语义关键词

用于 RULES 段落，表达强制程度：

- **MUST** — 项目/模块级强制规则
- **NEVER** — 项目/模块级禁止事项
- **PREFER** — 项目/模块级推荐做法

## 四、三级渐进式加载架构

### 4.1 层级总览

| 级别 | 文件 | 大小限制 | 加载时机 | 内容定位 |
|------|------|----------|----------|----------|
| L0 | `root.prizm` | 4KB (~100行) | 会话开始时**始终加载** | 项目全局索引 |
| L1 | `<module>.prizm` | 3KB | AI 在某模块区域工作时**按需加载** | 模块级索引 |
| L2 | `<submodule>.prizm` | 5KB | AI **修改**该子模块文件时才加载 | 子模块级详情 |
| Changelog | `changelog.prizm` | 最近50条 | 随 L0 加载 | 变更记录 |

### 4.2 目录结构

镜像源代码目录树，存放在 `.prizm-docs/` 下：

```
.prizm-docs/
  root.prizm                          # L0 — 项目根索引
  changelog.prizm                     # 变更日志
  internal/
    logic.prizm                       # L1 — internal/logic/ 的模块索引
    model.prizm                       # L1 — internal/model/ 的模块索引
    logic/
      statemachine.prizm              # L2 — internal/logic/statemachine/ 的详情
      session.prizm                   # L2 — internal/logic/session/ 的详情
```

### 4.3 加载规则

| 场景 | 操作 |
|------|------|
| 会话开始 | **始终**读取 `root.prizm` (L0) |
| 收到任务（指定文件/目录） | 加载对应模块的 L1 |
| 收到广泛任务（如"重构 auth"） | 加载所有匹配模块的 L1 |
| 修改文件前 | 加载对应子模块的 L2，重点看 TRAPS 和 DECISIONS |
| 探索性任务 | 仅 L0，按指针按需导航 |

**禁止：**
- 会话开始时加载所有 L1 和 L2
- 加载不修改的模块的 L2
- 跳过 L0

**Token 预算：** 典型任务应消耗 3000-5000 tokens 的 prizm 文档

## 五、各级别模板

### 5.1 L0 — root.prizm（项目全局索引）

```
PRIZM_VERSION: 1
PROJECT: <项目名>
LANG: <主语言>
FRAMEWORK: <主框架>
BUILD: <构建命令>
TEST: <测试命令>
ENTRY: <入口文件>
UPDATED: <YYYY-MM-DD>

ARCHITECTURE: <层1> -> <层2> -> <层3> -> ...
LAYERS:
- <层名>: <一行描述>

TECH_STACK:
- runtime: <列表>
- deps: <关键外部依赖>
- infra: <基础设施：数据库、队列、缓存等>

MODULE_INDEX:
- <源码路径>: <文件数> files. <一行描述>. -> .prizm-docs/<镜像路径>.prizm

ENTRY_POINTS:
- <名称>: <文件路径> (<协议/端口>)

RULES:
- MUST: <全局强制规则>
- NEVER: <全局禁止事项>
- PREFER: <全局推荐做法>

PATTERNS:
- <模式名>: <一行描述>

DECISIONS:
- [YYYY-MM-DD] <项目级架构决策及理由>
- REJECTED: <被否决的方案 + 原因>
```

**约束：** 最大 4KB，MODULE_INDEX 每个条目必须有 `->` 指针，RULES 限 5-10 条，不允许散文段落。

### 5.2 L1 — module.prizm（模块级索引）

```
MODULE: <源码路径>
FILES: <文件数>
RESPONSIBILITY: <一行描述>
UPDATED: <YYYY-MM-DD>

SUBDIRS:
- <名称>/: <一行描述>. -> .prizm-docs/<子路径>.prizm

KEY_FILES:
- <文件名>: <角色/用途>

INTERFACES:
- <函数/方法签名>: <功能描述>

DEPENDENCIES:
- imports: <本模块使用的内部模块>
- imported-by: <依赖本模块的内部模块>
- external: <使用的第三方包>

RULES:
- MUST: <模块级强制规则>
- NEVER: <模块级禁止事项>
- PREFER: <模块级推荐做法>

DATA_FLOW:
- <编号步骤，描述数据如何流经本模块>
```

**约束：** 最大 3KB，INTERFACES 仅列公开/导出签名，KEY_FILES 最多 10-15 个。

### 5.3 L2 — detail.prizm（子模块级详情）

```
MODULE: <源码路径>
FILES: <逗号分隔的所有文件列表>
RESPONSIBILITY: <一行描述>
UPDATED: <YYYY-MM-DD>

<领域特定段落>
（AI 根据模块职能自主生成，见下方示例）

KEY_FILES:
- <文件名>: <详细描述，行数，复杂度>

DEPENDENCIES:
- uses: <外部库>: <为何/如何使用>
- imports: <内部模块>: <消费了哪些接口>

DECISIONS:
- [YYYY-MM-DD] <模块内决策及理由>
- REJECTED: <被尝试/考虑后放弃的方案 + 原因>

TRAPS:
- <看起来正确但实际有问题的陷阱>
- <非显而易见的耦合、竞态条件或副作用>

CHANGELOG:
- YYYY-MM-DD | <动词>: <变更描述>
```

**领域特定段落示例：**

| 模块类型 | 推荐段落 |
|----------|----------|
| 状态机 | `STATES`, `TRIGGERS`, `TRANSITIONS` |
| API 处理器 | `ENDPOINTS`, `REQUEST_FORMAT`, `RESPONSE_FORMAT`, `ERROR_CODES` |
| 数据存储 | `TABLES`, `QUERIES`, `INDEXES`, `CACHE_KEYS` |
| 配置模块 | `CONFIG_KEYS`, `ENV_VARS`, `DEFAULTS` |
| UI 组件 | `PROPS`, `EVENTS`, `SLOTS`, `STYLES` |

**约束：** 最大 5KB，DECISIONS 仅追加不删除（超 20 条归档），FILES 列出所有文件，**TRAPS 段落至关重要**（防止 AI 犯已知错误），REJECTED 防止 AI 重提失败方案。

### 5.4 changelog.prizm（变更日志）

```
CHANGELOG:
- YYYY-MM-DD | <模块路径> | <动词>: <一行描述>
```

**动词：** `add`, `update`, `fix`, `remove`, `refactor`, `rename`, `deprecate`
**保留策略：** 最近 50 条，更早的归档到 `changelog-archive.prizm`

## 六、严格禁止的内容（反模式）

在 `.prizm` 文件中 **绝对不能** 出现以下内容：

| 禁止项 | 说明 |
|--------|------|
| 散文段落 | 使用 `KEY: value` 或列表，不写解释性文字 |
| 超过 1 行的代码片段 | 用 `file_path:line_number` 引用代替 |
| 视觉装饰 | 不用 emoji、ASCII art、Markdown 表格、分隔线 |
| 流程图/图表 | 不用 mermaid、流程图、ASCII 图（浪费 token，AI 无法视觉解析） |
| Markdown 标题 | `.prizm` 文件内不用 `##`/`###`，用全大写 `KEY:` 格式 |
| 跨层级重复 | L0 概述、L1 详述、L2 深入，不重复 |
| L0/L1 放实现细节 | 实现细节仅放 L2 |
| 过时信息 | 发现即更新或删除 |
| TODO / 未来计划 | 属于 issue tracker，不属于文档 |
| 会话上下文 | 文档与会话无关，是持久化的 |
| 全文件重写 | 更新时只修改受影响的段落 |

## 七、自动更新协议

### 触发时机

每次 commit 前（通过 hook 自动检测或手动触发 `prizmkit.doc.update`）。

### 更新流程

1. **获取变更文件**：`git diff --cached --name-status`
2. **映射到模块**：根据 `root.prizm` 的 MODULE_INDEX 分组
3. **分类变更**：
   - `A`（新增）→ 可能需要新建 KEY_FILES、INTERFACES
   - `D`（删除）→ 从 KEY_FILES 移除，更新 FILES 计数
   - `M`（修改）→ 检查公开接口或依赖是否变化
   - `R`（重命名）→ 更新所有路径引用
4. **更新文档**：逐层更新 L2 → L1 → L0
5. **追加 changelog**
6. **强制大小检查**：超限则压缩/拆分
7. **暂存文档**：`git add .prizm-docs/`

### 跳过条件

- 仅内部实现变更（无接口/依赖变化）
- 仅注释、空白、格式变更
- 仅测试文件变更
- 仅 `.prizm` 文件变更（避免循环更新）

## 八、初始化流程

运行 `prizmkit.doc.init` 后：

1. **检测项目类型**（语言、框架、构建系统）
2. **发现模块**（含 3+ 源文件的目录）
3. **创建目录结构**（镜像源码树）
4. **生成 L0**（root.prizm）
5. **生成 L1**（每个模块一个 .prizm 文件）
6. **不生成 L2**（延迟到首次修改时创建）
7. **创建 changelog.prizm**
8. **验证**（大小限制、指针解析、无循环依赖）

### 最小可用配置

只需两个文件即可获得基本能力：

```
.prizm-docs/
  root.prizm          # 项目元信息 + 模块索引
  changelog.prizm     # 变更日志
```

L1 和 L2 后续按需增量添加。

## 九、多语言支持

### 模块边界检测

| 语言 | 模块边界标志 | 入口点检测 |
|------|-------------|-----------|
| Go | 含 `.go` 文件的目录 | `main.go`, `cmd/**/main.go` |
| JS/TS | 含 `index.ts/js/tsx/jsx` 的目录 | `package.json` 的 main/bin |
| Python | 含 `__init__.py` 的目录 | `__main__.py`, `manage.py`, `app.py` |
| Rust | 含 `mod.rs` 的目录 | `main.rs`, `lib.rs` |
| Java | `src/main/java/*` 包目录 | `*Application.java`, `Main.java` |
| C# | 含 `*.cs` 文件的目录 | `Program.cs`, `Startup.cs` |

### 接口检测

| 语言 | 导出接口模式 |
|------|-------------|
| Go | 大写开头的函数/类型名 |
| JS/TS | `export` / `export default` 声明 |
| Python | 无下划线前缀的函数/类 |
| Rust | `pub fn`, `pub struct`, `pub enum`, `pub trait` |
| Java/C# | `public class`, `public interface`, `public method` |

### 依赖检测

| 语言 | 导入模式 |
|------|---------|
| Go | `import "path/to/package"` |
| JS/TS | `import ... from "..."`, `require("...")` |
| Python | `import ...`, `from ... import ...` |
| Rust | `use crate::...`, `use super::...` |
| Java | `import package.Class` |
| C# | `using Namespace` |
