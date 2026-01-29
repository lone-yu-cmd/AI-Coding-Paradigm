import os
import argparse
import sys
from update_readme import update_readme

# Constants
SKILLS_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def create_skill(name, description):
    skill_path = os.path.join(SKILLS_DIR, name)
    
    if os.path.exists(skill_path):
        print(f"Error: Skill '{name}' already exists at {skill_path}")
        return False
        
    print(f"Creating skill '{name}' at {skill_path}...")
    
    # Create directory structure
    os.makedirs(os.path.join(skill_path, "scripts"), exist_ok=True)
    
    # Create SKILL.md
    skill_md_content = f"""---
name: "{name}"
description: "{description}"
---

# {name.replace('-', ' ').title()}

{description}

## Usage

<!-- Add usage instructions here -->

## Implementation

Scripts are located in the `scripts/` directory.
"""
    
    with open(os.path.join(skill_path, "SKILL.md"), "w") as f:
        f.write(skill_md_content)
        
    print(f"Successfully created skill skeleton for '{name}'")
    
    # Update index
    print("Updating skills index...")
    update_readme()
    
    return True

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create a new skill in the skills directory.")
    parser.add_argument("--name", required=True, help="Name of the skill (kebab-case recommended)")
    parser.add_argument("--description", required=True, help="Short description of the skill")
    
    args = parser.parse_args()
    
    if create_skill(args.name, args.description):
        print("\nNext steps:")
        print(f"1. Edit skills/{args.name}/SKILL.md to add detailed instructions")
        print(f"2. Add your scripts to skills/{args.name}/scripts/")
    else:
        sys.exit(1)
