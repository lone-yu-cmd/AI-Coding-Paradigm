---
name: "context-code-explainer"
description: "Generates a structured analysis report for a given code snippet. Invoke when user asks to explain, understand, or analyze specific code."
---

# Code Explainer

This skill analyzes code (Python, JS, Java, etc.) and generates a professional, structured report to help the user understand its purpose and mechanics.

## When to Use

Invoke this skill when the user:
- Asks "What does this code do?"
- Asks "Explain this file to me."
- Pastes a snippet and asks for an analysis.
- Wants to understand the purpose or design of a specific module.

## Workflow

1.  **Context Loading**:
    Read `docs/AI_CONTEXT/ARCHITECTURE.md` to understand the system context.

2.  **Read Code**: Ensure you have the full content of the file or snippet the user is referring to.
3.  **Analyze**:
    -   Identify the main class/function/module.
    -   Trace data flow and key logic.
    -   Infer business intent from naming and comments.
    -   **Cross-Reference**: Relate the code to Architecture decisions (ADR) if applicable.
4.  **Generate Report**: Output a response strictly following the **Report Format** below.

## Report Format

### 1. 核心功能 (Core Functionality)
[Summarize the main task of the code in 1-2 sentences. Example: "This script fetches data from API X, cleans it, and stores it in DB Y."]

### 2. 使用场景 (Use Cases)
[Describe when this code is used or what problem it solves in 1-2 sentences. Example: "Used during nightly batch jobs to synchronize local data with the remote server."]

### 3. 设计意图 (Design Intent)
[Explain the specific problem it addresses or the requirement it meets. Example: "Designed to handle network jitter by implementing exponential backoff retries."]

### 4. 关键逻辑解析 (Key Logic Breakdown)
[List the critical parts of the code and what they do.]
*   **[Function/Class Name]**: [Description of what it implements]
*   **[Variable/Constant]**: [Role in the logic]
*   **[Flow Control]**: [Explanation of complex loops or conditions]

## Example Output

### 1. 核心功能
这段代码的主要功能是解析本地的 JSON Registry 文件，并将其合并为一个统一的 `llm_registry.json` 构建产物。

### 2. 使用场景
通常在 CI/CD 流程中或发布新版本前使用，确保所有分散的厂商数据被正确打包分发给 SDK。

### 3. 设计意图
旨在解决单文件管理大量厂商数据带来的合并冲突问题，通过“分治”策略提升可维护性，同时保持对外交付物的单一性。

### 4. 关键逻辑解析
*   **`load_providers()`**: 遍历 `registry/providers/` 目录，加载所有独立的厂商配置。
*   **`resolve_refs()`**: 递归处理 JSON 中的 `$ref` 字段，将引用的 Schema 文件内容内联到主文件中。
*   **`merge_data()`**: 将处理后的数据组装成最终的字典结构，并写入磁盘。
