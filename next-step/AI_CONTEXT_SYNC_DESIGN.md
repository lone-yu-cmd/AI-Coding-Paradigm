# AI Context Sync - AI 驱动项目理解框架

## 设计日期
2026-02-03

## 问题定义

### 核心问题
对于**开发中期的项目**，当开启新的 AI 对话时，AI 无法快速理解项目的逻辑结构，导致：
- 需要大量时间探索代码库
- 实现需求时可能不够准确
- 可能创建重复功能或违反项目约定

### 目标
创建一个**通用的、编辑器无关的、AI 驱动的自动化系统**，为任意项目维护一份"项目逻辑地图"，让 AI 在新对话中能够快速理解项目并上手工作。

---

## 设计原则

### 1. 编辑器无关
- ❌ 不依赖特定 IDE（VSCode、Cursor、JetBrains 等）
- ❌ 不依赖特定 AI 模型（Claude、GPT、Gemini 等）
- ✅ 使用通用的 Markdown 格式
- ✅ 使用标准的文件路径约定

### 2. AI 驱动判断
- ❌ 不使用硬编码的代码解析规则
- ❌ 不依赖语言特定的 AST 解析
- ✅ 让 AI 理解变更的语义含义
- ✅ Subagent 基于自然语言规则做决策

### 3. 代码共存
- ❌ 不将模块文档集中存放在单独目录
- ✅ 模块文档与代码目录共存
- ✅ 文档跟随代码移动（重构友好）
- ✅ 提高文档的可发现性

### 4. 职责驱动
- 文档核心：清楚描述每个目录/模块**负责什么**
- 不是需求文档，不是变更日志
- 是项目逻辑结构的**当前状态快照**

### 5. 自动化维护
- 用户只提需求，系统自动维护文档
- 基于 Git Hook 触发，无需人工记忆
- 增量更新，不重新生成

---

## 系统架构

### 整体结构

```
┌─────────────────────────────────────────────────────┐
│ docs/AI_CONTEXT/_RULES.md - AI 行为规则层（编辑器无关）│
│ - 定义 AI 何时读取文档                                 │
│ - 定义 AI 如何理解项目                                 │
│ - 定义遇到问题时的处理策略                              │
│ - 适用于任何 AI 编程助手                               │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ docs/AI_CONTEXT/MAP.md - 导航索引层                   │
│ - 项目概览（一句话描述 + 核心价值）                     │
│ - 模块职责（每个目录负责什么 + _AI_CONTEXT.md 路径）    │
│ - 关键路径（典型场景的执行流程）                        │
│ - 核心概念（领域模型）                                 │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ /<模块目录>/_AI_CONTEXT.md - 模块详情层（与代码共存）    │
│ - 模块职责范围                                        │
│ - 文件结构说明                                        │
│ - 关键接口文档                                        │
│ - 依赖关系图                                          │
│ - 使用示例和注意事项                                   │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ Subagent: doc-maintainer - AI 驱动的智能维护层         │
│ - 分析 git diff HEAD                                  │
│ - AI 理解变更语义（非规则匹配）                         │
│ - 基于自然语言规则判断影响范围                          │
│ - 增量更新文档                                        │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│ Git Hook (pre-commit) - 自动触发层                    │
│ - 提交前自动执行                                       │
│ - 调用 doc-maintainer                                 │
│ - 将文档更新包含在同一 commit                          │
└─────────────────────────────────────────────────────┘
```

### 文件分布示意

```
project-root/
├── docs/
│   └── AI_CONTEXT/
│       ├── _RULES.md          # AI 行为协议（原 CLAUDE.md）
│       └── MAP.md             # 项目导航索引
│
├── src/
│   ├── _AI_CONTEXT.md         # src 模块文档
│   ├── auth/
│   │   ├── _AI_CONTEXT.md     # auth 模块文档
│   │   ├── login.py
│   │   └── session.py
│   ├── payment/
│   │   ├── _AI_CONTEXT.md     # payment 模块文档
│   │   ├── processor.py
│   │   └── billing.py
│   └── utils/
│       ├── _AI_CONTEXT.md     # utils 模块文档
│       └── helpers.py
│
├── tests/
│   ├── _AI_CONTEXT.md         # tests 模块文档
│   └── test_auth.py
│
└── scripts/
    ├── _AI_CONTEXT.md         # scripts 模块文档
    ├── init_ai_context.py
    └── doc_maintainer.py
```

---

## 文档结构设计

### _RULES.md - AI 行为协议（编辑器无关）

#### 职责
定义 AI 在项目中的行为规范，适用于**任何 AI 编程助手**：
- 新对话启动流程
- 任务驱动的文档加载策略
- 文档异常处理
- 文档更新触发规则

#### 结构模板

```markdown
# AI Context Rules

> 本文档定义 AI 编程助手在本项目中的行为规范。
> 适用于：Claude、GPT、Gemini、Copilot 等任何 AI 助手。

## 新对话启动流程

当开始一个新对话时，AI 必须按以下顺序执行：

### Step 1: 读取导航文件（强制）
```
READ: docs/AI_CONTEXT/MAP.md
```

### Step 2: 快速理解项目（2分钟内）
- 项目一句话描述是什么？
- 有哪些主要模块？各自负责什么？
- 有哪些核心概念？
- 有哪些重要约定必须遵守？

### Step 3: 建立心智模型
在你的"工作记忆"中记住：
- 要做 X 功能 → 应该看 Y 模块
- Y 模块位于 Z 目录
- Y 模块的详细文档是 Z/_AI_CONTEXT.md

---

## 任务驱动的文档加载策略

根据用户任务类型，按需加载相关文档：

### 理解现有功能
```
用户说："解释一下 X 功能是如何实现的"

流程：
1. 在 MAP.md [模块职责] 中定位负责 X 的模块
2. READ: /<模块目录>/_AI_CONTEXT.md
3. 阅读 [关键接口] 和 [典型使用场景]
4. 如果还不清楚，READ: 具体代码文件
5. 向用户解释
```

### 修改现有代码
```
用户说："修改 X 功能，让它支持 Y"

流程：
1. 在 MAP.md 中定位负责 X 的模块
2. READ: /<模块目录>/_AI_CONTEXT.md
3. 检查 [依赖关系] 了解影响范围
4. 检查 [注意事项] 避免踩坑
5. READ: 相关代码文件
6. 修改代码
7. 确认是否影响其他模块
```

### 添加新功能
```
用户说："添加一个新功能 X"

流程：
1. 在 MAP.md [模块职责] 中判断应该放在哪个模块
2. 如果不确定，READ: 多个 /<模块>/_AI_CONTEXT.md 对比职责范围
3. READ: 目标模块的 _AI_CONTEXT.md [扩展指南]
4. 阅读目标模块的现有代码了解模式
5. 实现新功能
6. 如果新功能"跨模块"，考虑在哪里建立协调层
```

### 修复 Bug
```
用户说："修复 X Bug" 或 "为什么 Y 不工作了"

流程：
1. 在 MAP.md [关键路径] 中找到相关场景的执行流程
2. READ: 涉及的模块的 _AI_CONTEXT.md
3. 检查 [注意事项] 中是否有相关陷阱
4. READ: 相关代码文件定位问题
5. 修复 Bug
```

---

## 文档异常处理

### 文档不存在
```
IF docs/AI_CONTEXT/MAP.md 不存在:
    提示用户: "项目尚未初始化 AI 上下文，建议运行初始化命令"
    询问: "是否现在初始化？"
```

### 文档内容与代码不符
```
IF 发现文档描述与实际代码不一致:
    1. 以代码为准完成当前任务
    2. 完成任务后提示用户文档可能过时
    3. 如果用户确认，更新文档
```

### 模块文档缺失
```
IF MAP.md 中某个模块没有对应的 _AI_CONTEXT.md:
    1. 直接阅读该模块的代码
    2. 完成任务
    3. (可选) 提示用户是否需要为该模块生成文档
```

---

## 文档更新触发规则

在以下情况，AI 应该**主动建议**更新文档：

### 模块职责变化
修改代码导致某个模块的职责发生变化时

### 新增重要接口
添加新的公共函数/类，且会被其他模块使用时

### 执行流程变化
修改典型场景的执行流程时

### 新增目录/模块
创建新的顶层目录或重要模块时

---

## 阅读效率优化

### 分层阅读策略
```
Layer 0: MAP.md [快速定位] - 必读，<30秒
Layer 1: MAP.md [项目概览] + [模块职责] - 了解全局，<2分钟
Layer 2: MAP.md [关键路径] + [核心概念] - 理解运作，<5分钟
Layer 3: 相关 /<模块>/_AI_CONTEXT.md - 深入细节，按需
Layer 4: 具体代码文件 - 精确理解，按需
```

### 避免过度阅读
- ❌ 不要一次性阅读所有 _AI_CONTEXT.md
- ✅ 根据任务类型，只读取相关模块的文档
- ❌ 不要阅读代码后再读文档
- ✅ 先读文档建立心智模型，再读代码验证
```

---

### MAP.md - 核心导航文件

#### 职责
作为项目的"入口文档"，提供：
- 快速定位：要做 X，应该看哪个模块
- 职责映射：每个模块负责什么
- 执行路径：典型场景如何运行
- 概念词典：核心领域概念

#### 结构模板

```markdown
# Project Map

## 快速定位

### 我想理解项目整体
→ 阅读本文档的 [项目概览] 部分

### 我想修改某个功能
→ 在 [模块职责] 中找到负责该功能的目录
→ 阅读对应目录下的 _AI_CONTEXT.md

### 我想添加新功能
→ 在 [模块职责] 中判断应该放在哪个模块
→ 阅读该模块的 _AI_CONTEXT.md 了解约定

### 我想理解数据流
→ 阅读 [关键路径] 部分

---

## 项目概览

**一句话描述**: [30字以内，说明项目是什么]

**核心价值**: [解决什么问题，为谁解决]

**主要技术栈**: [语言、框架、关键工具]

**项目规模**:
- 主要目录数: ~N
- 核心模块数: ~N

---

## 模块职责

### /src/auth
**职责**: 用户认证与会话管理
**关键能力**:
- 用户登录/注销
- Session 管理
- Token 验证
**详细文档**: [_AI_CONTEXT.md](/src/auth/_AI_CONTEXT.md)

### /src/payment
**职责**: 支付处理
**关键能力**:
- 订单支付
- 账单管理
- 退款处理
**详细文档**: [_AI_CONTEXT.md](/src/payment/_AI_CONTEXT.md)

[... 更多模块]

---

## 关键路径

### 路径1: 用户登录流程
1. [用户提交凭证] → src/auth/login.py:authenticate()
2. [验证密码] → src/auth/password.py:verify()
3. [创建会话] → src/auth/session.py:create_session()
4. [返回 Token]

### 路径2: 支付流程
[类似描述...]

---

## 核心概念

- **User**: 系统用户实体 - src/models/user.py
- **Session**: 用户会话 - src/auth/session.py
- **Order**: 订单实体 - src/models/order.py

**概念关系**:
- User 拥有多个 Session
- User 可以创建多个 Order

---

## 重要约定

### 架构约定
- [约定1]
- [约定2]

### 编码约定
- [约定1]
- [约定2]
```

---

### _AI_CONTEXT.md - 模块详情文档（与代码共存）

#### 职责
为**每个重要模块**提供详细文档，**与代码放在同一目录**：
- 职责边界（做什么、不做什么）
- 内部结构（文件组织）
- 对外接口（关键函数/类）
- 依赖关系（依赖谁、被谁依赖）

#### 命名规范
- 文件名：`_AI_CONTEXT.md`（下划线前缀，排在目录最前）
- 位置：与代码文件同级目录

#### 何时创建
- ✅ 核心业务模块
- ✅ 被多个模块依赖的基础模块
- ✅ 复杂度较高的模块
- ❌ 简单的配置目录
- ❌ 纯静态资源目录

#### 结构模板

```markdown
# Module: /当前目录路径

## 职责范围

**核心职责**:
- [职责1]
- [职责2]
- [职责3]

**不负责**:
- [非职责1] - 由 /其他目录 负责
- [非职责2] - 由 /其他目录 负责

---

## 文件结构

```
/当前目录/
├── _AI_CONTEXT.md    - 本文档
├── file1.py          - [作用描述]
├── file2.py          - [作用描述]
└── subdir/
    └── file3.py      - [作用描述]
```

---

## 关键接口

### function_or_class_1
- **用途**: [做什么]
- **签名**: `function(arg1: type, arg2: type) -> return_type`
- **位置**: file.py:行号
- **示例**:
  ```python
  result = function(arg1, arg2)
  ```

---

## 依赖关系

**依赖的模块**:
- `/模块A` - 使用其 [功能]
- `/模块B` - 使用其 [功能]

**被依赖的模块**:
- `/模块C` - 调用本模块的 [接口]

---

## 注意事项

### 常见陷阱
- [陷阱1]
- [陷阱2]

### 扩展指南
1. [步骤1]
2. [步骤2]
```

---

## Subagent: doc-maintainer 设计（AI 驱动）

### 核心理念：AI 驱动 

#### AI 驱动
```
# 自然语言规则定义
doc-maintainer 通过 AI 理解以下问题：

1. 这次变更的本质是什么？
   - 新增功能？修改功能？重构？Bug修复？
   
2. 变更影响了什么？
   - 哪些模块的职责？
   - 哪些对外接口？
   - 哪些执行流程？
   
3. 文档需要如何更新？
   - 更新哪个 _AI_CONTEXT.md？
   - 更新 MAP.md 的哪个部分？
```

---

### doc-maintainer 自然语言规则

```markdown
# doc-maintainer Subagent 规则

## 身份定义
你是一个专门负责维护项目 AI 上下文文档的智能助手。
你的职责是分析代码变更，判断是否需要更新文档，以及如何更新。

## 输入
你将收到 `git diff HEAD` 的输出，这是本次 commit 的所有代码变更。

## 决策流程

### Step 1: 理解变更语义
阅读 diff 内容，用自然语言回答：
- 这次变更做了什么？
- 为什么要做这个变更？（根据变更内容推断）
- 变更的规模有多大？（小改动/中等修改/大型重构）

### Step 2: 判断文档影响
根据变更语义，判断是否影响文档：

**需要更新 MAP.md 的情况**：
- 新增或删除了顶层目录
- 某个模块的核心职责发生变化
- 典型执行流程发生变化
- 核心概念发生变化

**需要更新 _AI_CONTEXT.md 的情况**：
- 模块内新增/删除/修改了重要的公共接口
- 模块的职责边界发生变化
- 模块的依赖关系发生变化
- 新增了需要特别注意的陷阱或约定

**不需要更新文档的情况**：
- 纯粹的 Bug 修复（不改变接口和行为）
- 代码重构（不改变外部行为）
- 注释或文档的修改
- 测试代码的修改
- 配置文件的小调整

### Step 3: 生成更新内容
如果需要更新文档，生成具体的更新内容：
- 明确指出更新哪个文件的哪个章节
- 提供新的内容（增量更新，不是重写）
- 保留原有的 MANUAL 标记内容

## 输出格式

### 无需更新
```
DECISION: NO_UPDATE
REASON: [简短说明为什么不需要更新]
```

### 需要更新
```
DECISION: UPDATE_REQUIRED

UPDATES:
---
FILE: [文件路径]
SECTION: [章节名]
ACTION: [ADD|MODIFY|DELETE]
CONTENT:
[更新内容]
---
FILE: [另一个文件路径]
...
```

## 重要原则

1. **宁可少更新，不要过度更新**
   - 文档应该精炼，不是事无巨细
   - 只记录对"AI 理解项目"有帮助的信息

2. **以语义理解为主，不要机械匹配**
   - 不要因为看到 `def` 就更新接口文档
   - 要理解这个函数是否是重要的公共接口

3. **保持一致性**
   - 更新风格应与现有文档保持一致
   - 使用相同的术语和格式

4. **尊重人工标记**
   - 永远不要修改 `<!-- MANUAL -->` 和 `<!-- END_MANUAL -->` 之间的内容
```

---

### 工作流程

```
Git pre-commit hook 触发
    ↓
调用 doc-maintainer subagent
    ↓
传入 git diff HEAD 作为输入
    ↓
doc-maintainer AI 分析变更语义
    ↓
AI 根据自然语言规则判断
    ↓
IF 需要更新:
    生成更新内容
    写入对应的 .md 文件
    自动 git add 更新的文档
ELSE:
    记录日志，不做更新
    ↓
继续 commit 流程
```

---

## 增量更新机制

### 区块标记系统

```markdown
<!-- AUTO_SYNC: section-name | updated=2026-02-03 -->\n[自动生成的内容 - 会被系统更新]
<!-- END_AUTO_SYNC -->

<!-- MANUAL: custom-notes -->
[用户手动添加的内容 - 永远不被覆盖]
<!-- END_MANUAL -->
```

### 更新策略
1. **读取现有文档** - 解析所有区块标记
2. **识别更新目标** - AI 判断需要更新的 section
3. **生成新内容** - AI 基于语义理解生成更新
4. **替换 AUTO_SYNC 区块** - 只更新标记为 AUTO_SYNC 的内容
5. **保留 MANUAL 区块** - 完整保留用户手动编辑的内容

---

## 框架初始化指南

> 本章节详细说明如何从零开始为项目建立 AI 上下文框架。

### 初始化概览

```
┌─────────────────────────────────────────────────────────────┐
│                    框架初始化完整流程                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Phase 1: 环境准备                                           │
│  ├── 确认项目满足前置条件                                      │
│  └── 准备必要的工具和权限                                      │
│                        ↓                                    │
│  Phase 2: 核心文件创建（按顺序）                               │
│  ├── Step 1: 创建 docs/AI_CONTEXT/ 目录                     │
│  ├── Step 2: 创建 _RULES.md（AI 行为协议）                   │
│  ├── Step 3: 创建 MAP.md（项目导航）                         │
│  └── Step 4: 创建模块 _AI_CONTEXT.md                        │
│                        ↓                                    │
│  Phase 3: 内容填充                                           │
│  ├── AI 辅助生成初始内容                                      │
│  └── 人工验证和补充                                           │
│                        ↓                                    │
│  Phase 4: 自动化配置                                         │
│  ├── 安装 Git Hook                                          │
│  └── 配置 doc-maintainer                                    │
│                        ↓                                    │
│  Phase 5: 验证与测试                                         │
│  ├── 功能验证                                                │
│  └── AI 理解测试                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Phase 1: 环境准备

#### 前置条件检查

```markdown
## 项目前置条件

### 必须满足
- [ ] 项目使用 Git 进行版本控制
- [ ] 项目有明确的目录结构（不是单文件项目）
- [ ] 有至少一个人了解项目的整体架构

### 建议满足
- [ ] 项目已有基本的开发文档或注释
- [ ] 项目已进入相对稳定的开发阶段
- [ ] 团队成员了解 Markdown 语法

### 不适用的场景
- ❌ 单文件脚本项目
- ❌ 纯配置/数据项目
- ❌ 一次性或临时项目
```

#### 权限检查

```bash
# 检查 Git 仓库
git status
# 应该显示当前在一个 Git 仓库中

# 检查写入权限
touch docs/test_write_permission.txt && rm docs/test_write_permission.txt
# 应该能正常创建和删除文件

# 检查 hooks 目录
ls -la .git/hooks/
# 应该存在 hooks 目录
```

---

### Phase 2: 基于 Subagent 的智能初始化

> 核心思路：利用 AI Subagent 在各个目录层级进行智能分析，结合预定义的生成规范（Skill），自动创建和填充 `_AI_CONTEXT.md` 文件。

#### 初始化架构概览

```
┌─────────────────────────────────────────────────────────────────┐
│                    Subagent 智能初始化架构                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              预定义生成规范 (Skills / Rules)                │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐   │  │
│  │  │ 文档结构模板 │  │ 内容生成规则 │  │ 质量检查标准    │   │  │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘   │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              ↓                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   分层级 Subagent 调用                      │  │
│  │                                                            │  │
│  │   Level 1: 项目根目录分析                                   │  │
│  │   ├── 扫描项目整体结构                                      │  │
│  │   ├── 识别主要模块和关键配置                                │  │
│  │   └── 生成 docs/AI_CONTEXT/MAP.md                          │  │
│  │                    ↓                                        │  │
│  │   Level 2: 模块层分析 (src/, lib/, docs/ 等)               │  │
│  │   ├── 为每个重要目录调用专用 Subagent                       │  │
│  │   ├── 分析目录内的文件结构和代码逻辑                        │  │
│  │   └── 生成 /<模块>/_AI_CONTEXT.md                          │  │
│  │                    ↓                                        │  │
│  │   Level 3: 文件层分析 (关键代码文件)                        │  │
│  │   ├── 对重要文件进行深度分析                                │  │
│  │   ├── 提取函数签名、类定义和注释                            │  │
│  │   └── 补充到对应模块的上下文中                              │  │
│  │                                                            │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              ↓                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    交叉验证和整合                            │  │
│  │  ├── 上层 Subagent 验证下层内容一致性                       │  │
│  │  ├── 建立模块间的关联关系描述                               │  │
│  │  └── 确保整个项目的上下文连贯性                             │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

#### Step 1: 预定义生成规范

在使用 Subagent 初始化之前，需要先建立标准化的生成规范：

##### 文档结构模板 (Skill: ai-context-generator)

```yaml
# skills/ai-context-generator/skill.yaml
name: ai-context-generator
description: 生成标准化的 _AI_CONTEXT.md 文档

templates:
  # 项目级别模板
  project_map:
    sections:
      - name: 快速定位
        required: true
        auto_generate: false
      - name: 项目概览
        required: true
        auto_generate: true
        fields: [description, core_value, tech_stack, scale]
      - name: 模块职责
        required: true
        auto_generate: true
      - name: 关键路径
        required: true
        auto_generate: true
      - name: 核心概念
        required: true
        auto_generate: true
      - name: 重要约定
        required: false
        auto_generate: false
        preserve_manual: true
  
  # 模块级别模板
  module_context:
    sections:
      - name: 职责范围
        required: true
        auto_generate: true
      - name: 文件结构
        required: true
        auto_generate: true
      - name: 关键接口
        required: true
        auto_generate: true
      - name: 依赖关系
        required: true
        auto_generate: true
      - name: 注意事项
        required: false
        auto_generate: false
        preserve_manual: true
```

##### 内容生成规则

```markdown
## 生成规则 (Rules)

### 规则 1: 职责描述生成
- 职责描述应该是一句话，不超过 30 个字
- 使用动词开头，描述"做什么"而非"是什么"
- 避免使用模糊词汇（处理、管理）

### 规则 2: 关键接口提取
- 只提取公共接口（exported / public）
- 按使用频率排序，最常用的放在前面
- 每个接口必须包含：用途、签名、位置、示例

### 规则 3: 依赖关系分析
- 只记录直接依赖，不递归展开
- 区分"依赖"和"被依赖"
- 标注依赖的具体功能点

### 规则 4: 路径分析
- 从入口点开始追踪
- 只记录主干流程，忽略异常分支
- 步骤数控制在 5-8 步

### 规则 5: 质量检查
- 所有 TODO 必须被填充或标记为可选
- 代码引用必须可验证（文件存在、行号有效）
- 概念定义必须与代码一致
```

##### 质量检查标准

```yaml
# 质量检查清单
quality_checklist:
  completeness:
    - "所有 required sections 都已填充"
    - "没有遗留的 [TODO] 标记（除非明确标记为可选）"
    - "所有模块都有对应的 _AI_CONTEXT.md"
  
  accuracy:
    - "文件路径可验证（文件实际存在）"
    - "函数签名与代码一致"
    - "依赖关系与 import 语句一致"
  
  consistency:
    - "MAP.md 中的模块列表与实际目录一致"
    - "模块间引用使用相同的命名"
    - "术语定义在全项目保持一致"
```

---

#### Step 2: 分层级 Subagent 调用

##### Level 1: 项目根目录分析

**Subagent 名称**: `context-initializer-root`

**输入**: 项目根目录路径
**输出**: `docs/AI_CONTEXT/MAP.md` + `docs/AI_CONTEXT/_RULES.md`

**执行流程**:

```
用户触发: "初始化项目的 AI 上下文框架"
    ↓
Subagent 执行:
    ↓
1. 扫描项目整体结构
   ├── 列出所有顶层目录
   ├── 识别配置文件 (package.json, setup.py, go.mod, Cargo.toml 等)
   ├── 读取 README.md（如存在）
   └── 统计项目规模（目录数、文件数）
    ↓
2. 智能分析
   ├── 推断项目类型和技术栈
   ├── 识别入口点和主要模块
   ├── 分析目录命名模式
   └── 提取项目描述和核心价值
    ↓
3. 生成项目级文档
   ├── 创建 docs/AI_CONTEXT/ 目录
   ├── 生成 _RULES.md（使用标准模板）
   ├── 生成 MAP.md 初稿
   │   ├── [项目概览] - 基于分析结果填充
   │   ├── [模块职责] - 列出识别到的模块
   │   ├── [关键路径] - 标记为待分析
   │   └── [核心概念] - 标记为待分析
   └── 输出需要进一步分析的模块列表
    ↓
4. 触发下一层分析
   └── 为每个重要模块调用 Level 2 Subagent
```

**生成的 _RULES.md 标准模板**:

```markdown
# AI Context Rules

> 本文档定义 AI 编程助手在本项目中的行为规范。
> 适用于：Claude、GPT、Gemini、Copilot 等任何 AI 助手。
> 
> ⚠️ 本文件是 AI 的"工作手册"，请勿随意修改。

---

## 新对话启动流程

当开始一个新对话时，AI 必须按以下顺序执行：

### Step 1: 读取导航文件（强制）
```
READ: docs/AI_CONTEXT/MAP.md
```

### Step 2: 快速理解项目（2分钟内）
请在"工作记忆"中记住以下信息：
- 项目一句话描述是什么？
- 有哪些主要模块？各自负责什么？
- 有哪些核心概念？
- 有哪些重要约定必须遵守？

### Step 3: 建立心智模型
在开始任何任务前，确保你能回答：
- 要做 X 功能 → 应该看 Y 模块
- Y 模块位于 Z 目录
- Y 模块的详细文档是 Z/_AI_CONTEXT.md

---

## 任务驱动的文档加载策略

根据用户任务类型，按需加载相关文档：

| 任务类型 | 加载策略 |
|---------|---------|
| 理解现有功能 | MAP.md → 定位模块 → 模块/_AI_CONTEXT.md → 代码文件 |
| 修改现有代码 | MAP.md → 模块/_AI_CONTEXT.md（检查依赖和注意事项）→ 代码文件 |
| 添加新功能 | MAP.md → 判断目标模块 → 模块/_AI_CONTEXT.md（扩展指南）→ 现有代码 |
| 修复 Bug | MAP.md [关键路径] → 相关模块/_AI_CONTEXT.md → 代码文件 |

---

## 文档异常处理

### 文档不存在
```
IF docs/AI_CONTEXT/MAP.md 不存在:
    提示用户: "项目尚未初始化 AI 上下文，建议运行初始化"
    询问: "是否需要我帮助初始化？"
```

### 文档内容与代码不符
```
IF 发现文档描述与实际代码不一致:
    1. 以代码为准完成当前任务
    2. 完成任务后提示用户文档可能过时
    3. 如果用户确认，更新文档
```

### 模块文档缺失
```
IF MAP.md 中某个模块没有对应的 _AI_CONTEXT.md:
    1. 直接阅读该模块的代码
    2. 完成任务
    3. (可选) 提示用户是否需要为该模块生成文档
```

---

## 阅读效率优化

### 分层阅读策略
```
Layer 0: MAP.md [快速定位]              - 必读，<30秒
Layer 1: MAP.md [项目概览] + [模块职责]  - 了解全局，<2分钟
Layer 2: MAP.md [关键路径] + [核心概念]  - 理解运作，<5分钟
Layer 3: 相关 /<模块>/_AI_CONTEXT.md    - 深入细节，按需
Layer 4: 具体代码文件                    - 精确理解，按需
```

### 避免过度阅读
- ❌ 不要一次性阅读所有 _AI_CONTEXT.md
- ✅ 根据任务类型，只读取相关模块的文档
- ❌ 不要阅读代码后再读文档
- ✅ 先读文档建立心智模型，再读代码验证
```

---

##### Level 2: 模块层分析

**Subagent 名称**: `context-initializer-module`

**输入**: 模块目录路径 + 上层分析结果
**输出**: `/<模块>/_AI_CONTEXT.md`

**执行流程**:

```
接收上层调用: analyze_module("/src/payment")
    ↓
Subagent 执行:
    ↓
1. 扫描模块结构
   ├── 列出目录内所有文件
   ├── 识别主要文件和入口文件
   ├── 分析文件命名模式
   └── 统计代码行数
    ↓
2. 深度代码分析
   ├── 解析 import/require 语句 → 提取依赖关系
   ├── 识别 exported/public 接口
   ├── 提取类定义和函数签名
   └── 读取现有注释和文档字符串
    ↓
3. 智能推断
   ├── 基于文件名和代码内容推断模块职责
   ├── 基于调用关系推断关键接口
   ├── 基于导出判断对外暴露的能力
   └── 标记需要人工验证的推断 (⚠️)
    ↓
4. 生成模块级文档
   └── 创建 /<模块>/_AI_CONTEXT.md
       ├── [职责范围] - 填充推断结果
       ├── [文件结构] - 自动生成目录树
       ├── [关键接口] - 填充提取的接口
       ├── [依赖关系] - 填充分析结果
       └── [注意事项] - 保留为 MANUAL 区块
    ↓
5. 返回分析结果
   └── 供上层 Subagent 更新 MAP.md
```

**生成的模块 _AI_CONTEXT.md 示例**:

```markdown
# Module: /src/payment

> 本文档描述 payment 模块的职责、结构和使用方式。
> 最后更新：2026-02-03
> 生成方式：Subagent 自动分析 + 人工验证

---

## 职责范围

<!-- AUTO_SYNC: responsibilities | updated=2026-02-03 -->

**核心职责**:
- 处理用户支付流程（下单、支付、退款）
- 对接第三方支付网关（Stripe、PayPal）
- 管理支付状态和交易记录

**不负责**:
- 用户认证 - 由 /src/auth 负责
- 订单业务逻辑 - 由 /src/order 负责
- 通知发送 - 由 /src/notification 负责

<!-- END_AUTO_SYNC -->

---

## 文件结构

<!-- AUTO_SYNC: file-structure | updated=2026-02-03 -->

```
/src/payment/
├── _AI_CONTEXT.md     - 本文档
├── index.ts           - 模块入口，导出公共接口
├── processor.ts       - 支付处理核心逻辑
├── gateway/
│   ├── stripe.ts      - Stripe 网关适配器
│   └── paypal.ts      - PayPal 网关适配器
├── models/
│   ├── transaction.ts - 交易模型定义
│   └── refund.ts      - 退款模型定义
└── utils/
    └── validator.ts   - 支付参数校验工具
```

<!-- END_AUTO_SYNC -->

---

## 关键接口

<!-- AUTO_SYNC: key-interfaces | updated=2026-02-03 -->

### processPayment
- **用途**: 处理用户支付请求
- **签名**: `processPayment(userId: string, amount: number, gateway: 'stripe' | 'paypal') -> Promise<Transaction>`
- **位置**: processor.ts:45
- **示例**:
  ```typescript
  const transaction = await processPayment('user123', 99.99, 'stripe');
  console.log(transaction.status); // 'completed'
  ```

### refund
- **用途**: 处理退款请求
- **签名**: `refund(transactionId: string, amount?: number) -> Promise<Refund>`
- **位置**: processor.ts:120
- **示例**:
  ```typescript
  // 全额退款
  const refund = await refund('txn_123');
  // 部分退款
  const partialRefund = await refund('txn_123', 50.00);
  ```

### getTransactionStatus
- **用途**: 查询交易状态
- **签名**: `getTransactionStatus(transactionId: string) -> Promise<TransactionStatus>`
- **位置**: processor.ts:180

<!-- END_AUTO_SYNC -->

---

## 依赖关系

<!-- AUTO_SYNC: dependencies | updated=2026-02-03 -->

**依赖的模块**:
- `/src/auth` - 使用其 `validateUser()` 验证用户身份
- `/src/config` - 使用其支付网关配置
- `/src/logger` - 使用其记录交易日志

**被依赖的模块**:
- `/src/order` - 调用本模块的 `processPayment()` 完成订单支付
- `/src/admin` - 调用本模块的 `refund()` 处理退款

**外部依赖**:
- `stripe` - Stripe SDK
- `@paypal/checkout-server-sdk` - PayPal SDK

<!-- END_AUTO_SYNC -->

---

## 注意事项

<!-- MANUAL: notes -->

### 常见陷阱
- ⚠️ [待补充] 请根据实际开发经验补充

### 扩展指南
当需要添加新的支付网关时：
1. 在 `gateway/` 目录下创建新的适配器文件
2. 实现 `PaymentGateway` 接口
3. 在 `processor.ts` 中注册新网关
4. 更新本文档的 [关键接口] 部分

### 特别说明
- 所有支付操作都需要记录日志，用于审计
- 退款操作有 24 小时的冷却期

<!-- END_MANUAL -->
```

---

##### Level 3: 文件层分析（可选深度）

**触发条件**: 
- 模块复杂度高（文件数 > 10 或代码行数 > 1000）
- 用户明确要求深度分析

**Subagent 名称**: `context-initializer-file`

**输入**: 关键文件路径
**输出**: 补充到模块 _AI_CONTEXT.md 的详细接口文档

**执行流程**:

```
接收调用: analyze_file("/src/payment/processor.ts")
    ↓
1. 深度解析文件
   ├── 解析 AST（抽象语法树）
   ├── 提取所有函数定义和签名
   ├── 提取所有类定义和方法
   ├── 提取注释和文档字符串
   └── 分析函数调用关系
    ↓
2. 生成详细文档
   ├── 为每个公共函数生成接口文档
   ├── 为每个类生成类图描述
   └── 生成调用流程图
    ↓
3. 补充到模块文档
   └── 更新 /<模块>/_AI_CONTEXT.md [关键接口]
```

---

#### Step 3: 交叉验证和整合

##### 一致性验证

```
Level 2 分析完成后:
    ↓
1. 收集所有模块的分析结果
    ↓
2. 交叉验证
   ├── 检查依赖关系是否双向一致
   │   例: /auth 说被 /payment 依赖
   │        → 验证 /payment 说依赖 /auth
   │
   ├── 检查术语定义一致性
   │   例: "Transaction" 在所有模块中含义相同
   │
   └── 检查路径引用有效性
       例: MAP.md 中引用的 _AI_CONTEXT.md 都存在
    ↓
3. 整合到 MAP.md
   ├── 更新 [模块职责] - 填充所有模块描述
   ├── 更新 [关键路径] - 基于模块间调用关系生成
   ├── 更新 [核心概念] - 汇总各模块的领域概念
   └── 标记需要人工验证的内容 (⚠️)
    ↓
4. 输出验证报告
   └── 列出发现的不一致和待确认项
```

##### 整合后的 MAP.md 示例

```markdown
# Project Map

> 本文档是项目的"导航地图"，帮助 AI 快速理解项目结构。
> 最后更新：2026-02-03
> 生成方式：Subagent 自动分析

---

## 快速定位

### 我想理解项目整体
→ 阅读本文档的 [项目概览] 部分

### 我想修改某个功能
→ 在 [模块职责] 中找到负责该功能的目录
→ 阅读对应目录下的 _AI_CONTEXT.md

### 我想添加新功能
→ 在 [模块职责] 中判断应该放在哪个模块
→ 阅读该模块的 _AI_CONTEXT.md 了解约定

### 我想理解数据流
→ 阅读 [关键路径] 部分

---

## 项目概览

<!-- AUTO_SYNC: project-overview | updated=2026-02-03 -->

**一句话描述**: 电商平台后端服务，提供订单、支付、用户管理能力

**核心价值**: 为中小型电商提供开箱即用的后端解决方案

**主要技术栈**: TypeScript, Node.js, Express, PostgreSQL, Redis

**项目规模**:
- 主要目录数: ~8
- 核心模块数: ~5
- 代码行数: ~15,000

<!-- END_AUTO_SYNC -->

---

## 模块职责

<!-- AUTO_SYNC: module-responsibilities | updated=2026-02-03 -->

### /src/auth
**职责**: 处理用户认证、会话管理和权限控制
**关键能力**:
- 用户登录/注册
- JWT Token 管理
- 权限验证中间件
**详细文档**: [_AI_CONTEXT.md](/src/auth/_AI_CONTEXT.md)

### /src/payment
**职责**: 处理支付流程和第三方支付网关对接
**关键能力**:
- 支付处理
- 退款管理
- 交易记录
**详细文档**: [_AI_CONTEXT.md](/src/payment/_AI_CONTEXT.md)

### /src/order
**职责**: 管理订单生命周期和业务逻辑
**关键能力**:
- 订单创建和更新
- 订单状态流转
- 订单查询
**详细文档**: [_AI_CONTEXT.md](/src/order/_AI_CONTEXT.md)

### /src/notification
**职责**: 处理消息通知发送（邮件、短信、推送）
**关键能力**:
- 多渠道通知
- 模板管理
- 发送队列
**详细文档**: [_AI_CONTEXT.md](/src/notification/_AI_CONTEXT.md)

### /src/common
**职责**: 提供跨模块共享的工具和基础设施
**关键能力**:
- 日志记录
- 错误处理
- 配置管理
**详细文档**: [_AI_CONTEXT.md](/src/common/_AI_CONTEXT.md)

<!-- END_AUTO_SYNC -->

---

## 关键路径

<!-- AUTO_SYNC: key-paths | updated=2026-02-03 -->

### 路径1: 用户下单支付流程
```
1. 用户提交订单 → /src/order/service.ts:createOrder()
2. 验证用户身份 → /src/auth/middleware.ts:authenticate()
3. 创建订单记录 → /src/order/repository.ts:save()
4. 调用支付处理 → /src/payment/processor.ts:processPayment()
5. 更新订单状态 → /src/order/service.ts:updateStatus()
6. 发送确认通知 → /src/notification/sender.ts:send()
```

### 路径2: 用户登录流程
```
1. 用户提交凭证 → /src/auth/controller.ts:login()
2. 验证密码 → /src/auth/service.ts:validateCredentials()
3. 生成 Token → /src/auth/jwt.ts:generateToken()
4. 返回登录结果
```

<!-- END_AUTO_SYNC -->

---

## 核心概念

<!-- AUTO_SYNC: core-concepts | updated=2026-02-03 -->

- **Order**: 订单实体，包含商品、用户、金额等信息 - /src/order/models/order.ts
- **Transaction**: 支付交易记录 - /src/payment/models/transaction.ts
- **User**: 用户实体 - /src/auth/models/user.ts
- **Notification**: 通知消息 - /src/notification/models/notification.ts

**概念关系**:
- 一个 User 可以有多个 Order
- 一个 Order 对应一个 Transaction
- 一个 Order 状态变更会触发 Notification

<!-- END_AUTO_SYNC -->

---

## 重要约定

<!-- MANUAL: conventions -->

### 架构约定
- ⚠️ [待补充] 请根据项目实际情况补充

### 编码约定
- ⚠️ [待补充] 请根据项目实际情况补充

### 命名约定
- ⚠️ [待补充] 请根据项目实际情况补充

<!-- END_MANUAL -->
```

---

#### 智能初始化 Subagent 调用示例

##### 触发方式

用户可以通过以下方式触发初始化：

```markdown
# 方式 1: 直接对话
用户: "帮我初始化这个项目的 AI 上下文框架"

# 方式 2: 使用 Skill
用户: "使用 ai-context-generator skill 初始化项目"

# 方式 3: 命令行（如果集成到 CLI）
$ ai-context init
```

##### Subagent 调用链

```
用户触发初始化
    ↓
AI 主体识别意图，调用 context-initializer-root
    ↓
context-initializer-root 执行:
    ├── 扫描项目结构
    ├── 生成 docs/AI_CONTEXT/_RULES.md
    ├── 生成 docs/AI_CONTEXT/MAP.md (初稿)
    └── 识别需要分析的模块列表: [/src/auth, /src/payment, /src/order, ...]
    ↓
对每个模块，调用 context-initializer-module
    ├── context-initializer-module("/src/auth")
    │   └── 生成 /src/auth/_AI_CONTEXT.md
    ├── context-initializer-module("/src/payment")
    │   └── 生成 /src/payment/_AI_CONTEXT.md
    └── ... (并行执行)
    ↓
所有模块分析完成后，执行交叉验证
    ├── 检查一致性
    ├── 整合 MAP.md
    └── 生成验证报告
    ↓
输出给用户:
    "✅ AI 上下文框架初始化完成！
     
     已生成文件:
     - docs/AI_CONTEXT/_RULES.md
     - docs/AI_CONTEXT/MAP.md
     - /src/auth/_AI_CONTEXT.md
     - /src/payment/_AI_CONTEXT.md
     - /src/order/_AI_CONTEXT.md
     - ...
     
     ⚠️ 以下内容需要人工验证:
     - MAP.md [重要约定] 部分为空，建议补充
     - /src/payment/_AI_CONTEXT.md [注意事项] 部分为空，建议补充
     
     建议下一步:
     1. 快速浏览 MAP.md 确认模块职责描述准确
     2. 为核心模块补充 [注意事项]
     3. 运行一次 AI 理解测试验证效果"
```

---

### Phase 4: 自动化配置

#### 安装 Git Hook

**创建 pre-commit 脚本**:

```bash
#!/bin/bash
# 文件路径: .git/hooks/pre-commit
# 权限: chmod +x .git/hooks/pre-commit

# ===== AI Context 自动维护 Hook =====

# 配置
AI_CONTEXT_DIR="docs/AI_CONTEXT"
DOC_MAINTAINER_SCRIPT="scripts/doc_maintainer.py"

# 检测是否有代码变更（排除文档变更）
CODE_CHANGES=$(git diff --cached --name-only | grep -v "^${AI_CONTEXT_DIR}/" | grep -v "_AI_CONTEXT.md$")

if [ -z "$CODE_CHANGES" ]; then
    echo "ℹ️  [AI-Context] 仅文档变更，跳过文档维护"
    exit 0
fi

echo "🔍 [AI-Context] 检测到代码变更，分析文档更新需求..."

# 检查 doc-maintainer 脚本是否存在
if [ ! -f "$DOC_MAINTAINER_SCRIPT" ]; then
    echo "⚠️  [AI-Context] doc-maintainer 脚本不存在，跳过自动维护"
    exit 0
fi

# 调用 doc-maintainer
if python3 "$DOC_MAINTAINER_SCRIPT"; then
    # 检查是否有文档更新
    DOC_CHANGES=$(git diff "${AI_CONTEXT_DIR}/" 2>/dev/null)
    MODULE_DOC_CHANGES=$(find . -name "_AI_CONTEXT.md" -exec git diff {} \; 2>/dev/null)
    
    if [ -n "$DOC_CHANGES" ] || [ -n "$MODULE_DOC_CHANGES" ]; then
        echo "✅ [AI-Context] 文档已更新，自动添加到本次提交"
        git add "${AI_CONTEXT_DIR}/"
        find . -name "_AI_CONTEXT.md" -exec git add {} \;
    else
        echo "ℹ️  [AI-Context] 文档无需更新"
    fi
else
    echo "⚠️  [AI-Context] 文档更新失败，但不阻断提交"
    echo "    建议稍后手动检查文档同步"
fi

exit 0
```

**安装命令**:

```bash
# 创建 hook 文件
cat > .git/hooks/pre-commit << 'EOF'
# [粘贴上面的脚本内容]
EOF

# 添加执行权限
chmod +x .git/hooks/pre-commit

# 验证安装
ls -la .git/hooks/pre-commit
```

#### 配置 doc-maintainer

**创建配置文件** (可选):

```yaml
# 文件路径: .ai-context.yml

# doc-maintainer 配置
doc_maintainer:
  # 是否启用自动维护
  enabled: true
  
  # 需要忽略的目录
  ignore_dirs:
    - node_modules
    - __pycache__
    - .git
    - dist
    - build
    - coverage
  
  # 需要忽略的文件模式
  ignore_patterns:
    - "*.min.js"
    - "*.map"
    - "*.lock"
  
  # 需要创建 _AI_CONTEXT.md 的最小文件数阈值
  min_files_for_context: 3
  
  # 日志级别
  log_level: info
```

---

### Phase 5: 验证与测试

#### 功能验证清单

```markdown
## 初始化验证清单

### 文件结构验证
- [ ] docs/AI_CONTEXT/_RULES.md 存在且内容完整
- [ ] docs/AI_CONTEXT/MAP.md 存在且包含基本结构
- [ ] 至少一个模块有 _AI_CONTEXT.md
- [ ] 所有文件使用 UTF-8 编码

### Git Hook 验证
- [ ] .git/hooks/pre-commit 存在
- [ ] .git/hooks/pre-commit 有执行权限
- [ ] 执行测试提交时 hook 正常触发

### 内容验证
- [ ] MAP.md [项目概览] 描述准确
- [ ] MAP.md [模块职责] 覆盖主要目录
- [ ] _AI_CONTEXT.md 职责描述与代码一致
```

#### AI 理解测试

创建测试提示词，验证 AI 是否能正确理解项目：

```markdown
## AI 理解测试提示词

请阅读 docs/AI_CONTEXT/ 目录下的文档，然后回答以下问题：

### 基础理解测试
1. 用一句话描述这个项目是做什么的？
2. 项目有几个主要模块？分别叫什么？
3. 如果我想修改登录功能，应该看哪个目录的代码？

### 深度理解测试
4. 描述一下用户登录的完整执行流程
5. [核心概念A] 和 [核心概念B] 是什么关系？
6. 如果我要添加一个新的 API 接口，应该遵循什么约定？

### 实践测试
7. 请帮我在 [模块X] 中添加一个 [功能Y]

---

预期结果：
- 问题 1-3：AI 应该能准确回答，无需查看代码
- 问题 4-6：AI 应该能基本准确回答，可能需要查看少量代码验证
- 问题 7：AI 应该能找到正确的位置，遵循项目约定实现
```

#### 验证成功标准

| 指标 | 成功标准 | 验证方法 |
|------|----------|----------|
| 文档完整性 | 核心文件全部存在 | 检查文件是否存在 |
| 内容准确性 | 关键信息准确率 > 90% | 人工抽检 |
| AI 理解度 | 基础问题正确率 100% | AI 测试提示词 |
| Hook 可用性 | 提交时正常触发 | 测试提交 |

---

### 最佳实践建议

#### 初始化阶段

1. **先完成核心文档，再逐步完善**
   ```
   第一天：完成 _RULES.md + MAP.md 骨架
   第一周：完成 3-5 个核心模块的 _AI_CONTEXT.md
   持续：随开发逐步补充其他模块
   ```

2. **让了解项目的人参与验证**
   - AI 生成的内容需要人工验证
   - 特别是 [职责范围] 和 [关键路径]

3. **不要追求完美**
   - 初始内容 70% 准确即可
   - 在使用中逐步修正和完善

#### 内容编写

1. **职责描述要聚焦**
   - ✅ "处理用户认证和会话管理"
   - ❌ "包含各种和用户登录相关的代码"

2. **关键接口要有示例**
   - 示例代码比文字描述更清晰
   - 保持示例简洁、可运行

3. **善用 MANUAL 标记**
   - 对于 AI 难以准确理解的约定
   - 对于团队特有的"潜规则"

#### 维护阶段

1. **定期检查文档同步**
   ```bash
   # 每周检查命令
   git log --oneline --since="1 week ago" -- "*.py" "*.js" "*.ts" | head -20
   # 对照检查相关的 _AI_CONTEXT.md 是否需要更新
   ```

2. **重大重构后手动验证**
   - 自动维护可能无法完全捕获大型重构
   - 重构后花 10 分钟检查文档

3. **新成员入职测试**
   - 让新成员通过 AI 理解项目
   - 记录 AI 回答不准确的地方
   - 用于改进文档

---

### 常见问题解答

#### Q: 初始化需要多长时间？

| 项目规模 | 预计时间 |
|----------|----------|
| 小型项目（< 10 个文件） | 30 分钟 |
| 中型项目（10-50 个文件） | 1-2 小时 |
| 大型项目（> 50 个文件） | 2-4 小时 |

#### Q: 哪些目录需要创建 _AI_CONTEXT.md？

**需要创建**:
- 核心业务逻辑目录
- 被多个模块依赖的基础设施目录
- 包含复杂逻辑的目录
- 有特殊约定的目录

**不需要创建**:
- 纯配置文件目录
- 静态资源目录
- 测试数据目录
- 第三方代码目录

#### Q: 如何处理已有的 README.md？

两种策略：
1. **共存**：README 面向人类，_AI_CONTEXT.md 面向 AI，内容可以有重叠
2. **引用**：在 _AI_CONTEXT.md 中引用 README 的某些章节，避免重复

#### Q: 多人协作时如何避免冲突？

1. 使用 AUTO_SYNC 标记让系统自动管理
2. MANUAL 区域的修改应该先沟通
3. 将 _AI_CONTEXT.md 纳入 Code Review

---

## Git Hook 实现

### pre-commit 脚本

```bash
#!/bin/bash
# .git/hooks/pre-commit

# 检测是否有代码变更（排除文档变更）
CODE_CHANGES=$(git diff --cached --name-only | grep -v "^docs/AI_CONTEXT/" | grep -v "_AI_CONTEXT.md$")

if [ -n "$CODE_CHANGES" ]; then
    echo "🔍 检测代码变更，分析文档更新..."

    # 调用 doc-maintainer subagent
    python3 scripts/doc_maintainer.py

    # 检查是否有文档更新
    DOC_CHANGES=$(git diff docs/AI_CONTEXT/ 2>/dev/null; find . -name "_AI_CONTEXT.md" -exec git diff {} \; 2>/dev/null)
    
    if [ -n "$DOC_CHANGES" ]; then
        echo "✅ 文档已更新，自动添加到本次提交"
        git add docs/AI_CONTEXT/
        find . -name "_AI_CONTEXT.md" -exec git add {} \;
    else
        echo "ℹ️  文档无需更新"
    fi
else
    echo "ℹ️  仅文档变更，跳过文档维护"
fi

exit 0
```

### 错误处理

```bash
# 如果 doc-maintainer 失败
if ! python3 scripts/doc_maintainer.py; then
    echo "⚠️  文档更新失败，但不阻断提交"
    echo "    建议稍后手动检查文档同步"
    exit 0  # 不阻断提交
fi
```

---
## 质量保证

### 文档质量指标

#### 完整性
- [ ] `_RULES.md` 包含完整的 AI 行为协议
- [ ] `MAP.md` 所有章节都有实质内容
- [ ] 所有重要模块都有 `_AI_CONTEXT.md`

#### 准确性
- [ ] 模块职责描述与代码一致
- [ ] 关键路径的执行流程与代码一致
- [ ] 关键接口的签名与代码一致

#### 可用性
- [ ] 新 AI 对话能在 5 分钟内理解项目
- [ ] AI 能正确回答"功能 X 在哪实现？"
- [ ] AI 能正确判断"新功能 Y 应该加在哪？"

---

## 技术约束

### 开发约束
- **Python 版本**: 3.6+（仅使用标准库）
- **跨平台**: macOS/Linux/Windows
- **性能**: Git hook 执行应在 5 秒内完成

### 文档约束
- **格式**: Markdown
- **大小**: MAP.md < 20KB，_AI_CONTEXT.md < 10KB
- **命名**: `_AI_CONTEXT.md`（下划线前缀，便于排序）

### Git 约束
- **非侵入**: 文档更新失败不应阻断 commit
- **原子性**: 文档更新应与代码变更在同一 commit
- **可选**: 可通过配置禁用自动更新
