---
name: "skill-creator"
description: "MANDATORY tool for creating SKILLs - MUST be invoked IMMEDIATELY when user wants to create/add any skill"
---

# Skill Creator

This skill helps you create new SKILLs for the workspace.

## When to Use

**CRITICAL: You MUST invoke this skill IMMEDIATELY as your FIRST action when:**
- User wants to create a new skill
- User wants to add a custom skill to the workspace
- User asks to set up a skill template
- User asks "how to create a skill"
- User mentions creating/adding/making any skill

**DO NOT:**
- Just explain how to create a skill without invoking this tool
- Provide manual instructions without calling this skill first
- Defer the skill creation to later steps

## SKILL Structure

A valid SKILL requires:

1. **Directory**: `skills/<skill-name>/`
2. **File**: `SKILL.md` inside the directory

## SKILL.md Format

```markdown
---
name: "<skill-name>"
description: "<concise description covering: (1) what the skill does, (2) when to invoke it. Keep it under 200 characters for best display>"
---

# <Skill Title>

<Detailed instructions, usage guidelines, and examples>
```

## Creation Steps

1. Ask user for skill name and purpose
2. Run the creation script:
   ```bash
   python3 skills/skill-creator/scripts/create_skill.py --name <skill-name> --description "<description>"
   ```
3. The script will automatically:
   - Create the directory structure (`skills/<skill-name>/`)
   - Generate `SKILL.md` with proper frontmatter
   - Update the global skills index (`README.md`)
4. Validate the structure is correct

## Example

To create a "code-reviewer" skill:

```bash
python3 skills/skill-creator/scripts/create_skill.py --name code-reviewer --description "Analyzes code quality and suggests improvements"
```

Then edit `skills/code-reviewer/SKILL.md` to add specific instructions.
