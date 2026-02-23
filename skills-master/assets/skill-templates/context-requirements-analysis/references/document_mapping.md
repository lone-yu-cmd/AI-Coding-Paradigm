# AI Context 文档映射指南

> 本文档为 AI 提供在不同开发场景下应该阅读哪些 AI_CONTEXT 文档的详细映射规则。

---

## 核心原则

**本技能是规划技能，不是实施技能**

工作流程：
1. 📖 **读取** AI_CONTEXT 文档（了解上下文）
2. 📝 **创建** 需求分析文档
3. ✅ **确认** 等待用户确认
4. 🔨 **实施** 按计划执行代码变更
5. 📚 **更新** AI_CONTEXT 文档（保持同步）

---

## 文档索引

### 核心入门文档

| 文档 | 路径 | 用途 | 优先级 |
|-----|------|------|-------|
| 快速上手 | `docs/AI_CONTEXT/QUICK_START.md` | 新 AI 会话入口，5 分钟了解项目 | 🔴 必读 |
| 项目地图 | `docs/AI_CONTEXT/MAP.md` | 项目全貌导航 | 🔴 必读 |
| 行为规范 | `docs/AI_CONTEXT/_RULES.md` | AI 开发约束 | 🔴 必读 |

### 架构与设计文档

| 文档 | 路径 | 用途 | 优先级 |
|-----|------|------|-------|
| Core 架构 | `docs/AI_CONTEXT/CORE_ARCHITECTURE.md` | 适配器模式、平台注入 | 🟡 重要 |
| 总体架构 | `docs/AI_CONTEXT/ARCHITECTURE.md` | 系统级架构设计 | 🟡 重要 |
| 宪章文档 | `docs/AI_CONTEXT/CONSTITUTION.md` | 设计原则与决策记录 | 🟢 推荐 |

### 模块详解文档

| 文档 | 路径 | 用途 | 优先级 |
|-----|------|------|-------|
| Core Hooks | `docs/AI_CONTEXT/CORE_HOOKS.md` | 业务逻辑 Hooks 详解 | 🟡 重要 |
| Core Utils | `docs/AI_CONTEXT/CORE_UTILS.md` | 工具函数库 | 🟡 重要 |
| Extension 适配器 | `docs/AI_CONTEXT/EXTENSION_ADAPTERS.md` | 浏览器扩展适配层 | 🟢 推荐 |
| Extension 入口点 | `docs/AI_CONTEXT/EXTENSION_ENTRYPOINTS.md` | 扩展各入口点说明 | 🟢 推荐 |
| Extension 架构 | `docs/AI_CONTEXT/EXTENSION_ARCHITECTURE.md` | 扩展专属架构 | 🟢 推荐 |

### 数据与业务文档

| 文档 | 路径 | 用途 | 优先级 |
|-----|------|------|-------|
| 数据模型 | `docs/AI_CONTEXT/DATA_MODEL.md` | 核心数据结构、存储策略、同步机制 | 🔴 必读 |
| 业务流程 | `docs/AI_CONTEXT/BUSINESS_FLOWS.md` | 认证、同步、优化等核心流程详解 | 🟡 重要 |

### 开发规范文档

| 文档 | 路径 | 用途 | 优先级 |
|-----|------|------|-------|
| 开发指南 | `docs/AI_CONTEXT/DEVELOPMENT_GUIDE.md` | 技术栈、规范、最佳实践 | 🟡 重要 |

### 功能索引文档

| 文档 | 路径 | 用途 | 优先级 |
|-----|------|------|-------|
| 功能索引 | `docs/AI_CONTEXT/FEATURE_INDEX.md` | 快速查找功能对应代码 | 🟢 推荐 |

---

## 场景化文档阅读策略

### 场景 1: 新 AI 会话开始

**触发条件**：
- 用户启动新的 AI 对话
- AI 需要快速了解项目全貌

**必读文档**（按顺序）：
1. ✅ `QUICK_START.md` - 5 分钟快速了解项目定位、结构、核心概念
2. ✅ `MAP.md` - 了解项目全貌、模块职责、关键路径
3. ✅ `_RULES.md` - 理解 AI 开发约束与禁止事项

**后续动作**：
- 向用户确认已理解项目结构
- 询问用户具体需求场景
- 如果用户提供开发任务 → 进入对应的开发场景

**不需要创建需求文档**

---

### 场景 2: 开发新功能

**触发条件**：
- 用户请求"添加新功能"
- 用户描述新的业务需求
- 用户需要创建新的 UI 组件或业务逻辑

#### Step 1: 读取 AI_CONTEXT 文档

**必读文档**（按顺序）：
1. ✅ `FEATURE_INDEX.md` - 查找是否有类似功能，避免重复造轮子
2. ✅ `DATA_MODEL.md` - 理解数据结构，确定新功能需要的数据字段
3. ✅ `BUSINESS_FLOWS.md` - 了解相关业务流程，确保新功能符合现有逻辑
4. ✅ `DEVELOPMENT_GUIDE.md` - 遵循开发规范（Atomic Design、Hooks 规范等）

**推荐文档**（按模块）：
- Core 层 → `CORE_ARCHITECTURE.md`, `CORE_HOOKS.md`, `CORE_UTILS.md`
- 扩展 → `EXTENSION_ARCHITECTURE.md`, `EXTENSION_ADAPTERS.md`, `EXTENSION_ENTRYPOINTS.md`
- 认证相关 → `BUSINESS_FLOWS.md` 的"用户认证流程"章节
- 同步相关 → `BUSINESS_FLOWS.md` 的"数据同步流程"章节

#### Step 2: 创建需求分析文档

使用标准需求分析工作流：

1. 创建 `.requirementsAnalysis` 文件夹
2. 更新 `.gitignore`
3. 创建需求目录（如 `001-new-feature/`）
4. 创建增强版 `requirements.md`

**增强内容**：
- 需求背景要引用 AI_CONTEXT 文档的发现
- 实施计划要参考架构和规范文档
- 添加"AI_CONTEXT 文档更新计划"章节

#### Step 3: 等待用户确认

**必须等待用户明确回复！**

确认内容：
1. 需求背景是否准确？
2. 功能点清单是否完整？
3. 代码实施计划是否合理？
4. AI_CONTEXT 文档更新计划是否遗漏？

#### Step 4: 实施开发

**用户确认后才能开始**

1. 按照需求文档中的实施步骤执行
2. 每完成一个功能点，在文档中勾选
3. 遇到问题时更新文档

#### Step 5: 更新 AI_CONTEXT 文档

**必须更新**：
- ✅ `FEATURE_INDEX.md` - 添加新功能的代码位置

**按需更新**：
- ⚠️ `DATA_MODEL.md` - 如果新增了数据字段
- ⚠️ `BUSINESS_FLOWS.md` - 如果新增了业务流程

---

### 场景 3: 修复 Bug

**触发条件**：
- 用户报告 Bug
- 功能异常或逻辑错误
- 数据同步/存储问题

#### Step 1: 读取 AI_CONTEXT 文档

**必读文档**（按顺序）：
1. ✅ `FEATURE_INDEX.md` - 快速定位问题代码位置
2. ✅ `BUSINESS_FLOWS.md` - 理解完整业务流程，找出哪个环节出错
3. ✅ `DATA_MODEL.md` - 检查数据结构与存储策略是否正确

**推荐文档**（按问题类型）：
- UI 问题 → `CORE_ARCHITECTURE.md`, `EXTENSION_ENTRYPOINTS.md`
- 数据同步问题 → `BUSINESS_FLOWS.md` 的"数据同步流程"章节
- 认证问题 → `BUSINESS_FLOWS.md` 的"用户认证流程"章节
- 架构问题 → `CORE_ARCHITECTURE.md`, `CONSTITUTION.md`

#### Step 2: 创建需求分析文档

包含：
- Bug 描述和复现步骤
- 根因分析（基于 BUSINESS_FLOWS.md 的流程理解）
- 修复方案

#### Step 3: 等待用户确认

#### Step 4: 实施修复

#### Step 5: 更新 AI_CONTEXT 文档

**按需更新**：
- ⚠️ `BUSINESS_FLOWS.md` - 如果发现了边界情况
- ⚠️ `_RULES.md` - 如果 Bug 是由违反规范导致

---

### 场景 4: 重构代码

**触发条件**：
- 用户请求"优化代码结构"
- 代码可维护性差，需要重构
- 架构演进需要调整

#### Step 1: 读取 AI_CONTEXT 文档

**必读文档**（按顺序）：
1. ✅ `CORE_ARCHITECTURE.md` - 理解设计原则，确保重构符合架构约定
2. ✅ `CONSTITUTION.md` - 了解历史决策记录，避免重复错误
3. ✅ `DEVELOPMENT_GUIDE.md` - 遵循开发规范进行重构
4. ✅ `DATA_MODEL.md` - 确保重构不破坏数据结构

**推荐文档**（按重构范围）：
- Core 层 → `CORE_HOOKS.md`, `CORE_UTILS.md`
- 扩展层 → `EXTENSION_ARCHITECTURE.md`, `EXTENSION_ADAPTERS.md`
- 业务流程 → `BUSINESS_FLOWS.md`

#### Step 2: 创建需求分析文档

包含：
- 重构原因和目标
- 方案对比（旧方案 vs 新方案）
- 影响范围分析
- 回滚计划

#### Step 3: 等待用户确认

#### Step 4: 实施重构

#### Step 5: 更新 AI_CONTEXT 文档

**必须更新**：
- ✅ `CONSTITUTION.md` - 记录重构决策（ADR）

**按需更新**：
- ⚠️ `CORE_ARCHITECTURE.md` - 如果架构发生变更
- ⚠️ `FEATURE_INDEX.md` - 如果文件路径变化
- ⚠️ `DEVELOPMENT_GUIDE.md` - 如果发现新的最佳实践

---

## 需求文档模板

### 增强版 requirements.md 模板

```markdown
# {需求名称}

## 需求背景

### 项目上下文
{基于 QUICK_START.md 和 MAP.md 的项目概述}

### 现有相关功能
{基于 FEATURE_INDEX.md 的相关功能分析}

### 相关业务流程
{基于 BUSINESS_FLOWS.md 的流程分析}

### 数据模型约束
{基于 DATA_MODEL.md 的数据结构分析}

## 需求内容

{详细描述需求的具体内容、功能点、业务规则等}

### 功能点清单

- [ ] 功能点 1
- [ ] 功能点 2
- [ ] ...

## 代码实施计划

### 涉及模块
{参考 CORE_ARCHITECTURE.md}

### 开发规范
{参考 DEVELOPMENT_GUIDE.md}

### 改动文件清单

| 文件路径 | 改动类型 | 改动说明 | 参考文档 |
|---------|---------|---------|---------|
| path/to/file | 新增/修改 | 说明 | AI_CONTEXT 参考 |

### 实施步骤

1. 步骤 1
2. 步骤 2
3. ...

## AI_CONTEXT 文档更新计划

| 文档 | 更新内容 | 优先级 |
|-----|---------|-------|
| FEATURE_INDEX.md | 添加新功能索引 | 🔴 高 |
| DATA_MODEL.md | 更新数据结构 | 🟡 中 |
| BUSINESS_FLOWS.md | 补充业务流程 | 🟡 中 |
| CONSTITUTION.md | 记录重要决策 | 🟢 中 |
```

---

## 文档更新模板

### FEATURE_INDEX.md 更新模板

```markdown
### [功能类别]

| 功能 | 代码位置 | 说明 | 最后更新 |
|-----|---------|------|---------|
| [新功能名称] | `packages/core/src/hooks/useNewFeature.ts` | [功能描述] | YYYY-MM-DD |
| [新功能组件] | `packages/core/src/customComponents/Features/NewFeature/` | [组件说明] | YYYY-MM-DD |
```

### DATA_MODEL.md 更新模板

```markdown
#### [新数据类型]

\`\`\`typescript
interface NewDataType {
  id: string;
  // 字段定义
}
\`\`\`

**用途**: [数据类型用途]

**存储位置**: [存储在哪里]

**关联关系**: [与其他数据的关系]
```

### BUSINESS_FLOWS.md 更新模板

```markdown
### [流程名称]

#### 触发条件
- [条件 1]
- [条件 2]

#### 执行步骤
1. **[步骤 1]**: [描述]
2. **[步骤 2]**: [描述]

#### 边界情况
- **边界 1**: [处理方案]
- **边界 2**: [处理方案]
```

### CONSTITUTION.md 更新模板（ADR）

```markdown
#### ADR-[编号]: [决策标题]

**日期**: YYYY-MM-DD
**状态**: 已采纳/已废弃/已替代
**决策者**: AI + 用户

**背景**:
[为什么需要做这个决策]

**决策**:
[具体决策内容]

**理由**:
- [理由 1]
- [理由 2]

**影响**:
- [影响范围 1]
- [影响范围 2]
```

---

## 文档更新优先级速查

| 场景 | 🔴 必须更新 | 🟡 按需更新 |
|-----|-----------|-----------|
| 功能开发 | FEATURE_INDEX.md | DATA_MODEL.md, BUSINESS_FLOWS.md |
| Bug 修复 | - | BUSINESS_FLOWS.md, _RULES.md |
| 代码重构 | CONSTITUTION.md | CORE_ARCHITECTURE.md, FEATURE_INDEX.md, DEVELOPMENT_GUIDE.md |

---

## 常见问题

### Q1: 什么时候需要创建需求文档？

**A**: 任何涉及代码变更的开发任务都应该创建需求文档：
- ✅ 新功能开发 → 创建需求文档
- ✅ Bug 修复 → 创建需求文档
- ✅ 代码重构 → 创建需求文档
- ❌ 新 AI 会话（仅了解项目）→ 不需要

### Q2: 用户不确认怎么办？

**A**: **必须等待用户明确确认**！
- 不要假设用户已确认
- 不要在用户未回复时开始实施
- 如果用户要求修改，更新需求文档后再次确认

### Q3: 需求文档和 AI_CONTEXT 文档的关系？

**A**: 
- **需求文档** = 具体任务的详细计划（存放在 `.requirementsAnalysis/`）
- **AI_CONTEXT 文档** = 项目级别的持久文档（存放在 `docs/AI_CONTEXT/`）
- 需求文档**引用** AI_CONTEXT 文档来了解上下文
- 完成后**更新** AI_CONTEXT 文档来保持同步

### Q4: 工作流程是怎样的？

**A**: 本技能采用完整的需求分析流程：
1. 先读取 AI_CONTEXT 文档（理解上下文）
2. 创建需求文档（标准工作流）
3. 需求文档内容增强（包含 AI_CONTEXT 洞察）
4. 完成后更新 AI_CONTEXT 文档（保持同步）

---

> 📅 最后更新：2026-02-05  
> 🎯 用途：指导 AI 在不同场景下阅读文档和创建规划  
> 🔑 关键词：规划导向、等待确认、文档同步
