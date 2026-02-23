#!/usr/bin/env python3
"""
Update Skills Master Script

This script pulls the latest skills-master directory from a remote GitHub repository
and replaces the local skills-master directory using Git sparse checkout.
"""

import os
import sys
import shutil
import subprocess
import argparse
from pathlib import Path


# Default GitHub repository URL
DEFAULT_REPO_URL = "https://github.com/lone-yu-cmd/AI-Coding-Paradigm.git"
DEFAULT_BRANCH = "master"
DEFAULT_SPARSE_PATH = "skills-master"


def run_command(cmd, cwd=None, check=True):
    """
    Execute a shell command and return the result.
    
    Args:
        cmd: Command to execute (list or string)
        cwd: Working directory for the command
        check: Whether to raise exception on non-zero exit code
    
    Returns:
        subprocess.CompletedProcess object
    """
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            check=check,
            capture_output=True,
            text=True,
            shell=isinstance(cmd, str)
        )
        return result
    except subprocess.CalledProcessError as e:
        print(f"❌ Command failed: {' '.join(cmd) if isinstance(cmd, list) else cmd}")
        print(f"   Error: {e.stderr}")
        raise


def validate_git_installed():
    """Check if Git is installed on the system."""
    try:
        result = subprocess.run(
            ["git", "--version"],
            capture_output=True,
            text=True,
            check=True
        )
        print(f"✅ Git is installed: {result.stdout.strip()}")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Git is not installed. Please install Git first.")
        print("   Download from: https://git-scm.com/downloads")
        return False


def backup_local_skills_master(target_dir):
    """
    Create a backup of the local skills-master directory.
    
    Args:
        target_dir: Path to the skills-master directory
    
    Returns:
        Path to the backup directory or None if no backup needed
    """
    if not os.path.exists(target_dir):
        print(f"ℹ️  No existing skills-master found at {target_dir}")
        return None
    
    backup_dir = f"{target_dir}.backup"
    counter = 1
    while os.path.exists(backup_dir):
        backup_dir = f"{target_dir}.backup.{counter}"
        counter += 1
    
    print(f"📦 Backing up existing skills-master to: {backup_dir}")
    shutil.copytree(target_dir, backup_dir)
    print(f"✅ Backup created successfully")
    return backup_dir


def clone_sparse_checkout(repo_url, branch, sparse_path, temp_dir):
    """
    Clone a specific directory from a Git repository using sparse checkout.
    
    Args:
        repo_url: GitHub repository URL
        branch: Branch to clone from
        sparse_path: Path within the repository to checkout
        temp_dir: Temporary directory for cloning
    
    Returns:
        Path to the cloned sparse directory
    """
    print(f"\n🔄 Cloning {sparse_path} from {repo_url} (branch: {branch})...")
    
    # Initialize git repository
    print("  1️⃣  Initializing Git repository...")
    run_command(["git", "init"], cwd=temp_dir)
    
    # Add remote
    print("  2️⃣  Adding remote repository...")
    run_command(["git", "remote", "add", "origin", repo_url], cwd=temp_dir)
    
    # Enable sparse checkout
    print("  3️⃣  Enabling sparse checkout...")
    run_command(["git", "config", "core.sparseCheckout", "true"], cwd=temp_dir)
    
    # Specify which directory to checkout
    sparse_checkout_file = os.path.join(temp_dir, ".git", "info", "sparse-checkout")
    os.makedirs(os.path.dirname(sparse_checkout_file), exist_ok=True)
    with open(sparse_checkout_file, "w") as f:
        f.write(f"{sparse_path}\n")
    print(f"  4️⃣  Configured sparse checkout for: {sparse_path}")
    
    # Pull the specified branch
    print(f"  5️⃣  Pulling branch: {branch}...")
    run_command(["git", "pull", "origin", branch], cwd=temp_dir)
    
    cloned_path = os.path.join(temp_dir, sparse_path)
    if not os.path.exists(cloned_path):
        raise Exception(f"Failed to clone {sparse_path} from repository")
    
    print(f"✅ Successfully cloned {sparse_path}")
    return cloned_path


def replace_local_directory(source_dir, target_dir):
    """
    Replace the local directory with the cloned directory.
    
    Args:
        source_dir: Source directory (cloned)
        target_dir: Target directory (local)
    """
    print(f"\n🔄 Replacing local directory...")
    print(f"   Source: {source_dir}")
    print(f"   Target: {target_dir}")
    
    # Remove old directory if exists
    if os.path.exists(target_dir):
        print(f"  ➖ Removing old directory...")
        shutil.rmtree(target_dir)
    
    # Copy new directory
    print(f"  ➕ Copying new directory...")
    shutil.copytree(source_dir, target_dir)
    
    print(f"✅ Successfully replaced local directory")


def find_skills_directory():
    """
    Find the skills directory by looking for the parent of this script.
    
    This script is located in: skills/update-skills-master/scripts/update_skills_master.py
    So the skills directory is 2 levels up from this script.
    
    Returns:
        Path to the skills directory
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    # Go up: scripts -> update-skills-master -> skills
    skills_dir = os.path.dirname(os.path.dirname(script_dir))
    return skills_dir


def update_skills_master(
    repo_url=DEFAULT_REPO_URL,
    branch=DEFAULT_BRANCH,
    sparse_path=DEFAULT_SPARSE_PATH,
    target_dir=None,
    no_backup=False
):
    """
    Main function to update skills-master from remote repository.
    
    Args:
        repo_url: GitHub repository URL
        branch: Branch to clone from
        sparse_path: Path within the repository to checkout
        target_dir: Local target directory (default: auto-detect skills-master in same parent as this skill)
        no_backup: Skip backup if True
    """
    print("=" * 60)
    print("🚀 Skills Master Update Script")
    print("=" * 60)
    
    # Validate Git installation
    if not validate_git_installed():
        sys.exit(1)
    
    # Determine target directory
    if target_dir is None:
        # Auto-detect: find skills directory, then skills-master sibling
        skills_dir = find_skills_directory()
        target_dir = os.path.join(skills_dir, sparse_path)
        print(f"ℹ️  Auto-detected skills directory: {skills_dir}")
    target_dir = os.path.abspath(target_dir)
    
    print(f"\n📋 Configuration:")
    print(f"   Repository: {repo_url}")
    print(f"   Branch: {branch}")
    print(f"   Remote Path: {sparse_path}")
    print(f"   Local Target: {target_dir}")
    print(f"   Backup: {'No' if no_backup else 'Yes'}")
    
    # Create backup if needed
    backup_dir = None
    if not no_backup:
        backup_dir = backup_local_skills_master(target_dir)
    
    # Create temporary directory for cloning (in the same parent directory as skills-master)
    parent_dir = os.path.dirname(target_dir)
    temp_dir = os.path.join(parent_dir, ".temp_skills_master_clone")
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
    os.makedirs(temp_dir)
    
    try:
        # Clone with sparse checkout
        cloned_path = clone_sparse_checkout(repo_url, branch, sparse_path, temp_dir)
        
        # Replace local directory
        replace_local_directory(cloned_path, target_dir)
        
        print("\n" + "=" * 60)
        print("✅ Skills Master updated successfully!")
        print("=" * 60)
        
        if backup_dir:
            print(f"\n💡 Backup location: {backup_dir}")
            print("   You can safely delete it after verifying the update.")
        
    except Exception as e:
        print("\n" + "=" * 60)
        print(f"❌ Update failed: {e}")
        print("=" * 60)
        
        if backup_dir:
            print(f"\n💡 Restoring from backup: {backup_dir}")
            if os.path.exists(target_dir):
                shutil.rmtree(target_dir)
            shutil.move(backup_dir, target_dir)
            print("✅ Restored from backup")
        
        sys.exit(1)
    
    finally:
        # Cleanup temporary directory
        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir)
            print(f"🧹 Cleaned up temporary directory")


def main():
    parser = argparse.ArgumentParser(
        description="Update skills-master from remote GitHub repository using sparse checkout.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Update with default settings (from lone-yu-cmd/AI-Coding-Paradigm)
  python3 update_skills_master.py
  
  # Update from a different repository
  python3 update_skills_master.py --repo https://github.com/username/repo.git
  
  # Update from a different branch
  python3 update_skills_master.py --branch main
  
  # Update to a custom local directory
  python3 update_skills_master.py --target /path/to/my-skills-master
  
  # Update without creating backup
  python3 update_skills_master.py --no-backup
  
  # Full custom update
  python3 update_skills_master.py \\
    --repo https://github.com/username/repo.git \\
    --branch main \\
    --sparse-path skills-master \\
    --target /path/to/skills-master
        """
    )
    
    parser.add_argument(
        "--repo",
        default=DEFAULT_REPO_URL,
        help=f"GitHub repository URL (default: {DEFAULT_REPO_URL})"
    )
    
    parser.add_argument(
        "--branch",
        default=DEFAULT_BRANCH,
        help=f"Branch to clone from (default: {DEFAULT_BRANCH})"
    )
    
    parser.add_argument(
        "--sparse-path",
        default=DEFAULT_SPARSE_PATH,
        help=f"Path within repository to checkout (default: {DEFAULT_SPARSE_PATH})"
    )
    
    parser.add_argument(
        "--target",
        help="Local target directory (default: auto-detect skills-master in skills parent directory)"
    )
    
    parser.add_argument(
        "--no-backup",
        action="store_true",
        help="Skip creating backup of existing skills-master"
    )
    
    args = parser.parse_args()
    
    update_skills_master(
        repo_url=args.repo,
        branch=args.branch,
        sparse_path=args.sparse_path,
        target_dir=args.target,
        no_backup=args.no_backup
    )


if __name__ == "__main__":
    main()
