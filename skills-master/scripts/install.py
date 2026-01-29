import os
import shutil
import argparse
import sys

# Constants
# Assuming structure:
# .../skills/skills-master/scripts/install.py  (when installed in user's project)
# OR
# .../SkillsMaster/skills-master/scripts/install.py (in repo dev)

# We need to find the "skills" directory where other skills should be installed.
# If this script is in .../skills/skills-master/scripts/install.py, 
# then os.path.dirname(os.path.abspath(__file__)) is .../skills/skills-master/scripts
# ... up one level is .../skills/skills-master
# ... up two levels is .../skills  <-- This is the target SKILLS_DIR

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
SKILLS_MASTER_DIR = os.path.dirname(CURRENT_DIR) # .../skills-master
SKILLS_DIR = os.path.dirname(SKILLS_MASTER_DIR) # .../skills (target directory)

TEMPLATES_DIR = os.path.join(SKILLS_MASTER_DIR, "assets", "skill-templates")

def install_skill(skill_name):
    src = os.path.join(TEMPLATES_DIR, skill_name)
    dst = os.path.join(SKILLS_DIR, skill_name)
    
    if not os.path.exists(src):
        print(f"Error: Skill template '{skill_name}' not found.")
        return False
        
    if os.path.exists(dst):
        print(f"Warning: Skill '{skill_name}' already exists. Skipping.")
        return False
        
    shutil.copytree(src, dst)
    print(f"Successfully installed skill: {skill_name}")
    return True

def list_templates():
    if not os.path.exists(TEMPLATES_DIR):
        print("No templates found.")
        return []
    return [d for d in os.listdir(TEMPLATES_DIR) if os.path.isdir(os.path.join(TEMPLATES_DIR, d))]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Install standard skills from templates.")
    parser.add_argument("--name", help="Name of the skill to install")
    parser.add_argument("--all", action="store_true", help="Install all available skills")
    parser.add_argument("--list", action="store_true", help="List available templates")
    
    args = parser.parse_args()
    
    if args.list:
        print("Available Skill Templates:")
        for t in list_templates():
            print(f"- {t}")
        sys.exit(0)
        
    if args.all:
        for t in list_templates():
            install_skill(t)
    elif args.name:
        install_skill(args.name)
    else:
        parser.print_help()
