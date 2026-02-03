---
name: "ai-context-sync"
description: "Intelligent AI context documentation system for projects. Invoke with 'AI Context Sync' to initialize project docs or sync with code changes."
subagent:
  name: "doc-maintainer"
  description: "专门用于文档分析和维护的子智能体，负责分析代码变更对文档的影响并提供更新建议"
  trigger_condition: "当处理大型项目或批量文档更新时自动调用"
  fallback: "主 Agent 直接处理"
---

# AI Context Sync Skill

为任意项目维护一份"项目逻辑地图"，让 AI 在新对话中能够快速理解项目并上手工作。

## 触发方式

- **初始化项目**：`调用 AI Context Sync Skill 帮我初始化项目`
- **同步文档**：`调用 AI Context Sync Skill 帮我提交代码`
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

#### Step 4: 询问 Git Hook 安装

```
是否安装 Git pre-commit Hook 以便在提交时自动提醒文档同步？
- [Y] 是，安装 Hook（推荐）
- [N] 否，稍后手动安装
```

如果用户选择安装，执行 `scripts/install-hook.sh` 脚本。

---

## 维护模式

### 执行步骤

#### Step 1: 获取代码变更

执行以下命令获取变更信息：

```bash
# 获取未暂存的变更
git diff HEAD

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
1. 检测 Subagent 可用性（Level 3）→ 检查 doc-maintainer Subagent
2. 检测 AI CLI 工具（Level 2）→ 检测 codebuddy-cli / cursor-cli
3. 回退到提示模式（Level 1）→ 默认方案
```

##### Subagent 配置机制

本 Skill 声明了一个可选的 Subagent 配置（见 YAML frontmatter）：

| 配置项 | 值 | 说明 |
|--------|-----|------|
| name | `doc-maintainer` | Subagent 唯一标识 |
| description | 文档分析和维护专用子智能体 | 职责说明 |
| trigger_condition | 大型项目或批量更新 | 何时触发 |
| fallback | 主 Agent 直接处理 | 不可用时的降级策略 |

##### 详细环境检测逻辑

**Subagent 可用性检测**

```python
# 检测 Subagent 是否已配置并可用
# 1. 检查 SKILL.md frontmatter 中声明的 subagent
# 2. 检查项目的 .codebuddy/subagents/ 目录或 subagents-master/ 目录
# 3. 验证对应的 subagent.md 文件是否存在

def check_subagent_availability(subagent_name: str) -> bool:
    """检测指定的 Subagent 是否可用"""
    search_paths = [
        f".codebuddy/subagents/{subagent_name}/subagent.md",
        f"subagents-master/{subagent_name}/subagent.md"
    ]
    for path in search_paths:
        if os.path.exists(path):
            return True
    return False
```

**执行级别判断逻辑**

```
IF SKILL.md 声明了 subagent 配置
  AND 对应的 Subagent 已安装
  AND 用户未禁用 Subagent（.aicontextrc.json 中 useSubagent != false）
THEN
  LEVEL = 3（Subagent 辅助模式）
ELSE IF 检测到 AI CLI 工具可用
THEN
  LEVEL = 2（CLI 调用模式）
ELSE
  LEVEL = 1（提示模式）
```

**CLI 工具检测**

```bash
# 检测 CLI 工具
CLI_AVAILABLE=""
for cli in codebuddy-cli cursor-cli ai-context-cli; do
    if command -v "$cli" &>/dev/null; then
        CLI_AVAILABLE="$cli"
        break
    fi
done

# 检测环境变量指定的 CLI
if [[ -n "$AI_CLI_PATH" && -x "$AI_CLI_PATH" ]]; then
    CLI_AVAILABLE="$AI_CLI_PATH"
fi
```

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
  --non-interactive \  # CI/CD 模式
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

当 SKILL.md 中声明的 Subagent（doc-maintainer）可用时：
- 主 Agent 检测到声明的 Subagent 配置
- 验证 Subagent 已安装（存在于 subagents-master/ 或 .codebuddy/subagents/）
- 委托文档分析和更新建议任务给 Subagent
- 主 Agent 执行最终编辑决策

##### Subagent 调用流程

```
主 Agent 接收用户请求
  ↓
读取 SKILL.md frontmatter 中的 subagent 配置
  ↓
检查 Subagent 可用性（调用 check_subagent_availability）
  ↓
IF 可用 THEN
  调用 use_sub_agent 工具，委托任务
  接收 Subagent 返回的分析结果
  主 Agent 根据结果执行文档编辑
ELSE
  输出提示："Subagent doc-maintainer 未安装，回退到主 Agent 处理"
  主 Agent 直接执行分析和编辑
```

##### Subagent 调用格式

```
使用 use_sub_agent 工具调用：
- name: "doc-maintainer"
- message: |
    请分析以下代码变更对项目文档的影响：
    
    ## 变更内容
    <git diff 输出>
    
    ## 现有文档
    <docs/AI_CONTEXT/ 目录结构>
    
    ## 配置信息
    <.aicontextrc.json 内容>
    
    请返回：
    1. 需要更新的文档列表
    2. 每个文档的具体更新建议
    3. 是否需要创建新文档
```

##### doc-maintainer Subagent 规范

如需创建此 Subagent，应包含以下定义：

```yaml
# subagents-master/doc-maintainer/subagent.md
name: doc-maintainer
description: 专门用于文档分析和维护的子智能体，负责分析代码变更对文档的影响并提供更新建议
prompt: |
  你是一个专业的文档维护专家，专注于分析代码变更并维护项目文档的一致性。
  
  你的职责：
  1. 分析 git diff 输出，识别代码变更类型
  2. 判断变更对现有文档的影响
  3. 提供具体的文档更新建议
  4. 识别需要创建新文档的场景
  
  你应该关注：
  - 模块职责变化
  - 接口签名变更
  - 依赖关系变化
  - 文件结构调整
  - 配置项变更
  
  返回格式要求：
  使用结构化的 JSON 格式返回分析结果
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

1. **声明式配置**：Subagent 配置在 SKILL.md frontmatter 中声明，便于查看和维护
2. **灵活调整**：可通过 `.aicontextrc.json` 的 `useSubagent: false` 禁用 Subagent
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

配置项说明见 `assets/config/.aicontextrc.template.json`。

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
- 配置模板：`assets/config/`
- Hook 脚本：`scripts/hooks/`
- 安装脚本：`scripts/install-hook.sh`
