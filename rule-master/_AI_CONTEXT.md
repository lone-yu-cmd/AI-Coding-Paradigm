# Rule Master 模块

> 规则管理系统模块详情文档，帮助 AI 理解规则生成器的职责和实现细节。
> 文档大小限制：< 10KB

---

## 模块职责（Responsibility）

<!-- AUTO_SYNC_START -->

### 核心职责

交互式生成项目的 AI Coding 规范文档（`rule.md`），通过问答流程帮助团队快速定制适合项目的角色设定、技术栈、编码风格和工程实践。

### 模块边界

- **负责**：
  - 加载和解析规则定义文件（JSON 格式）
  - 提供交互式命令行界面（单选/多选/自定义输入）
  - 处理动态变量替换（inputs 机制）
  - 生成标准化的 `rule.md` 文档
  - 支持规则预览、编辑和跳过功能

- **不负责**：
  - 规则的语义验证（由用户和 AI 协作完成）
  - 规则文档的版本管理（由 Git 管理）
  - 规则的自动应用（需手动提供给 AI）
  - 与 IDE 或 AI 工具的集成

<!-- AUTO_SYNC_END -->

---

## 文件结构（File Structure）

<!-- AUTO_SYNC_START -->

```
rule-master/
├── main.py                    # 核心执行脚本（385 行）
├── README.md                  # 模块使用文档
├── rule.md                    # 生成的规则文档（输出文件）
└── rules/                     # 规则定义目录（11 个 JSON 文件）
    ├── 01-role.json           # 角色设定
    ├── 02-tech-stack.json     # 技术栈规范
    ├── 03-coding-style.json   # 编码风格
    ├── 04-testing.json        # 测试策略
    ├── 05-engineering.json    # 工程实践
    ├── 06-docs-mandatory.json # 文档要求
    ├── 07-agent-hook.json     # Agent Hook 规范
    ├── 08-ai-interaction.json # AI 交互模式
    ├── 09-checklist.json      # 任务检查清单
    ├── 10-security.json       # 安全规范
    └── 11-glossary.json       # 术语表
```

### 文件说明

| 文件 | 职责 | 重要程度 |
|-----|-----|---------|
| `main.py` | 主程序，实现交互逻辑、规则处理、文档生成 | ⭐⭐⭐ |
| `rules/*.json` | 规则定义配置，定义选项、内容模板、动态变量 | ⭐⭐⭐ |
| `rule.md` | 输出文件，生成的 AI 规范文档 | ⭐⭐ |
| `README.md` | 使用说明和自定义指南 | ⭐⭐ |

<!-- AUTO_SYNC_END -->

---

## 规则类别（Rule Categories）

<!-- AUTO_SYNC_START -->

| 规则 ID | 标题 | 类型 | 说明 |
|--------|------|------|------|
| `01-role` | 角色设定 | 单选 | 定义 AI 的身份（全栈/后端/前端专家） |
| `02-tech-stack` | 技术栈规范 | 多选 | 选择语言、框架、数据库及版本 |
| `03-coding-style` | 编码风格 | 单选 | 代码格式、命名规范、注释风格 |
| `04-testing` | 测试策略 | 单选 | 单元测试、集成测试、TDD 要求 |
| `05-engineering` | 工程实践 | 多选 | 日志、错误处理、性能优化规范 |
| `06-docs-mandatory` | 文档要求 | 单选 | API 文档、代码注释、README 规范 |
| `07-agent-hook` | Agent Hook | 单选 | Git 提交、代码审查的自动化规范 |
| `08-ai-interaction` | AI 交互模式 | 单选 | 思维链、代码审查、确认机制 |
| `09-checklist` | 任务检查清单 | 单选 | 开发前、提交前的检查项 |
| `10-security` | 安全规范 | 多选 | 输入验证、敏感数据处理、依赖安全 |
| `11-glossary` | 术语表 | 自定义 | 项目特定术语和缩写定义 |

<!-- AUTO_SYNC_END -->

---

## 关键接口（Key Interfaces）

<!-- AUTO_SYNC_START -->

### 主要函数/方法

| 名称 | 参数 | 返回值 | 说明 |
|-----|-----|-------|-----|
| `main()` | 无 | 无 | 主入口，协调整个流程 |
| `load_rules()` | 无 | `List[dict]` | 加载 rules/ 目录下的所有 JSON 文件 |
| `process_rule(rule)` | `rule: dict` | `str` | 处理单个规则，返回生成的 Markdown 内容 |
| `process_inputs(option)` | `option: dict` | `str` | 处理选项中的动态变量替换 |
| `custom_select(title, options, multi)` | `title: str`<br>`options: List`<br>`multi: bool` | `List[int]` 或 `tuple` | 自定义选择器，支持 d/e 快捷键 |

### 交互快捷键

| 按键 | 功能 | 说明 |
|-----|------|------|
| `↑` / `↓` | 导航 | 在选项间移动光标 |
| `Space` | 切换选择 | 多选模式下切换选中状态 |
| `Enter` | 确认 | 确认当前选择 |
| `d` | 查看详情 | 显示选项的完整描述和内容预览 |
| `e` | 编辑内容 | 临时修改选项的生成内容（仅本次有效） |
| `Ctrl+C` | 退出 | 取消并退出程序 |

<!-- AUTO_SYNC_END -->

---

## 依赖关系（Dependencies）

<!-- AUTO_SYNC_START -->

### 内部依赖（本项目模块）

无（独立模块）

### 外部依赖（第三方库）

| 依赖名称 | 版本 | 用途 |
|---------|-----|-----|
| `questionary` | - | 提供现代化的命令行交互界面 |
| `prompt_toolkit` | - | 底层终端控制（questionary 的依赖） |

### 被依赖情况

本模块被以下模块依赖：
- 无（作为独立工具使用）

<!-- AUTO_SYNC_END -->

---

## 常见操作指南（Common Operations）

<!-- MANUAL_START -->

### 如何运行规则生成器

```bash
# 在项目根目录执行
python3 rule-master/main.py
```

### 如何添加新规则类别

1. 在 `rules/` 目录下创建新的 JSON 文件（建议按序号命名，如 `12-new-rule.json`）
2. 按照以下格式定义规则：
   ```json
   {
     "id": "unique_rule_id",
     "title": "规则标题",
     "description": "规则说明（显示在交互界面）",
     "type": "single_select",  // 或 "multi_select"
     "options": [
       {
         "label": "选项名称",
         "description": "选项详细说明（按 d 键查看）",
         "content": "生成的 Markdown 内容...",
         "inputs": [  // 可选：动态变量
           {
             "key": "variable_name",
             "prompt": "提示用户输入的文本",
             "default": "默认值"
           }
         ]
       }
     ]
   }
   ```
3. 重新运行 `main.py`，新规则会自动加载

### 如何修改现有规则

1. 打开对应的 JSON 文件（如 `rules/01-role.json`）
2. 修改 `options` 中的 `content` 字段（支持 Markdown 语法）
3. 如需动态变量，添加 `inputs` 数组并在 `content` 中使用 `{variable_name}` 占位符
4. 保存后重新运行生成器

### 如何使用生成的 rule.md

```markdown
# 在与 AI 对话时提供上下文
"请先阅读项目根目录的 rule.md 文件，并在后续开发中严格遵循其中的规范。"
```

### 注意事项

- ⚠️ 所有规则文件必须是有效的 JSON 格式（建议使用 JSON 验证工具）
- ⚠️ `content` 中的花括号 `{}` 会被识别为变量占位符，如需显示字面花括号需转义
- ⚠️ 规则文件按文件名排序加载，建议使用 `01-`, `02-` 前缀控制顺序
- ⚠️ 生成的 `rule.md` 会覆盖同名文件，建议在修改前备份

<!-- MANUAL_END -->

---

## 代码示例（Code Examples）

<!-- MANUAL_START -->

### 基本用法：运行生成器

```bash
# 安装依赖
pip install questionary

# 运行生成器
python3 rule-master/main.py

# 按照提示选择规则选项
# 最终生成 rule-master/rule.md
```

### 高级用法：自定义规则配置

```json
// rules/12-api-design.json
{
  "id": "api_design",
  "title": "API 设计规范",
  "description": "定义 RESTful API 的设计风格",
  "type": "single_select",
  "options": [
    {
      "label": "RESTful 标准",
      "description": "遵循 REST 架构风格和 HTTP 语义",
      "content": "## API Design\n\n- 使用标准 HTTP 方法（GET/POST/PUT/DELETE）\n- 资源路径使用复数名词（如 `/users`）\n- 状态码：{status_codes}\n- 版本控制：{versioning}",
      "inputs": [
        {
          "key": "status_codes",
          "prompt": "常用状态码规范（如 200/201/400/404/500）",
          "default": "200 成功, 201 创建, 400 参数错误, 404 未找到, 500 服务器错误"
        },
        {
          "key": "versioning",
          "prompt": "版本控制方式（如 URL 路径 /v1/ 或 Header）",
          "default": "URL 路径 /api/v1/"
        }
      ]
    }
  ]
}
```

### 代码扩展：添加新的交互快捷键

```python
# 在 custom_select() 函数中添加新的按键绑定
@kb.add('h')  # 添加 'h' 键显示帮助
def show_help(event):
    nonlocal detail_msg
    detail_msg = """
    快捷键说明：
    ↑/↓   - 导航选项
    Space - 切换选择（多选模式）
    Enter - 确认选择
    d     - 查看详情
    e     - 编辑内容
    h     - 显示帮助
    Ctrl+C - 退出
    """
```

<!-- MANUAL_END -->

---

## 工作流程（Workflow）

<!-- MANUAL_START -->

### 交互式规则生成流程

```
用户启动 main.py
    ↓
加载 rules/*.json 文件（按文件名排序）
    ↓
遍历每个规则定义
    ↓
显示规则标题和描述
    ↓
展示选项列表（单选/多选）
    ↓
用户操作：
  - 按 d 查看详情
  - 按 e 编辑内容
  - 选择选项 / 自定义内容 / 跳过
    ↓
如果选项包含 inputs：
  提示用户输入变量值
  替换 content 中的 {key} 占位符
    ↓
收集选中选项的 content
    ↓
重复上述流程直到所有规则处理完毕
    ↓
询问是否添加自定义规则
    ↓
生成最终的 rule.md 文件
    ↓
显示成功消息和文件路径
```

### 规则内容生成逻辑

```python
# 伪代码示例
for rule in rules:
    selected_options = user_select(rule.options)
    
    for option in selected_options:
        if option.has_inputs():
            # 收集用户输入
            variables = collect_inputs(option.inputs)
            # 替换变量
            content = replace_variables(option.content, variables)
        else:
            content = option.content
        
        final_content.append(content)

write_file("rule.md", final_content)
```

<!-- MANUAL_END -->

---

## 已知问题与限制（Known Issues & Limitations）

<!-- MANUAL_START -->

### 当前限制

- **终端兼容性**：某些旧版终端可能不支持 prompt_toolkit 的高级特性（如彩色输出）
- **变量替换**：仅支持简单的 `{key}` 格式，不支持嵌套或条件逻辑
- **编辑功能**：按 `e` 键编辑的内容仅在当前运行有效，不会持久化到 JSON 文件
- **多行输入**：自定义内容输入不支持多行编辑器（需手动换行）
- **规则验证**：不验证生成的 Markdown 语法或逻辑一致性

### 待改进项

- [ ] 支持从已有的 `rule.md` 反向生成配置（导入功能）
- [ ] 添加规则模板预览（在选择前查看完整生成结果）
- [ ] 支持规则的条件依赖（如选择了 A 才显示 B）
- [ ] 提供 Web UI 版本（降低命令行使用门槛）
- [ ] 支持多语言规则定义（中文/英文切换）

<!-- MANUAL_END -->

---

## 变更历史（Change History）

<!-- AUTO_SYNC_START -->

| 日期 | 变更类型 | 说明 |
|-----|---------|-----|
| 2026-02-04 | 文档创建 | 初始化 _AI_CONTEXT.md 文档 |

<!-- AUTO_SYNC_END -->

---

> 📅 本文档由 AI Context Sync Skill 生成  
> 🔄 AUTO_SYNC 区域会在代码变更时自动更新  
> ✏️ MANUAL 区域供人工编辑，不会被自动覆盖
