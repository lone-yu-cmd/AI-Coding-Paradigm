---
name: "add-in-skills-master"
description: "Adds or updates skill templates in the skills-master library. Invoke when user wants to contribute a new skill to the master library."
---

# Add In Skills Master

This skill helps developers register their custom skills into the `skills-master` library, making them available as standard templates for distribution. It supports both local project skills and skills from external project paths.

## When to Use

Invoke this skill when:
- The user has created a new skill and wants to "publish" or "add" it to the `skills-master` library.
- The user wants to update an existing template in `skills-master` with changes from a working skill instance.
- The user asks to "contribute" a skill.
- **The user wants to import a skill from another local project into the current project's `skills-master`.**

## Capabilities

1.  **Template Registration**: Copies a skill directory (source) to the `skills-master/assets/skill-templates/` directory.
2.  **External Path Support**: Can import skills from any local path, not just the current project directory.
3.  **Target Directory Specification**: Allows explicit specification of the target `skills-master` directory.
4.  **Auto-detection of Skill Metadata**: Automatically extracts skill name and description from `SKILL.md` frontmatter if not provided.
5.  **Source Validation**: Validates that the source directory contains a valid `SKILL.md` file.
6.  **Duplicate Detection**: Checks for existing skills and prompts for confirmation before overwriting.
7.  **Documentation Update**: Automatically updates `skills-master/SKILL.md` to list the new skill under "Capabilities" with its description.
8.  **Project README Update**: If the script detects it's running in the Skills Master open-source repository root, it automatically updates `README.md` and `README_zh-CN.md` with the new skill.


## Usage

### Basic Usage (Add skill from current project)

```bash
python3 scripts/add_skill.py \
  --name <skill-name> \
  --description "<skill description>" \
  --source <path-to-skill-source>
```

### Import Skill from External Project

```bash
python3 scripts/add_skill.py \
  --source /path/to/other-project/skills/external-skill
```

When importing from an external path, the script will automatically extract the skill name and description from the `SKILL.md` frontmatter if `--name` and `--description` are not provided.

### Specify Target skills-master Directory

```bash
python3 scripts/add_skill.py \
  --source /path/to/skill \
  --target /path/to/target/skills-master
```

### Force Overwrite (Skip Confirmation)

```bash
python3 scripts/add_skill.py \
  --source ./my-skill \
  --force
```

**Parameters:**
- `--name`: (Optional) The unique identifier of the skill. If not provided, will be extracted from `SKILL.md` or use the directory name.
- `--description`: (Optional) A brief description of what the skill does. If not provided, will be extracted from `SKILL.md`.
- `--source`: (Required) The local path to the skill you want to add. Supports any valid local path.
- `--target`: (Optional) The target `skills-master` directory. If not specified, the script will auto-detect.
- `--force`, `-f`: (Optional) Skip confirmation prompts and force overwrite existing skills.

## Examples

### Example 1: Add a skill from the current project

User: "I want to add my 'database-manager' skill to the master library."

Agent:
```bash
python3 scripts/add_skill.py \
  --name database-manager \
  --description "Automates database migrations and backups." \
  --source skills/database-manager
```

### Example 2: Import a skill from an external project

User: "Import the 'api-generator' skill from my other project at `/Users/john/projects/backend-tools`."

Agent:
```bash
python3 scripts/add_skill.py \
  --source /Users/john/projects/backend-tools/skills/api-generator
```

### Example 3: Import with explicit target directory

User: "Add the 'logging-helper' skill from `/tmp/my-skills/logging-helper` to the skills-master at `/Users/john/main-project/skills-master`."

Agent:
```bash
python3 scripts/add_skill.py \
  --source /tmp/my-skills/logging-helper \
  --target /Users/john/main-project/skills-master
```

## Helper Instructions for Agent

- **Path Resolution**: The scripts are located in `scripts/`. You must determine the skill's location and prepend it.
- **External Paths**: The `--source` parameter accepts any valid local path, including absolute paths to other projects.
- **Auto-detection**: If `--name` and `--description` are not provided, the script will attempt to extract them from the source `SKILL.md` frontmatter.
- **Root-Level `skills-master` Support**: This script automatically detects if `skills-master` is in the project root (common in the open-source repository) or nested in a `skills/` directory (common in user projects).
- **Verify Source**: Ensure the source directory exists and contains a valid `SKILL.md` before running the script.
- **Duplicate Handling**: If a skill with the same name already exists, the script will prompt for confirmation unless `--force` is used.
- **Confirmation**: After running the script, verify that `skills-master/assets/skill-templates/<skill-name>` exists and `skills-master/SKILL.md` has been updated.
