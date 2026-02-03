---
name: "skills-master"
description: "The Meta-Skill for managing standard capabilities. Use it to install, update, or list available standard skills (like auto-committer, code-explainer)."
---

# Skills Master

This skill acts as a package manager for the Skill ecosystem. It contains a library of "Standard Skills" that can be deployed to any project.

## Capabilities

The following skill templates are available in `assets/skill-templates/`:

*   **add-in-skills-master**: Adds or updates skill templates in the skills-master library. Invoke when user wants to contribute a new skill to the master library.
*   **auto-committer**: Automates git commits with Context Refresh checks.
*   **code-explainer**: Generates structured code analysis reports.
*   **context-aware-coding**: Manages `AI_README.md` and enforces Context-First Architecture.
*   **project-analyzer**: Bootstraps documentation for new/legacy projects.
*   **skill-creator**: Creates new skills and maintains the index.
*   **spec-kit-workflow**: Implements Spec-Driven Development (Specify -> Plan -> Tasks -> Implement).
*   **git-diff-requirement**: Analyzes git diff HEAD to evaluate code changes against business requirements, detects defects, and generates structured analysis reports. Invoke when reviewing code changes or validating requirement implementation.
*   **subagent-creator**: 专门用于生成子智能体的 skill，通过交互式问答收集信息并生成标准化的子智能体配置文档
## Instructions
If you want to use the following command, you need to change the current directory to the upper directory of `skills/`.

### List Available Skills
To see what can be installed:
```bash
python3 skills/skills-master/scripts/install.py --list
```

### Install a Specific Skill
To install a single skill (e.g., `auto-committer`):
```bash
python3 skills/skills-master/scripts/install.py --name auto-committer
```
*Note: After installation, run `skill-creator`'s update script to refresh the README index.*

### Install All Standard Skills
To bootstrap a full environment:
```bash
python3 skills/skills-master/scripts/install.py --all
```
