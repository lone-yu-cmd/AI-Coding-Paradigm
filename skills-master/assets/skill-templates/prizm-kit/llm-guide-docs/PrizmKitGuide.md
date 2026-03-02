# PrizmKit 命令系统架构 — 完整依赖关系图

## 一、核心命令流（主干管线）

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    PrizmKit 命令执行管线 (Pipeline)                       │
│                                                                         │
│   ┌──────────────────────────┐                                          │
│   │   prizmkit.init          │  ◄── 基础层（项目接管，首次必需）           │
│   │   项目初始化 & 文档生成    │                                          │
│   └──────────┬───────────────┘                                          │
│              │ .prizm-docs/ + .prizmkit/ 就绪                            │
│              ▼                                                          │
│   ┌──────────────────────────┐      ┌─────────────────────┐             │
│   │  prizmkit.specify        │─────►│  prizmkit.clarify   │             │
│   │  功能规格说明             │◄─────│  需求澄清            │             │
│   └──────────┬───────────────┘      └─────────────────────┘             │
│              │ spec.md 就绪                                              │
│              ▼                                                          │
│   ┌──────────────────────────┐                                          │
│   │  prizmkit.plan           │                                          │
│   │  实施计划                 │                                          │
│   └──────────┬───────────────┘                                          │
│              │ plan.md + 设计文档就绪                                     │
│              ▼                                                          │
│   ┌──────────────────────────┐                                          │
│   │  prizmkit.tasks          │                                          │
│   │  任务分解                 │                                          │
│   └──────────┬───────────────┘                                          │
│              │ tasks.md 就绪                                             │
│              ▼                                                          │
│   ┌──────────────────────────┐                                          │
│   │  prizmkit.analyze        │  ◄── 一致性分析（推荐）                    │
│   │  交叉文档一致性检查        │                                          │
│   └──────────┬───────────────┘                                          │
│              │ 分析通过                                                   │
│              ▼                                                          │
│   ┌──────────────────────────┐      ┌───────────────────────┐           │
│   │  prizmkit.implement      │─────►│ prizmkit.code-review  │           │
│   │  执行实施                 │◄─────│ 代码审查（只读）       │           │
│   └──────────┬───────────────┘      └───────────────────────┘           │
│              │ 代码实施完成                                               │
│              ▼                                                          │
│   ┌──────────────────────────┐      ┌───────────────────────┐           │
│   │  prizmkit.summarize      │─────►│ prizmkit.retrospective│           │
│   │  功能摘要归档             │      │ 回顾学习（可选）       │           │
│   └──────────┬───────────────┘      └───────────────────────┘           │
│              │ REGISTRY.md 更新                                          │
│              ▼                                                          │
│   ┌──────────────────────────┐                                          │
│   │  prizmkit.committer      │  ◄── 提交层（自动同步 Prizm 文档）        │
│   │  提交 + 文档同步          │                                          │
│   └──────────────────────────┘                                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 辅助命令（可随时调用）

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    PrizmKit 辅助命令 (Utility Skills)                     │
│                                                                         │
│   ┌─── 文档管理 ──────────────────────────────────────────────────┐      │
│   │ prizmkit.doc.init / .update / .status / .rebuild / .validate │      │
│   │ prizmkit.doc.migrate                                         │      │
│   └──────────────────────────────────────────────────────────────┘      │
│                                                                         │
│   ┌─── 质量保障 ──────────────────────────────────────────────────┐      │
│   │ prizmkit.security-audit      [Tier 2] 安全漏洞扫描              │      │
│   │ prizmkit.dependency-health   [Tier 2] 依赖健康检查              │      │
│   │ prizmkit.tech-debt           [Tier 1] 技术债务追踪              │      │
│   └──────────────────────────────────────────────────────────────┘      │
│                                                                         │
│   ┌─── 运维部署 ──────────────────────────────────────────────────┐      │
│   │ prizmkit.ci-cd               [Tier 2] CI/CD 管线生成            │      │
│   │ prizmkit.deploy-plan         [Tier 2] 部署策略规划              │      │
│   │ prizmkit.db-migrate          [Tier 2] 数据库迁移规划            │      │
│   │ prizmkit.monitoring          [Tier 2] 监控告警配置              │      │
│   └──────────────────────────────────────────────────────────────┘      │
│                                                                         │
│   ┌─── 调试排障 ──────────────────────────────────────────────────┐      │
│   │ prizmkit.error-triage        [Tier 2] 错误分类 & 根因分析       │      │
│   │ prizmkit.analyze-logs        [Tier 2] 日志模式分析              │      │
│   │ prizmkit.perf-profile        [Tier 2] 性能瓶颈识别              │      │
│   │ prizmkit.bug-reproduce       [Tier 1] 最小复现脚本生成           │      │
│   └──────────────────────────────────────────────────────────────┘      │
│                                                                         │
│   ┌─── 知识管理 ──────────────────────────────────────────────────┐      │
│   │ prizmkit.onboarding          [Tier 2] 新人入职指南生成           │      │
│   │ prizmkit.api-docs            [Tier 2] API 文档自动生成           │      │
│   │ prizmkit.adr.new / .list / .supersede  [Tier 1] 架构决策记录管理 │      │
│   └──────────────────────────────────────────────────────────────┘      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 二、命令间依赖关系矩阵

```
                          ┌─ 前置依赖 ───────────────────────────────────────────────┐
                          │                                                          │
命令                      │ .prizm-docs/  .prizmkit/  spec.md  plan.md  tasks.md     │
──────────────────────────┼──────────────────────────────────────────────────────────┤
init                      │     -           -          -        -        -           │
doc.*                     │   必需          -          -        -        -           │
specify                   │   推荐        必需         -        -        -           │
clarify                   │   推荐        必需       必需       -        -           │
plan                      │   必需        必需       必需       -        -           │
tasks                     │   必需        必需       必需     必需       -           │
analyze                   │   必需        必需       必需     必需     推荐          │
implement                 │   必需        必需       必需     必需     必需          │
code-review               │   推荐        必需       必需     必需     必需          │
summarize                 │     -         必需       必需     必需     必需          │
committer                 │   必需          -          -        -        -           │
retrospective             │   推荐        必需       必需     必需     必需          │
security-audit            │   推荐          -          -        -        -           │
dependency-health         │     -           -          -        -        -           │
tech-debt                 │   推荐          -          -        -        -           │
ci-cd                     │   推荐          -          -        -        -           │
deploy-plan               │   推荐          -          -        -        -           │
db-migrate                │   推荐          -          -        -        -           │
monitoring                │   推荐          -          -        -        -           │
error-triage              │   推荐          -          -        -        -           │
analyze-logs              │     -           -          -        -        -           │
perf-profile              │   推荐          -          -        -        -           │
bug-reproduce             │   推荐          -          -        -        -           │
onboarding                │   必需          -          -        -        -           │
api-docs                  │   推荐          -          -        -        -           │
adr.*                     │   推荐          -          -        -        -           │
                          └──────────────────────────────────────────────────────────┘

图例: 必需 = 缺少则报错  推荐 = 缺少会警告  - = 无依赖
```

---

## 三、每个命令的输入/输出/依赖

### A. 基础层

#### ① prizmkit.init — 项目接管 & 初始化

- **用途**: 扫描任何项目（棕地或绿地），生成 Prizm 文档框架，配置钩子
- **输入**: 项目源码、构建文件（package.json、requirements.txt、go.mod 等）
- **模板**:
  - `${SKILL_DIR}/assets/hooks/prizm-commit-hook.json`（钩子模板）
  - `${SKILL_DIR}/assets/codebuddy-md-template.md`（CODEBUDDY.md 模板）
- **脚本**: 无
- **输出**:
  - `.prizm-docs/root.prizm`（L0 项目元数据）
  - `.prizm-docs/<module>.prizm`（L1 模块文档）
  - `.prizm-docs/changelog.prizm`
  - `.prizmkit/config.json`
  - `.prizmkit/specs/` 目录
  - `ASSESSMENT.md`（技术债务评估）
  - 更新 `.codebuddy/settings.json`（注入钩子）
  - 更新 `CODEBUDDY.md`（追加渐进加载协议）
- **关键行为**:
  - 自动检测技术栈（语言、框架、构建工具、测试工具）
  - 映射目录结构生成 L0 MODULE_INDEX
  - 为核心目录生成 L1 模块文档
  - 支持三种采纳模式: passive → advisory → active
  - 棕地项目生成 ASSESSMENT.md 评估现有技术债务
- **Handoff**: `prizmkit.specify` 或 `prizmkit.doc.migrate`

### B. 文档框架

#### ② prizmkit.doc.* — Prizm 文档管理

- **用途**: 管理 AI 专用的三层渐进式加载文档体系
- **命令集**:
  - `prizmkit.doc.init` — 初始化 .prizm-docs/
  - `prizmkit.doc.update` — 根据代码变更同步文档
  - `prizmkit.doc.status` — 检查文档新鲜度
  - `prizmkit.doc.rebuild <module>` — 从零重建模块文档
  - `prizmkit.doc.validate` — 格式合规性和一致性检查
  - `prizmkit.doc.migrate` — 将已有文档转换为 .prizm-docs/ 格式
- **规格文件**: `${SKILL_DIR}/assets/PRIZM-SPEC.md`
- **输出**:
  - `.prizm-docs/root.prizm`（L0，≤4KB）
  - `.prizm-docs/<module>.prizm`（L1，≤3KB 每文件）
  - `.prizm-docs/<module>/<submodule>.prizm`（L2，≤5KB 每文件）
  - `.prizm-docs/changelog.prizm`（追加式，保留最近 50 条）
- **关键行为**:
  - L0 在会话开始时**始终加载**
  - L1 在操作相关模块时**按需加载**
  - L2 在首次修改子模块时**延迟生成**（非初始化时创建）
  - 格式: KEY: value 纯文本，无注释，无装饰
  - 文档大小强制限制，防止膨胀
- **Handoff**: 被所有其他命令隐式依赖

### C. 规格驱动工作流（8 个技能）

#### ③ prizmkit.specify — 功能规格说明

- **用途**: 从自然语言描述创建结构化功能规格
- **输入**: 用户的功能描述文本
- **模板**: `${SKILL_DIR}/assets/spec-template.md`
- **输出**:
  - `.prizmkit/specs/###-feature-name/` 目录
  - `spec.md`（用户故事、验收标准、范围边界）
  - `checklists/requirements.md`（规格质量检查清单）
- **关键行为**:
  - 聚焦 WHAT 和 WHY，禁止 HOW（不含技术实现细节）
  - 最多 3 个 `[NEEDS CLARIFICATION]` 标记
  - 读取 `.prizm-docs/root.prizm` 获取项目上下文
  - 自动编号功能目录 `###-feature-name`
- **Handoff**: `prizmkit.clarify` 或 `prizmkit.plan`

#### ④ prizmkit.clarify — 需求澄清

- **用途**: 交互式解决规格中的模糊点
- **输入**: `.prizmkit/specs/###-feature-name/spec.md`（含 `[NEEDS CLARIFICATION]` 标记）
- **输出**: 更新后的 `spec.md`（模糊点已解决，标记已移除）
- **关键行为**:
  - **逐个提问**（非一次全部），最多 5 个问题
  - 每个问题提供**推荐选项**和原因
  - 每次回答后立即原子化写入 spec 文件
  - 支持早期终止信号（"done"、"stop"）
  - 按 10 个维度分类扫描模糊性
- **Handoff**: `prizmkit.plan`

#### ⑤ prizmkit.plan — 实施计划

- **用途**: 从规格生成技术实施计划和设计文档
- **输入**: `spec.md`、`.prizm-docs/root.prizm`、相关 L1/L2 模块文档
- **模板**: `${SKILL_DIR}/assets/plan-template.md`
- **输出**:
  - `plan.md`（架构方案、组件设计、数据模型、API 契约、测试策略、风险评估）
  - `data-model.md`（如有数据变更）
  - `contracts/` 目录（如有 API 变更）
  - `research.md`（技术调研发现）
  - `quickstart.md`（关键验证场景）
- **关键行为**:
  - 每个用户故事映射到计划组件
  - 与项目 RULES 对齐
  - 包含风险评估表
  - 交叉检查 spec.md 与 `.prizm-docs/` 规则一致性
- **Handoff**: `prizmkit.tasks` 或 `prizmkit.code-review`

#### ⑥ prizmkit.tasks — 任务分解

- **用途**: 将实施计划分解为可执行的任务清单
- **输入**: `spec.md`、`plan.md`、`data-model.md`、`contracts/`
- **模板**: `${SKILL_DIR}/assets/tasks-template.md`
- **输出**: `tasks.md`
- **关键行为**:
  - 严格格式: `- [ ] [T-NNN] [P?] [US?] Description — file: path/to/file`
  - Phase 结构: Setup(T-001~T-009) → Foundational(T-010~T-099) → User Stories(T-100+) → Polish(T-900+)
  - `[P]` 标记可并行执行的任务
  - 支持三种实施策略: MVP 优先、增量交付、并行团队
  - Phase 之间插入检查点任务
  - 每个任务引用目标文件路径
- **Handoff**: `prizmkit.implement`

#### ⑥½ prizmkit.analyze — 交叉文档一致性分析

- **用途**: 对 spec.md、plan.md、tasks.md 进行非破坏性交叉一致性和质量分析
- **输入**: spec.md、plan.md（必需）、tasks.md（推荐）、`.prizm-docs/root.prizm` RULES
- **输出**: 结构化分析报告（**仅输出到对话，不写入文件**）
- **关键行为**:
  - 8 个执行步骤: 初始化上下文 → 加载工件 → 构建语义模型 → 检测通道 → 严重性分级 → 生成报告 → 下一步建议 → 提供修复方案
  - 6 个检测通道: 重复检测、歧义检测、不完整检测、Prizm 规则对齐、覆盖缺口、不一致性
  - 严重级别: CRITICAL > HIGH > MEDIUM > LOW
  - Prizm RULES 违规自动标记为 CRITICAL
  - 最多 50 个发现项
  - 可在 plan 之后运行（spec+plan 分析）或 tasks 之后运行（完整三文档分析）
  - **严格只读**，不修改任何文件
- **Handoff**: `prizmkit.implement`（无问题）或 `prizmkit.specify`/`prizmkit.plan`/`prizmkit.tasks`（有问题）
- **模式**: 只读

#### ⑦ prizmkit.implement — 执行实施

- **用途**: 按 tasks.md 逐步执行代码实施
- **输入**: `tasks.md`、`plan.md`、`spec.md`、相关 `.prizm-docs/` L2 文档
- **输出**: 代码文件 + `tasks.md` 标记完成 `[x]`
- **关键行为**:
  - 遵循 TDD（测试先行）
  - 读取 `.prizm-docs/` TRAPS 段避免已知陷阱
  - 遵守任务排序和依赖约束
  - 顺序任务失败则停止，并行任务可继续
  - 检查点任务失败则全局停止
  - 完成任务后**立即**标记 `[x]`
- **Handoff**: `prizmkit.code-review`

#### ⑧ prizmkit.code-review — 代码审查

- **用途**: 对实施完成的代码进行结构化审查
- **输入**: `spec.md`、`plan.md`、`tasks.md`（已完成任务）、`.prizm-docs/` RULES
- **输出**: 结构化审查报告（**仅输出到对话，不写入文件**）
- **关键行为**:
  - 6 个审查维度: 规格符合度、计划遵循度、代码质量、安全性、一致性、测试覆盖
  - 严重级别: CRITICAL > HIGH > MEDIUM > LOW
  - 最多 30 个发现项
  - 判定结论: PASS | PASS WITH WARNINGS | NEEDS FIXES
  - **严格只读**，不修改任何文件
- **Handoff**: `prizmkit.summarize`（PASS）或 `prizmkit.implement`（NEEDS FIXES）

#### ⑨ prizmkit.summarize — 功能摘要归档

- **用途**: 将已完成功能结构化沉淀到 Feature Registry
- **输入**: `spec.md`、`plan.md`、`data-model.md`、`contracts/`、`tasks.md`
- **模板**: `${SKILL_DIR}/assets/registry-template.md`
- **输出**:
  - 更新 `.prizmkit/specs/REGISTRY.md`（追加式，不修改已有条目）
  - 条目包含: 功能编号/名称、分支、状态、核心文件、API 变更、数据变更、完成日期
- **关键行为**:
  - 扫描实际代码目录提取核心路径
  - tasks.md 完成率 < 100% 则标记为 "Partial" 并警告
  - 幂等: 相同输入重复执行产出一致
  - REGISTRY.md 只追加不修改
- **Handoff**: `prizmkit.specify`（新功能）或 `prizmkit.retrospective`

### D. 提交 & 回顾（2 个技能）

#### ⑩ prizmkit.committer — 提交 + Prizm 文档同步

- **用途**: 自动化提交流程，确保文档与代码同步
- **触发**: 用户说 "commit"、"提交"、"finish"、"done"、"ship it"
- **输入**: Git diff（暂存和未暂存变更）、`.prizm-docs/`、`CHANGELOG.md`
- **输出**:
  - 更新 `.prizm-docs/`（L0/L1/L2 受影响模块的文件计数、KEY_FILES、INTERFACES 等）
  - 追加 `.prizm-docs/changelog.prizm`
  - 更新 `CHANGELOG.md`（如存在）
  - Git commit（Conventional Commits 格式）
  - 可选推送到远端
- **关键行为**:
  - 工作流: 状态检查 → Prizm 文档更新 → Diff 分析 → CHANGELOG → 提交 → 验证 → 可选推送
  - 变更文件通过 `root.prizm` MODULE_INDEX 映射到模块
  - 跳过条件: 仅内部实现变更、仅注释/空白、仅测试、仅 .prizm 文件
  - 通过 `UserPromptSubmit` 钩子自动触发
- **Handoff**: 无（提交流程终端技能）

#### ⑪ prizmkit.retrospective — 功能回顾 & 学习沉淀

- **用途**: 从已完成功能中提取经验教训
- **输入**: 功能工件（`spec.md`、`plan.md`、`tasks.md`、`data-model.md`、`contracts/`）、`.prizm-docs/`
- **输出**:
  - `retrospective.md`（决策结果、发现的模式、反模式、改进建议）
  - 更新 `.prizm-docs/` 模块的 TRAPS、RULES、DECISIONS 段
- **关键行为**:
  - 分析: 计划 vs 实际、跳过的任务、架构偏差、挑战
  - 分类: 做得好、做得不好、意外发现、下次改进
  - 将发现沉淀到 Prizm 文档中防止重蹈覆辙
- **Handoff**: `prizmkit.specify`（下一功能）或无

### E. 质量保障（3 个技能）

#### ⑫ prizmkit.security-audit — 安全漏洞扫描

- **用途**: 扫描代码中的安全漏洞和硬编码密钥
- **输入**: 源代码文件、`.prizm-docs/root.prizm`（技术栈）、.gitignore、Git 历史
- **输出**: 安全报告（**仅输出到对话**，最多 50 个发现项）
- **关键行为**:
  - 8 个扫描类别: 注入、认证、授权、数据暴露、配置、依赖、加密、输入验证
  - 严重级别: CRITICAL > HIGH > MEDIUM > LOW
  - 每个发现包含: 文件:行号、类别、描述、影响、修复方案
  - 可选: 将发现写入 `.prizm-docs/` TRAPS 和 RULES
- **Handoff**: 无（仅建议）
- **模式**: 只读

#### ⑬ prizmkit.dependency-health — 依赖健康检查

- **用途**: 审计依赖的版本、漏洞和兼容性
- **输入**: 构建文件（支持 Node.js、Python、Go、Rust、Java、Ruby、PHP、.NET）
- **输出**: 健康报告（**仅输出到对话**）
- **关键行为**:
  - 分类: HEALTHY | STALE | VULNERABLE | ABANDONED | INCOMPATIBLE
  - 按生态系统提供升级命令（npm、pip、go get 等）
  - 风险评估: patch/minor 低风险，major 中风险，替换高成本
- **Handoff**: 无（仅建议）
- **模式**: 只读

#### ⑭ prizmkit.tech-debt — 技术债务追踪

- **用途**: 系统化识别、分类和追踪技术债务
- **输入**: 源代码文件、`.prizm-docs/`、之前的 `tech-debt.md`（趋势对比）
- **输出**: `.prizmkit/tech-debt.md`（每次运行覆盖）
- **关键行为**:
  - 扫描指标: TODO/FIXME/HACK、复杂度热点（>500行文件、4+嵌套）、代码重复、缺失测试、过时模式、死代码、命名问题、缺失文档
  - 债务评分: CRITICAL×4 + HIGH×3 + MEDIUM×2 + LOW×1
  - 输出 Top 10 热点、按类别统计、趋势分析
  - 按影响/爆炸半径/工作量/风险排序行动建议
- **Handoff**: 无（仅建议）

### F. 运维部署（4 个技能）

#### ⑮ prizmkit.ci-cd — CI/CD 管线生成

- **用途**: 从技术栈生成 CI/CD 管线配置
- **输入**: `.prizm-docs/root.prizm`（LANG、FRAMEWORK、BUILD、TEST）、用户选择的平台和环境
- **输出**:
  - GitHub Actions: `.github/workflows/ci.yml`、`.github/workflows/deploy.yml`
  - GitLab CI: `.gitlab-ci.yml`
  - Jenkins: `Jenkinsfile`
- **关键行为**:
  - 阶段: install → lint → test → build → deploy
  - 自动配置依赖缓存、制品管理、环境变量
  - 密钥使用占位符 + TODO 标记
- **Handoff**: 无

#### ⑯ prizmkit.deploy-plan — 部署策略规划

- **用途**: 规划部署策略和回滚流程
- **输入**: `.prizm-docs/`（架构、技术栈、基础设施）、用户选择的策略和目标
- **输出**:
  - `.prizmkit/deployment-plan.md`
  - `rollback.sh`（如适用，可执行回滚脚本）
- **关键行为**:
  - 策略: Blue-green、Canary、Rolling、Recreate
  - 目标: 云服务（AWS/GCP/Azure）、Kubernetes、Docker Swarm、ECS、Serverless、裸机
  - 内容: 预部署清单、部署步骤、健康检查、回滚步骤、监控点、部署后验证
- **Handoff**: 无

#### ⑰ prizmkit.db-migrate — 数据库迁移规划

- **用途**: 规划安全的数据库结构变更
- **输入**: 数据模型（来自 `.prizmkit/specs/` 或 `.prizm-docs/`）、用户描述的变更、已有迁移文件
- **输出**:
  - 迁移脚本（在项目迁移目录中）
  - 回滚脚本
  - `migration-plan.md`
- **关键行为**:
  - 变更分类: Additive（安全）、Destructive（危险）、Transformative（复杂）
  - 包含: 预迁移备份命令、前向迁移 DDL/DML、反向迁移、数据验证查询
  - 风险评估: 数据丢失可能性、停机时间估计、锁竞争分析
- **Handoff**: 无

#### ⑱ prizmkit.monitoring — 监控告警配置

- **用途**: 生成全面的可观测性配置
- **输入**: `.prizm-docs/root.prizm`（技术栈、架构、服务、数据库）、用户选择的监控栈
- **输出**:
  - `monitoring/prometheus.yml`、`monitoring/alerts.yml`（Prometheus）
  - `monitoring/dashboards/`（Grafana JSON）
  - 健康检查端点代码（liveness、readiness、startup probes）
- **关键行为**:
  - 指标类型: RED（请求率/错误率/延迟）、System、Business、Database
  - 告警级别: Critical、Warning、Info
  - 支持: Prometheus+Grafana、ELK、CloudWatch、Datadog
- **Handoff**: 无

### G. 调试排障（4 个技能）

#### ⑲ prizmkit.error-triage — 错误分类 & 根因分析

- **用途**: 系统化错误分类和根因分析
- **输入**: 错误描述/堆栈跟踪/日志片段、`.prizm-docs/` TRAPS 段
- **输出**: 结构化分诊报告（**仅输出到对话**）
- **关键行为**:
  - 错误分类: Runtime、Network、Auth、Data、Resource、Logic、Config、External
  - 先查 `.prizm-docs/` TRAPS 是否有已知模式
  - 提供: 根因分析、受影响文件、修复建议、预防措施
  - 建议更新 TRAPS 以防再犯
- **Handoff**: 无（仅建议）
- **模式**: 只读

#### ⑳ prizmkit.analyze-logs — 日志分析

- **用途**: 分析日志文件，识别异常模式和错误关联
- **输入**: 日志文件或日志目录（自动检测格式: JSON、key=value、syslog、自定义）
- **输出**: 结构化分析报告（**仅输出到对话**）
- **关键行为**:
  - 标准化字段: timestamp、level、source、message、metadata
  - 分析: 错误频率、关联性、异常检测、时间线、请求追踪
  - 输出: Top 10 错误模式、关联发现、异常告警、调查优先级
- **Handoff**: 无（仅建议）
- **模式**: 只读

#### ㉑ prizmkit.perf-profile — 性能瓶颈识别

- **用途**: 通过静态分析识别性能瓶颈
- **输入**: 源代码文件、`.prizm-docs/`（架构、模块关系、热路径）
- **输出**: 性能分析报告（**仅输出到对话**）
- **关键行为**:
  - 检测模式: N+1 查询、缺失索引、同步阻塞、序列化开销、内存泄漏、低效算法、缺失缓存、热路径日志过多、大载荷传输、连接管理问题
  - 按技术栈推荐性能分析工具（clinic.js、cProfile、JFR、pprof 等）
  - 评估每个优化的预期影响
- **Handoff**: 无（仅建议）
- **模式**: 只读

#### ㉒ prizmkit.bug-reproduce — 最小复现脚本生成

- **用途**: 从 Bug 描述生成最小复现脚本和测试用例
- **输入**: Bug 描述（预期 vs 实际行为、步骤、环境）、`.prizm-docs/` TRAPS
- **输出**: 复现脚本/测试文件
- **关键行为**:
  - 按 Bug 类型生成不同格式:
    - API Bug: curl/HTTP 请求序列
    - UI Bug: 分步交互指南
    - Logic Bug: 单元测试（arrange/act/assert）
    - Data Bug: 种子数据 + 查询序列
  - 断言: 有 Bug 时 FAIL，修复后 PASS（兼作回归测试）
  - 自包含、可运行、使用项目约定
- **Handoff**: 无

### H. 知识管理（3 个技能）

#### ㉓ prizmkit.onboarding — 新人入职指南生成

- **用途**: 从项目上下文生成全面的开发者入职指南
- **输入**: `.prizm-docs/root.prizm`、L1 模块文档、README.md、CONTRIBUTING.md
- **输出**: 项目根目录下的 `ONBOARDING.md`
- **关键行为**:
  - 章节: 环境搭建、架构概览、核心目录、构建/测试命令、开发工作流、核心概念/术语、常见任务步骤、调试技巧（引用 TRAPS）、帮助资源
  - 避免与已有文档重复，改为引用
- **Handoff**: 无

#### ㉔ prizmkit.api-docs — API 文档自动生成

- **用途**: 从源代码自动生成 API 文档
- **输入**: API 源文件（路由、控制器、处理函数）、`.prizm-docs/`、JSDoc/docstring
- **输出**:
  - `docs/api/openapi.yaml`（OpenAPI 3.0 规格）
  - `docs/api/API_REFERENCE.md`（Markdown 参考手册）
- **关键行为**:
  - 自动检测框架（Express、Django、Spring、Go 等）
  - 提取: HTTP 方法/路径、请求参数、响应 Schema、认证要求、错误响应
  - 包含示例（curl 命令 + 示例响应）
- **Handoff**: 无

#### ㉕ prizmkit.adr.* — 架构决策记录管理

- **命令集**:
  - `prizmkit.adr.new <title>` — 创建新 ADR
  - `prizmkit.adr.list` — 列出所有 ADR 及状态
  - `prizmkit.adr.supersede <number> <new-title>` — 标记为已替代并创建新 ADR
- **输入**: 用户描述的决策上下文、`${SKILL_DIR}/assets/adr-template.md`、`.prizm-docs/` DECISIONS
- **输出**:
  - `docs/adr/NNNN-title.md`（零填充编号、kebab-case）
  - 更新 `.prizm-docs/` 模块 DECISIONS 段
- **关键行为**:
  - ADR 字段: Title、Date、Status（Proposed/Accepted/Deprecated/Superseded）、Context、Decision、Consequences、Alternatives
  - 状态追踪: Proposed → Accepted/Deprecated → Superseded
  - 交叉引用: ADR 与 Prizm 文档 DECISIONS 双向关联
- **Handoff**: 无

---

## 四、Prizm 文档层级体系

```
┌───────────────────────────────────────────────────────────────────┐
│               Prizm 三层渐进式加载架构                              │
│                                                                   │
│  L0 — 根索引 (.prizm-docs/root.prizm)  ≤4KB                      │
│  ├── 始终在会话开始时加载                                           │
│  ├── PROJECT / LANG / FRAMEWORK / BUILD / TEST                    │
│  ├── MODULE_INDEX（模块索引，-> 指向 L1）                           │
│  ├── ARCHITECTURE / LAYERS / TECH_STACK / ENTRY_POINTS            │
│  ├── RULES（5-10 条最关键的项目级约定）                              │
│  ├── PATTERNS（跨项目代码模式）                                     │
│  └── DECISIONS（追加式项目级架构决策）                               │
│       │                                                           │
│       ├──► L1 — 模块索引 (.prizm-docs/<module>.prizm)  ≤3KB      │
│       │    ├── 操作相关模块时按需加载                                │
│       │    ├── MODULE / FILES / RESPONSIBILITY / UPDATED          │
│       │    ├── SUBDIRS（-> 指向 L2）                               │
│       │    ├── KEY_FILES（5-10 个最重要的文件）                     │
│       │    ├── INTERFACES（仅 PUBLIC/EXPORTED 签名）               │
│       │    ├── DEPENDENCIES（imports / imported-by / external）   │
│       │    ├── RULES（模块级规则，仅补充 root.prizm）              │
│       │    └── DATA_FLOW（编号步骤）                               │
│       │         │                                                 │
│       │         └──► L2 — 详细文档 (.../<submodule>.prizm) ≤5KB  │
│       │              ├── 修改该子模块文件时加载                     │
│       │              ├── 首次修改时延迟生成（非初始化时创建）        │
│       │              ├── KEY_FILES（详细描述）                      │
│       │              ├── 领域特定段（如 ENDPOINTS、ERROR_CODES）   │
│       │              ├── DEPENDENCIES（详细 uses/imports）         │
│       │              ├── DECISIONS（模块级决策，追加式）            │
│       │              ├── TRAPS（陷阱：隐式耦合、竞态、副作用）      │
│       │              └── CHANGELOG（模块变更日志，追加式）          │
│       │                                                           │
│       └── changelog.prizm（全局变更日志，保留最近 50 条）           │
│            格式: - YYYY-MM-DD | <module-path> | <verb>: <desc>   │
│                                                                   │
│  格式规则:                                                         │
│  ├── 标题: 全大写 + 冒号（MODULE:、FILES:、RESPONSIBILITY:）       │
│  ├── 值: 冒号后单空格，同行书写                                    │
│  ├── 列表: 破折号-空格前缀                                         │
│  ├── 指针: 箭头标记 ->                                             │
│  ├── 日期: [YYYY-MM-DD] 方括号                                    │
│  ├── 分隔: 管道符 | 分隔日期/模块/描述                              │
│  ├── 缩进: 子键 2 空格                                             │
│  └── 注释: 不允许。每行都承载信息                                   │
│                                                                   │
│  典型任务 Token 消耗: 3000-5000 tokens                             │
└───────────────────────────────────────────────────────────────────┘
```

---

## 五、Hook 机制

```
┌───────────────────────────────────────────────────────────────┐
│               PrizmKit 钩子系统                                 │
│                                                               │
│  钩子文件: assets/hooks/prizm-commit-hook.json                │
│  钩子类型: UserPromptSubmit（用户提交消息时触发）               │
│                                                               │
│  触发流程:                                                     │
│  1. 分析用户消息是否包含提交意图                                │
│     (commit / push / finish / ship / merge / pull request)    │
│  2. 如检测到提交意图:                                          │
│     ├── 返回 PRIZMKIT_DOC_UPDATE_REQUIRED                     │
│     ├── 执行 git diff --cached --name-status                 │
│     ├── 通过 root.prizm MODULE_INDEX 映射变更文件到模块        │
│     ├── 读取并更新受影响的 .prizm 文件（仅变更段落）            │
│     ├── 追加 changelog.prizm                                  │
│     ├── git add .prizm-docs/                                  │
│     └── 交由 prizmkit-committer 执行提交                       │
│  3. 如无提交意图: 返回空成功                                    │
│                                                               │
│  规则: 绝不重写整个 .prizm 文件，绝不添加散文，                  │
│       仅更新受影响段落                                          │
└───────────────────────────────────────────────────────────────┘
```

---

## 六、文件系统产出物全景

```
项目根目录/
├── .prizm-docs/                         ◄── 项目"是什么"（静态知识层）
│   ├── root.prizm                       ◄── L0 项目元数据（prizmkit.init 产出）
│   ├── changelog.prizm                  ◄── 全局变更日志（prizmkit.committer 追加）
│   ├── <module>.prizm                   ◄── L1 模块索引（prizmkit.init / doc.update 产出）
│   └── <module>/
│       └── <submodule>.prizm            ◄── L2 详细文档（延迟生成，doc.update 维护）
│
├── .prizmkit/                           ◄── 功能"做什么"（工作流层）
│   ├── config.json                      ◄── PrizmKit 配置（prizmkit.init 产出）
│   ├── tech-debt.md                     ◄── 技术债务报告（prizmkit.tech-debt 产出）
│   ├── deployment-plan.md               ◄── 部署策略（prizmkit.deploy-plan 产出）
│   └── specs/
│       ├── REGISTRY.md                  ◄── 功能注册表（prizmkit.summarize 追加）
│       └── ###-feature-name/
│           ├── spec.md                  ◄── prizmkit.specify
│           ├── plan.md                  ◄── prizmkit.plan
│           ├── research.md              ◄── prizmkit.plan（调研阶段）
│           ├── data-model.md            ◄── prizmkit.plan（数据模型）
│           ├── quickstart.md            ◄── prizmkit.plan（快速验证）
│           ├── contracts/               ◄── prizmkit.plan（API 契约）
│           ├── tasks.md                 ◄── prizmkit.tasks
│           ├── retrospective.md         ◄── prizmkit.retrospective
│           └── checklists/
│               └── requirements.md      ◄── prizmkit.specify（自动生成）
│
├── .codebuddy/
│   ├── settings.json                    ◄── prizmkit.init 注入钩子配置
│   └── skills/                          ◄── install-prizmkit.py 安装目标
│       ├── prizm-kit/                   ◄── 元技能
│       └── prizmkit-*/                  ◄── 26 个子技能
│
├── docs/
│   ├── adr/
│   │   └── NNNN-title.md               ◄── prizmkit.adr.new 产出
│   └── api/
│       ├── openapi.yaml                 ◄── prizmkit.api-docs 产出
│       └── API_REFERENCE.md             ◄── prizmkit.api-docs 产出
│
├── monitoring/                          ◄── prizmkit.monitoring 产出
│   ├── prometheus.yml
│   ├── alerts.yml
│   └── dashboards/
│
├── .github/workflows/                   ◄── prizmkit.ci-cd 产出
│   ├── ci.yml
│   └── deploy.yml
│
├── ASSESSMENT.md                        ◄── prizmkit.init 产出（棕地项目评估）
├── ONBOARDING.md                        ◄── prizmkit.onboarding 产出
├── CHANGELOG.md                         ◄── prizmkit.committer 维护
├── CODEBUDDY.md                         ◄── prizmkit.init 追加渐进加载协议
├── rollback.sh                          ◄── prizmkit.deploy-plan 产出（如适用）
└── migration scripts                    ◄── prizmkit.db-migrate 产出（在项目迁移目录中）
```

---

## 七、典型工作流时序

```
开发者                      PrizmKit 命令                     产出物
  │                             │                              │
  │── 1. 项目接管 ─────────────►│ init                          │
  │                             │───────────────────────────►│ .prizm-docs/ + .prizmkit/
  │                             │───────────────────────────►│ ASSESSMENT.md
  │                             │───────────────────────────►│ CODEBUDDY.md (更新)
  │                             │                              │
  │── 2. 描述功能需求 ─────────►│ specify                       │
  │                             │───────────────────────────►│ .prizmkit/specs/###/ + spec.md
  │                             │                              │
  │── 3. (可选) 澄清模糊点 ───►│ clarify                       │
  │   ◄── AI 逐个提问 ─────────│                               │
  │── 回答 ───────────────────►│───────────────────────────►│ spec.md (更新)
  │                             │                              │
  │── 4. 生成实施计划 ─────────►│ plan                          │
  │                             │───────────────────────────►│ plan.md
  │                             │                             ►│ research.md
  │                             │                             ►│ data-model.md
  │                             │                             ►│ contracts/
  │                             │                             ►│ quickstart.md
  │                             │                              │
  │── 5. 分解任务 ─────────────►│ tasks                         │
  │                             │───────────────────────────►│ tasks.md
  │                             │                              │
  │── 5.5 (推荐) 一致性检查 ──►│ analyze                       │
  │   ◄── 分析报告 ───────────│ (只读，不写文件)               │
  │                             │                              │
  │── 6. 执行实施 ─────────────►│ implement                     │
  │                             │── 逐任务执行 ────────────►│ 代码文件
  │                             │── 标记完成 ──────────────►│ tasks.md [x]
  │                             │                              │
  │── 7. (推荐) 代码审查 ──────►│ code-review                   │
  │   ◄── 审查报告 ───────────│ (只读，不写文件)               │
  │                             │                              │
  │── 8. 功能摘要归档 ─────────►│ summarize                     │
  │                             │───────────────────────────►│ REGISTRY.md (追加)
  │                             │                              │
  │── 9. (可选) 回顾学习 ──────►│ retrospective                 │
  │                             │───────────────────────────►│ retrospective.md
  │                             │───────────────────────────►│ .prizm-docs/ (TRAPS/RULES 更新)
  │                             │                              │
  │── 10. 提交代码 ────────────►│ committer                     │
  │                             │── Prizm 文档同步 ──────►│ .prizm-docs/ (更新)
  │                             │── CHANGELOG ──────────►│ CHANGELOG.md (更新)
  │                             │── Git commit ─────────►│ Conventional Commit
  │                             │                              │
  │                             │                              │
  │── (随时) 安全审计 ─────────►│ security-audit                │
  │   ◄── 审计报告 ───────────│ (只读)                         │
  │                             │                              │
  │── (随时) 依赖检查 ─────────►│ dependency-health             │
  │   ◄── 健康报告 ───────────│ (只读)                         │
  │                             │                              │
  │── (随时) 技术债务 ─────────►│ tech-debt                     │
  │                             │───────────────────────────►│ .prizmkit/tech-debt.md
  │                             │                              │
  │── (上线前) CI/CD 生成 ─────►│ ci-cd                         │
  │                             │───────────────────────────►│ .github/workflows/
  │                             │                              │
  │── (上线前) 部署规划 ───────►│ deploy-plan                   │
  │                             │───────────────────────────►│ .prizmkit/deployment-plan.md
  │                             │                              │
  │── (Schema变更) 迁移规划 ──►│ db-migrate                    │
  │                             │───────────────────────────►│ 迁移脚本 + migration-plan.md
  │                             │                              │
  │── (上线前) 监控配置 ───────►│ monitoring                    │
  │                             │───────────────────────────►│ monitoring/
  │                             │                              │
  │── (调试时) 错误分诊 ───────►│ error-triage                  │
  │   ◄── 分诊报告 ───────────│ (只读)                         │
  │                             │                              │
  │── (调试时) 日志分析 ───────►│ analyze-logs                  │
  │   ◄── 分析报告 ───────────│ (只读)                         │
  │                             │                              │
  │── (性能问题) 性能分析 ─────►│ perf-profile                  │
  │   ◄── 性能报告 ───────────│ (只读)                         │
  │                             │                              │
  │── (Bug修复) 复现脚本 ──────►│ bug-reproduce                 │
  │                             │───────────────────────────►│ 复现脚本/测试文件
  │                             │                              │
  │── (发布前) 入职指南 ───────►│ onboarding                    │
  │                             │───────────────────────────►│ ONBOARDING.md
  │                             │                              │
  │── (API变更) API 文档 ──────►│ api-docs                      │
  │                             │───────────────────────────►│ docs/api/
  │                             │                              │
  │── (架构决策) ADR 管理 ─────►│ adr.new / .list / .supersede  │
  │                             │───────────────────────────►│ docs/adr/NNNN-title.md
  │                             │                              │
```

### 快速路径 (Fast Path)

并非所有变更都需要走完整的 specify→plan→tasks 流程:

**使用完整流程:**
- 新功能或面向用户的能力
- 多文件协调变更
- 架构决策
- 数据模型或 API 变更

**使用快速路径 (implement → commit):**
- 有明确根因的 Bug 修复
- 单文件配置或拼写修复
- 简单重构（重命名、提取方法）
- 仅文档变更
- 为已有代码添加测试

快速路径: 直接使用 `prizmkit.implement`（内联任务描述） → `prizmkit.committer`

---

## 八、关键架构特征总结

| 特征 | 说明 |
|------|------|
| **管线式架构** | 核心命令按 init → specify → plan → tasks → analyze → implement → code-review → summarize → committer 严格排序 |
| **双知识层** | `.prizm-docs/`（项目"是什么"）+ `.prizmkit/specs/`（功能"做什么"），互补不重叠 |
| **三层渐进加载** | L0 始终加载（≤4KB）→ L1 按需加载（≤3KB/模块）→ L2 延迟生成（≤5KB/子模块），典型任务 3000-5000 tokens |
| **辅助技能** | 质量(3) + 运维(4) + 调试(4) + 知识(3) 共 14 个辅助技能可在任意时机独立调用 |
| **钩子驱动** | 通过 UserPromptSubmit 钩子自动检测提交意图，触发 Prizm 文档同步 |
| **只读命令** | analyze、code-review、security-audit、dependency-health、error-triage、analyze-logs、perf-profile 是不写入文件的命令 |
| **追加式历史** | REGISTRY.md、changelog.prizm、DECISIONS 段均为只追加不修改 |
| **延迟生成** | L2 文档在首次修改对应子模块时才创建，非初始化时全量生成 |
| **渐进产出** | 每个命令产出独立文件，后续命令读取前序产出物 |
| **技能分级** | 核心技能(12个)无标签 + Tier 1(3个,AI 独立胜任) + Tier 2(11个,指导/清单,需外部工具增强) |
| **实施前检查** | analyze 命令提供 spec↔plan↔tasks 交叉一致性分析，在动手前发现问题 |
| **幂等设计** | summarize 等命令相同输入重复执行产出一致 |
| **跨 IDE 兼容** | 所有路径使用 `${SKILL_DIR}` 占位符，支持 VS Code、Cursor、Trae、CodeBuddy、PyCharm |
| **自动文档同步** | 每次提交前自动更新受影响模块的 Prizm 文档，代码与文档永不分离 |

---

## 九、安装与配置

```
# 列出所有可用技能
python3 install-prizmkit.py --list

# 安装所有技能 + 钩子
python3 install-prizmkit.py --target .codebuddy/skills --hooks --project-root .

# 安装单个技能
python3 install-prizmkit.py --skill prizmkit-init --target .codebuddy/skills

# 强制覆盖安装
python3 install-prizmkit.py --target .codebuddy/skills --force
```

安装工具行为:
- 自动检测 `skills/` 目录下的所有技能
- 验证每个技能包含 SKILL.md
- 安装元技能（顶层 SKILL.md）+ 全部子技能
- 复制 assets（钩子、模板）到元技能目录旁
- 将钩子配置合并到 `.codebuddy/settings.json`（不重复）
- 支持 `--skill` 按名称选择性安装
- 支持 `--force` 覆盖已有安装
