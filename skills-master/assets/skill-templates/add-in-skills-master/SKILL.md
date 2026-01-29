---
name: "add-in-skills-master"
description: "Adds or updates skill templates in the skills-master library. Invoke when user wants to contribute a new skill to the master library."
---

# Add In Skills Master

This skill helps developers register their custom skills into the `skills-master` library, making them available as standard templates for distribution.

## When to Use

Invoke this skill when:
- The user has created a new skill and wants to "publish" or "add" it to the `skills-master` library.
- The user wants to update an existing template in `skills-master` with changes from a working skill instance.
- The user asks to "contribute" a skill.

## Capabilities

1.  **Template Registration**: Copies a skill directory (source) to the `skills-master/assets/skill-templates/` directory.
2.  **Documentation Update**: Automatically updates `skills-master/SKILL.md` to list the new skill under "Capabilities" with its description.
3.  **Project README Update**: If the script detects it's running in the Skills Master open-source repository root, it automatically updates `README.md` and `README_zh-CN.md` with the new skill.


## Usage

### Add/Update a Skill

```bash
python3 scripts/add_skill.py \
  --name <skill-name> \
  --description "<skill description>" \
  --source <path-to-skill-source>
```

**Parameters:**
- `--name`: The unique identifier of the skill (e.g., `my-custom-skill`).
- `--description`: A brief description of what the skill does.
- `--source`: The local path to the skill you want to add (e.g., `skills/my-custom-skill`).

### Example

User: "I want to add my 'database-manager' skill to the master library."

Agent:
```bash
python3 scripts/add_skill.py \
  --name database-manager \
  --description "Automates database migrations and backups." \
  --source skills/database-manager
```

## Helper Instructions for Agent

- **Path Resolution**: The scripts are located in `scripts/`. You must determine the skill's location and prepend it.
- **Root-Level `skills-master` Support**: This script automatically detects if `skills-master` is in the project root (common in the open-source repository) or nested in a `skills/` directory (common in user projects).
- **Verify Source**: Ensure the source directory exists and contains a valid `SKILL.md` before running the script.
- **Confirmation**: After running the script, verify that `skills-master/assets/skill-templates/<skill-name>` exists and `skills-master/SKILL.md` has been updated.
