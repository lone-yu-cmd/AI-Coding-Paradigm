import os
import shutil
import argparse
import sys
import re

# Define paths relative to this script
# Script is in .../scripts/add_skill.py
# If run from installed location: skills/add-in-skills-master/scripts/add_skill.py
# If run from templates location: skills/skills-master/assets/skill-templates/add-in-skills-master/scripts/add_skill.py

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))

# Path Resolution Logic
# 1. Check if we are in the root 'skills-master' repository (development mode)
#    Structure: root/skills-master/assets/skill-templates/add-in-skills-master/scripts/add_skill.py
#    Target: root/skills-master

# 2. Check if we are installed in a user's project
#    Structure: root/skills/add-in-skills-master/scripts/add_skill.py
#    Target: root/skills/skills-master (sibling directory)

def find_skills_master_dirs(current_dir):
    """
    Find all relevant skills-master directories to update.
    Returns a list of valid skills-master root directories.
    """
    targets = []
    
    # Path 1: Dev mode (nested in assets/skill-templates)
    # Structure: root/skills-master/assets/skill-templates/add-in-skills-master/scripts/add_skill.py
    if "assets/skill-templates" in current_dir:
        dev_master = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(current_dir))))
        if os.path.exists(dev_master):
            targets.append(dev_master)

    # Path 2: Installed mode (nested in skills/)
    # Structure: root/skills/add-in-skills-master/scripts/add_skill.py
    skills_root = os.path.dirname(os.path.dirname(current_dir))
    sibling_master = os.path.join(skills_root, "skills-master")
    if os.path.exists(sibling_master):
        if sibling_master not in targets:
             targets.append(sibling_master)
    
    # Path 3: Root level check (Open Source Repo Structure)
    # Structure: root/skills-master (where root contains skills/add-in-skills-master)
    # Strategy: Go up from skills_root until we find 'skills-master' or hit root
    
    current_search_dir = os.path.dirname(skills_root)
    # Limit search depth to avoid infinite loops, e.g., 3 levels up
    for _ in range(3):
        possible_master = os.path.join(current_search_dir, "skills-master")
        if os.path.exists(possible_master):
            if possible_master not in targets:
                targets.append(possible_master)
            break # Stop after finding the first one to avoid duplicates if nested weirdly
        
        parent = os.path.dirname(current_search_dir)
        if parent == current_search_dir: # Reached filesystem root
            break
        current_search_dir = parent

    return targets

TARGET_MASTERS = find_skills_master_dirs(CURRENT_DIR)

if not TARGET_MASTERS:
    print("Error: Could not find any 'skills-master' directory.")
    sys.exit(1)

print(f"DEBUG: Found targets: {TARGET_MASTERS}")

def update_single_master(master_dir, skill_name, description, source_path):
    print(f"\n--- Updating skills-master at {master_dir} ---")
    templates_dir = os.path.join(master_dir, "assets", "skill-templates")
    doc_path = os.path.join(master_dir, "SKILL.md")
    
    # 1. Copy Template
    dest_path = os.path.join(templates_dir, skill_name)
    if os.path.exists(dest_path):
        print(f"Removing existing template at {dest_path}")
        shutil.rmtree(dest_path)
    
    try:
        shutil.copytree(source_path, dest_path)
        print(f"Successfully copied template to {dest_path}")
    except Exception as e:
        print(f"Error copying template: {e}")
        return

    # 2. Update Documentation
    update_skills_master_doc(doc_path, skill_name, description)

def update_skills_master_doc(doc_path, skill_name, description):
    """Updates the Capabilities section in skills-master/SKILL.md"""
    if not os.path.exists(doc_path):
        print(f"Warning: Could not find {doc_path} to update.")
        return

    with open(doc_path, 'r') as f:
        content = f.read()

    # Look for the Capabilities list
    # It usually starts after "## Capabilities" and contains lines starting with "*   **"
    
    # We want to check if the skill is already listed
    pattern = re.compile(f"\\*\\s+\\*\\*{re.escape(skill_name)}\\*\\*:")
    
    new_entry = f"*   **{skill_name}**: {description}"
    
    if pattern.search(content):
        # Update existing entry
        print(f"Updating existing entry for {skill_name} in SKILL.md...")
        content = re.sub(f"\\*\\s+\\*\\*{re.escape(skill_name)}\\*\\*:.*", new_entry, content)
    else:
        # Add new entry
        print(f"Adding new entry for {skill_name} to SKILL.md...")
        
        capabilities_start = content.find("## Capabilities")
        if capabilities_start != -1:
             # Find the first list item after this section
             list_start_match = re.search(r"\n\*   \*\*", content[capabilities_start:])
             if list_start_match:
                 list_start_index = capabilities_start + list_start_match.start()
                 
                 # Now find the end of the list
                 # We assume the list ends when we hit a line that doesn't start with "*   " or empty line followed by new section
                 # But simplistic approach: just find the block of lines starting with "*   "
                 
                 # Let's grab the whole text after the first list item
                 rest_of_text = content[list_start_index:]
                 
                 # Split into lines
                 lines = rest_of_text.split('\n')
                 list_lines = []
                 in_list = True
                 
                 last_list_item_index = -1
                 
                 for i, line in enumerate(lines):
                     if in_list:
                         if line.strip() == "" or line.strip().startswith("*   "):
                             if line.strip().startswith("*   "):
                                 last_list_item_index = i
                         else:
                             in_list = False
                 
                 # Insert after the last list item
                 if last_list_item_index != -1:
                     lines.insert(last_list_item_index + 1, new_entry)
                     
                     # Reconstruct content
                     new_rest_of_text = "\n".join(lines)
                     content = content[:list_start_index] + new_rest_of_text
        else:
            print("Warning: Could not find '## Capabilities' section to append to.")

    with open(doc_path, 'w') as f:
        f.write(content)
    print("Updated SKILL.md")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Add a skill to the skills-master library.")
    parser.add_argument("--name", required=True, help="Name of the skill")
    parser.add_argument("--description", required=True, help="Description of the skill")
    parser.add_argument("--source", required=True, help="Path to the skill source directory")
    
    args = parser.parse_args()
    
    source_path = os.path.abspath(args.source)
    
    if not os.path.exists(source_path):
        print(f"Error: Source path '{source_path}' does not exist.")
        sys.exit(1)
        
    for master_dir in TARGET_MASTERS:
        update_single_master(master_dir, args.name, args.description, source_path)

