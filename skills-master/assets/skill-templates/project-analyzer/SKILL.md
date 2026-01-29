---
name: "project-analyzer"
description: "Scans project structure to infer technology stack and architecture, then generates standard Context-First documentation. Invoke when initializing a new project or refreshing docs."
---

# Project Analyzer

This skill bootstraps the **Context-First Architecture** for any project by analyzing its structure and generating base documentation.

## When to Use
- Onboarding a new project.
- Initializing the `docs/AI_CONTEXT/` structure.
- When the project structure changes significantly.

## Instructions

1.  **Run Analysis**:
    Execute the analysis script to scan the current working directory:
    ```bash
    python3 skills/project-analyzer/scripts/analyze.py
    ```

2.  **Review & Refine**:
    -   The script generates `docs/AI_CONTEXT/ARCHITECTURE.md` and `CONSTITUTION.md`.
    -   **Action**: Open these files and refine the auto-generated placeholders with specific project details.

3.  **Integrate**:
    -   Once generated, other skills like `context-aware-coding` will automatically start using these files as the source of truth.
