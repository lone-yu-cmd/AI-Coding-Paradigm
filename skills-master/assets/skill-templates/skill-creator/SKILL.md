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

## Path & Environment Constraints

**CRITICAL: All new skills MUST strictly adhere to the following path conventions to ensure cross-IDE compatibility (VS Code, Antigravity, codebuddy, PyCharm, etc.):**

1.  **Base Directory Placeholder**:
    *   ALWAYS use `${SKILL_DIR}` as the placeholder for the skill's root directory.
    *   NEVER use hardcoded absolute paths (e.g., `/Users/name/...`) or IDE-specific variables (e.g., `${workspaceFolder}`).

2.  **Relative Paths**:
    *   All file references within the skill documentation, configuration, and scripts must be relative to `${SKILL_DIR}`.
    *   Example: Use `${SKILL_DIR}/scripts/run.py` instead of `./scripts/run.py` or `scripts/run.py`.

3.  **Configuration & Dependencies**:
    *   Ensure all config files, dependency declarations, and execution scripts utilize `${SKILL_DIR}` for path resolution.

4.  **Installation Instructions**:
    *   The skill's `SKILL.md` MUST include an "Installation" section that explicitly explains the `${SKILL_DIR}` mechanism.

5.  **Portability Check**:
    *   Before finalizing a skill, verify it can work in different project locations without path modifications.
    *   Test: Move the skill to a different directory and ensure all paths still resolve correctly.

## SKILL.md Format

```markdown
---
name: "<skill-name>"
description: "<concise description covering: (1) what the skill does, (2) when to invoke it. Keep it under 200 characters for best display>"
---

# <Skill Title>

## Installation

The `${SKILL_DIR}` placeholder represents the absolute path to this skill's directory. It is automatically resolved by the environment when the skill is invoked.

## Usage

<Detailed instructions using ${SKILL_DIR} for all path references>
Example: `python3 ${SKILL_DIR}/scripts/main.py`
```

## Path Usage Examples

**✅ CORRECT - Using Relative Paths:**

Run the script:
\`\`\`bash
python3 ${SKILL_DIR}/scripts/run.py
\`\`\`

Configuration file: `${SKILL_DIR}/config/settings.json`
```

**❌ WRONG - Using Absolute Paths:**
```markdown
# DON'T: Absolute paths in documentation
Run the script:
\`\`\`bash
python3 /Users/username/project/skills/my-skill/scripts/run.py
\`\`\`
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
5. **Path Verification Checklist**:
   - ✅ All paths in SKILL.md use `${SKILL_DIR}` placeholder
   - ✅ Python scripts use `os.path.dirname(__file__)` for path detection
   - ✅ No hardcoded absolute paths anywhere
   - ✅ Configuration files use relative paths
6. **Verify Cross-IDE Compatibility**: Ensure the skill works in different IDEs (VS Code, Antigravity, codebuddy, PyCharm) without path errors.

## Example

To create a "code-reviewer" skill:

```bash
python3 skills/skill-creator/scripts/create_skill.py --name code-reviewer --description "Analyzes code quality and suggests improvements"
```

Then edit `skills/code-reviewer/SKILL.md` to add specific instructions.
