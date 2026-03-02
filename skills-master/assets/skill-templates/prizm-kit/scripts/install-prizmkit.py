#!/usr/bin/env python3
"""
PrizmKit Installer — Install PrizmKit skills to a project's skills directory.

Usage:
    # Install all PrizmKit skills
    python3 install-prizmkit.py --target /path/to/project/.codebuddy/skills

    # Install a specific skill
    python3 install-prizmkit.py --skill prizmkit-init --target /path/to/project/.codebuddy/skills

    # List available skills
    python3 install-prizmkit.py --list

    # Install with force (overwrite existing)
    python3 install-prizmkit.py --target /path/to/project/.codebuddy/skills --force
"""

import os
import sys
import shutil
import argparse
import json

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PRIZMKIT_DIR = os.path.dirname(CURRENT_DIR)  # PrizmKit/
SKILLS_SRC_DIR = os.path.join(PRIZMKIT_DIR, "skills")
ASSETS_DIR = os.path.join(PRIZMKIT_DIR, "assets")


def get_available_skills():
    """List all available PrizmKit skills."""
    if not os.path.exists(SKILLS_SRC_DIR):
        return []
    return sorted([
        d for d in os.listdir(SKILLS_SRC_DIR)
        if os.path.isdir(os.path.join(SKILLS_SRC_DIR, d))
        and os.path.exists(os.path.join(SKILLS_SRC_DIR, d, "SKILL.md"))
    ])


def get_skill_metadata(skill_name):
    """Extract description and tier from a skill's SKILL.md frontmatter."""
    skill_md = os.path.join(SKILLS_SRC_DIR, skill_name, "SKILL.md")
    metadata = {"description": "", "tier": None}
    if not os.path.exists(skill_md):
        return metadata
    try:
        with open(skill_md, "r", encoding="utf-8") as f:
            content = f.read()
        if content.startswith("---"):
            end = content.find("---", 3)
            if end != -1:
                frontmatter = content[3:end]
                for line in frontmatter.strip().split("\n"):
                    if line.strip().startswith("description:"):
                        metadata["description"] = line.split(":", 1)[1].strip().strip('"').strip("'")
                    elif line.strip().startswith("tier:"):
                        try:
                            metadata["tier"] = int(line.split(":", 1)[1].strip())
                        except ValueError:
                            pass
    except Exception:
        pass
    return metadata


def install_skill(skill_name, target_dir, force=False):
    """Install a single PrizmKit skill to the target directory."""
    src = os.path.join(SKILLS_SRC_DIR, skill_name)
    dst = os.path.join(target_dir, skill_name)

    if not os.path.exists(src):
        print(f"  ERROR: Skill '{skill_name}' not found in PrizmKit.")
        return False

    if not os.path.exists(os.path.join(src, "SKILL.md")):
        print(f"  ERROR: Skill '{skill_name}' has no SKILL.md.")
        return False

    if os.path.exists(dst):
        if force:
            shutil.rmtree(dst)
            print(f"  Removed existing: {skill_name}")
        else:
            print(f"  SKIP: '{skill_name}' already exists. Use --force to overwrite.")
            return False

    shutil.copytree(src, dst)
    print(f"  OK: {skill_name}")
    return True


def install_meta_skill(target_dir, force=False):
    """Install the PrizmKit meta SKILL.md (the top-level skill)."""
    src = os.path.join(PRIZMKIT_DIR, "SKILL.md")
    dst_dir = os.path.join(target_dir, "prizm-kit")
    dst = os.path.join(dst_dir, "SKILL.md")

    if not os.path.exists(src):
        print("  WARNING: PrizmKit/SKILL.md not found, skipping meta-skill.")
        return False

    os.makedirs(dst_dir, exist_ok=True)

    if os.path.exists(dst) and not force:
        print("  SKIP: PrizmKit meta-skill already exists.")
        return False

    shutil.copy2(src, dst)

    # Also copy assets
    assets_src = ASSETS_DIR
    assets_dst = os.path.join(dst_dir, "assets")
    if os.path.exists(assets_src):
        if os.path.exists(assets_dst):
            if force:
                shutil.rmtree(assets_dst)
            else:
                return True
        shutil.copytree(assets_src, assets_dst)

    print("  OK: PrizmKit (meta-skill + assets)")
    return True


def configure_hooks(project_root):
    """Add PrizmKit hooks to .codebuddy/settings.json.

    Loads all *.json hook templates from assets/hooks/ and merges them
    into the project's settings.json without duplicating existing hooks.
    """
    settings_dir = os.path.join(project_root, ".codebuddy")
    settings_path = os.path.join(settings_dir, "settings.json")
    hooks_dir = os.path.join(ASSETS_DIR, "hooks")

    if not os.path.exists(hooks_dir):
        print("  WARNING: Hooks directory not found, skipping hook configuration.")
        return False

    # Collect all hook template files
    hook_files = sorted([
        f for f in os.listdir(hooks_dir)
        if f.endswith(".json") and os.path.isfile(os.path.join(hooks_dir, f))
    ])

    if not hook_files:
        print("  WARNING: No hook templates found, skipping hook configuration.")
        return False

    os.makedirs(settings_dir, exist_ok=True)

    existing = {}
    if os.path.exists(settings_path):
        try:
            with open(settings_path, "r", encoding="utf-8") as f:
                existing = json.load(f)
        except (json.JSONDecodeError, Exception):
            existing = {}

    if "hooks" not in existing:
        existing["hooks"] = {}

    loaded = 0
    for hook_file in hook_files:
        hook_path = os.path.join(hooks_dir, hook_file)
        try:
            with open(hook_path, "r", encoding="utf-8") as f:
                hook_config = json.load(f)
        except (json.JSONDecodeError, Exception) as e:
            print(f"  WARNING: Failed to parse {hook_file}: {e}")
            continue

        # Merge hooks without overwriting existing ones
        for event, handlers in hook_config.get("hooks", {}).items():
            if event not in existing["hooks"]:
                existing["hooks"][event] = handlers
                loaded += 1
            else:
                # Collect existing prompts to deduplicate
                existing_prompts = []
                for handler_group in existing["hooks"][event]:
                    for hook in handler_group.get("hooks", []):
                        if hook.get("type") == "prompt":
                            existing_prompts.append(hook.get("prompt", ""))

                for handler_group in handlers:
                    for hook in handler_group.get("hooks", []):
                        if hook.get("prompt", "") not in existing_prompts:
                            existing["hooks"][event].append(handler_group)
                            loaded += 1

    with open(settings_path, "w", encoding="utf-8") as f:
        json.dump(existing, f, indent=2, ensure_ascii=False)

    print(f"  OK: Hooks configured in .codebuddy/settings.json ({loaded} hook(s) from {len(hook_files)} template(s))")
    return True


def main():
    parser = argparse.ArgumentParser(
        description="PrizmKit Installer — Install PrizmKit skills to your project.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  Install all skills:
    python3 install-prizmkit.py --target .codebuddy/skills

  Install specific skill:
    python3 install-prizmkit.py --skill prizmkit-init --target .codebuddy/skills

  List available skills:
    python3 install-prizmkit.py --list
        """
    )
    parser.add_argument("--target", help="Target skills directory (e.g., .codebuddy/skills)")
    parser.add_argument("--skill", help="Install a specific skill by name")
    parser.add_argument("--list", action="store_true", help="List available PrizmKit skills")
    parser.add_argument("--force", action="store_true", help="Overwrite existing skills")
    parser.add_argument("--hooks", action="store_true", help="Also configure hooks (requires --project-root)")
    parser.add_argument("--project-root", help="Project root for hook configuration")

    args = parser.parse_args()

    if args.list:
        skills = get_available_skills()
        core_skills = []
        aux_skills = []
        for s in skills:
            meta = get_skill_metadata(s)
            if meta["tier"] is not None:
                aux_skills.append((s, meta))
            else:
                core_skills.append((s, meta))

        print(f"PrizmKit Skills ({len(skills)} available):\n")

        if core_skills:
            print(f"Core Skills ({len(core_skills)}):")
            for s, meta in core_skills:
                desc = meta["description"]
                desc_short = desc[:80] + "..." if len(desc) > 80 else desc
                print(f"  {s}")
                if desc_short:
                    print(f"    {desc_short}")
            print()

        if aux_skills:
            print(f"Auxiliary Skills ({len(aux_skills)}):")
            for s, meta in aux_skills:
                desc = meta["description"]
                desc_short = desc[:80] + "..." if len(desc) > 80 else desc
                tier_label = f"[Tier {meta['tier']}] " if meta["tier"] else ""
                print(f"  {tier_label}{s}")
                if desc_short:
                    # Strip [Tier N] prefix from description to avoid duplication
                    display_desc = desc_short
                    if display_desc.startswith("[Tier"):
                        bracket_end = display_desc.find("] ")
                        if bracket_end != -1:
                            display_desc = display_desc[bracket_end + 2:]
                    print(f"    {display_desc}")

        sys.exit(0)

    if not args.target:
        parser.print_help()
        print("\nError: --target is required for installation.")
        sys.exit(1)

    target = os.path.abspath(args.target)
    os.makedirs(target, exist_ok=True)

    print(f"PrizmKit Installer")
    print(f"Target: {target}\n")

    installed = 0
    skipped = 0

    if args.skill:
        # Install specific skill
        if install_skill(args.skill, target, args.force):
            installed += 1
        else:
            skipped += 1
    else:
        # Install all skills + meta-skill
        print("Installing PrizmKit meta-skill...")
        if install_meta_skill(target, args.force):
            installed += 1
        else:
            skipped += 1

        print("\nInstalling PrizmKit skills...")
        for skill in get_available_skills():
            if install_skill(skill, target, args.force):
                installed += 1
            else:
                skipped += 1

    # Configure hooks if requested
    if args.hooks and args.project_root:
        print("\nConfiguring hooks...")
        configure_hooks(os.path.abspath(args.project_root))

    print(f"\nDone: {installed} installed, {skipped} skipped.")


if __name__ == "__main__":
    main()
