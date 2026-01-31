# AI Document Format Specification
# AI 可高效理解的文档格式规范

## CORE_PRINCIPLES

AI 语言模型以序列化 token 方式处理文本，不具备视觉感知能力。

RULES:
- MUST: 所有信息用自然语言描述，避免依赖空间/视觉排列
- MUST: 使用一致的格式模式，便于模式匹配
- MUST: 关键信息放在前面，减少上下文窗口压力
- MUST: 使用明确的语义关键词，避免模糊表述
- NEVER: 使用 ASCII 艺术（树形图、箭头图、边框装饰）

---

## FORMAT_RULES_BY_CONTENT_TYPE

### 1. DIRECTORY_STRUCTURE

AVOID: ASCII 树形图
REASON: ASCII 图依赖空格对齐，AI 易误读层级关系

PREFER: 嵌套列表 或 PATH → PURPOSE 映射

EXAMPLE:
```
PATH_MAP:
- /src/core → 核心业务逻辑
  - /components → 共享 UI 组件
  - /hooks → 共享 React Hooks
- /src/platform → 平台适配层
```

---

### 2. FLOW_AND_DATA_FLOW

AVOID: ASCII 箭头图 (`A ──▶ B`)、Mermaid、PlantUML
REASON: 特殊符号语义不明确，需要额外解析

PREFER: 编号步骤列表 或 链式声明

EXAMPLE_NUMBERED:
```
DATA_FLOW:
1. User triggers action in [ComponentA]
2. ComponentA calls [ServiceB.method()]
3. ServiceB processes and returns result
4. ComponentA updates state and re-renders
```

EXAMPLE_CHAIN:
```
FLOW: User Input → Validation → API Call → State Update → UI Render
```

---

### 3. RULES_AND_CONSTRAINTS

AVOID: 长段落描述
REASON: 关键信息容易淹没在文字中

PREFER: 强制关键词 + 条件动作对

KEYWORDS:
- `MUST` - 必须遵守，违反会导致错误
- `NEVER` - 绝对禁止
- `PREFER` - 推荐做法
- `AVOID` - 尽量避免
- `IF...THEN` - 条件规则

EXAMPLE:
```
RULES:
- MUST: 所有用户可见文本使用 i18n
- NEVER: 在核心层导入平台特定 API
- PREFER: 函数式组件优于类组件
- IF: 逻辑在 2+ 组件复用 → THEN: 抽取为 Hook
```

---

### 4. MAPPING_RELATIONS

AVOID: 复杂多列表格
REASON: 表格格式易被误解析

PREFER: 分组声明块

EXAMPLE:
```
FILE_ROLES:
[HostShell.tsx]
- role: 应用根容器
- manages: 全局状态、主题、路由

[adapter.ts]
- role: 平台抽象层
- provides: storage, auth, clipboard APIs
```

---

### 5. TECH_STACK

AVOID: 图例、徽章装饰
REASON: 视觉噪音，无语义价值

PREFER: 分类列表

EXAMPLE:
```
TECH_STACK:
- runtime: React 19, TypeScript 5.6
- styling: Tailwind CSS, shadcn/ui
- state: Zustand
- backend: Supabase
- build: Vite, pnpm
```

---

### 6. DECISION_LOGIC

AVOID: 流程图
REASON: 需要视觉解析能力

PREFER: Q&A 格式 或 IF-THEN 链

EXAMPLE:
```
DECISION:
Q: 新功能应该放在哪里？
A:
- IF 是共享 UI 组件 → /packages/core/components
- IF 是业务逻辑 → /packages/core/features
- IF 是平台特定 → /platform_projects/{platform}
```

---

### 7. CODE_EXAMPLES

AVOID: 孤立代码块
REASON: 缺乏上下文关联

PREFER: 紧跟规则 + 正反例对比

EXAMPLE:
```
RULE: 组件必须使用 i18n

✅ CORRECT:
const label = t('submitButton')

❌ WRONG:
const label = "Submit"
```

---

## DOCUMENT_STRUCTURE_TEMPLATE

```
AI_CONTEXT_DOCUMENT:

1. METADATA
   - version: 文档版本
   - updated: 最后更新时间
   - scope: 适用范围

2. QUICK_REFERENCE
   - 关键路径表
   - 常用命令
   - 入口点映射

3. ARCHITECTURE
   - 分层结构声明
   - 模块职责映射
   - 数据流描述

4. RULES
   - HARD_RULES (MUST/NEVER)
   - SOFT_RULES (PREFER/AVOID)

5. PATTERNS
   - 代码模板 + 使用场景
   - 反模式警告

6. FAQ
   - Q&A 格式决策指南

7. TRAPS
   - 已知陷阱及规避方法
```

---

## QUICK_REFERENCE_TABLE

| CONTENT_TYPE | AVOID | PREFER |
|--------------|-------|--------|
| 目录结构 | ASCII 树形图 | 嵌套列表 / PATH→PURPOSE 表 |
| 流程数据流 | ASCII 箭头图、Mermaid | 编号步骤 / 链式声明 |
| 规则约束 | 段落描述 | MUST/NEVER + IF-THEN |
| 映射关系 | 复杂表格 | 分组声明块 `[KEY]: value` |
| 技术栈 | 图例装饰 | 分类列表 |
| 决策逻辑 | 流程图 | Q&A / IF-THEN 链 |
| 代码示例 | 孤立展示 | 紧跟规则 + 正反例对比 |

---

## KEY_TAKEAWAYS

1. 消灭一切 ASCII 艺术 - 树形图、箭头图、边框装饰全部用文字替代
2. 使用语义关键词 - MUST/NEVER/PREFER 比"建议""应该"更明确
3. 一致的格式模式 - 同类信息用相同格式，便于 AI 模式识别
4. 信息密度优先 - 紧凑的声明式格式优于冗长的描述性段落
5. 关联性展示 - 规则紧跟示例，概念紧跟应用场景