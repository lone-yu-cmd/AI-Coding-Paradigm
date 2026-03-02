---
name: "prizmkit-init"
description: "Project takeover and bootstrap. Scans any project, generates Prizm docs, configures hooks. Use 'prizmkit.init' to start. (project)"
---

# PrizmKit Init

Project takeover and bootstrap skill. Scans any project (brownfield or greenfield), generates Prizm documentation, and configures hooks for documentation sync.

### When to Use
- Taking over a new project (brownfield or greenfield)
- User says "initialize PrizmKit", "set up PrizmKit", "take over this project"
- First time using PrizmKit on a project

### Commands

#### prizmkit.init
Full project initialization.

MODE DETECTION:
- If `.prizm-docs/` exists: Ask user if they want to reinitialize or update
- If project has source code: brownfield mode
- If project is nearly empty: greenfield mode

BROWNFIELD WORKFLOW (existing project):

**Step 1: Project Scanning**
1. Detect tech stack from build files (`package.json`, `requirements.txt`, `go.mod`, `pom.xml`, `Cargo.toml`, etc.)
2. Map directory structure — identify source directories, test directories, config files
3. Identify entry points by language convention
4. Catalog dependencies (external packages)
5. Count source files per directory

**Step 2: State Assessment**
2a. Run dependency analysis:
  - Count outdated dependencies (if lockfile exists)
  - Note any known vulnerability patterns

2b. Scan for technical debt indicators:
  - Count TODO/FIXME/HACK/XXX comments
  - Identify large files (>500 lines)
  - Check for test directories and coverage config

2c. Generate `ASSESSMENT.md` in project root with findings

**Step 3: Prizm Documentation Generation**
3a. Invoke prizmkit-prizm-docs `prizmkit.doc.init` algorithm:
  - Create `.prizm-docs/` directory structure
  - Generate `root.prizm` (L0) with project meta and module index
  - Generate L1 docs for all discovered modules
  - Create `changelog.prizm`
  - Skip L2 (lazy generation)

3b. If project has existing `docs/AI_CONTEXT/`: suggest running `prizmkit.doc.migrate`

**Step 4: PrizmKit Workspace Initialization**
4a. Create `.prizmkit/` directory:
  - `.prizmkit/config.json` (adoption_mode, speckit_hooks_enabled)
  - `.prizmkit/specs/` (empty)

**Step 5: Hook Configuration**
5a. Read or create `.codebuddy/settings.json`
5b. Add UserPromptSubmit hook from `${SKILL_DIR}/../../../assets/hooks/prizm-commit-hook.json`
5c. Preserve any existing hooks

**Step 6: CODEBUDDY.md Update**
6a. Read existing `CODEBUDDY.md` (or create if missing)
6b. Append PrizmKit section from `${SKILL_DIR}/../../../assets/codebuddy-md-template.md`
6c. Do not duplicate if already present

**Step 7: Report**
Output summary: tech stack detected, modules discovered, L1 docs generated, assessment highlights, next recommended steps.

GREENFIELD WORKFLOW (new project):
- Skip Steps 1-2 (no code to scan)
- Step 3: Create minimal `.prizm-docs/` with just `root.prizm` skeleton
- Steps 4-6: Same as brownfield
- Step 7: Recommend starting with `prizmkit.specify` for first feature

### Gradual Adoption Path
After init, PrizmKit operates in phases:
- **Passive** (default): Generates docs, doesn't enforce workflow
- **Advisory**: Suggests improvements, flags issues (enable in config)
- **Active**: Enforces spec-driven workflow for new features (enable in config)

User can change mode in `.prizmkit/config.json`: `"adoption_mode": "passive" | "advisory" | "active"`

IMPORTANT: Use `${SKILL_DIR}` placeholder for all path references. Never hardcode absolute paths.
