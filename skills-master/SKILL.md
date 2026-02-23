---
name: "skills-master"
description: "The Meta-Skill for managing standard capabilities. Use it to install, update, or list available standard skills (like auto-committer, context-code-explainer)."
---

# Skills Master

This skill acts as a package manager for the Skill ecosystem. It contains a library of "Standard Skills" that can be deployed to any project.

## Capabilities

The following skill templates are available in `assets/skill-templates/`:

*   **add-in-skills-master**: Adds or updates skill templates in the skills-master library. Invoke when user wants to contribute a new skill to the master library.
*   **auto-committer**: Automates git commits with Context Refresh checks.
*   **context-code-explainer**: Generates structured code analysis reports with AI_CONTEXT awareness.
*   **context-aware-coding**: Manages `AI_README.md` and enforces Context-First Architecture.
*   **context-project-analyzer**: Bootstraps AI_CONTEXT documentation for new/legacy projects.
*   **skill-creator**: Creates new skills and maintains the index.
*   **git-diff-requirement**: Analyzes git diff HEAD to evaluate code changes against business requirements, detects defects, and generates structured analysis reports. Invoke when reviewing code changes or validating requirement implementation.
*   **subagent-creator**: 专门用于生成子智能体的 skill，通过交互式问答收集信息并生成标准化的子智能体配置文档
*   **git-diff-requirement**: Analyzes git diff HEAD to evaluate code changes against business requirements, detects defects, and generates structured analysis reports. Invoke when reviewing code changes or validating requirement implementation.

*   **playwright-analyze-page**: 连接调试版Chrome浏览器，分析当前页面的DOM结构、交互元素和CSS样式信息。同时直接解析加载的插件内容。
*   **context-ai-sync**: Intelligent AI context documentation system for projects. Invoke with 'AI Context Sync' to initialize project docs or sync with code changes.
*   **context-requirements-analysis**: Context-aware requirements analysis skill. Automatically triggered when users request to complete specific requirements by reading existing AI documents or AI_CONTEXT documentation. The skill intelligently identifies scenario types and reads relevant documentation.
*   **update-skills-master**: Pull latest skills-master from GitHub using sparse checkout. Auto-detects target directory and works universally across different project structures.
*   **codebuddy-speckit-summary**: Extends the Speckit pipeline with a Feature Registry system. This skill should be used when working with Speckit commands (speckit.specify, speckit.plan, speckit.implement) to maintain a centralized feature index. It adds a speckit.summarize command for archiving completed features and injects REGISTRY.md awareness into existing Speckit commands via a project rule.

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
