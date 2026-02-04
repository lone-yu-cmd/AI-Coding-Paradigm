# Rule Master - AI Coding 规范生成器

Rule Master 是一个交互式工具，旨在帮助团队快速生成标准化的 AI Coding 规范文档 (`rule.md`)。通过简单的问答流程，您可以定制适合当前项目的角色设定、技术栈、编码风格和工程实践。

## 📦 安装依赖

本工具依赖 `questionary` 库提供现代化的命令行交互体验。

```bash
pip install questionary
```

## 🚀 快速开始

在项目根目录下运行以下命令：

```bash
python3 rule-master/main.py
```

脚本将启动交互式界面：
*   **导航**：使用 `↑` / `↓` 键移动光标。
*   **选择**：
    *   单选：按 `Enter` 确认。
    *   多选：按 `Space` 切换选中状态，按 `Enter` 确认。
*   **高级交互**：
    *   **查看详情**：按 `d` 键查看当前选项的完整描述。
    *   **编辑内容**：按 `e` 键实时修改当前选项的生成内容（修改仅本次有效）。
*   **输入**：直接输入文本并按 `Enter`。

脚本将引导您完成以下步骤：
1.  **选择角色**：设定 AI 的身份（如全栈工程师、后端专家）。
2.  **配置技术栈**：选择语言、框架及版本（支持多选）。
3.  **制定规范**：选择测试策略、代码风格、日志规范等。
4.  **设定交互模式**：定义 AI 的沟通方式（如是否需要思维链）。
5.  **添加自定义规则**：在流程最后，您可以手动输入额外的规则标题和内容。

**提示**：所有规则步骤均支持跳过。

完成后，工具将在 `rule-master/` 目录下生成 `rule.md` 文件。

## 📂 目录结构

```text
rule-master/
├── main.py              # 核心执行脚本
├── rules/               # 规则定义文件 (JSON)
│   ├── 01-role.json
│   ├── 02-tech-stack.json
│   ├── ...
│   └── 11-glossary.json
└── README.md            # 本文档
```

## 🛠 如何自定义规则

所有的规则都定义在 `rules/` 目录下的 JSON 文件中。您可以直接修改这些文件来扩展或调整规则。

### 规则文件格式示例

```json
{
  "id": "example_rule",
  "title": "示例规则",
  "description": "规则描述",
  "type": "single_select", // 或 "multi_select"
  "options": [
    {
      "label": "选项 A",
      "value": "opt_a",
      "content": "生成的 Markdown 内容...",
      "inputs": [ // 可选：自定义输入变量
        {"key": "var_name", "prompt": "请输入变量值", "default": "默认值"}
      ]
    }
  ]
}
```

*   **type**: `single_select` (单选) 或 `multi_select` (多选)。
*   **inputs**: 定义后，脚本会在用户选择该选项时提示输入，并将 `content` 中的 `{key}` 替换为用户输入的值。

## 📝 关于 rule.md

生成的 `rule.md` 文件旨在作为 AI 编码助手的上下文输入。建议在与 AI 结对编程时，要求 AI 首先阅读并遵循该文件中的规范。
