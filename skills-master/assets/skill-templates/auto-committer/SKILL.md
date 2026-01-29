---
name: "auto-committer"
description: "Automates code commits: analyzes git diffs, updates CHANGELOG.md, generates conventional commit messages, and commits changes. Invoke when user wants to 'commit', 'finish task', or 'release'."
---

# Auto Committer

This skill automates the end-of-task workflow by analyzing your changes, documenting them in the changelog, and creating a semantic commit.

## When to Use
- User says "commit my changes"
- User says "I'm done with this task"
- User asks to "update changelog and commit"

## Workflow

Follow these steps strictly:

### 1. Status Check
Check the current repository status.
```bash
git status
```
- If "nothing to commit, working tree clean", inform the user and stop.
- If there are changes, proceed.

### 2. Context Refresh (CRITICAL)
Before committing, you MUST verify if the documentation is up-to-date with the code changes.
- **Action**: Invoke `context-aware-coding` skill (mentally or explicitly) to check `AI_README.md` and `ARCHITECTURE.md`.
- **Question**: "Did this change introduce new patterns, rules, or architectural decisions?"
- **If YES**: 
    1. Update the relevant `AI_README.md` or `docs/AI_CONTEXT/`.
    2. Ask user to review the documentation changes alongside code.
    3. Add the documentation files to the commit.

### 3. Diff Analysis
Get the detailed changes.
```bash
git diff HEAD
```
**Cognitive Task**: Analyze the diff output.
- **Type**: Identify if it's a `feat` (new feature), `fix` (bug fix), `refactor`, `docs`, etc.
- **Scope**: What module/file is affected? (e.g., `auth`, `api`, `readme`)
- **Description**: Summarize the change in imperative mood (e.g., "add login", not "added login").

### 4. Update Changelog
Use the helper script to append the change to `CHANGELOG.md`.
```bash
python3 skills/auto-committer/scripts/manage_changelog.py add --type <type> --message "<description>"
```
*Note: Use the analyzed 'type' (e.g., 'feat') and 'description' from Step 3.*

### 5. Git Commit
Stage all changes (including the updated CHANGELOG.md and docs) and commit.
```bash
git add .
git commit -m "<type>(<scope>): <description>"
```
*Example*: `git commit -m "feat(auth): implement jwt token validation"`

### 6. Verification
Show the commit log to the user.
```bash
git log -1 --stat
```

### 7. Optional Push
Ask the user: "Would you like me to push these changes to the remote repository?"
- If **Yes**: Run `git push`.
- If **No**: Stop here.

## Error Handling
- If `git diff` is empty but `git status` shows untracked files, run `git add -N .` first to see the diff, or just inspect the untracked files.
- If `CHANGELOG.md` script fails, report the error and try to fix the file manually or ask user for guidance.
