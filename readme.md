# AI-Coding-Paradigm 🚀

> **A Comprehensive Framework for AI-Assisted Development**
>
> Standardize, automate, and enhance your AI-powered development workflow with three powerful core modules: Skills Management, Rule Generation, and Sub-Agent Systems.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/ai-coding-paradigm)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**AI-Coding-Paradigm** is a comprehensive framework that revolutionizes AI-assisted development by providing three integrated core modules. It enables developers to manage reusable skills, generate standardized rules, and deploy specialized sub-agents across different projects and development environments (Trae, VS Code, Cursor, etc.).

## 🎯 Project Overview

This framework consists of three equal and complementary core modules:

- **🧰 Skills-Master**: Universal skill management system for AI capabilities
- **📋 Rule-Master**: Standardized rule generation and management
- **🤖 Subagents-Master**: Specialized sub-agent creation and deployment

Together, these modules form a complete ecosystem for building, managing, and scaling AI-assisted development workflows.

[English](README.md) | [中文版](README_zh-CN.md)

---

## 🏗️ Core Modules

### 🧰 Skills-Master

**Your Universal Skill Manager for AI-Assisted Development**

Skills-Master acts as a package manager for the AI Skill ecosystem, allowing developers to easily install, update, and manage a library of "Standard Skills" across different projects.

**Key Features:**
- 📦 **Centralized Skill Repository**: Curated collection of 13+ standard skills ready to deploy
- 🛠️ **Universal Compatibility**: Works across different IDEs (Trae, VS Code, Cursor)
- 🔄 **Easy Installation**: Simple scripts to bootstrap your environment
- 🧩 **Extensible Architecture**: Add your own custom skills to the library
- 🤖 **Automation Ready**: Includes skills for git workflows, code analysis, and documentation

**Location**: `skills-master/`

### 📋 Rule-Master

**Standardized Rule Generation and Management System**

Rule-Master provides a systematic approach to defining and managing development rules, coding standards, and AI interaction guidelines for your projects.

**Key Features:**
- 📝 **Rule Templates**: Pre-defined templates for common development scenarios
- 🎯 **Standardization**: Ensure consistent coding practices across teams
- 🔧 **Customizable**: Adapt rules to your project's specific needs
- 📚 **Rule Library**: 11+ standard rule definitions (role, tech-stack, coding-style, etc.)
- 🤝 **AI Integration**: Rules that guide AI assistants in understanding your project

**Location**: `rule-master/`

### 🤖 Subagents-Master

**Specialized Sub-Agent Creation and Deployment System**

Subagents-Master enables you to create and manage specialized AI sub-agents that handle specific, complex tasks with domain expertise.

**Key Features:**
- 🎭 **Specialized Agents**: Create focused agents for specific domains (e.g., code-mysql-converter)
- 🔄 **Interactive Creation**: Guided workflow for sub-agent generation
- 📦 **Standardized Structure**: Consistent configuration and deployment format
- 🧠 **Domain Expertise**: Agents with deep knowledge in specific areas
- 🔌 **Easy Integration**: Seamlessly integrate with your existing workflow

**Location**: `subagents-master/`

---

## 🔗 Module Collaboration

These three modules work together to create a powerful AI development ecosystem:

```
┌─────────────────┐
│  Skills-Master  │ ← Provides reusable capabilities
└────────┬────────┘
         │
         ├
         │          
┌────────▼────────┐
│ Subagents-Master ← Defines domain-specific agents
└─────────────────┘ 
       
       
       
┌─────────────────────┐
│  Rule-Master        │ ← Defines standards and guidelines
└─────────────────────┘
```

- **Skills** provide the building blocks for common tasks
- **Rules** ensure consistency and guide AI behavior
- **Sub-agents** tackle complex, domain-specific challenges

---

## 📦 Skills-Master: Included Skills

| Skill Name | Description |
| :--- | :--- |
| **auto-committer** | Automates git commits with changelog updates and semantic messages. |
| **code-explainer** | Generates structured code analysis reports for complex logic. |
| **project-analyzer** | Bootstraps Context-First documentation for new or legacy projects. |
| **skill-creator** | A tool to easily create new skills with standard directory structures. |
| **add-in-skills-master** | Adds or updates skill templates in the skills-master library. Invoke when user wants to contribute a new skill to the master library. |
| **context-aware-coding** | Manages `AI_README.md` and enforces architectural context. |
| **spec-kit-workflow** | A skill that integrates [Spec-Kit](https://github.com/Start-With-Spec/Spec-Kit) methodology (Specify -> Plan -> Tasks -> Implement) into your workflow. It includes templates and guides for Spec-Driven Development. |
| **git-diff-requirement** | Analyzes git diff HEAD to evaluate code changes against business requirements, detects defects, and generates structured analysis reports. Invoke when reviewing code changes or validating requirement implementation. |
| **subagent-creator** | 专门用于生成子智能体的 skill，通过交互式问答收集信息并生成标准化的子智能体配置文档 |
| **code-review** | Code review skill. Triggered when user says 'I have completed this requirement, please review my code'. Analyzes git diff HEAD changes, checks business correctness against requirement documents, identifies logic defects or implementation errors, and provides detailed review feedback and suggestions. |
| **requirements-analysis** | 需求分析文档创建技能。当用户告知"需要开始一个新需求"时触发。该技能会创建 .requirementsAnalysis 文件夹、更新 .gitignore、按序号命名创建需求目录，并生成包含需求背景、需求内容、代码实施计划的需求文档。完成后与用户确认内容，确认后开始代码实施。 |
| **playwright-analyze-page** | 连接调试版Chrome浏览器，分析当前页面的DOM结构、交互元素和CSS样式信息 |
| **ai-context-sync** | Intelligent AI context documentation system for projects. Invoke with 'AI Context Sync' to initialize project docs or sync with code changes. |
| **ai_context_requirements-analysis** | Context-aware requirements analysis skill. Automatically triggered when users request to complete specific requirements by reading existing AI documents or AI_CONTEXT documentation. The skill intelligently identifies scenario types and reads relevant documentation. |
| **update-skills-master** | Pull latest skills-master from GitHub using sparse checkout. Auto-detects target directory and works universally across different project structures. |

---

## 🛠️ Installation

### Prerequisites

*   Python 3.6+
*   Git

### Quick Start

**Clone the repository** to get all three core modules:

```bash
git clone https://github.com/lone-yu-cmd/ai-coding-paradigm.git
```

The repository structure:
```
ai-coding-paradigm/
├── skills-master/      # Skill management system
├── rule-master/        # Rule generation system
├── subagents-master/   # Sub-agent system
└── docs/              # Documentation
```

**For Skills-Master**: Copy or symlink the `skills-master` directory to your IDE's skills directory, then tell the AI Assistant: "What skills are available in Skills-Master?" or "Call skills-master to help me install auto-committer".

**For Rule-Master**: Use the rule generation tools to create standardized rules for your project.

**For Subagents-Master**: Create specialized sub-agents using the `subagent-creator` skill.

### 💡 Recommended Workflow for Existing Projects

If you are integrating AI-Coding-Paradigm into an existing project:

1.  **Initialize Documentation**: Use **ai-context-sync** skill to generate AI context documentation (`docs/AI_CONTEXT/`).
2.  **Define Rules**: Use **rule-master** to establish coding standards and AI interaction guidelines.
3.  **Install Core Skills**: We **strongly recommend** installing **auto-committer** and **context-aware-coding** for automated workflows.
4.  **Create Sub-Agents**: Use **subagent-creator** to build specialized agents for complex domain-specific tasks.
5.  **Customize**: Add more skills and rules as needed for your specific requirements.

---

## 📖 Usage Guide

Once installed, each skill resides in its own directory (e.g., `skills/auto-committer`) and comes with its own `SKILL.md` documentation.

### Example: Creating a New Skill

Use the **skill-creator** (once installed) to generate a new skill template

### Example: Automating Commits

Use the **auto-committer** to handle your git workflow
---

## 🤝 Contributing

We welcome contributions! If you have a useful skill you'd like to share with the community, follow these steps:

1.  **Fork the repository**.
2.  **Create your skill** using `skill-creator`.
3.  **Add it to the master library** using `add-in-skills-master`:
4.  **Submit a Pull Request**.

### Guidelines
*   Keep skills self-contained in their own directory.
*   Include a `SKILL.md` with clear usage instructions.
*   Avoid hardcoded paths (use relative paths).
*   Ensure scripts are cross-platform compatible.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">Made with ❤️ for the AI Developer Community</p>
