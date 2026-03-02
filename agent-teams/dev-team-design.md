# Multi-Agent 软件开发协作团队架构设计

> 版本: 1.0.0 | 状态: 设计文档 | 日期: 2025-03-02

## 目录

1. [架构概览](#1-架构概览)
2. [Agent 定义](#2-agent-定义)
3. [三层通信协议](#3-三层通信协议)
4. [端到端工作流](#4-端到端工作流)
5. [接口契约标准](#5-接口契约标准)
6. [报告标准](#6-报告标准)
7. [LLM 行为容错与防护机制](#7-llm-行为容错与防护机制)
8. [冲突解决与异常处理](#8-冲突解决与异常处理)
9. [Git Worktree 策略](#9-git-worktree-策略)
10. [附录](#10-附录)

---

## 1. 架构概览

### 1.1 设计哲学

本架构借鉴了 SkillsMaster 项目中已验证的多个模式:

- **PrizmKit 流水线模式**: specify → plan → tasks → implement → code-review → summarize 的阶段化执行，阶段间通过 PRECONDITION/HANDOFF 标记衔接
- **子智能体模式**: 每个 Agent 有明确的角色定义、核心能力、工作流程、输出要求
- **文件系统契约模式**: 通过约定的目录结构和文件格式实现持久化数据交换（类似 `.prizmkit/specs/` 模式）
- **三层记忆架构**: 借鉴 prizmkit-memory 的 episodic/semantic/working 三层设计
- **检查点验证模式**: 借鉴 prizmkit-tasks 的 Checkpoint 机制，在阶段间设置必须通过的验证关卡

### 1.2 团队组成

```
                    ┌─────────────────┐
                    │   Coordinator   │
                    │   (全局调度器)    │
                    └───────┬─────────┘
                            │
           ┌────────────────┼────────────────┐
           │                │                │
    ┌──────┴──────┐  ┌──────┴──────┐  ┌──────┴──────┐
    │     PM      │  │     QA      │  │   Review    │
    │ (任务分解)   │  │ (集成测试)   │  │ (代码审查)   │
    └──────┬──────┘  └─────────────┘  └─────────────┘
           │
    ┌──────┴──────────────────┐
    │                         │
┌───┴───┐  ┌───────┐  ┌──────┴──┐
│ Dev-1 │  │ Dev-2 │  │ Dev-N   │
│(模块A) │  │(模块B) │  │(模块N)  │
└───────┘  └───────┘  └─────────┘
```

### 1.3 核心原则

1. **单一职责**: 每个 Agent 只负责其定义范围内的工作，不越权
2. **契约驱动**: 所有 Agent 间的协作通过明确的接口契约进行，不存在隐式依赖
3. **检查点必过**: 阶段间的 Checkpoint 是硬性门控，未通过不得进入下一阶段
4. **可追溯性**: 所有决策、变更、异常都有持久化记录
5. **并行优先**: 在依赖关系允许的情况下，最大化并行执行
6. **LLM 容错**: 假设 Agent 可能产出格式错误、越权操作或注意力衰减，系统必须有防护和恢复机制

---

## 2. Agent 定义

### 2.1 Coordinator Agent（协调者）

#### 角色定义

全局调度与协调中心。不参与任何业务分析或代码实现，专注于任务分配、进度监控、冲突解决和异常处理。类比：交通指挥中心，不开车但确保所有车辆高效通行。

#### 核心职责

**必须做 (MUST)**:
- 接收 PM 产出的任务列表，执行任务分配和调度
- 维护全局任务状态看板（通过 TaskList 工具）
- 监控各 Agent 的执行进度，检测阻塞和超时
- 管理阶段间的 Checkpoint 验证
- 协调 Agent 间的冲突和依赖
- 管理 Git Worktree 的创建、分支和合并
- 处理 Agent 失败的重试和降级策略
- 在每个阶段完成时生成状态摘要报告

**绝不做 (NEVER)**:
- 不分析需求（PM 的职责）
- 不编写或修改代码（Dev 的职责）
- 不执行测试（QA 的职责）
- 不进行代码审查（Review 的职责）
- 不修改接口契约（PM 的职责）

#### 行为规范

```
规则 C-01: 任务分配前必须检查依赖关系图，确保前置任务已完成
规则 C-02: 检测到 Agent 无响应超过 5 分钟，发送 HEARTBEAT_CHECK 消息
规则 C-03: 检测到 Agent 连续失败 2 次，升级为 P0 异常并暂停相关流水线
规则 C-04: 每个 Checkpoint 必须收集所有相关 Agent 的完成信号后才能放行
规则 C-05: 并行任务中某个失败时，评估是否影响其他并行任务，决定是否全部暂停
规则 C-06: 所有调度决策必须写入 .dev-team/logs/coordinator.log
规则 C-07: 收到 PM 产出的 JSON 制品后，必须执行 JSON Schema 校验，校验失败则返回错误详情并要求重新生成（最多 2 次）
规则 C-08: 收到任何 Agent 的报告后，必须校验报告包含所有必需章节，缺失则要求补充
规则 C-09: 分配任务时，必须在 SendMessage 中附带该 Agent 的核心行为规则摘要（注意力衰减对策）
规则 C-10: 每个 Checkpoint 校验必须将制品格式校验作为第一个检查项
```

#### 输入标准

| 输入来源 | 格式 | 路径 |
|---------|------|------|
| PM 的任务列表 | Markdown + JSON | `.dev-team/tasks/task-manifest.json` |
| PM 的接口契约 | JSON | `.dev-team/contracts/*.json` |
| 各 Agent 的状态消息 | SendMessage | 实时消息通道 |
| 各 Agent 的完成报告 | Markdown | `.dev-team/reports/` |

#### 输出标准

| 输出内容 | 格式 | 路径 |
|---------|------|------|
| 任务分配指令 | SendMessage + TaskList | 实时 + 任务看板 |
| 阶段状态摘要 | Markdown | `.dev-team/reports/phase-summary-{phase}.md` |
| 调度日志 | 结构化文本 | `.dev-team/logs/coordinator.log` |
| Git Worktree 指令 | Bash 命令 | 直接执行 |

#### 异常处理

| 异常场景 | 处理策略 |
|---------|---------|
| Agent 超时无响应 | 发送 HEARTBEAT_CHECK → 等待 2 分钟 → 标记 BLOCKED → 尝试重新分配任务 |
| Agent 执行失败 | 记录失败原因 → 第 1 次自动重试 → 第 2 次升级为人工介入 |
| 依赖死锁 | 分析依赖图 → 找到环路 → 上报 PM 重新分解任务 |
| 合并冲突 | 暂停相关 Dev Agent → 按优先级逐一合并 → 通知受影响 Agent 更新基线 |
| Checkpoint 未通过 | 收集失败详情 → 生成问题报告 → 分发给相关 Agent 修复 |

#### 工具权限

```json
{
  "tools": {
    "allowed": ["Read", "Write", "Bash", "Glob", "Grep", "SendMessage", "TaskCreate", "TaskUpdate", "TaskList", "TaskGet"],
    "forbidden": ["Edit"],
    "note": "不允许编辑代码文件，只能通过 Write 写入报告和日志"
  }
}
```

---

### 2.2 PM Agent（项目经理）

#### 角色定义

需求分析与任务分解专家。将用户需求转化为结构化的任务列表和接口契约。类比：建筑设计师，不砌砖但提供精确的施工图纸。

#### 核心职责

**必须做 (MUST)**:
- 分析用户需求，识别功能点和非功能性需求
- 将需求分解为粒度合适的开发任务（单个 Dev Agent 可在一个 session 内完成）
- 定义模块间的接口契约（API 规格、数据模型、依赖关系）
- 为每个任务定义明确的输入、输出和验收标准
- 识别任务间的依赖关系和可并行度
- 在契约歧义被 Dev 上报时，裁定并更新契约

**绝不做 (NEVER)**:
- 不编写实现代码（Dev 的职责）
- 不执行测试（QA 的职责）
- 不进行代码审查（Review 的职责）
- 不进行任务调度（Coordinator 的职责）
- 不直接与 Dev Agent 通信（通过 Coordinator 中转）

#### 行为规范

```
规则 PM-01: 每个任务的描述必须包含: 目标、输入、输出、验收标准、预估复杂度
规则 PM-02: 接口契约必须在 Phase 2 结束前完成，进入 Phase 3 后不得擅自修改
规则 PM-03: 契约修改必须通过「契约变更流程」，通知所有受影响的 Dev Agent
规则 PM-04: 任务粒度标准：单个 Dev Agent 可在 1 个 session 内完成
规则 PM-05: 必须为每个可并行的任务标记 [P] 标识
规则 PM-06: 必须在任务分解完成后生成依赖关系图（DAG）
```

#### 输入标准

| 输入来源 | 格式 | 描述 |
|---------|------|------|
| 用户需求 | 自然语言/文档 | 由 Coordinator 转发 |
| 项目上下文 | Markdown | `docs/AI_CONTEXT/` 或 `.prizm-docs/` |
| 现有代码结构 | 分析报告 | 通过 Glob/Grep/Read 获取 |

#### 输出标准

| 输出内容 | 格式 | 路径 |
|---------|------|------|
| 需求分析文档 | Markdown | `.dev-team/specs/requirements.md` |
| 任务清单 | JSON + Markdown | `.dev-team/tasks/task-manifest.json` + `.dev-team/tasks/task-manifest.md` |
| 接口契约 | JSON | `.dev-team/contracts/{module-name}.contract.json` |
| 数据模型契约 | JSON | `.dev-team/contracts/data-models.json` |
| 依赖关系图 | JSON | `.dev-team/tasks/dependency-graph.json` |

#### 异常处理

| 异常场景 | 处理策略 |
|---------|---------|
| 需求不清晰 | 在 requirements.md 中标记 `[NEEDS CLARIFICATION]` → 通过 Coordinator 向用户确认 |
| 任务无法原子化分解 | 标记为复合任务 → 分配给单个 Dev Agent → 在任务描述中说明内部分步 |
| 契约变更请求 | 评估影响范围 → 生成变更影响报告 → 通知 Coordinator 协调所有受影响 Agent |
| 循环依赖发现 | 重新设计模块边界 → 引入接口抽象层打破循环 |

#### 工具权限

```json
{
  "tools": {
    "allowed": ["Read", "Write", "Glob", "Grep", "SendMessage", "TaskCreate", "TaskList"],
    "forbidden": ["Edit", "Bash"],
    "note": "不允许编辑代码或执行命令（避免意外修改）"
  }
}
```

---

### 2.3 Dev Agent（开发者，可多实例）

#### 角色定义

模块实现者。严格按照 PM 定义的接口契约实现具体功能模块，产出代码和单元测试。每个 Dev Agent 在独立的 Git Worktree 中工作，互不干扰。类比：建筑工人，严格按图纸施工。

#### 核心职责

**必须做 (MUST)**:
- 按照分配的任务和接口契约实现功能模块
- 遵循 TDD 方式：先写测试，再实现，再验证
- 产出的代码必须通过本模块的单元测试
- 产出自测报告（self-test report）
- 发现契约歧义时，立即通过 Coordinator 上报 PM
- 在独立的 Git Worktree/Branch 中工作

**绝不做 (NEVER)**:
- 不修改接口契约（契约是只读的，修改需通过 PM）
- 不修改其他 Dev Agent 负责的模块代码
- 不进行集成测试（QA 的职责）
- 不直接与其他 Dev Agent 通信（通过 Coordinator 中转）
- 不直接向 main/develop 分支提交代码

#### 行为规范

```
规则 DEV-01: 开始任务前必须读取最新的接口契约文件
规则 DEV-02: 实现必须严格符合契约定义的输入输出格式
规则 DEV-03: 每个公开 API/函数必须有对应的单元测试
规则 DEV-04: 发现契约歧义时，不得自行假设，必须上报
规则 DEV-05: 任务完成后必须运行全部本模块测试并生成自测报告
规则 DEV-06: 代码提交信息遵循 Conventional Commits 格式
规则 DEV-07: 不得引入未在任务描述中声明的外部依赖
规则 DEV-08: 所有 Mock/Stub 必须基于接口契约生成，不得凭空构造
规则 DEV-09: 每次 Write/Edit 操作前，必须验证目标路径在自己的 worktree 目录内，禁止写入其他路径
规则 DEV-10: 每次 git commit 前，必须验证当前分支名与任务分配的分支名一致
规则 DEV-11: 不得修改 `.dev-team/contracts/` 目录下的任何文件，发现需要修改时必须通过 ESCALATION 上报
```

#### 输入标准

| 输入来源 | 格式 | 描述 |
|---------|------|------|
| 任务描述 | JSON (from task-manifest.json) | 包含目标、验收标准、预估复杂度 |
| 接口契约 | JSON (from contracts/) | 本模块需实现和依赖的接口定义 |
| 项目上下文 | Markdown | 架构文档、编码规范 |
| Worktree 信息 | Coordinator 指令 | 分支名、worktree 路径 |

#### 输出标准

| 输出内容 | 格式 | 路径 |
|---------|------|------|
| 实现代码 | 源代码文件 | 项目对应目录（worktree 内） |
| 单元测试 | 测试文件 | 项目测试目录（worktree 内） |
| 自测报告 | Markdown | `.dev-team/reports/dev/self-test-{agent-id}-{task-id}.md` |
| 完成信号 | SendMessage | COMPLETION_SIGNAL 类型消息 |

#### 异常处理

| 异常场景 | 处理策略 |
|---------|---------|
| 契约歧义 | 标记为 BLOCKED → 发送 ESCALATION 给 Coordinator → 等待 PM 裁定 |
| 单元测试失败 | 最多重试修复 3 次 → 仍失败则发送 ISSUE_REPORT → 标记任务为 BLOCKED |
| 外部依赖不可用 | 使用 Mock 代替 → 在自测报告中标注 → 发送 STATUS_UPDATE |
| 性能不达标 | 记录性能数据 → 在自测报告中标注 → 标记为 WARNING 级别 |
| 任务超出预估复杂度 | 发送 ESCALATION → 建议 PM 拆分任务 |

#### 工具权限

```json
{
  "tools": {
    "allowed": ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "SendMessage", "TaskUpdate", "TaskGet"],
    "forbidden": [],
    "restrictions": {
      "Edit_scope": "仅限 worktree 内自己负责的模块目录",
      "Bash_scope": "仅限测试/构建/lint 命令，禁止 git push",
      "Write_scope": "仅限 worktree 内目录和 .dev-team/reports/dev/"
    }
  }
}
```

---

### 2.4 QA Agent（质量保证）

#### 角色定义

集成测试专家。验证多个 Dev Agent 的产出在组合后是否正确工作，重点关注模块间的数据流和契约合规性。类比：质检员，不生产产品但确保各零件组装后正常运转。

#### 核心职责

**必须做 (MUST)**:
- 编写和执行集成测试，验证模块间的交互
- 验证实际实现是否符合接口契约定义
- 验证跨模块数据流的完整性和正确性
- 测试边界条件和异常路径
- 产出结构化的集成测试报告

**绝不做 (NEVER)**:
- 不编写单元测试（Dev 的职责）
- 不修改实现代码（Dev 的职责）
- 不进行代码风格审查（Review 的职责）
- 不分解任务（PM 的职责）

#### 行为规范

```
规则 QA-01: 集成测试必须基于接口契约定义的数据格式
规则 QA-02: 每个契约中定义的接口必须至少有一个集成测试用例
规则 QA-03: 必须测试正常路径和至少 2 个异常路径
规则 QA-04: 发现契约违规时，必须精确指出: 契约定义 vs 实际行为
规则 QA-05: 测试报告中的每个 FAIL 必须包含复现步骤
规则 QA-06: 集成测试在 integration 分支上执行，不在 Dev 的 feature 分支上
```

#### 输入标准

| 输入来源 | 格式 | 描述 |
|---------|------|------|
| 接口契约 | JSON | `.dev-team/contracts/*.json` |
| Dev 自测报告 | Markdown | `.dev-team/reports/dev/self-test-*.md` |
| 已合并的集成代码 | 源代码 | integration 分支上的代码 |
| 任务清单 | JSON | `.dev-team/tasks/task-manifest.json` |

#### 输出标准

| 输出内容 | 格式 | 路径 |
|---------|------|------|
| 集成测试代码 | 测试文件 | 项目测试目录（integration 分支） |
| 集成测试报告 | Markdown | `.dev-team/reports/qa/integration-test-{timestamp}.md` |
| 完成信号 | SendMessage | COMPLETION_SIGNAL 或 ISSUE_REPORT |

#### 异常处理

| 异常场景 | 处理策略 |
|---------|---------|
| 契约违规发现 | 分类严重级别 → 生成 ISSUE_REPORT → 发送给 Coordinator → Coordinator 派发给对应 Dev |
| 模块间数据不兼容 | 精确记录两端数据格式 → 升级给 PM 裁定哪一方需要修改 |
| 测试环境异常 | 记录环境信息 → 发送给 Coordinator → 请求环境修复 |
| 集成分支合并冲突 | 通知 Coordinator → 等待冲突解决后重新执行测试 |

#### 工具权限

```json
{
  "tools": {
    "allowed": ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "SendMessage", "TaskUpdate", "TaskGet"],
    "forbidden": [],
    "restrictions": {
      "Edit_scope": "仅限测试相关文件，不得修改实现代码",
      "Write_scope": "仅限测试目录和 .dev-team/reports/qa/"
    }
  }
}
```

---

### 2.5 Review Agent（代码审查）

#### 角色定义

代码一致性与质量审查员。审查所有 Dev Agent 产出的代码在风格、模式、最佳实践方面的一致性。不关注功能正确性（那是 QA 的职责），专注于代码质量维度。类比：编辑校对员，不写书但确保全书风格统一。

#### 核心职责

**必须做 (MUST)**:
- 审查所有 Dev Agent 的代码在命名、结构、模式上的一致性
- 检查是否遵循项目编码规范和最佳实践
- 检测跨模块的代码重复
- 检查错误处理模式的一致性
- 产出结构化的审查报告，按严重级别分类

**绝不做 (NEVER)**:
- 不执行功能测试（QA 的职责）
- 不修改代码（Dev 的职责）
- 不验证业务逻辑正确性（QA 的职责）
- 不分解任务（PM 的职责）

#### 行为规范

```
规则 REV-01: 审查范围必须覆盖所有 Dev Agent 的代码产出
规则 REV-02: 每个发现必须引用具体的文件路径和行号
规则 REV-03: CRITICAL 级别发现必须包含具体的修复建议
规则 REV-04: 审查维度固定为 6 个: 命名规范、代码结构、设计模式、错误处理、代码重复、最佳实践
规则 REV-05: 最多 30 个发现（保持可操作性）
规则 REV-06: 审查是只读操作，不修改任何文件
```

#### 判定标准

| 判定 | 条件 | 后续动作 |
|------|------|---------|
| **PASS** | 无 CRITICAL 或 HIGH 发现 | 进入下一阶段 |
| **PASS_WITH_WARNINGS** | 无 CRITICAL，有 HIGH 发现 | 记录待改进项，可进入下一阶段 |
| **NEEDS_FIXES** | 存在 CRITICAL 发现 | 必须修复后重新审查 |

#### 输入标准

| 输入来源 | 格式 | 描述 |
|---------|------|------|
| 所有 Dev 的代码 | 源代码 | integration 分支上的完整代码 |
| 接口契约 | JSON | `.dev-team/contracts/*.json` |
| 项目编码规范 | Markdown | `CODEBUDDY.md` 或项目规范文档 |

#### 输出标准

| 输出内容 | 格式 | 路径 |
|---------|------|------|
| 审查报告 | Markdown | `.dev-team/reports/review/code-review-{timestamp}.md` |
| 完成信号 | SendMessage | COMPLETION_SIGNAL（含 PASS/NEEDS_FIXES 判定） |

#### 工具权限

```json
{
  "tools": {
    "allowed": ["Read", "Glob", "Grep", "SendMessage", "TaskUpdate", "TaskGet", "Write"],
    "forbidden": ["Edit", "Bash"],
    "restrictions": {
      "Write_scope": "仅限 .dev-team/reports/review/"
    }
  }
}
```

---

## 3. 三层通信协议

### 3.1 概览

```
Layer 1: SendMessage  ──── 实时通信（状态更新、问题上报、查询响应）
Layer 2: TaskList     ──── 协调看板（任务生命周期、依赖关系、进度跟踪）
Layer 3: File System  ──── 持久化制品（契约、报告、日志、代码）
```

三层各司其职:
- **SendMessage** 解决「即时性」: Agent 间需要实时感知的信息
- **TaskList** 解决「可见性」: 全局任务状态的唯一真相来源
- **File System** 解决「持久性」: 结构化制品的长期存储和版本控制

### 3.2 Layer 1: SendMessage（实时通信）

#### 消息类型定义

**STATUS_UPDATE** — Agent 主动汇报当前状态变化:

```json
{
  "type": "STATUS_UPDATE",
  "agent_id": "dev-1",
  "task_id": "T-101",
  "status": "in_progress",
  "progress_pct": 60,
  "detail": "单元测试编写中，已完成 3/5 个测试用例"
}
```

**COMPLETION_SIGNAL** — Agent 完成任务的正式通知:

```json
{
  "type": "COMPLETION_SIGNAL",
  "agent_id": "dev-1",
  "task_id": "T-101",
  "result": "SUCCESS",
  "artifact_paths": [
    ".dev-team/reports/dev/self-test-dev1-T101.md"
  ],
  "summary": "模块 A 实现完成，6/6 单元测试通过"
}
```

**ISSUE_REPORT** — Agent 报告发现的问题:

```json
{
  "type": "ISSUE_REPORT",
  "agent_id": "qa",
  "severity": "P1",
  "category": "CONTRACT_VIOLATION",
  "description": "模块 A 的 getUserById 接口返回格式与契约不符",
  "evidence": {
    "contract_expects": "{ user: { id, name, email } }",
    "actual_returns": "{ id, name, email }",
    "contract_file": ".dev-team/contracts/user-service.contract.json",
    "test_file": "tests/integration/user-api.test.ts:42"
  },
  "affected_tasks": ["T-101", "T-201"]
}
```

**ESCALATION** — Agent 请求升级处理:

```json
{
  "type": "ESCALATION",
  "agent_id": "dev-2",
  "escalation_type": "CONTRACT_AMBIGUITY",
  "description": "user-service.contract.json 中 pagination 参数的 offset 行为未定义：是基于 0 还是基于 1？",
  "target_agent": "pm",
  "blocking_task": "T-202",
  "suggested_resolution": "建议使用基于 0 的 offset，与行业惯例一致"
}
```

**QUERY** — Agent 向另一个 Agent 请求信息:

```json
{
  "type": "QUERY",
  "agent_id": "qa",
  "target_agent": "dev-1",
  "query": "模块 A 的自测报告中提到 3 个 Mock 依赖，请确认这些 Mock 的行为是否与真实服务一致",
  "context_ref": ".dev-team/reports/dev/self-test-dev1-T101.md"
}
```

**RESPONSE** — 对 QUERY 的回复:

```json
{
  "type": "RESPONSE",
  "agent_id": "dev-1",
  "in_reply_to": "query-qa-20250302-001",
  "answer": "Mock 行为与契约定义一致，但真实服务可能有 100ms 延迟差异"
}
```

**HEARTBEAT_CHECK** — Coordinator 检查 Agent 是否存活:

```json
{
  "type": "HEARTBEAT_CHECK",
  "target_agent": "dev-2",
  "last_activity": "2025-03-02T10:30:00Z",
  "timeout_warning": true
}
```

#### 路由规则

所有消息必须经过 Coordinator 中转，不允许 Agent 间直接通信。

```
路由矩阵:
┌──────────────┬───────┬────┬─────┬────┬────────┐
│ From \ To    │ Coord │ PM │ Dev │ QA │ Review │
├──────────────┼───────┼────┼─────┼────┼────────┤
│ Coordinator  │   -   │ ✓  │  ✓  │ ✓  │   ✓    │
│ PM           │   ✓   │ -  │  ✗  │ ✗  │   ✗    │
│ Dev          │   ✓   │ ✗  │  ✗  │ ✗  │   ✗    │
│ QA           │   ✓   │ ✗  │  ✗  │ -  │   ✗    │
│ Review       │   ✓   │ ✗  │  ✗  │ ✗  │   -    │
└──────────────┴───────┴────┴─────┴────┴────────┘

说明: ✓ = 可直接发送, ✗ = 必须通过 Coordinator 中转
```

这种「星型路由」设计的好处:
1. Coordinator 可以拦截、记录和审计所有通信
2. 避免 Agent 间形成混乱的网状通信
3. Coordinator 可以在中转时添加上下文或优先级标记

### 3.3 Layer 2: TaskList（协调看板）

#### 任务生命周期

```
pending ──→ in_progress ──→ completed
   │              │
   │              └──→ blocked ──→ in_progress (解除阻塞后)
   │                      │
   └──────────────────────└──→ cancelled (极端情况)
```

#### 任务元数据约定

每个任务在 TaskList 中的标准字段:

```json
{
  "id": "T-101",
  "subject": "[Dev-1] 实现 UserService.getUserById",
  "description": "按照 user-service.contract.json 中定义的接口实现 getUserById 方法",
  "activeForm": "实现 UserService.getUserById",
  "status": "in_progress",
  "owner": "dev-1",
  "metadata": {
    "phase": "Phase 4: Parallel Development",
    "priority": "P1",
    "module": "user-service",
    "contract_ref": ".dev-team/contracts/user-service.contract.json",
    "worktree_branch": "feat/T-101-user-get-by-id",
    "estimated_complexity": "medium",
    "parallel_group": "PG-01",
    "created_by": "pm",
    "assigned_by": "coordinator"
  },
  "blockedBy": [],
  "blocks": ["T-301"]
}
```

#### Coordinator 调度算法

```
1. 初始化阶段:
   - PM 完成任务分解后，Coordinator 读取 task-manifest.json
   - 为每个任务调用 TaskCreate 创建 TaskList 条目
   - 根据 dependency-graph.json 设置 blockedBy 关系

2. 调度循环:
   WHILE (存在 pending 或 in_progress 的任务):
     a. TaskList() 获取全局状态
     b. 找出所有 status=pending 且 blockedBy 为空的任务
     c. 对可执行任务按 priority 排序
     d. 将任务分配给空闲的 Agent (TaskUpdate: owner + status=in_progress)
     e. 通过 SendMessage 通知 Agent 开始工作
     f. 检查 in_progress 任务是否超时
     g. 检查 blocked 任务是否可解除阻塞

3. 完成处理:
   - 收到 COMPLETION_SIGNAL 后，TaskUpdate 标记 completed
   - 检查是否有任务的 blockedBy 列表因此清空
   - 检查当前 Phase 的所有任务是否完成（Checkpoint 检查）
```

### 3.4 Layer 3: File System（持久化制品仓库）

#### 目录结构

```
.dev-team/
├── specs/                              # 需求规格
│   └── requirements.md                 # 需求分析文档
├── contracts/                          # 接口契约（Phase 2 产出）
│   ├── {module-name}.contract.json     # 模块接口契约
│   ├── data-models.json               # 全局数据模型定义
│   └── dependency-map.json            # 模块依赖关系
├── tasks/                             # 任务管理
│   ├── task-manifest.json             # 机器可读的任务清单
│   ├── task-manifest.md               # 人类可读的任务清单
│   └── dependency-graph.json          # 任务依赖关系图 (DAG)
├── reports/                           # 各类报告
│   ├── dev/                           # Dev Agent 产出
│   │   └── self-test-{agent}-{task}.md
│   ├── qa/                            # QA Agent 产出
│   │   └── integration-test-{timestamp}.md
│   ├── review/                        # Review Agent 产出
│   │   └── code-review-{timestamp}.md
│   └── phase-summary-{phase}.md       # Coordinator 阶段摘要
├── issues/                            # 问题跟踪
│   ├── ISS-{NNN}-{title}.json         # 单个问题记录
│   └── issue-index.json               # 问题索引
├── validators/                        # 格式校验与完整性校验
│   ├── validate-json-schema.py        # JSON Schema 通用校验器
│   ├── validate-report-format.py      # 报告格式校验器
│   ├── validate-dag.py                # DAG 无环验证
│   ├── check-contract-integrity.py    # 契约哈希完整性校验
│   ├── schemas/                       # JSON Schema 定义文件
│   │   ├── task-manifest.schema.json
│   │   ├── contract.schema.json
│   │   ├── dependency-graph.schema.json
│   │   ├── data-models.schema.json
│   │   └── issue.schema.json
│   └── checksums/                     # 契约完整性哈希
│       └── contract-hashes.json       # CP-2 后由 Coordinator 生成
└── logs/                              # 执行日志
    ├── coordinator.log                # 调度日志
    └── timeline.json                  # 全局时间线
```

#### 文件命名约定

```
契约文件:     {module-name}.contract.json        例: user-service.contract.json
自测报告:     self-test-{agent-id}-{task-id}.md   例: self-test-dev1-T101.md
集成报告:     integration-test-{YYYYMMDD-HHmm}.md
审查报告:     code-review-{YYYYMMDD-HHmm}.md
阶段摘要:     phase-summary-{phase-number}.md    例: phase-summary-04.md
问题记录:     ISS-{NNN}-{slug}.json              例: ISS-001-contract-mismatch.json
```

#### 格式规范

- **契约文件**: JSON — 机器可解析，便于 Agent 自动验证
- **报告文件**: Markdown — 人类可读，便于审查和归档
- **日志文件**: JSON Lines — 便于追加和解析
- **时间线**: JSON — 结构化的全局事件流

---

## 4. 端到端工作流

### 4.1 工作流总览

```
Phase 1  ──→  Phase 2  ──→  Phase 3  ──→  Phase 4  ──→  Phase 5
需求分析      任务分解      任务调度      并行开发      自测报告
  (PM)      (PM)       (Coord)    (Dev x N)    (Dev x N)
   │          │           │           │           │
   └──[CP-1]──┘──[CP-2]──┘──[CP-3]──┘           │
                                                   │
Phase 6  ──→  Phase 7  ──→  Phase 8  ──→  Phase 9  │
集成测试      代码审查     问题修复循环    最终交付    │
  (QA)      (Review)    (Coord+Dev)   (Coord)    │
   │          │           │           │           │
   └──[CP-4]──┘──[CP-5]──┘──[CP-6]──┘──[CP-7]──┘
```

### 4.2 Phase 1: 需求分析 (PM)

**执行者**: PM Agent
**前置条件**: 收到用户需求输入

**步骤**:

1. PM 接收 Coordinator 转发的用户需求
2. PM 读取项目上下文文档 (`docs/AI_CONTEXT/`, `.prizm-docs/root.prizm`)
3. PM 分析需求，识别功能点和非功能性需求
4. PM 在需求中标记不明确之处为 `[NEEDS CLARIFICATION]`（最多 3 个）
5. PM 生成 `.dev-team/specs/requirements.md`
6. PM 发送 COMPLETION_SIGNAL 给 Coordinator

**Checkpoint CP-1**:
```
- [ ] requirements.md 已生成
- [ ] requirements.md 格式校验通过（包含所有必需章节）
- [ ] 所有 [NEEDS CLARIFICATION] 已得到用户确认
- [ ] 需求点可追溯（每个需求有唯一编号 REQ-NNN）
验证者: Coordinator
放行条件: 所有检查项通过
```

### 4.3 Phase 2: 任务分解与契约定义 (PM)

**执行者**: PM Agent
**前置条件**: CP-1 通过

**步骤**:

1. PM 基于 requirements.md 进行模块划分
2. PM 为每个模块定义接口契约，写入 `.dev-team/contracts/`
3. PM 定义全局数据模型，写入 `.dev-team/contracts/data-models.json`
4. PM 将需求分解为开发任务:
   - 任务 ID 使用零填充编号: `[T-001]`, `[T-010]`, `[T-100]`
   - 可并行任务标记 `[P]`
5. PM 生成 `task-manifest.json` 和 `task-manifest.md`
6. PM 生成 `dependency-graph.json`
7. PM 发送 COMPLETION_SIGNAL 给 Coordinator

**task-manifest.json 示例**:

```json
{
  "project": "feature-name",
  "created_by": "pm",
  "created_at": "2025-03-02T10:00:00Z",
  "phases": [
    {
      "id": "setup",
      "name": "Setup",
      "tasks": [
        {
          "id": "T-001",
          "title": "项目脚手架搭建",
          "description": "创建模块目录结构，配置构建工具",
          "module": "infrastructure",
          "parallel": false,
          "acceptance_criteria": [
            "目录结构创建完成",
            "构建命令可正常执行",
            "空白测试可通过"
          ],
          "input_contracts": [],
          "output_contracts": [],
          "target_files": ["src/config/", "package.json"],
          "estimated_complexity": "low",
          "depends_on": []
        }
      ]
    },
    {
      "id": "foundational",
      "name": "Foundational",
      "tasks": [
        {
          "id": "T-010",
          "title": "数据模型实现",
          "description": "按照 data-models.json 实现所有数据实体",
          "module": "data-layer",
          "parallel": false,
          "acceptance_criteria": [
            "所有实体类型定义完成",
            "数据库迁移脚本生成",
            "模型单元测试通过"
          ],
          "input_contracts": ["data-models.json"],
          "output_contracts": [],
          "target_files": ["src/models/", "migrations/"],
          "estimated_complexity": "medium",
          "depends_on": ["T-001"]
        }
      ]
    },
    {
      "id": "development",
      "name": "Module Development",
      "tasks": [
        {
          "id": "T-100",
          "title": "UserService 模块实现",
          "module": "user-service",
          "parallel": true,
          "acceptance_criteria": [
            "所有契约定义的接口已实现",
            "单元测试覆盖率 >= 80%",
            "自测报告已生成"
          ],
          "input_contracts": ["user-service.contract.json"],
          "target_files": ["src/services/user/", "tests/unit/user/"],
          "estimated_complexity": "high",
          "depends_on": ["T-010"]
        },
        {
          "id": "T-200",
          "title": "OrderService 模块实现",
          "module": "order-service",
          "parallel": true,
          "acceptance_criteria": [
            "所有契约定义的接口已实现",
            "单元测试覆盖率 >= 80%",
            "自测报告已生成"
          ],
          "input_contracts": ["order-service.contract.json"],
          "target_files": ["src/services/order/", "tests/unit/order/"],
          "estimated_complexity": "high",
          "depends_on": ["T-010"]
        }
      ]
    },
    {
      "id": "polish",
      "name": "Polish",
      "tasks": [
        {
          "id": "T-900",
          "title": "最终集成验证",
          "module": "all",
          "parallel": false,
          "acceptance_criteria": [
            "所有集成测试通过",
            "代码审查判定为 PASS 或 PASS_WITH_WARNINGS"
          ],
          "depends_on": ["T-100", "T-200"]
        }
      ]
    }
  ],
  "checkpoints": [
    {"id": "CP-2", "after_phase": "setup", "criteria": ["项目可构建", "空测试通过"]},
    {"id": "CP-3", "after_phase": "foundational", "criteria": ["数据模型验证", "迁移可执行"]},
    {"id": "CP-4", "after_phase": "development", "criteria": ["所有自测报告收集", "无 P0 问题"]},
    {"id": "CP-5", "after_phase": "polish", "criteria": ["集成测试通过", "审查通过"]}
  ]
}
```

**dependency-graph.json 示例**:

```json
{
  "nodes": ["T-001", "T-010", "T-100", "T-200", "T-900"],
  "edges": [
    {"from": "T-001", "to": "T-010"},
    {"from": "T-010", "to": "T-100"},
    {"from": "T-010", "to": "T-200"},
    {"from": "T-100", "to": "T-900"},
    {"from": "T-200", "to": "T-900"}
  ],
  "parallel_groups": [
    {"id": "PG-01", "tasks": ["T-100", "T-200"], "description": "可并行开发的独立模块"}
  ]
}
```

**Checkpoint CP-2**:
```
- [ ] task-manifest.json 通过 JSON Schema 校验
- [ ] 所有契约文件通过 JSON Schema 校验
- [ ] dependency-graph.json 通过 JSON Schema 校验且为有效 DAG（无环）
- [ ] task-manifest.json 任务间无循环依赖
- [ ] 每个任务有明确的验收标准
- [ ] 每个可并行任务标记了 [P]
- [ ] 契约文件 SHA-256 哈希已记录到 contract-hashes.json
验证者: Coordinator
放行条件: 所有检查项通过
```

### 4.4 Phase 3: 任务分配与调度 (Coordinator)

**执行者**: Coordinator Agent
**前置条件**: CP-2 通过

**步骤**:

1. Coordinator 读取 `task-manifest.json` 和 `dependency-graph.json`
2. Coordinator 为每个任务创建 TaskList 条目
3. Coordinator 设置任务间的 blockedBy 关系
4. Coordinator 为每个 Dev Agent 创建 Git Worktree:
   ```bash
   git worktree add ../worktree-dev-1 -b feat/T-100-user-service
   git worktree add ../worktree-dev-2 -b feat/T-200-order-service
   ```
5. Coordinator 从 DAG 中找出入度为 0 的就绪任务，分配给可用 Agent
6. Coordinator 通过 SendMessage 发送任务指令

**Checkpoint CP-3**:
```
- [ ] 所有 TaskList 条目已创建
- [ ] 所有 Git Worktree 已创建且分支正确
- [ ] 调度计划已写入 phase-summary-03.md
验证者: Coordinator（自检）
```

### 4.5 Phase 4 & 5: 并行开发与自测 (Dev Agents)

**执行者**: Dev Agent x N（并行）
**前置条件**: 接收到 Coordinator 的任务分配

**每个 Dev Agent 的执行步骤**:

1. 接收任务分配，获取 worktree 路径和契约文件
2. 读取接口契约文件
3. 在 worktree 中执行 TDD 开发:
   a. 基于契约编写接口类型定义
   b. 编写单元测试（基于验收标准）
   c. 实现功能代码
   d. 运行测试验证
4. 每完成一个子步骤，发送 STATUS_UPDATE
5. 遇到契约歧义，发送 ESCALATION（不自行假设）
6. 运行完整模块测试，生成自测报告
7. 在 worktree 中提交代码
8. 发送 COMPLETION_SIGNAL

**Checkpoint CP-4**:
```
- [ ] 所有 Dev Agent 已提交 COMPLETION_SIGNAL
- [ ] 所有自测报告已生成
- [ ] 所有自测报告格式校验通过（包含必需章节和表格）
- [ ] 无 P0 级别的自测失败
- [ ] 所有 worktree 代码已提交
- [ ] 契约文件哈希完整性校验通过（未被篡改）
验证者: Coordinator
失败处理: 通知失败的 Dev Agent 修复后重新提交
```

### 4.6 Phase 6: 集成测试 (QA Agent)

**执行者**: QA Agent
**前置条件**: CP-4 通过

**步骤**:

1. Coordinator 将所有 feature 分支合并到 integration 分支:
   ```bash
   git checkout -b integration
   git merge feat/T-100-user-service --no-ff
   git merge feat/T-200-order-service --no-ff
   ```
2. 如合并有冲突，Coordinator 协调解决（见第 9 章）
3. QA Agent 在 integration 分支上:
   a. 读取所有接口契约
   b. 编写跨模块集成测试
   c. 验证契约合规性
   d. 验证数据流完整性
   e. 测试异常路径
4. 生成集成测试报告
5. 发送 COMPLETION_SIGNAL 或 ISSUE_REPORT

**Checkpoint CP-5**:
```
- [ ] 所有契约定义的接口都有集成测试
- [ ] 集成测试全部通过（或失败已记录）
- [ ] 集成测试报告格式校验通过
- [ ] 无 P0/P1 级别的集成测试失败
验证者: Coordinator
失败处理: 将 ISSUE 分发给对应的 Dev Agent 修复
```

### 4.7 Phase 7: 代码审查 (Review Agent)

**执行者**: Review Agent
**前置条件**: CP-5 通过

**步骤**:

1. Review Agent 在 integration 分支上审查 `git diff main...integration`
2. 按 6 个维度审查（命名规范、代码结构、设计模式、错误处理、代码重复、最佳实践）
3. 跨 Dev Agent 一致性对比
4. 生成审查报告
5. 发送 COMPLETION_SIGNAL（含判定结果）

**Checkpoint CP-6**:
```
- [ ] 审查报告已生成
- [ ] 审查报告格式校验通过
- [ ] 判定结果非 NEEDS_FIXES
验证者: Coordinator
失败处理: 进入 Phase 8 修复循环
```

### 4.8 Phase 8: 问题修复循环 (Coordinator 协调)

**执行者**: Coordinator 协调，Dev/QA/Review 参与
**前置条件**: Phase 6 或 Phase 7 产出了需修复的问题
**最多 3 轮循环**

```
ROUND = 1
WHILE (存在未解决的 P0/P1 问题 AND ROUND <= 3):

  1. Coordinator 收集所有 ISSUE（QA 的测试失败 + Review 的 CRITICAL/HIGH 发现）
  
  2. Coordinator 按模块分组，分发给对应 Dev Agent
  
  3. Dev Agent 在各自 worktree 中修复 → 生成修复自测报告
  
  4. Coordinator 重新合并到 integration 分支
  
  5. QA Agent 重新运行失败的集成测试
  
  6. Review Agent 重新审查修复的代码
  
  ROUND++

IF (ROUND > 3 AND 仍有 P0 问题):
  升级为人工介入，Coordinator 生成完整问题摘要
```

**Checkpoint CP-7**:
```
- [ ] 所有 P0 问题已解决
- [ ] 所有 P1 问题已解决或已记录为已知限制
- [ ] 最新的集成测试全部通过
- [ ] 最新的代码审查判定非 NEEDS_FIXES
验证者: Coordinator
```

### 4.9 Phase 9: 最终验证与交付 (Coordinator)

**执行者**: Coordinator Agent
**前置条件**: CP-7 通过

**步骤**:

1. 执行最终合并:
   ```bash
   git checkout main
   git merge integration --no-ff -m "feat: [feature-name] complete"
   ```
2. 清理 worktree:
   ```bash
   git worktree remove ../worktree-dev-1
   git worktree remove ../worktree-dev-2
   ```
3. 生成最终交付摘要 `.dev-team/reports/phase-summary-09-delivery.md`
4. 验证 main 分支构建和测试通过
5. 标记所有 TaskList 任务为 completed

---

## 5. 接口契约标准

### 5.1 API 契约格式

```json
{
  "$schema": "dev-team-contract-v1",
  "module": "user-service",
  "version": "1.0.0",
  "owner": "dev-1",
  "created_at": "2025-03-02T10:00:00Z",
  "updated_at": "2025-03-02T10:00:00Z",
  "change_history": [],
  "interfaces": [
    {
      "id": "USR-001",
      "name": "getUserById",
      "type": "function",
      "description": "根据用户 ID 获取用户详情",
      "input": {
        "parameters": [
          {
            "name": "userId",
            "type": "string",
            "required": true,
            "description": "用户唯一标识",
            "constraints": {
              "format": "uuid",
              "example": "550e8400-e29b-41d4-a716-446655440000"
            }
          }
        ]
      },
      "output": {
        "success": {
          "type": "object",
          "schema": {
            "user": {
              "id": "string (uuid)",
              "name": "string",
              "email": "string (email format)",
              "createdAt": "string (ISO 8601)",
              "updatedAt": "string (ISO 8601)"
            }
          },
          "example": {
            "user": {
              "id": "550e8400-e29b-41d4-a716-446655440000",
              "name": "张三",
              "email": "zhangsan@example.com",
              "createdAt": "2025-01-15T08:00:00Z",
              "updatedAt": "2025-03-01T12:30:00Z"
            }
          }
        },
        "errors": [
          {
            "code": "USER_NOT_FOUND",
            "http_status": 404,
            "description": "指定 ID 的用户不存在",
            "schema": { "error": { "code": "string", "message": "string" } }
          },
          {
            "code": "INVALID_USER_ID",
            "http_status": 400,
            "description": "用户 ID 格式不合法"
          }
        ]
      },
      "side_effects": [],
      "idempotent": true,
      "auth_required": true
    }
  ],
  "events": [
    {
      "id": "USR-EVT-001",
      "name": "UserCreated",
      "description": "新用户创建后发出的事件",
      "payload": {
        "userId": "string (uuid)",
        "name": "string",
        "email": "string",
        "createdAt": "string (ISO 8601)"
      },
      "consumers": ["order-service", "notification-service"]
    }
  ]
}
```

### 5.2 数据模型契约格式

```json
{
  "$schema": "dev-team-data-model-v1",
  "version": "1.0.0",
  "entities": [
    {
      "name": "User",
      "table": "users",
      "description": "系统用户",
      "fields": [
        { "name": "id", "type": "uuid", "primary_key": true, "auto_generate": true },
        { "name": "name", "type": "varchar(100)", "nullable": false },
        { "name": "email", "type": "varchar(255)", "nullable": false, "unique": true },
        { "name": "created_at", "type": "timestamp", "nullable": false, "default": "CURRENT_TIMESTAMP" },
        { "name": "updated_at", "type": "timestamp", "nullable": false, "default": "CURRENT_TIMESTAMP" }
      ],
      "indexes": [
        { "name": "idx_users_email", "fields": ["email"], "unique": true }
      ],
      "relationships": [
        {
          "type": "one_to_many",
          "target": "Order",
          "foreign_key": "user_id",
          "description": "一个用户可以有多个订单"
        }
      ]
    }
  ]
}
```

### 5.3 模块依赖契约格式

```json
{
  "$schema": "dev-team-dependency-v1",
  "version": "1.0.0",
  "modules": [
    {
      "name": "user-service",
      "provides": ["USR-001", "USR-002", "USR-EVT-001"],
      "consumes": []
    },
    {
      "name": "order-service",
      "provides": ["ORD-001", "ORD-002"],
      "consumes": [
        {
          "interface_id": "USR-001",
          "from_module": "user-service",
          "usage": "创建订单时验证用户是否存在"
        }
      ]
    }
  ],
  "call_graph": [
    {
      "caller": "order-service",
      "callee": "user-service",
      "interface": "USR-001",
      "call_type": "sync",
      "required": true
    }
  ]
}
```

### 5.4 契约变更流程

```
1. Dev Agent 发现契约需要修改
   ↓
2. Dev 发送 ESCALATION (CONTRACT_CHANGE_REQUEST) 给 Coordinator
   ↓
3. Coordinator 转发给 PM
   ↓
4. PM 评估变更影响:
   a. 查找 dependency-map.json 中所有依赖该接口的模块
   b. 生成影响分析
   ↓
5. PM 决定是否批准变更:
   - 批准: 更新契约文件 + change_history
   - 拒绝: 给出替代方案
   ↓
6. 如批准，Coordinator 通知所有受影响的 Dev Agent
   ↓
7. 受影响的 Dev Agent 按新契约调整实现
```

**契约变更记录格式**:

```json
{
  "change_history": [
    {
      "version": "1.1.0",
      "date": "2025-03-02T14:00:00Z",
      "author": "pm",
      "type": "MODIFY",
      "description": "getUserById 返回值增加 role 字段",
      "affected_interfaces": ["USR-001"],
      "affected_modules": ["order-service"],
      "reason": "业务需求变更: 订单流程需要检查用户角色"
    }
  ]
}
```

---

## 6. 报告标准

### 6.1 Dev 自测报告

**路径**: `.dev-team/reports/dev/self-test-{agent-id}-{task-id}.md`

```markdown
# 自测报告: {Task Title}

## 基本信息

| 字段 | 值 |
|------|-----|
| Agent ID | dev-1 |
| Task ID | T-100 |
| 模块 | user-service |
| 分支 | feat/T-100-user-service |
| 执行时间 | 2025-03-02T11:00:00Z |

## 契约合规性

| 接口 ID | 接口名 | 已实现 | 测试通过 | 备注 |
|---------|--------|--------|---------|------|
| USR-001 | getUserById | YES | PASS | |
| USR-002 | createUser | YES | PASS | |

契约合规率: 2/2 (100%)

## 测试结果

| 指标 | 值 |
|------|-----|
| 测试总数 | 18 |
| 通过 | 17 |
| 失败 | 1 |
| 跳过 | 0 |
| 覆盖率 | 85% |

### 失败测试详情

#### FAIL: updateUser 并发更新冲突处理
- **文件**: tests/unit/user/updateUser.test.ts:42
- **预期**: 抛出 ConflictError
- **实际**: 返回 200 覆盖旧数据
- **严重级别**: P2 (WARNING)

## Mock 依赖

| 依赖模块 | Mock 方式 | 与契约一致性 |
|---------|----------|------------|
| database | In-memory SQLite | 基本一致 |

## 遗留问题

1. [P2] 乐观锁机制未实现

## 总结

- **判定**: PASS_WITH_WARNINGS
- **可交付**: 是
```

### 6.2 QA 集成测试报告

**路径**: `.dev-team/reports/qa/integration-test-{timestamp}.md`

```markdown
# 集成测试报告

## 基本信息

| 字段 | 值 |
|------|-----|
| 执行时间 | 2025-03-02T14:00:00Z |
| 分支 | integration |
| 测试模块 | user-service <-> order-service |

## 测试概览

| 指标 | 值 |
|------|-----|
| 测试用例总数 | 24 |
| 通过 | 22 |
| 失败 | 2 |

## 契约合规验证

| 契约 | 接口 | 请求格式 | 响应格式 | 错误码 |
|------|------|---------|---------|--------|
| user-service | USR-001 | PASS | PASS | PASS |
| order-service | ORD-001 | PASS | PASS | PASS |

## 跨模块数据流验证

### Flow-001: 创建订单时验证用户
```
order-service.createOrder(userId, items)
  -> user-service.getUserById(userId)     [PASS]
  -> 创建订单记录                           [PASS]
  -> 返回订单详情                           [PASS]
```
**结果**: PASS

### Flow-002: 用户不存在时创建订单
**结果**: FAIL
**问题**: order-service 未正确处理 user-service 返回的 404 错误

## 失败详情

### FAIL-001: [P1] 用户不存在时订单服务异常
- **场景**: 调用 createOrder 时传入不存在的 userId
- **预期**: 返回 400 Bad Request
- **实际**: 500 Internal Server Error
- **定位**: src/services/order/createOrder.ts:15
- **修复建议**: 捕获 user-service 的 404 响应，转换为 400

## 总结

- **判定**: NEEDS_FIXES
- **P1 问题**: 2 个
```

### 6.3 Review 代码审查报告

**路径**: `.dev-team/reports/review/code-review-{timestamp}.md`

```markdown
# 代码审查报告

## 基本信息

| 字段 | 值 |
|------|-----|
| 审查时间 | 2025-03-02T15:00:00Z |
| 分支 | integration |
| 文件数 | 24 |
| 变更行数 | +1,850 / -120 |

## 审查概要

| 严重级别 | 数量 |
|---------|------|
| CRITICAL | 1 |
| HIGH | 3 |
| MEDIUM | 5 |
| LOW | 2 |
| **总计** | **11** |

**判定**: NEEDS_FIXES

## 发现列表

### CRITICAL

#### [CR-001] SQL 注入风险
- **文件**: src/services/user/searchUsers.ts:35
- **维度**: 最佳实践 (安全)
- **描述**: 搜索关键词直接拼接到 SQL 查询字符串
- **修复建议**: 使用参数化查询

### HIGH

#### [CR-002] 错误处理模式不一致
- **文件**: 多个文件
- **维度**: 错误处理
- **描述**: user-service 使用自定义 Error 类，order-service 使用普通 Error
- **修复建议**: 统一使用项目的自定义 Error 类体系

#### [CR-003] 日志格式不统一
- **维度**: 代码一致性
- **修复建议**: 统一使用项目约定的 Logger 工具

#### [CR-004] 重复的验证逻辑
- **维度**: 代码重复
- **修复建议**: 提取到 shared/validators.ts

## 跨 Agent 一致性对比

| 维度 | user-service (dev-1) | order-service (dev-2) | 一致性 |
|------|---------------------|----------------------|--------|
| 错误处理 | 自定义 Error 类 | 普通 Error | 不一致 |
| 日志格式 | 结构化 JSON | console.log | 不一致 |
| 命名风格 | camelCase | camelCase | 一致 |
| 测试风格 | describe/it | describe/it | 一致 |
```

### 6.4 Coordinator 阶段摘要

**路径**: `.dev-team/reports/phase-summary-{phase}.md`

```markdown
# 阶段摘要: Phase 4 - 并行开发

## 任务执行状态

| Task ID | 标题 | Agent | 状态 |
|---------|------|-------|------|
| T-100 | UserService | dev-1 | COMPLETED |
| T-200 | OrderService | dev-2 | COMPLETED |

## 并行执行情况

- 并行组 PG-01: T-100, T-200 同时执行
- 最大并行度: 2

## 问题汇总

| 问题 ID | 级别 | 来源 | 状态 |
|---------|------|------|------|
| ISS-001 | P2 | dev-1 | OPEN |

## Checkpoint CP-4 结果

- [x] 所有 Dev Agent 已提交
- [x] 所有自测报告已生成
- [x] 无 P0 问题

**判定**: PASS
```

---

## 7. LLM 行为容错与防护机制

### 7.1 设计动机

本架构中的 Agent 由大语言模型驱动，其行为与确定性程序有本质区别:

| 差异维度 | 确定性程序 | LLM Agent |
|---------|----------|-----------|
| 输出格式 | 编译期保证 | 可能产出不合法的 JSON、遗漏必需字段 |
| 作用域 | 权限系统硬性限制 | 可能越权操作非自己负责的文件 |
| 规则遵守 | 代码逻辑保证 | 长 session 中可能遗忘早期指令 |
| 失败模式 | 明确的异常/错误码 | 可能产出"看起来正常但结构错误"的输出 |

因此，本节定义了一套 **LLM 行为容错机制**，作为第 8 章业务级异常处理的补充。两者的关系:

- **第 8 章 (冲突解决与异常处理)**: 处理业务级问题 — 契约歧义、合并冲突、测试失败
- **第 7 章 (LLM 行为容错)**: 处理 Agent 级问题 — 格式错误、越权操作、注意力衰减

核心原则: **Agent 产出默认不可信，必须经过校验后才进入下一环节。**

---

### 7.2 输出格式校验 (Output Format Validation)

#### 7.2.1 校验目标清单

| 制品 | 产出者 | 校验者 | 校验方式 | 校验时机 |
|------|--------|--------|---------|---------|
| task-manifest.json | PM | Coordinator | JSON Schema | CP-2 |
| dependency-graph.json | PM | Coordinator | JSON Schema + DAG 无环验证 | CP-2 |
| {module}.contract.json | PM | Coordinator | JSON Schema | CP-2 |
| data-models.json | PM | Coordinator | JSON Schema | CP-2 |
| self-test-*.md | Dev | Coordinator | 必需章节检查 | CP-4 |
| integration-test-*.md | QA | Coordinator | 必需章节检查 | CP-5 |
| code-review-*.md | Review | Coordinator | 必需章节检查 | CP-6 |
| ISS-*.json | QA/Review | Coordinator | JSON Schema | 创建时 |

#### 7.2.2 JSON Schema 校验规则

**task-manifest.schema.json（核心字段）**:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["project", "created_by", "created_at", "phases"],
  "properties": {
    "project": { "type": "string", "minLength": 1 },
    "created_by": { "type": "string", "enum": ["pm"] },
    "created_at": { "type": "string", "format": "date-time" },
    "phases": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["id", "name", "tasks"],
        "properties": {
          "id": { "type": "string" },
          "name": { "type": "string" },
          "tasks": {
            "type": "array",
            "items": {
              "type": "object",
              "required": ["id", "title", "module", "acceptance_criteria", "depends_on"],
              "properties": {
                "id": { "type": "string", "pattern": "^T-\\d{3}$" },
                "title": { "type": "string", "minLength": 1 },
                "module": { "type": "string" },
                "parallel": { "type": "boolean" },
                "acceptance_criteria": {
                  "type": "array",
                  "minItems": 1,
                  "items": { "type": "string" }
                },
                "estimated_complexity": {
                  "type": "string",
                  "enum": ["low", "medium", "high"]
                },
                "depends_on": {
                  "type": "array",
                  "items": { "type": "string", "pattern": "^T-\\d{3}$" }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

**contract.schema.json（核心字段）**:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["$schema", "module", "version", "interfaces"],
  "properties": {
    "$schema": { "type": "string", "const": "dev-team-contract-v1" },
    "module": { "type": "string", "minLength": 1 },
    "version": { "type": "string", "pattern": "^\\d+\\.\\d+\\.\\d+$" },
    "interfaces": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["id", "name", "type", "input", "output"],
        "properties": {
          "id": { "type": "string", "pattern": "^[A-Z]{3}-\\d{3}$" },
          "name": { "type": "string" },
          "type": { "type": "string", "enum": ["function", "endpoint", "event"] },
          "input": { "type": "object" },
          "output": {
            "type": "object",
            "required": ["success", "errors"],
            "properties": {
              "success": { "type": "object" },
              "errors": { "type": "array" }
            }
          }
        }
      }
    }
  }
}
```

**dependency-graph.schema.json**:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["nodes", "edges"],
  "properties": {
    "nodes": {
      "type": "array",
      "items": { "type": "string", "pattern": "^T-\\d{3}$" },
      "minItems": 1
    },
    "edges": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["from", "to"],
        "properties": {
          "from": { "type": "string", "pattern": "^T-\\d{3}$" },
          "to": { "type": "string", "pattern": "^T-\\d{3}$" }
        }
      }
    },
    "parallel_groups": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "tasks"],
        "properties": {
          "id": { "type": "string" },
          "tasks": { "type": "array", "items": { "type": "string" } }
        }
      }
    }
  }
}
```

#### 7.2.3 报告格式合规校验

Markdown 报告的校验通过**必需章节检查**实现:

| 报告类型 | 必需章节（H2 标题） | 必需表格关键字 |
|---------|-------------------|--------------|
| Dev 自测报告 | 基本信息, 契约合规性, 测试结果, 总结 | Agent ID, 契约合规率, 测试总数 |
| QA 集成测试报告 | 基本信息, 测试概览, 契约合规验证, 总结 | 测试用例总数, 契约, 接口 |
| Review 审查报告 | 基本信息, 审查概要, 发现列表 | 严重级别, 判定 |
| 阶段摘要 | 任务执行状态, Checkpoint 结果 | Task ID, 状态 |

校验伪代码:

```python
def validate_report_format(report_path: str, report_type: str) -> dict:
    """校验 Markdown 报告是否包含所有必需章节和表格"""
    content = read_file(report_path)

    REQUIRED_SECTIONS = {
        "dev_self_test": ["基本信息", "契约合规性", "测试结果", "总结"],
        "qa_integration": ["基本信息", "测试概览", "契约合规验证", "总结"],
        "review": ["基本信息", "审查概要", "发现列表"],
        "phase_summary": ["任务执行状态", "Checkpoint"]
    }

    REQUIRED_TABLES = {
        "dev_self_test": ["Agent ID", "契约合规率", "测试总数"],
        "qa_integration": ["测试用例总数", "契约", "接口"],
        "review": ["严重级别", "判定"],
        "phase_summary": ["Task ID", "状态"]
    }

    # 提取 H2 标题
    headings = re.findall(r'^## (.+)$', content, re.MULTILINE)

    missing_sections = []
    for required in REQUIRED_SECTIONS[report_type]:
        if not any(required in h for h in headings):
            missing_sections.append(required)

    # 检查表格关键字是否存在
    missing_tables = []
    for keyword in REQUIRED_TABLES[report_type]:
        if keyword not in content:
            missing_tables.append(keyword)

    if missing_sections or missing_tables:
        return {
            "valid": False,
            "error": f"报告缺失章节: {missing_sections}, 缺失表格关键字: {missing_tables}"
        }

    return {"valid": True}
```

#### 7.2.4 校验失败处理流程

```
Coordinator 收到 Agent 产出的制品
  ↓
执行格式校验 (JSON Schema / 报告章节检查)
  ↓
校验通过? ──YES──→ 进入正常流程
  │
  NO
  ↓
attempt = 1
WHILE (attempt <= 2):
  1. Coordinator 发送 VALIDATION_FAILURE 消息给产出 Agent:
     {
       "type": "VALIDATION_FAILURE",
       "target_agent": "{agent_id}",
       "artifact_path": "{file_path}",
       "validation_errors": [
         {
           "error_type": "missing_required_field",
           "field": "phases[0].tasks[0].acceptance_criteria",
           "message": "任务 T-001 缺少 acceptance_criteria 字段（必需字段）"
         }
       ],
       "attempt": attempt,
       "max_attempts": 2,
       "instruction": "请根据以上错误信息修正制品并重新提交"
     }
  2. Agent 修正并重新提交
  3. Coordinator 重新校验
  4. 通过? → 继续; 不通过 → attempt++

IF (attempt > 2):
  1. Coordinator 记录校验失败到 .dev-team/logs/validation-failures.log
  2. 尝试宽松解析:
     - JSON 制品: 尝试修复常见错误（尾部逗号、缺失引号）后重新解析
     - 报告: 接受不完整报告但在 phase-summary 中标记 [FORMAT_WARNING]
  3. 如宽松解析也失败: 升级为人工介入
```

---

### 7.3 行为护栏 (Behavioral Guardrails)

#### 7.3.1 文件系统作用域强制

每个 Agent 的文件操作必须限制在其授权范围内:

| Agent | Write 允许路径 | Edit 允许路径 | 禁止路径 |
|-------|---------------|---------------|---------|
| Coordinator | `.dev-team/reports/phase-summary-*`, `.dev-team/logs/` | (禁止 Edit) | 任何代码文件 |
| PM | `.dev-team/specs/`, `.dev-team/contracts/`, `.dev-team/tasks/` | (禁止 Edit) | 任何代码文件 |
| Dev-N | `{worktree-path}/**`, `.dev-team/reports/dev/self-test-{N}-*` | `{worktree-path}/**` | 其他 Dev 的 worktree, `.dev-team/contracts/` |
| QA | 测试目录, `.dev-team/reports/qa/` | 测试文件 | 实现代码, `.dev-team/contracts/` |
| Review | `.dev-team/reports/review/` | (禁止 Edit) | 所有非报告文件 |

**作用域校验伪代码**（Coordinator 在分配任务时注入到 Agent 的约束中）:

```python
def validate_file_scope(agent_id: str, operation: str, target_path: str, agent_config: dict) -> bool:
    """
    Agent 在每次 Write/Edit 前必须自检。
    Coordinator 在任务分配时将此规则和参数注入到 Agent 的 system prompt 中。
    """
    worktree_path = agent_config.get("worktree_path", "")
    allowed_paths = agent_config["allowed_paths"][operation]
    forbidden_paths = agent_config.get("forbidden_paths", [])

    # 1. 检查是否在禁止路径中
    for forbidden in forbidden_paths:
        if target_path.startswith(forbidden):
            return False  # SCOPE_VIOLATION

    # 2. 检查是否在允许路径中
    for allowed in allowed_paths:
        pattern = allowed.replace("{worktree-path}", worktree_path)
        pattern = pattern.replace("{N}", agent_id.split("-")[1])
        if fnmatch(target_path, pattern):
            return True

    return False  # 默认拒绝
```

**作用域违规处理规则**:

```
规则 GUARD-01: Agent 的 system prompt 中必须包含其允许操作的路径白名单
规则 GUARD-02: Coordinator 在任务分配消息中必须明确列出 worktree 路径和允许的输出路径
规则 GUARD-03: 作用域违规发生时，Coordinator 执行以下恢复:
  1. 记录违规到 .dev-team/logs/scope-violations.log
  2. 如果文件已被错误修改，使用 git checkout 恢复
  3. 向违规 Agent 发送警告消息，附带正确的路径约束
  4. 重新执行该步骤
```

#### 7.3.2 Git 分支保护

```
规则 GUARD-04: Dev Agent 在执行 git commit 前，必须运行 `git branch --show-current`
             并验证输出与任务分配的分支名一致
规则 GUARD-05: 禁止任何 Agent 直接在 main 或 integration 分支上执行 git commit
规则 GUARD-06: Coordinator 在合并操作前，验证 feature 分支的 base commit 是否在预期的基线上
```

分支保护校验脚本:

```bash
# Dev Agent 在 commit 前必须执行的检查
EXPECTED_BRANCH="feat/T-100-user-service"  # 从任务分配中获取
CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" != "$EXPECTED_BRANCH" ]; then
    echo "BRANCH_VIOLATION: 当前分支 $CURRENT_BRANCH 不是预期分支 $EXPECTED_BRANCH"
    echo "操作已中止。请通过 Coordinator 确认分支信息。"
    exit 1
fi

# 额外检查: 确保不在保护分支上
PROTECTED_BRANCHES=("main" "master" "integration")
for branch in "${PROTECTED_BRANCHES[@]}"; do
    if [ "$CURRENT_BRANCH" == "$branch" ]; then
        echo "PROTECTED_BRANCH_VIOLATION: 不允许在 $branch 分支上直接提交"
        exit 1
    fi
done
```

#### 7.3.3 契约只读强制 (Hash-Based Integrity)

契约文件在 Phase 2 结束后应被视为只读。Coordinator 使用哈希校验确保契约未被篡改:

```
初始化（CP-2 通过后）:
  1. Coordinator 对所有契约文件计算 SHA-256 哈希
  2. 写入 .dev-team/validators/checksums/contract-hashes.json:
     {
       "generated_at": "2025-03-02T10:30:00Z",
       "hashes": {
         ".dev-team/contracts/user-service.contract.json": "a1b2c3...",
         ".dev-team/contracts/order-service.contract.json": "d4e5f6...",
         ".dev-team/contracts/data-models.json": "789abc..."
       }
     }

检查点校验（CP-4, CP-5, CP-6）:
  1. Coordinator 重新计算所有契约文件哈希
  2. 与 contract-hashes.json 中的记录比对
  3. 不一致 → 触发 CONTRACT_TAMPERING 警报:
     - 记录到 .dev-team/logs/scope-violations.log
     - 使用 git checkout 恢复契约文件到正确版本
     - 识别可能的篡改者（通过 git blame）
     - 重新运行受影响的校验

例外: PM 通过正式的契约变更流程修改契约时，Coordinator 同步更新哈希记录。
```

#### 7.3.4 工具调用审计

```
规则 GUARD-07: Coordinator 在 .dev-team/logs/tool-audit.jsonl 中记录所有关键工具调用:
  {
    "timestamp": "2025-03-02T11:15:00Z",
    "agent_id": "dev-1",
    "tool": "Write",
    "target_path": "src/services/user/index.ts",
    "within_scope": true,
    "phase": "Phase 4"
  }

规则 GUARD-08: 每个 Checkpoint 时，Coordinator 审计工具调用日志:
  - 统计各 Agent 的 Write/Edit 操作路径
  - 标记任何超出预期范围的操作
  - 写入 phase-summary 报告的 "工具调用审计" 章节
```

---

### 7.4 注意力衰减对策 (Attention Decay Mitigation)

LLM Agent 在长 session 中会逐渐"遗忘"早期注入的规则。以下机制确保关键规则持续生效。

#### 7.4.1 规则重注入触发器

| 触发条件 | 重注入内容 | 执行者 |
|---------|----------|--------|
| 每个 Phase 开始时 | 该 Agent 的完整行为规则 | Coordinator |
| 每个任务分配时 | 与该任务相关的核心规则子集 | Coordinator |
| Agent 连续 10 次工具调用后 | 作用域约束和禁止操作列表 | Agent 自检 |
| Checkpoint 校验时 | 校验标准和通过条件 | Coordinator |
| 检测到一次轻微违规后 | 完整行为规则 + 违规提醒 | Coordinator |

#### 7.4.2 任务分配消息中的规则提醒模板

Coordinator 在通过 SendMessage 分配任务时，必须使用以下模板结构:

```json
{
  "type": "TASK_ASSIGNMENT",
  "target_agent": "dev-1",
  "task_id": "T-100",
  "task_description": "按照 user-service.contract.json 实现 UserService 模块",
  "worktree_path": "../worktree-dev-1",
  "branch": "feat/T-100-user-service",
  "contract_refs": [".dev-team/contracts/user-service.contract.json"],
  "rule_reminder": {
    "critical_rules": [
      "DEV-01: 开始任务前必须读取最新的接口契约文件",
      "DEV-02: 实现必须严格符合契约定义的输入输出格式",
      "DEV-04: 发现契约歧义时，不得自行假设，必须上报",
      "DEV-09: 每次 Write/Edit 前验证目标路径在 worktree 内",
      "DEV-10: git commit 前验证当前分支名",
      "DEV-11: 不得修改 .dev-team/contracts/ 目录下的任何文件"
    ],
    "scope_constraints": {
      "write_allowed": ["../worktree-dev-1/**", ".dev-team/reports/dev/self-test-dev1-*"],
      "write_forbidden": ["../worktree-dev-2/**", ".dev-team/contracts/**"],
      "git_branch": "feat/T-100-user-service",
      "git_protected": ["main", "master", "integration"]
    }
  }
}
```

#### 7.4.3 上下文刷新机制

当 Agent 的上下文窗口接近容量限制时，需要主动刷新:

```
上下文刷新策略:

1. 预防性刷新:
   - Agent 每完成一个子任务后，在下一个子任务的 prompt 中重新注入:
     a. 当前任务的完整描述和验收标准
     b. 相关契约文件的关键接口定义
     c. 行为规则摘要

2. Agent 自检机制:
   - Agent 在每次重要操作前（提交代码、生成报告）执行自检:
     a. 重新读取接口契约文件
     b. 对照契约检查实现
     c. 确认操作路径在允许范围内

3. Coordinator 监控:
   - Coordinator 跟踪每个 Agent 的消息轮次数
   - 超过 20 轮交互后，在下一条消息中插入完整规则重注入
   - 超过 40 轮交互后，建议终止当前 session 并启动新 session
     （将已完成的工作作为上下文传递给新 session）
```

---

### 7.5 优雅降级 (Graceful Degradation)

当容错机制无法自动恢复时，系统按以下降级路径处理:

#### 7.5.1 不可解析输出的回退策略

```
L1 (自动修复): JSON 语法错误
  → 尝试修复常见问题（尾部逗号、单引号替换、缺失括号）
  → 修复后重新校验

L2 (引导重试): JSON 结构错误（缺字段、错误类型）
  → 返回具体的校验错误列表
  → 附带正确格式的示例片段
  → 要求 Agent 重新生成（最多 2 次）

L3 (宽松解析): 重试 2 次仍失败
  → 对 JSON 制品: 提取可用部分，缺失字段用默认值填充，标记 [PARTIAL_PARSE]
  → 对 Markdown 报告: 接受不完整报告，在 phase-summary 中标记 [FORMAT_WARNING]

L4 (人工介入): 宽松解析也失败
  → 生成完整的上下文转储: 原始输出 + 校验错误 + Agent 消息历史
  → 写入 .dev-team/logs/escalation-{timestamp}.md
  → 暂停流水线等待人工处理
```

#### 7.5.2 作用域违规的回滚机制

```
检测到作用域违规（Agent 写入了未授权路径的文件）:

1. 立即操作:
   a. 记录违规详情到 .dev-team/logs/scope-violations.log
   b. 使用 git diff 确认被修改的文件列表
   c. 对每个未授权修改的文件: git checkout HEAD -- {file_path}
   d. 验证恢复成功

2. 影响评估:
   a. 检查违规 Agent 的其他产出是否受影响
   b. 如果违规 Agent 修改了另一个 Agent 的代码:
      - 通知受影响 Agent 重新验证其产出
      - 如有必要，从最后一个已验证 commit 重新开始

3. 根因分析:
   a. 检查任务分配消息是否包含了正确的路径约束
   b. 检查是否是注意力衰减导致（交互轮次 > 20?）
   c. 如果是系统性问题，增强 rule_reminder 中的约束描述
```

#### 7.5.3 检查点反复失败的升级路径

```
Checkpoint 失败升级路径:

第 1 次失败:
  → Coordinator 生成具体的失败原因列表
  → 分发给相关 Agent 修复
  → 重新执行 Checkpoint

第 2 次失败:
  → Coordinator 分析是否是同一原因
  → 如果是新问题: 继续修复循环
  → 如果是同一问题:
    a. 重新注入完整规则给相关 Agent
    b. 在修复任务中附带前两次失败的具体错误和 diff
    c. 重新执行

第 3 次失败:
  → 升级为人工介入
  → Coordinator 生成完整上下文转储:
    {
      "checkpoint_id": "CP-4",
      "failure_count": 3,
      "failure_history": [
        {"attempt": 1, "errors": [...], "agent_actions": [...]},
        {"attempt": 2, "errors": [...], "agent_actions": [...]},
        {"attempt": 3, "errors": [...], "agent_actions": [...]}
      ],
      "related_artifacts": ["file paths..."],
      "agent_message_history_summary": "...",
      "suggested_human_action": "检查 PM 的任务分解是否合理，或 Agent 是否需要更明确的指令"
    }
  → 写入 .dev-team/logs/escalation-{timestamp}.md
  → 暂停流水线
```

#### 7.5.4 Token 预算感知与上下文重启

```
Token 预算管理策略:

监控指标:
  - 每个 Agent 的累计交互轮次
  - 单轮消息的大致 token 长度
  - 复杂任务的子步骤进度

阈值定义:
  | Agent 类型 | 预估轮次 | 警告阈值 | 强制刷新阈值 |
  |-----------|---------|---------|------------|
  | PM 需求分析 | 5-10 | 15 | 25 |
  | PM 任务分解 | 10-20 | 25 | 40 |
  | Dev 模块开发 | 15-30 | 35 | 50 |
  | QA 集成测试 | 10-20 | 25 | 40 |
  | Review 代码审查 | 5-10 | 15 | 25 |

到达警告阈值:
  → Coordinator 在下一条消息中插入完整规则重注入
  → Agent 在下一次子任务切换时进行上下文精简（丢弃中间调试信息，保留结论）

到达强制刷新阈值:
  → Coordinator 触发 "上下文重启":
    1. Agent 提交当前所有已完成的工作（代码 commit + 中间报告）
    2. Coordinator 生成「任务续接摘要」:
       - 已完成的子任务列表
       - 当前进行中的子任务状态
       - 未完成的子任务列表
       - 关键决策和已解决的问题摘要
    3. 启动新的 Agent session，注入:
       - 完整行为规则
       - 任务续接摘要
       - 未完成子任务的上下文
    4. 新 session 从上次中断点继续
```

---

### 7.6 校验脚本与工具目录

在 `.dev-team/validators/` 目录中提供标准化的校验工具:

```
.dev-team/validators/
├── validate-json-schema.py        # JSON Schema 通用校验器
├── validate-report-format.py      # 报告格式校验器
├── validate-dag.py                # DAG 无环验证
├── check-contract-integrity.py    # 契约哈希完整性校验
├── schemas/                       # JSON Schema 定义文件
│   ├── task-manifest.schema.json
│   ├── contract.schema.json
│   ├── dependency-graph.schema.json
│   ├── data-models.schema.json
│   └── issue.schema.json
└── checksums/                     # 契约完整性哈希
    └── contract-hashes.json       # CP-2 后由 Coordinator 生成
```

**validate-json-schema.py 核心逻辑**:

```python
#!/usr/bin/env python3
"""JSON Schema 通用校验器 - Coordinator 在 Checkpoint 时调用"""
import json
import sys
from pathlib import Path

def validate(artifact_path: str, schema_path: str) -> dict:
    """
    校验 JSON 制品是否符合 Schema。
    返回: {"valid": bool, "errors": list[str]}
    """
    # Step 1: 检查文件是否可解析为 JSON
    try:
        with open(artifact_path, 'r') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        return {
            "valid": False,
            "errors": [f"JSON 解析失败 (行 {e.lineno}, 列 {e.colno}): {e.msg}"]
        }

    # Step 2: 加载 Schema
    with open(schema_path, 'r') as f:
        schema = json.load(f)

    # Step 3: 校验 required 字段
    errors = []
    for field in schema.get("required", []):
        if field not in data:
            errors.append(f"缺少必需字段: '{field}'")

    # Step 4: 递归检查字段类型和约束
    errors.extend(check_properties(data, schema.get("properties", {})))

    return {"valid": len(errors) == 0, "errors": errors}

if __name__ == "__main__":
    result = validate(sys.argv[1], sys.argv[2])
    print(json.dumps(result, ensure_ascii=False, indent=2))
    sys.exit(0 if result["valid"] else 1)
```

**Coordinator 在 Checkpoint 中调用校验的流程**:

```bash
# CP-2 校验示例
python3 .dev-team/validators/validate-json-schema.py \
  .dev-team/tasks/task-manifest.json \
  .dev-team/validators/schemas/task-manifest.schema.json

python3 .dev-team/validators/validate-dag.py \
  .dev-team/tasks/dependency-graph.json

for contract in .dev-team/contracts/*.contract.json; do
  python3 .dev-team/validators/validate-json-schema.py \
    "$contract" \
    .dev-team/validators/schemas/contract.schema.json
done

# CP-4 契约完整性校验
python3 .dev-team/validators/check-contract-integrity.py \
  .dev-team/validators/checksums/contract-hashes.json

# CP-4 报告格式校验
python3 .dev-team/validators/validate-report-format.py \
  .dev-team/reports/dev/self-test-dev1-T100.md \
  --type dev_self_test
```

---

## 8. 冲突解决与异常处理

### 8.1 优先级系统

| 级别 | 定义 | 响应要求 | 示例 |
|------|------|---------|------|
| **P0 (CRITICAL)** | 阻塞整个流水线 | 立即处理 | 安全漏洞、核心崩溃、数据丢失 |
| **P1 (HIGH)** | 阻塞当前阶段 | 当前阶段内修复 | 契约违规、集成失败、关键逻辑错误 |
| **P2 (MEDIUM)** | 不阻塞，交付前修复 | 最终交付前 | 性能问题、非核心缺陷、代码质量 |
| **P3 (LOW)** | 改进建议 | 无硬性要求 | 代码风格、文档改进、可选优化 |

### 8.2 场景化冲突解决

#### 场景 A: Dev Agent 发现契约歧义

```
1. Dev 发送 ESCALATION (CONTRACT_AMBIGUITY) → Coordinator
2. Coordinator 标记 Dev 任务为 BLOCKED
3. Coordinator 转发给 PM
4. PM 裁定并更新契约
5. Coordinator 通知 Dev，解除 BLOCKED
6. Dev 按新契约继续

超时保护: PM 10 分钟未响应 → 采纳 Dev 的 suggested_resolution 作为临时方案
```

#### 场景 B: QA 发现契约违规

```
1. QA 发送 ISSUE_REPORT (CONTRACT_VIOLATION) → Coordinator
2. Coordinator 确定负责的 Dev Agent
3. 二次判定:
   - 「实现错误」→ Dev 修复实现
   - 「契约不合理」→ 升级给 PM 裁定
4. Dev 修复 → QA 重新验证
```

#### 场景 C: Review 发现跨 Agent 不一致

```
1. Review 在报告中记录不一致点
2. 确定「正确模式」:
   - 有项目规范 → 以规范为准
   - 无规范 → 以先完成的 Agent 为准
   - 两种都合理 → 升级给 PM 裁定
3. Coordinator 将修改任务分发给各 Dev Agent
4. Review 重新审查该维度
```

#### 场景 D: Dev Agent 失败或超时

```
1. Coordinator 检测到超时 (5 分钟无 STATUS_UPDATE)
2. 发送 HEARTBEAT_CHECK → 等待 2 分钟
3. 仍无响应:
   - 评估影响范围
   - 第 1 次重试: 同一 worktree 重新启动
   - 第 2 次重试: 新 worktree 从最后 commit 点重新开始
   - 第 3 次: 升级为人工介入
```

### 8.3 问题记录格式

```json
{
  "id": "ISS-001",
  "title": "getUserById 响应缺少 createdAt 字段",
  "severity": "P1",
  "category": "CONTRACT_VIOLATION",
  "status": "OPEN",
  "reported_by": "qa",
  "assigned_to": "dev-1",
  "created_at": "2025-03-02T14:30:00Z",
  "resolved_at": null,
  "description": "集成测试发现 getUserById 返回的对象缺少 createdAt 字段",
  "evidence": {
    "contract_file": ".dev-team/contracts/user-service.contract.json",
    "interface_id": "USR-001",
    "expected": "返回包含 createdAt 的完整 User 对象",
    "actual": "返回的 User 对象缺少 createdAt 字段"
  },
  "resolution": null,
  "related_tasks": ["T-100"],
  "fix_tasks": []
}
```

---

## 9. Git Worktree 策略

### 9.1 分支模型

```
main
 │
 ├── integration                    (QA/Review 工作分支)
 │    ├── feat/T-100-user-service   (Dev-1 feature 分支)
 │    ├── feat/T-200-order-service  (Dev-2 feature 分支)
 │    └── feat/T-300-payment        (Dev-3 feature 分支)
 │
 └── fix/ISS-001-missing-field      (修复分支，按需创建)
```

### 9.2 Worktree 生命周期

#### 创建阶段 (Phase 3)

```bash
# Coordinator 为每个 Dev Agent 创建独立 worktree
# 约定: worktree 放在主仓库的同级目录

# 确保 main 是最新的
git fetch origin main

# 为 Dev-1 创建 worktree
git worktree add ../worktree-dev-1 -b feat/T-100-user-service main

# 为 Dev-2 创建 worktree
git worktree add ../worktree-dev-2 -b feat/T-200-order-service main

# 确认 worktree 列表
git worktree list
```

#### 开发阶段 (Phase 4-5)

每个 Dev Agent 在自己的 worktree 中独立工作:

```bash
# Dev-1 在 worktree-dev-1 中工作
cd ../worktree-dev-1

# 正常的开发流程
# ... 编码 ...
git add .
git commit -m "feat(user-service): implement getUserById"

# ... 继续编码 ...
git add .
git commit -m "test(user-service): add unit tests for getUserById"
```

#### 集成阶段 (Phase 6)

```bash
# Coordinator 创建 integration 分支
git checkout -b integration main

# 按依赖顺序合并 (无环形依赖，拓扑排序后合并)
git merge feat/T-100-user-service --no-ff -m "merge: T-100 user-service"
# 如果冲突 → 见冲突解决协议

git merge feat/T-200-order-service --no-ff -m "merge: T-200 order-service"
```

#### 清理阶段 (Phase 9)

```bash
# 最终合并到 main
git checkout main
git merge integration --no-ff -m "feat: [feature-name] complete"

# 清理所有 worktree
git worktree remove ../worktree-dev-1
git worktree remove ../worktree-dev-2

# 删除已合并的分支
git branch -d feat/T-100-user-service
git branch -d feat/T-200-order-service
git branch -d integration
```

### 9.3 合并冲突解决协议

```
冲突检测:
  Coordinator 在合并时检测到冲突

冲突分类:
  A. 文件级冲突 (不同 Dev 修改了同一文件)
     → 常见于共享配置文件、路由定义等
  
  B. 语义级冲突 (代码可合并但语义矛盾)
     → 例如两个模块对同一个常量使用了不同的值

处理流程:
  1. Coordinator 识别冲突文件和涉及的 Dev Agent
  
  2. 按优先级决定合并顺序:
     - 基础设施模块优先
     - 被依赖多的模块优先
     - 同等优先级时，先完成的 Dev 优先
  
  3. 先合并优先级高的分支
  
  4. 通知优先级低的 Dev Agent:
     "你的分支需要 rebase 到最新的 integration 分支"
  
  5. Dev Agent 在自己的 worktree 中执行:
     git fetch origin integration
     git rebase integration
     # 解决冲突
     git rebase --continue
  
  6. Dev Agent 完成 rebase 后通知 Coordinator
  
  7. Coordinator 重新执行合并

极端情况:
  如果冲突无法由单个 Dev 解决（涉及架构级变更）:
  → 升级给 PM 重新审视模块边界
  → 可能需要重新分解任务
```

### 9.4 Worktree 目录约定

```
/Users/wylonyu/selfProjects/
├── SkillsMaster/                  # 主仓库 (main 分支)
├── worktree-dev-1/                # Dev-1 的工作目录
├── worktree-dev-2/                # Dev-2 的工作目录
├── worktree-dev-N/                # Dev-N 的工作目录
└── worktree-integration/          # 可选: QA 的独立 worktree
```

每个 worktree 共享同一个 `.git` 目录，因此:
- 分支操作不会互相干扰
- 文件系统完全隔离
- 可以真正并行构建和测试

---

## 10. 附录

### 10.1 术语表

| 术语 | 英文 | 定义 |
|------|------|------|
| 契约 | Contract | 模块间接口的形式化定义，包含输入输出格式、错误码等 |
| 检查点 | Checkpoint | 阶段间的强制验证关卡，未通过不得进入下一阶段 |
| 工作树 | Worktree | Git 的多工作目录功能，允许同一仓库同时检出多个分支 |
| 自测报告 | Self-Test Report | Dev Agent 完成任务后生成的单元测试结果和契约合规性报告 |
| 星型路由 | Star Routing | 所有 Agent 通信必须经过 Coordinator 中转的通信模式 |
| DAG | Directed Acyclic Graph | 有向无环图，用于表示任务间的依赖关系 |
| LLM 容错 | LLM Fault Tolerance | 针对大语言模型 Agent 可能出现的格式错误、越权、注意力衰减等行为的防护和恢复机制 |
| 行为护栏 | Behavioral Guardrails | 通过路径白名单、分支保护、哈希校验等手段限制 Agent 操作范围的机制 |
| 注意力衰减 | Attention Decay | LLM 在长 session 中逐渐遗忘早期注入规则的现象 |

### 10.2 设计决策记录

| 决策 | 选项 | 选定 | 理由 |
|------|------|------|------|
| 通信模式 | 直连 / 星型 / 总线 | 星型 | Coordinator 可审计和控制所有通信 |
| 契约格式 | YAML / JSON / Protobuf | JSON | 机器可解析，Agent 原生支持 |
| 报告格式 | JSON / Markdown / HTML | Markdown | 人类可读，Git 友好 |
| 并行隔离 | 分支 / Worktree / 容器 | Worktree | 轻量、文件系统隔离、共享 .git |
| 协调模式 | PM 兼任 / 独立 Coordinator | 独立 | 职责分离，PM 专注分析，Coordinator 专注调度 |
| 容错策略 | 信任模型 / 校验优先 / 人工兆底 | 校验优先 | Agent 产出默认不可信，必须经过格式校验后才进入下一阶段 |

### 10.3 从本文档到实现的路径

本文档是纯设计文档，后续实现步骤:

1. **Phase A**: 为每个 Agent 创建 `subagent.md` 配置文件（基于第 2 章定义）
2. **Phase B**: 实现 `.dev-team/` 目录初始化脚本
3. **Phase C**: 编写 Coordinator 的调度逻辑（基于第 4 章工作流）
4. **Phase D**: 创建契约模板和报告模板（基于第 5、6 章标准）
5. **Phase E**: 端到端集成测试（模拟完整的 9 阶段流程）

### 10.4 与 SkillsMaster 现有模式的映射

| 本文档概念 | SkillsMaster 对应模式 | 来源 |
|-----------|---------------------|------|
| 9 阶段流水线 | specify → plan → tasks → implement → review → summarize | PrizmKit |
| Checkpoint | `[CP-N]` 检查点任务 | prizmkit-tasks |
| 任务 ID 编号 | `[T-001]`, `[T-010]`, `[T-100]` | prizmkit-tasks |
| 接口契约 | `contracts/` 目录 | prizmkit-plan |
| 审查维度和判定 | CRITICAL/HIGH/MEDIUM/LOW + PASS/NEEDS_FIXES | prizmkit-code-review |
| 问题严重级别 | 严重/警告/建议 三级 | git-diff-requirement |
| 用户确认检查点 | Phase 2 后必须等待用户确认 | git-diff-requirement |
| 制品目录结构 | `.prizmkit/specs/` | PrizmKit |
| 变更历史记录 | `change_history` 数组 | 契约版本管理最佳实践 |
