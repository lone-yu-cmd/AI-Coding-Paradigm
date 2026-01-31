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
    tech_list = ', '.join(analysis['tech_stack']) if analysis['tech_stack'] else '(placeholder: add detected technologies)'
    
    # 1. Generate ARCHITECTURE.md (AI-optimized format)
    arch_content = f"""# Project Architecture

## METADATA
- version: 1.0
- updated: (placeholder: add date)
- scope: Full project architecture overview

---

## TECH_STACK
- runtime: {tech_list}
- architecture_pattern: {analysis['architecture']}
- styling: (placeholder: e.g., Tailwind CSS, CSS Modules)
- state: (placeholder: e.g., Zustand, Redux)
- build: (placeholder: e.g., Vite, Webpack)

---

## DIRECTORY_MAP

PATH_MAP:
- /src → (placeholder: main source code purpose)
- /docs → Documentation and AI context files
- /tests → (placeholder: test files location)

---

## CORE_COMPONENTS

[ComponentA]
- role: (placeholder: describe component responsibility)
- location: (placeholder: file path)
- dependencies: (placeholder: list dependencies)

[ComponentB]
- role: (placeholder: describe component responsibility)
- location: (placeholder: file path)
- dependencies: (placeholder: list dependencies)

---

## DATA_FLOW

FLOW: (placeholder: describe main data flow)

Example format:
1. User triggers action in [ComponentA]
2. ComponentA calls [ServiceB.method()]
3. ServiceB processes and returns result
4. ComponentA updates state and re-renders

---

## ENTRY_POINTS
- main: (placeholder: e.g., /src/index.ts)
- config: (placeholder: e.g., /config/settings.ts)
"""
    with open(os.path.join(context_dir, 'ARCHITECTURE.md'), 'w') as f:
        f.write(arch_content)
        
    # 2. Generate CONSTITUTION.md (AI-optimized format)
    const_content = """# Project Constitution

## METADATA
- version: 1.0
- updated: (placeholder: add date)
- scope: Mandatory rules for all code modifications

---

## HARD_RULES

MUST:
- Read `docs/AI_CONTEXT/ARCHITECTURE.md` before modifying code
- Document all architectural decisions in `docs/AI_CONTEXT/`
- (placeholder: add project-specific mandatory rules)

NEVER:
- Modify core architecture without updating documentation
- (placeholder: add project-specific prohibitions)

---

## SOFT_RULES

PREFER:
- (placeholder: e.g., Functional components over class components)
- (placeholder: add recommended patterns)

AVOID:
- (placeholder: e.g., Direct DOM manipulation)
- (placeholder: add discouraged patterns)

---

## CODING_STANDARDS

[Naming]
- files: (placeholder: e.g., kebab-case for files)
- components: (placeholder: e.g., PascalCase for React components)
- functions: (placeholder: e.g., camelCase for functions)

[Structure]
- IF: Logic reused in 2+ places → THEN: Extract to shared module
- IF: Component exceeds 200 lines → THEN: Consider splitting

---

## PATTERNS

### Pattern: (placeholder: pattern name)
USE_WHEN: (placeholder: describe scenario)

✅ CORRECT:
```
(placeholder: correct code example)
```

❌ WRONG:
```
(placeholder: incorrect code example)
```

---

## FAQ

Q: Where should new features be added?
A:
- IF shared utility → (placeholder: path)
- IF UI component → (placeholder: path)
- IF business logic → (placeholder: path)

Q: (placeholder: add common question)
A: (placeholder: add answer with IF-THEN format if applicable)

---

## TRAPS

[Trap: (placeholder: trap name)]
- symptom: (placeholder: describe the issue)
- cause: (placeholder: root cause)
- fix: (placeholder: solution)
"""
    with open(os.path.join(context_dir, 'CONSTITUTION.md'), 'w') as f:
        f.write(const_content)
        
    print(f"Successfully generated AI-optimized Context Docs in {context_dir}")

if __name__ == "__main__":
    root = os.getcwd()
    generate_docs(root)
