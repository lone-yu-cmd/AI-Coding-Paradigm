import os
import json

def analyze_project(root_dir):
    """Simple heuristic analysis of the project structure."""
    tech_stack = []
    architecture = "Unknown"
    
    # Check for languages/frameworks
    if os.path.exists(os.path.join(root_dir, 'package.json')):
        tech_stack.append("Node.js")
    if os.path.exists(os.path.join(root_dir, 'requirements.txt')) or os.path.exists(os.path.join(root_dir, 'pyproject.toml')):
        tech_stack.append("Python")
    if os.path.exists(os.path.join(root_dir, 'go.mod')):
        tech_stack.append("Go")
    
    # Check for Monorepo
    if os.path.exists(os.path.join(root_dir, 'packages')) or os.path.exists(os.path.join(root_dir, 'apps')):
        architecture = "Monorepo"
    elif "Python" in tech_stack and "Node.js" in tech_stack:
        architecture = "Polyglot"
    else:
        architecture = "Single Service"
        
    return {
        "tech_stack": tech_stack,
        "architecture": architecture
    }

def generate_docs(root_dir):
    context_dir = os.path.join(root_dir, 'docs', 'AI_CONTEXT')
    os.makedirs(context_dir, exist_ok=True)
    
    analysis = analyze_project(root_dir)
    
    # 1. Generate ARCHITECTURE.md
    arch_content = f"""# Project Architecture

## System Context
This project uses the following technology stack: {', '.join(analysis['tech_stack'])}.
The overall architectural pattern appears to be: **{analysis['architecture']}**.

## Core Components
(Auto-generated placeholder. Please refine based on actual code.)

## Data Flow
(Auto-generated placeholder.)
"""
    with open(os.path.join(context_dir, 'ARCHITECTURE.md'), 'w') as f:
        f.write(arch_content)
        
    # 2. Generate CONSTITUTION.md
    const_content = """# Project Constitution

## 1. Core Principles
*   **Documentation First**: All architectural decisions must be documented in `docs/AI_CONTEXT/`.
*   **Context Aware**: AI agents must read context files before modifying code.

## 2. Coding Standards
(Auto-generated based on detected languages)
"""
    with open(os.path.join(context_dir, 'CONSTITUTION.md'), 'w') as f:
        f.write(const_content)
        
    print(f"Successfully generated Context Docs in {context_dir}")

if __name__ == "__main__":
    root = os.getcwd()
    generate_docs(root)
