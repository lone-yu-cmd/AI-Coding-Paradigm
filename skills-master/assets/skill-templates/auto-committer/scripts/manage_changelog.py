import argparse
import datetime
import os
import re

CHANGELOG_FILE = 'CHANGELOG.md'

TEMPLATE = """# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
"""

def ensure_changelog_exists():
    if not os.path.exists(CHANGELOG_FILE):
        with open(CHANGELOG_FILE, 'w', encoding='utf-8') as f:
            f.write(TEMPLATE)
        print(f"Created {CHANGELOG_FILE}")

def read_changelog():
    with open(CHANGELOG_FILE, 'r', encoding='utf-8') as f:
        return f.read()

def write_changelog(content):
    with open(CHANGELOG_FILE, 'w', encoding='utf-8') as f:
        f.write(content)

def add_entry(entry_type, message):
    ensure_changelog_exists()
    content = read_changelog()
    
    # Standard Keep a Changelog types mapping
    type_map = {
        'feat': '### Added',
        'fix': '### Fixed',
        'change': '### Changed',
        'refactor': '### Changed',
        'perf': '### Changed',
        'docs': '### Documentation',
        'chore': '### Miscellaneous'
    }
    
    header = type_map.get(entry_type, '### Changed')
    
    # Find [Unreleased] section
    unreleased_pattern = r"(## \[Unreleased\].*?)(?=\n## \[|\Z)"
    match = re.search(unreleased_pattern, content, re.DOTALL)
    
    if not match:
        # If no Unreleased section, add it
        content = content.replace("## [Unreleased]", "## [Unreleased]\n") # simplistic fix
        # Retry with simpler approach if regex fails due to file structure
        if "## [Unreleased]" not in content:
             # Prepend after header
             lines = content.splitlines()
             insert_idx = 0
             for i, line in enumerate(lines):
                 if line.startswith('# Changelog'):
                     insert_idx = i + 1
                     break
             # skip some lines
             while insert_idx < len(lines) and not lines[insert_idx].startswith('## '):
                 insert_idx += 1
             
             lines.insert(insert_idx, "\n## [Unreleased]")
             content = "\n".join(lines)
    
    # Now insert the entry
    # We need to find the specific subsection (e.g. ### Added) under [Unreleased]
    # This is getting complex with regex. Let's use a line-based parser for reliability.
    
    lines = content.splitlines()
    output_lines = []
    in_unreleased = False
    inserted = False
    
    i = 0
    while i < len(lines):
        line = lines[i]
        output_lines.append(line)
        
        if line.strip().startswith("## [Unreleased]"):
            in_unreleased = True
            # Look ahead for the correct subsection or the next section
            # If we hit next version (## [x.x.x]) or end of file, we need to insert our section
            
            # Check if subsection exists
            has_subsection = False
            j = i + 1
            insertion_point = -1
            
            while j < len(lines):
                subline = lines[j]
                if subline.strip().startswith("## ["): # Next version
                    break
                if subline.strip().startswith(header):
                    has_subsection = True
                    insertion_point = j
                    break
                j += 1
            
            if has_subsection and not inserted:
                # Insert after the header
                output_lines.extend(lines[i+1:insertion_point+1])
                output_lines.append(f"- {message}")
                i = insertion_point
                inserted = True
            elif not inserted:
                # No subsection found, insert it right after [Unreleased] (or after blank line)
                output_lines.append("")
                output_lines.append(header)
                output_lines.append(f"- {message}")
                inserted = True
                
        i += 1
        
    write_changelog("\n".join(output_lines))
    print(f"Added '{message}' to {header} in [Unreleased]")

def main():
    parser = argparse.ArgumentParser(description='Manage CHANGELOG.md')
    subparsers = parser.add_subparsers(dest='command')
    
    add_parser = subparsers.add_parser('add', help='Add a new entry')
    add_parser.add_argument('--type', required=True, choices=['feat', 'fix', 'change', 'refactor', 'perf', 'docs', 'chore'], help='Type of change')
    add_parser.add_argument('--message', required=True, help='Description of the change')
    
    args = parser.parse_args()
    
    if args.command == 'add':
        add_entry(args.type, args.message)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
