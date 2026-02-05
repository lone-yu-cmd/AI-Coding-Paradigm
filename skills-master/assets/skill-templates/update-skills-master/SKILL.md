---
name: update-skills-master
description: Pull the latest skills-master directory from a remote GitHub repository and replace the local skills-master directory. Uses Git sparse checkout to fetch only the skills-master folder without cloning the entire repository. Invoke when user wants to update, sync, or pull the latest skills from the master repository.
---

# Update Skills Master

This skill provides automated synchronization of the `skills-master` directory from a remote GitHub repository to the local workspace. It uses Git sparse checkout to efficiently fetch only the `skills-master` directory without cloning the entire repository.

## Overview

The skill enables:
- **Sparse checkout** - Fetch only the `skills-master` directory from GitHub
- **Automatic backup** - Create backup before replacing local directory
- **Safe rollback** - Restore from backup if update fails
- **Flexible configuration** - Support custom repositories, branches, and target directories
- **Universal compatibility** - Works in any skills environment (CodeBuddy, standalone projects, etc.)
- **Smart path detection** - Automatically locates skills-master relative to this skill's location

## When to Use This Skill

Invoke this skill when the user requests:

**Explicit Triggers**:
- "更新 skills-master"
- "拉取最新的 skills-master"
- "同步远程 skills-master"
- "从 GitHub 更新技能库"
- "Update skills-master from remote"
- "Pull latest skills-master"
- "Sync skills-master with GitHub"

**Implicit Triggers**:
- User wants to get the latest skill templates
- User mentions outdated skills
- User wants to sync their local skills with the central repository

**Do NOT use this skill for**:
- Committing local changes to skills-master
- Creating or editing individual skills
- Installing specific skills (use `skills-master` skill instead)

## Usage

### Basic Usage (Update from Default Repository)

The simplest way to update skills-master:

```bash
python3 scripts/update_skills_master.py
```

This will:
1. Backup the existing `skills-master` directory
2. Clone the latest `skills-master` from `https://github.com/lone-yu-cmd/AI-Coding-Paradigm.git` (master branch)
3. Replace the local `skills-master` directory (auto-detected in skills parent directory)
4. Clean up temporary files

### Advanced Usage

#### Update from Custom Repository

```bash
python3 scripts/update_skills_master.py \
  --repo https://github.com/username/repository.git
```

#### Update from Different Branch

```bash
python3 scripts/update_skills_master.py \
  --branch main
```

#### Update to Custom Target Directory

```bash
python3 scripts/update_skills_master.py \
  --target ./my-custom-skills-master
```

#### Skip Backup (Not Recommended)

```bash
python3 scripts/update_skills_master.py \
  --no-backup
```

#### Full Custom Configuration

```bash
python3 scripts/update_skills_master.py \
  --repo https://github.com/username/repo.git \
  --branch develop \
  --sparse-path skills-master \
  --target ./skills-master
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `--repo` | No | `https://github.com/lone-yu-cmd/AI-Coding-Paradigm.git` | GitHub repository URL |
| `--branch` | No | `master` | Branch to clone from |
| `--sparse-path` | No | `skills-master` | Path within repository to checkout |
| `--target` | No | Auto-detect | Local target directory (auto-detects skills-master in skills parent) |
| `--no-backup` | No | `False` | Skip creating backup |

## Workflow

The skill follows these steps:

```
1. Validate Git Installation
   ├─ Check if Git is installed
   └─ Show Git version
   
2. Auto-detect Target Directory
   ├─ Find this skill's location (skills/update-skills-master/)
   ├─ Navigate to parent directory (skills/)
   └─ Locate skills-master sibling directory
   
3. Configuration
   ├─ Display configuration summary
   └─ Get user confirmation (if interactive)
   
4. Backup (if not skipped)
   ├─ Check if local skills-master exists
   └─ Create timestamped backup directory
   
5. Clone with Sparse Checkout
   ├─ Create temporary directory (in skills parent directory)
   ├─ Initialize Git repository
   ├─ Add remote repository
   ├─ Enable sparse checkout
   ├─ Configure sparse checkout path
   └─ Pull specified branch
   
6. Replace Local Directory
   ├─ Remove old skills-master directory
   └─ Copy new directory from clone
   
7. Cleanup
   ├─ Remove temporary directory
   └─ Report success/failure
   
8. Error Handling (if failure)
   ├─ Restore from backup
   └─ Report error details
```

## Execution Instructions

When the user requests to update skills-master, follow these steps:

### Step 1: Confirm User Intent

Before executing, confirm with the user:

```markdown
📋 Ready to update skills-master

**Configuration**:
- Repository: [repo URL]
- Branch: [branch name]
- Local Target: [target directory]
- Backup: [Yes/No]

This will:
1. Backup your existing skills-master (if enabled)
2. Pull the latest skills-master from GitHub
3. Replace your local skills-master directory

**⚠️ Warning**: Any local changes to skills-master will be overwritten.

Do you want to proceed? (yes/no)
```

### Step 2: Validate Prerequisites

Check that:
- Git is installed on the system
- Internet connection is available
- User has write permissions to the target directory

If Git is not installed, inform the user:

```markdown
❌ Git is not installed

To use this skill, please install Git first:
- macOS: `brew install git` or download from https://git-scm.com/
- Linux: `sudo apt-get install git` or `sudo yum install git`
- Windows: Download from https://git-scm.com/downloads

After installing Git, please try again.
```

### Step 3: Execute the Update Script

Run the script from the skill's scripts directory:

```bash
# Navigate to the skill's scripts directory
cd skills/update-skills-master/scripts

# Execute the update script (it will auto-detect the target directory)
python3 update_skills_master.py [options]
```

**Note**: The script automatically detects the `skills-master` directory by:
1. Finding its own location (`skills/update-skills-master/scripts/`)
2. Going up to the skills parent directory
3. Locating the `skills-master` sibling directory

This works in any project structure where skills are organized as:
```
project/
├── skills/
│   ├── update-skills-master/  ← This skill
│   ├── skills-master/         ← Target to update
│   └── other-skills/
```

Or in CodeBuddy environments:
```
project/
├── .codebuddy/
│   └── skills/
│       ├── update-skills-master/  ← This skill
│       └── skills-master/         ← Target to update
```

### Step 4: Monitor Progress

The script provides progress updates:
- ✅ Success indicators
- 🔄 In-progress operations
- ❌ Error messages
- 💡 Helpful information

Watch for any errors and be prepared to explain them to the user.

### Step 5: Report Results

After execution completes, report to the user:

**On Success**:
```markdown
✅ Skills Master updated successfully!

**Summary**:
- Repository: [repo URL]
- Branch: [branch]
- Local Directory: [target path]
- Backup Location: [backup path] (if created)

**Next Steps**:
1. Verify the updated skills-master directory
2. You can safely delete the backup after verification
3. Use `skills-master` skill to install specific skills

Would you like to install or update specific skills now?
```

**On Failure**:
```markdown
❌ Skills Master update failed

**Error**: [error message]

**What happened**:
[Explain the error in user-friendly terms]

**Recovery**:
- Your original skills-master has been restored from backup
- No changes were made to your local directory

**Troubleshooting**:
[Suggest solutions based on the error type]

Would you like to try again with different settings?
```

## Error Handling

### Common Errors and Solutions

#### Git Not Installed
```markdown
**Error**: Git is not installed

**Solution**: Install Git from https://git-scm.com/downloads
```

#### Network Connection Failed
```markdown
**Error**: Failed to connect to GitHub

**Solution**: 
1. Check your internet connection
2. Verify the repository URL is correct
3. Check if GitHub is accessible from your network
```

#### Permission Denied
```markdown
**Error**: Permission denied when writing to target directory

**Solution**:
1. Check if you have write permissions to the target directory
2. Try running with appropriate permissions
3. Specify a different target directory with --target
```

#### Branch Not Found
```markdown
**Error**: Branch 'xxx' does not exist in the repository

**Solution**:
1. Verify the branch name is correct
2. Check available branches on GitHub
3. Try with the default 'master' branch
```

#### Sparse Path Not Found
```markdown
**Error**: Path 'skills-master' not found in repository

**Solution**:
1. Verify the repository contains a 'skills-master' directory
2. Check the --sparse-path parameter
3. Ensure you're using the correct repository URL
```

## Best Practices

### 1. Always Keep Backup Enabled
❌ **Don't**: Use `--no-backup` unless absolutely necessary  
✅ **Do**: Let the script create automatic backups

### 2. Verify After Update
❌ **Don't**: Assume the update succeeded without checking  
✅ **Do**: Verify the updated directory structure and contents

### 3. Clean Up Backups
❌ **Don't**: Accumulate many backup directories  
✅ **Do**: Delete old backups after verifying the update

### 4. Use Version Control
❌ **Don't**: Modify files inside skills-master directly  
✅ **Do**: If you need customizations, copy skills to your project and modify there

### 5. Document Custom Repositories
❌ **Don't**: Use custom repositories without documenting the source  
✅ **Do**: Document which repository and branch you're syncing from

## Technical Details

### Git Sparse Checkout

This skill uses Git's sparse checkout feature to fetch only specific directories from a repository:

1. **Initialize** a new Git repository locally
2. **Add remote** pointing to the GitHub repository
3. **Enable sparse checkout** with `git config core.sparseCheckout true`
4. **Specify path** in `.git/info/sparse-checkout` file
5. **Pull branch** which fetches only the specified directory

**Benefits**:
- ✅ Faster than cloning entire repository
- ✅ Saves disk space
- ✅ Reduces network bandwidth usage
- ✅ Only downloads what's needed

### Directory Structure

After updating, the local structure should be:

```
project-root/
├── skills/                     # Or .codebuddy/skills/
│   ├── skills-master/         # ← Updated directory
│   │   ├── SKILL.md
│   │   ├── README.md
│   │   ├── assets/
│   │   │   └── skill-templates/
│   │   │       ├── auto-committer/
│   │   │       ├── code-explainer/
│   │   │       └── ...
│   │   └── scripts/
│   │       └── install.py
│   ├── skills-master.backup/  # ← Backup (if created)
│   └── update-skills-master/  # ← This skill
│       ├── SKILL.md
│       ├── README.md
│       └── scripts/
│           └── update_skills_master.py
```

**Universal Compatibility**:

This skill works in multiple project structures:

1. **Standard skills directory**:
   ```
   project/
   └── skills/
       ├── update-skills-master/
       └── skills-master/
   ```

2. **CodeBuddy environment**:
   ```
   project/
   └── .codebuddy/
       └── skills/
           ├── update-skills-master/
           └── skills-master/
   ```

3. **Custom directory structure** (with --target):
   ```
   project/
   ├── my-skills/
   │   └── update-skills-master/
   └── shared-skills-master/  ← Custom target
   ```

## Integration with Other Skills

This skill works well with other skills in the ecosystem:

- **`skills-master`** - After updating, use this to install specific skills
- **`skill-creator`** - Create new skills that will be added to skills-master
- **`add-in-skills-master`** - Contribute your skills to skills-master

### Example Workflow

```
1. Update skills-master (this skill)
   ↓
2. List available skills (skills-master --list)
   ↓
3. Install needed skills (skills-master --name skill-name)
   ↓
4. Create custom skills (skill-creator)
   ↓
5. Contribute back (add-in-skills-master)
```

## Troubleshooting

### Issue: "Already up-to-date" but Files Are Different

**Cause**: Git may cache the remote state

**Solution**:
```bash
# Force a fresh clone by removing and re-running
rm -rf skills-master.backup.*
python3 scripts/update_skills_master.py
```

### Issue: Update Fails Midway

**Cause**: Network interruption or permission issues

**Solution**:
- Script automatically restores from backup
- Check error message for specific cause
- Ensure stable network connection
- Verify write permissions

### Issue: Cannot Find Script

**Cause**: Running from wrong directory

**Solution**:
```bash
# Navigate to the skill's scripts directory
cd skills/update-skills-master/scripts

# Or use full path from project root
python3 skills/update-skills-master/scripts/update_skills_master.py
```

## Security Considerations

### Repository Trust

⚠️ **Important**: Only update from trusted repositories

- Default repository: `https://github.com/lone-yu-cmd/AI-Coding-Paradigm.git`
- Verify repository ownership before using custom repos
- Check repository contents on GitHub before pulling

### Local Modifications

⚠️ **Warning**: This operation overwrites local changes

- Any modifications to `skills-master/` will be lost
- Use backups to preserve important changes
- Consider using version control for custom modifications

## Examples

### Example 1: Simple Update

**User**: "Update skills-master from GitHub"

**Agent Action**:
```bash
cd /path/to/project/skills/update-skills-master/scripts
python3 update_skills_master.py
```

**Expected Output**:
```
==============================================================
🚀 Skills Master Update Script
==============================================================
✅ Git is installed: git version 2.39.0
ℹ️  Auto-detected skills directory: /path/to/project/skills

📋 Configuration:
   Repository: https://github.com/lone-yu-cmd/AI-Coding-Paradigm.git
   Branch: master
   Remote Path: skills-master
   Local Target: /path/to/project/skills/skills-master
   Backup: Yes

📦 Backing up existing skills-master to: /path/to/project/skills/skills-master.backup
✅ Backup created successfully

🔄 Cloning skills-master from repository...
  1️⃣  Initializing Git repository...
  2️⃣  Adding remote repository...
  3️⃣  Enabling sparse checkout...
  4️⃣  Configured sparse checkout for: skills-master
  5️⃣  Pulling branch: master...
✅ Successfully cloned skills-master

🔄 Replacing local directory...
  ➖ Removing old directory...
  ➕ Copying new directory...
✅ Successfully replaced local directory

🧹 Cleaned up temporary directory

==============================================================
✅ Skills Master updated successfully!
==============================================================

💡 Backup location: /path/to/project/skills/skills-master.backup
   You can safely delete it after verifying the update.
```

### Example 2: Update from Different Repository

**User**: "Update skills-master from my company's fork at https://github.com/company/skills.git"

**Agent Action**:
```bash
python3 .codebuddy/skills/update-skills-master/scripts/update_skills_master.py \
  --repo https://github.com/company/skills.git \
  --branch main
```

### Example 3: Update to Custom Directory

**User**: "Pull the latest skills to a folder called 'shared-skills'"

**Agent Action**:
```bash
python3 .codebuddy/skills/update-skills-master/scripts/update_skills_master.py \
  --target ./shared-skills
```

## Summary

This skill provides a robust, safe, and efficient way to synchronize the local `skills-master` directory with a remote GitHub repository. Key features include:

- ✅ **Efficient**: Uses sparse checkout to fetch only needed files
- ✅ **Safe**: Creates automatic backups before replacing
- ✅ **Flexible**: Supports custom repositories, branches, and targets
- ✅ **Reliable**: Automatic rollback on failure
- ✅ **User-friendly**: Clear progress indicators and error messages

Use this skill whenever you need to get the latest skill templates from the central repository while preserving your local work through automatic backups.
