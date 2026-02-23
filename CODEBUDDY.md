# CODEBUDDY.md This file provides guidance to CodeBuddy when working with code in this repository.

## Project Overview

**AI-Coding-Paradigm** is a comprehensive framework for AI-assisted development with three core modules:
- **Skills-Master**: Universal skill management system with 13+ standard skills
- **Rule-Master**: Interactive rule generation and management system
- **Subagents-Master**: Specialized sub-agent creation and deployment system

## Common Commands

### Skills-Master Commands

List available skills:
```bash
python3 skills-master/scripts/install.py --list
```

Install a specific skill (run from parent directory of `skills/`):
```bash
python3 skills/skills-master/scripts/install.py --name <skill-name>
```

Install all skills:
```bash
python3 skills/skills-master/scripts/install.py --all
```

Create a new skill:
```bash
python3 skills/skill-creator/scripts/create_skill.py --name <skill-name> --description "<description>"
```

Add skill to master library (supports external project paths):
```bash
python3 skills-master/assets/skill-templates/add-in-skills-master/scripts/add_skill.py \
  --source <path-to-skill> \
  [--name <skill-name>] \
  [--description "<description>"] \
  [--target <path-to-skills-master>] \
  [--force]
```

Update changelog:
```bash
python3 skills/auto-committer/scripts/manage_changelog.py add --type <type> --message "<description>"
```

Analyze project structure:
```bash
python3 skills/context-project-analyzer/scripts/analyze.py
```

### Rule-Master Commands

Generate project rules interactively:
```bash
python3 rule-master/main.py
```

Follow interactive prompts to configure role, tech stack, coding style, and engineering practices. Supports custom input variables and real-time content editing (press `d` for details, `e` to edit).

### Subagents-Master Commands

Create a new subagent:
```bash
python3 skills/subagent-creator/scripts/create_subagent.py
```

Follow interactive wizard to generate standardized subagent configuration with name, description, scenario prompt, tools, MCP, and knowledge base.

### Debug Commands (Playwright)

Connect to Chrome DevTools Protocol:
```bash
npm run debug:connect
```

Analyze styles (skip screenshots):
```bash
npm run debug:styles
```

Launch Chrome in debug mode:
```bash
npm run debug:launch-chrome
```

## Architecture

### Directory Structure

```
SkillsMaster/
├── skills-master/                    # Skill management system
│   ├── SKILL.md                     # Master skill definition
│   ├── scripts/install.py           # Installation tool
│   └── assets/skill-templates/      # Template library (13+ skills)
├── rule-master/                      # Rule generation system
│   ├── main.py                      # Interactive rule generator
│   ├── rules/                       # Rule definitions (11 JSON files)
│   └── rule.md                      # Generated output
├── subagents-master/                 # Subagent configurations
│   ├── README.md                    # Subagent index
│   └── code-mysql-converter/        # Example subagent
├── .codebuddy/skills/               # CodeBuddy IDE installation
├── .trae/skills/                    # Trae IDE installation
└── docs/AI_CONTEXT/                 # Project context docs
```

### Skill Architecture

**Skill Structure:**
- `SKILL.md`: Frontmatter with `name` and `description` (under 200 chars), plus usage instructions
- `scripts/`: Python automation scripts
- `assets/`: Templates, configs, and resources

**Critical Path Convention:**
All skills MUST use `${SKILL_DIR}` placeholder for path references instead of:
- Hardcoded absolute paths (e.g., `/Users/...`)
- IDE-specific variables (e.g., `${workspaceFolder}`)
- Relative paths without the placeholder

This ensures cross-IDE compatibility (VS Code, Cursor, Trae, CodeBuddy, PyCharm).

**Skill Invocation:**
Skills are invoked by AI assistants via natural language. The frontmatter `description` field must clearly state:
1. What the skill does
2. When to invoke it (trigger conditions)

**Skill Lifecycle:**
1. Create: Use `skill-creator` to scaffold new skill
2. Develop: Implement logic in SKILL.md and scripts/
3. Test: Install locally via `install.py`
4. Contribute: Use `add-in-skills-master` to add to template library
5. Distribute: Skills become available via `install.py --list`

### Rule-Master Architecture

**Rule Definition Format:**
Rules are defined in `rule-master/rules/*.json` with structure:
```json
{
  "id": "rule_id",
  "title": "Rule Title",
  "type": "single_select" | "multi_select",
  "options": [
    {
      "label": "Option Label",
      "value": "opt_value",
      "content": "Generated Markdown content...",
      "inputs": [  // Optional custom inputs
        {"key": "var_name", "prompt": "Input prompt", "default": "value"}
      ]
    }
  ]
}
```

**Rule Types:**
- 01-role.json: AI role definitions (Full-stack, Backend, Frontend, etc.)
- 02-tech-stack.json: Languages, frameworks, and versions
- 03-coding-style.json: Code style and formatting
- 04-testing.json: Testing strategies
- 05-engineering.json: Engineering practices
- 06-docs-mandatory.json: Documentation requirements
- 07-agent-hook.json: Agent behavior hooks
- 08-ai-interaction.json: AI interaction patterns
- 09-checklist.json: Development checklists
- 10-security.json: Security standards
- 11-glossary.json: Project terminology

**Interactive Features:**
- Press `d` to view option details
- Press `e` to edit content in real-time
- Press `Space` for multi-select
- Press `Enter` to confirm

### Subagent Architecture

**Subagent Configuration Format:**
Each subagent's `subagent.md` contains:
1. **名称** (Name): Unique identifier
2. **描述** (Description): Purpose and capabilities
3. **场景提示词** (Scenario Prompt): Role definition and behavior
4. **工具** (Tools): Optional internal tools
5. **MCP**: Optional MCP Server connections
6. **知识库** (Knowledge Base): Optional documentation references

### Context-First Documentation Strategy

Several skills (`context-project-analyzer`, `context-aware-coding`, `context-ai-sync`) implement a documentation pattern:
- `docs/AI_CONTEXT/` contains AI-optimized documentation
- Uses semantic keywords: MUST/NEVER/PREFER
- Avoids ASCII art, tree diagrams, visual decorations
- Uses numbered steps instead of flow diagrams
- Follows specification in `assets/AI_DOCUMENT_SPECIFICATION.md`

### Module Collaboration

The three core modules work together:
- **Skills** provide building blocks for common tasks
- **Rules** ensure consistency and guide AI behavior
- **Subagents** tackle complex, domain-specific challenges

## Important Skills

### Essential for New Projects
- **context-project-analyzer**: Bootstrap documentation (run first)
- **context-aware-coding**: Maintain AI_README.md and architecture docs
- **auto-committer**: Automate commit workflow with changelog updates

### Development Workflow
- **skill-creator**: Create new skills with standard structure
- **add-in-skills-master**: Contribute skills to master library
- **update-skills-master**: Pull latest skills from GitHub using sparse checkout

### Code Quality
- **git-diff-requirement**: Detect defects in code changes
- **git-diff-requirement**: Detect defects in code changes
- **context-code-explainer**: Generate structured code analysis reports

### Requirements Management

- **context-requirements-analysis**: Context-aware requirements analysis with AI_CONTEXT documentation

### Specialized Analysis
- **playwright-analyze-page**: Connect to Chrome DevTools, analyze page DOM, interactions, and CSS
- **context-ai-sync**: Intelligent AI context documentation system

### Subagent Creation
- **subagent-creator**: Interactive wizard for creating subagent configurations

## Development Guidelines

### Python Requirements
- Python 3.6+ required for all scripts
- Scripts use stdlib only (no external dependencies except `questionary` for rule-master)
- Use `python3` not `python` in command examples

### Git Workflow
- CHANGELOG.md follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
- Commits follow Conventional Commits: `<type>(<scope>): <description>`
- Common types: `feat`, `fix`, `refactor`, `docs`, `test`

### Documentation Updates
When adding skills:
1. `add_skill.py` auto-updates `skills-master/SKILL.md` Capabilities section
2. If in repo root, also updates `README.md` and `README_zh-CN.md`
3. The skill index must be kept in sync

### IDE-Specific Directories
- `.codebuddy/` and `.trae/` contain IDE-specific skill installations
- Do not directly edit these—modify the source in `skills-master/` and reinstall
- Scripts auto-detect the appropriate target directory

### Localization
The project supports both English and Chinese:
- README.md (English) and README_zh-CN.md (Chinese)
- Skills may have Chinese descriptions for Chinese-speaking users
- Subagents primarily use Chinese documentation
- Maintain parallel updates when possible

### Cross-IDE Compatibility
When creating or modifying skills:
1. Test that `${SKILL_DIR}` resolves correctly in target environment
2. Avoid shell-specific syntax in bash commands
3. Ensure scripts work on both Unix and Windows (if applicable)
4. Document any OS-specific limitations clearly

## Context Loading Protocol

When starting a new conversation in this repository, you MUST:
1. **Read Project Context Documentation** (if it exists):
   - `docs/AI_CONTEXT/ARCHITECTURE.md` - Project architecture overview
   - `docs/AI_CONTEXT/CONSTITUTION.md` - Project rules and conventions
   
2. **If Context Documentation Missing**:
   - Run `python3 skills/context-project-analyzer/scripts/analyze.py` to generate it
   - Then read the generated files before proceeding

3. **Exception**: Skip context loading ONLY if the user explicitly requests a quick, isolated task
