# Skills Master 🧰

> **Your Universal Skill Manager for AI-Assisted Development**
>
> Manage, distribute, and standardize AI skills across your projects and IDEs.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/skills-master)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**Skills Master** is a meta-skill designed to act as a package manager for the AI Skill ecosystem. It allows developers to easily install, update, and manage a library of "Standard Skills" (like `auto-committer`, `code-explainer`, `skill-creator`) across different projects and development environments (Trae, VS Code, Cursor, etc.).

[English](README.md) | [中文版](README_zh-CN.md)

---

## 🚀 Features

*   **📦 Centralized Skill Repository**: A curated collection of standard skills ready to be deployed.
*   **🛠️ Universal Compatibility**: Designed to work across different IDEs by removing environment-specific dependencies.
*   **🔄 Easy Installation**: Simple scripts to bootstrap your environment with essential AI capabilities.
*   **🧩 Extensible Architecture**: Easily add your own custom skills to the master library.
*   **🤖 Automation Ready**: Includes skills for automated git workflows, code analysis, and documentation generation.

---

## 📦 Included Skills

| Skill Name | Description |
| :--- | :--- |
| **auto-committer** | Automates git commits with changelog updates and semantic messages. |
| **code-explainer** | Generates structured code analysis reports for complex logic. |
| **project-analyzer** | Bootstraps Context-First documentation for new or legacy projects. |
| **skill-creator** | A tool to easily create new skills with standard directory structures. |
| **add-in-skills-master** | Helper to register new skills into the Skills Master library. |
| **context-aware-coding** | Manages `AI_README.md` and enforces architectural context. |
| **spec-kit-workflow** | A skill that integrates [Spec-Kit](https://github.com/Start-With-Spec/Spec-Kit) methodology (Specify -> Plan -> Tasks -> Implement) into your workflow. It includes templates and guides for Spec-Driven Development. |

---

## 🛠️ Installation

### Prerequisites

*   Python 3.6+
*   Git

### Quick Start
**Clone the repository** (or copy the `skills-master` directory) into your IDE's skills directory.

    ```bash
    git clone https://github.com/lone-yu-cmd/skills-master.git .skills/skills-master
    ```

Open your IDE's SKILL capabilities and tell the AI Assistant: "What skills are available in Skill-master?" or "Call skill-master to help me install auto-committer".

### 💡 Recommended Workflow for Existing Projects

If you are integrating Skills Master into an existing project:

1.  **Bootstrap with Project Analyzer**: First, use `skills-master` to install **project-analyzer**. This will generate the necessary documentation to understand your project structure.
2.  **AI-Assisted Development**: We **strongly recommend** installing **auto-committer** and **context-aware-coding**. These skills are crucial for providing context and automating tasks when working with AI assistants (like GPT).
3.  **Customize**: Install other skills as needed for your specific development requirements.

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
