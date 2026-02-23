---
name: context-requirements-analysis
description: Context-aware requirements analysis skill. Automatically triggered when users request "to complete specific requirements by reading existing AI documents or AI_CONTEXT documentation". The skill intelligently identifies scenario types (new AI session, develop new feature, fix bug, refactor code), reads relevant documentation, executes requirements, and updates documentation accordingly.
---

# AI Context Requirements Analysis

## Overview

This skill is a **planning-focused** skill that combines AI_CONTEXT documentation reading with requirements analysis. It does NOT directly implement code changes, but instead:

1. **Reads AI_CONTEXT documents** to understand project context
2. **Creates a requirements analysis plan** (using standard requirements workflow)
3. **Prepares documentation update plan** for post-implementation

After planning is complete and confirmed by user, the actual implementation begins.

## When to Use This Skill

Invoke this skill when the user expresses ANY of the following:

**Explicit Triggers**:
- "通过阅读 AI 文档完成..."
- "基于 AI_CONTEXT 文档完成..."
- "参考项目文档来..."
- "阅读项目上下文后..."
- "Read AI context and then..."
- "Based on the AI documentation..."

**Implicit Triggers**:
- User starts a new AI conversation (new session scenario)
- User requests to add/develop new features (feature development scenario)
- User reports bugs or functional issues (bug fixing scenario)
- User requests code refactoring/optimization (refactoring scenario)

**Do NOT use this skill for**:
- Simple code formatting or style adjustments
- Answering general programming questions
- Tasks that don't require project context understanding

---

## Workflow Decision Tree

```
User Request
     │
     ├─ New AI session?  → [Scenario 1: New AI Session] → No detailed requirements analysis needed
     │
     └─ Development task? → [Step 1: Read AI_CONTEXT Documents]
                                    │
                                    ↓
                           [Step 2: Identify Scenario Type]
                                    │
                           ┌────────┼────────┐
                           ↓        ↓        ↓
                      Feature   Bug Fix   Refactor
                           │        │        │
                           └────────┴────────┘
                                    │
                                    ↓
                           [Step 3: Create Requirements Analysis Document]
                                    │
                                    ↓
                           [Step 4: User Confirmation]
                                    │
                                    ↓
                           [Step 5: Implementation]
                                    │
                                    ↓
                           [Step 6: Update AI_CONTEXT Documents]
```

---

## Scenario 1: New AI Session

**Trigger Conditions**:
- User starts a new AI conversation
- User asks "help me understand the project"
- First interaction in a new chat session

### Required Documents (Read in Order)

Read these documents using the `read_file` tool:

1. ✅ **QUICK_START.md**
   - Path: `docs/AI_CONTEXT/QUICK_START.md`
   - Purpose: 5-minute project overview

2. ✅ **MAP.md**
   - Path: `docs/AI_CONTEXT/MAP.md`
   - Purpose: Project navigation map

3. ✅ **_RULES.md**
   - Path: `docs/AI_CONTEXT/_RULES.md`
   - Purpose: AI development constraints

### Execution Steps

1. **Read Required Documents**: Load the 3 required documents above
2. **Analyze Project Context**: Extract key information
3. **Confirm Understanding**: Report to user
4. **Ask for Requirements**: Prompt user for specific requirements
5. **Transition**: If user provides a development task, continue to Step 1 of Development Workflow

### Documentation Update

❌ **No documentation update required** for new session scenario.

---

## Development Workflow (Feature / Bug Fix / Refactor)

### Step 1: Read AI_CONTEXT Documents

Based on the identified scenario type, read the appropriate AI_CONTEXT documents:

#### For Feature Development:

| Order | Document | Path | Purpose |
|-------|----------|------|---------|
| 1 | FEATURE_INDEX.md | `docs/AI_CONTEXT/FEATURE_INDEX.md` | Check existing features |
| 2 | DATA_MODEL.md | `docs/AI_CONTEXT/DATA_MODEL.md` | Understand data structures |
| 3 | BUSINESS_FLOWS.md | `docs/AI_CONTEXT/BUSINESS_FLOWS.md` | Understand business processes |
| 4 | DEVELOPMENT_GUIDE.md | `docs/AI_CONTEXT/DEVELOPMENT_GUIDE.md` | Development conventions |

#### For Bug Fixing:

| Order | Document | Path | Purpose |
|-------|----------|------|---------|
| 1 | FEATURE_INDEX.md | `docs/AI_CONTEXT/FEATURE_INDEX.md` | Locate problem code |
| 2 | BUSINESS_FLOWS.md | `docs/AI_CONTEXT/BUSINESS_FLOWS.md` | Understand complete flow |
| 3 | DATA_MODEL.md | `docs/AI_CONTEXT/DATA_MODEL.md` | Verify data structure |

#### For Code Refactoring:

| Order | Document | Path | Purpose |
|-------|----------|------|---------|
| 1 | CORE_ARCHITECTURE.md | `docs/AI_CONTEXT/CORE_ARCHITECTURE.md` | Design principles |
| 2 | CONSTITUTION.md | `docs/AI_CONTEXT/CONSTITUTION.md` | Historical decisions |
| 3 | DEVELOPMENT_GUIDE.md | `docs/AI_CONTEXT/DEVELOPMENT_GUIDE.md` | Development conventions |
| 4 | DATA_MODEL.md | `docs/AI_CONTEXT/DATA_MODEL.md` | Data structure constraints |

---

### Step 2: Create Requirements Analysis Document

**IMPORTANT**: This step follows the standard requirements analysis workflow.

#### 2.1 Check/Create `.requirementsAnalysis` Folder

```bash
ls -la .requirementsAnalysis 2>/dev/null || mkdir -p .requirementsAnalysis
```

#### 2.2 Update `.gitignore`

```bash
grep -q "^\.requirementsAnalysis" .gitignore 2>/dev/null || echo ".requirementsAnalysis" >> .gitignore
```

#### 2.3 Create Requirements Directory

Format: `{3-digit-number}-{short-name}`

1. Check existing directories to determine next sequence number
2. Ask user for a short name for the requirement
3. Create directory: `.requirementsAnalysis/{number}-{name}/`

Example:
```
.requirementsAnalysis/
├── 001-user-login/
├── 002-payment-integration/
└── 003-new-feature/
```

#### 2.4 Create Requirements Document

Create `requirements.md` in the new directory with the following structure:

```markdown
# {Requirement Name}

## 需求背景

{Based on AI_CONTEXT documents, describe:}
- 项目背景（来自 QUICK_START.md 和 MAP.md）
- 现有相关功能（来自 FEATURE_INDEX.md）
- 相关业务流程（来自 BUSINESS_FLOWS.md）
- 数据模型约束（来自 DATA_MODEL.md）

## 需求内容

{Detailed requirement description}

### 功能点清单

- [ ] 功能点 1
- [ ] 功能点 2
- [ ] ...

## 代码实施计划

{Based on AI_CONTEXT documents, describe:}
- 涉及的模块（参考 CORE_ARCHITECTURE.md）
- 遵循的开发规范（参考 DEVELOPMENT_GUIDE.md）
- 可能的影响范围

### 改动文件清单

| 文件路径 | 改动类型 | 改动说明 | 参考文档 |
|---------|---------|---------|---------|
| path/to/file | 新增/修改 | 说明 | AI_CONTEXT 参考 |

### 实施步骤

1. 步骤 1
2. 步骤 2
3. ...

## AI_CONTEXT 文档更新计划

{After implementation, which documents need updating:}

| 文档 | 更新内容 | 优先级 |
|-----|---------|-------|
| FEATURE_INDEX.md | 添加新功能索引 | 🔴 高 |
| DATA_MODEL.md | 更新数据结构 | 🟡 中 |
| BUSINESS_FLOWS.md | 补充业务流程 | 🟡 中 |
```

---

### Step 3: User Confirmation

Present the requirements document to user and ask for confirmation:

```markdown
📝 需求分析文档已创建

**文档位置**: .requirementsAnalysis/{序号}-{需求简称}/requirements.md

**已阅读的 AI_CONTEXT 文档**:
- ✅ [列出已读取的文档]

**规划的 AI_CONTEXT 文档更新**:
- [列出计划更新的文档]

请确认以下事项：
1. 需求背景是否准确反映了项目现状？
2. 功能点清单是否完整？
3. 代码实施计划是否合理？
4. AI_CONTEXT 文档更新计划是否遗漏？

请查看文档内容并告知是否需要调整，确认无误后我将开始按照文档进行代码改造实施。
```

**IMPORTANT**: Wait for explicit user confirmation before proceeding!

---

### Step 4: Implementation

After user confirmation:

1. **Re-read requirements document** to ensure correct understanding
2. **Execute implementation** following the planned steps
3. **Track progress** by checking off completed items in the requirements document:
   ```markdown
   - [x] 功能点 1 ✅ 已完成
   - [ ] 功能点 2
   ```

---

### Step 5: Update AI_CONTEXT Documents

After implementation is complete, update AI_CONTEXT documents according to the plan in `requirements.md`.

#### 5.1 Update Priority

| Priority | Document | Update When |
|----------|----------|-------------|
| 🔴 Highest | FEATURE_INDEX.md | Always update when adding features |
| 🟡 High | DATA_MODEL.md | When data structures change |
| 🟡 High | BUSINESS_FLOWS.md | When business flows change |
| 🟢 Medium | CORE_ARCHITECTURE.md | When architecture changes |
| 🟢 Medium | CONSTITUTION.md | Record important decisions |
| 🟦 Low | DEVELOPMENT_GUIDE.md | When discovering new best practices |

#### 5.2 Update FEATURE_INDEX.md (for new features)

```markdown
### [Feature Category]

| 功能 | 代码位置 | 说明 | 最后更新 |
|-----|---------|------|---------|
| [新功能名称] | `path/to/file.ts` | [功能描述] | YYYY-MM-DD |
```

#### 5.3 Update DATA_MODEL.md (if data structures changed)

```markdown
#### [New Data Type]

\`\`\`typescript
interface NewDataType {
  // field definitions
}
\`\`\`

**用途**: [Data type purpose]
**存储位置**: [Where it's stored]
**关联关系**: [Relationships with other data]
```

#### 5.4 Update BUSINESS_FLOWS.md (if business flows changed)

```markdown
### [Flow Name]

#### 触发条件
- [Condition 1]
- [Condition 2]

#### 执行步骤
1. **[Step 1]**: [Description]
2. **[Step 2]**: [Description]

#### 边界情况
- **边界 1**: [Handling approach]
```

#### 5.5 Update CONSTITUTION.md (for significant decisions)

```markdown
#### ADR-[Number]: [Decision Title]

**日期**: YYYY-MM-DD
**状态**: 已采纳
**决策者**: AI + User

**背景**: [Why this decision was needed]
**决策**: [The decision made]
**理由**: [Reasons for the decision]
**影响**: [Impact of the decision]
```

---

### Step 6: Completion Report

After all updates are complete, report to user:

```markdown
✅ 需求实施完成

**需求文档**: .requirementsAnalysis/{序号}-{需求简称}/requirements.md

**代码变更**:
- [List of changed files]

**AI_CONTEXT 文档更新**:
- ✅ FEATURE_INDEX.md: [更新内容]
- ✅ DATA_MODEL.md: [更新内容]（如适用）
- ✅ BUSINESS_FLOWS.md: [更新内容]（如适用）
- ✅ CONSTITUTION.md: [更新内容]（如适用）

**功能点完成状态**:
- [x] 功能点 1 ✅
- [x] 功能点 2 ✅
- [x] ...

所有文档已同步更新，便于后续 AI 会话查阅。
```

---

## Scenario-Specific Guidelines

### For Feature Development

**Read Documents**:
1. FEATURE_INDEX.md → Check for similar existing features
2. DATA_MODEL.md → Understand data structures
3. BUSINESS_FLOWS.md → Understand related business flows
4. DEVELOPMENT_GUIDE.md → Follow development conventions

**Requirements Document Emphasis**:
- Highlight how the new feature fits into existing architecture
- Reference existing similar features if any
- Plan data model changes explicitly

**Documentation Updates**:
- ✅ FEATURE_INDEX.md (mandatory)
- ⚠️ DATA_MODEL.md (if new data fields)
- ⚠️ BUSINESS_FLOWS.md (if new business flow)

---

### For Bug Fixing

**Read Documents**:
1. FEATURE_INDEX.md → Locate problem code
2. BUSINESS_FLOWS.md → Understand complete flow
3. DATA_MODEL.md → Verify data structure

**Requirements Document Emphasis**:
- Describe the bug clearly with reproduction steps
- Analyze root cause based on business flow understanding
- Plan minimal changes to fix the issue

**Documentation Updates**:
- ⚠️ BUSINESS_FLOWS.md (if edge case discovered)
- ⚠️ _RULES.md (if bug caused by violating conventions)

---

### For Code Refactoring

**Read Documents**:
1. CORE_ARCHITECTURE.md → Understand design principles
2. CONSTITUTION.md → Review historical decisions
3. DEVELOPMENT_GUIDE.md → Follow conventions
4. DATA_MODEL.md → Ensure data integrity

**Requirements Document Emphasis**:
- Explain why refactoring is needed
- Compare before/after approaches
- List all affected modules

**Documentation Updates**:
- ✅ CONSTITUTION.md (mandatory - record the refactoring decision)
- ⚠️ CORE_ARCHITECTURE.md (if architecture changes)
- ⚠️ FEATURE_INDEX.md (if file paths change)
- ⚠️ DEVELOPMENT_GUIDE.md (if new best practices discovered)

---

## Requirements Analysis Workflow

This skill follows a structured workflow:

1. **Adding AI_CONTEXT Reading Phase**: Read project documentation before creating requirements
2. **Enriching Requirements Document**: Include AI_CONTEXT insights in the requirements document
3. **Adding Documentation Update Phase**: Plan and execute AI_CONTEXT document updates after implementation

### Workflow Comparison

| Step | Basic Analysis | Context-Aware Analysis |
|------|----------------------|----------------------------------|
| 1 | Create .requirementsAnalysis folder | **Read AI_CONTEXT documents** |
| 2 | Update .gitignore | Create .requirementsAnalysis folder |
| 3 | Create requirements directory | Update .gitignore |
| 4 | Create requirements.md | Create requirements directory |
| 5 | User confirmation | Create **enriched** requirements.md |
| 6 | Start implementation | User confirmation |
| 7 | - | Start implementation |
| 8 | - | **Update AI_CONTEXT documents** |
| 9 | - | Completion report |

---

## Best Practices

### 1. Always Read AI_CONTEXT Before Planning

❌ **Wrong**: Create requirements document without reading AI_CONTEXT
✅ **Right**: Read relevant AI_CONTEXT documents first, then create informed requirements

### 2. Include AI_CONTEXT Insights in Requirements

❌ **Wrong**: Generic requirements document
✅ **Right**: Requirements document with explicit references to AI_CONTEXT findings

### 3. Plan Documentation Updates Upfront

❌ **Wrong**: Forget about documentation updates until the end
✅ **Right**: Include "AI_CONTEXT 文档更新计划" section in requirements document

### 4. Wait for User Confirmation

❌ **Wrong**: Start implementation without confirmation
✅ **Right**: Always wait for explicit user confirmation before implementing

### 5. Track Progress in Requirements Document

❌ **Wrong**: Don't update progress
✅ **Right**: Check off completed items in real-time

---

## Resources

### References

- **`references/document_mapping.md`**: Detailed guide on which AI_CONTEXT documents to read for each scenario

Use `read_file` on this reference when unsure about:
- Which documents to read for a specific scenario
- How to update documentation after completing requirements
- Documentation update priorities and best practices

---

## Summary

This skill provides **intelligent, context-aware requirements planning** by:

1. **Reading AI_CONTEXT Documents** → Understand project context before planning
2. **Creating Enriched Requirements Document** → Using standard workflow with AI_CONTEXT insights
3. **Getting User Confirmation** → Ensure plan is correct before implementation
4. **Executing Implementation** → Track progress in requirements document
5. **Updating AI_CONTEXT Documents** → Maintain documentation synchronization

**Key Difference from basic analysis**:
- This skill is **context-aware** - it reads AI_CONTEXT documents first
- Requirements documents include **AI_CONTEXT insights**
- Includes **documentation update phase** after implementation

**Remember**: This is a **planning skill**. The goal is to create a well-informed plan based on project documentation, NOT to directly implement code changes without planning!
