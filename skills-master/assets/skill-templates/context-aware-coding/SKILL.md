---
name: "context-aware-coding"
description: "Ensures AI understands directory context and keeps documentation up-to-date. Invoke BEFORE starting implementation in a directory AND AFTER finishing code changes."
---

# Context Aware Coding

This skill ensures that the AI developer is always aware of the specific context of the directory they are working in, and that this context is maintained for future sessions.

## When to Use

1.  **BEFORE Coding**: When user asks to implement a feature or modify code in a specific directory (e.g., `registry/`, `scripts/`).
2.  **AFTER Coding**: When a task is completed and code changes have been applied.

## Workflow

### Step 1: Context Acquisition (Pre-implementation)

Before writing or editing any code:

1.  **Global Context**: Read `docs/AI_CONTEXT/ARCHITECTURE.md` and `docs/AI_CONTEXT/CONSTITUTION.md` to understand the project's core principles and data flow.
2.  **Local Context**: Identify the target directory for the task.
3.  Check for the existence of `AI_README.md` in that directory.
4.  **Action**: Read the `AI_README.md` content.
5.  **Reasoning**: Combine the global architecture rules with local directory rules to guide your implementation.

### Step 2: Documentation Maintenance (Post-implementation - Pre-Commit)

After code changes are verified:

1.  Review the changes you just made.
2.  Ask: "Did I introduce a new pattern, file structure, or important rule?"
3.  **Action**:
    -   If **YES**: Update the `AI_README.md` in that directory to reflect the new reality. Use the Standard Template below.
    -   If **NO**: No action needed.

## Standard AI_README Template

When creating or updating `AI_README.md`, strict adherence to this structure is required:

```markdown
# AI Context: [Directory Name]

## 1. Responsibility
(What is the single responsibility of this directory? What is out of scope?)

## 2. Key Files & Structure
(List key files/subdirectories and their purposes)

## 3. Rules & Constraints
(Hard rules: naming conventions, forbidden dependencies, file formats)

## 4. Patterns & Best Practices
(Soft rules: coding styles, preferred idioms, error handling patterns)

## 5. Dependencies
(Inbound: Who consumes this? Outbound: What does this depend on?)
```

## Example Scenarios

*   **User**: "Add a new script to crawl Anthropic docs."
    *   **Agent**:
        1.  Target dir: `scripts/`.
        2.  Read `scripts/AI_README.md`.
        3.  See rule: "Use Python 3.10+, add type hints".
        4.  Implement script following these rules.
        5.  (Post-task) Update `scripts/AI_README.md` to list the new script in "Key Scripts".

*   **User**: "Add a new provider DeepSeek."
    *   **Agent**:
        1.  Target dir: `registry/`.
        2.  Read `registry/AI_README.md`.
        3.  See rule: "Do NOT put all providers in one file".
        4.  Create `registry/providers/deepseek.json`.
