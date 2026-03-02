PRIZM_SPEC_VERSION: 1
PURPOSE: AI-only documentation framework for vibe coding projects
AUDIENCE: AI agents (not humans)
FORMAT: KEY: value pairs, ALL CAPS section headers, arrow pointers
FILE_EXT: .prizm
DOC_ROOT: .prizm-docs/
LICENSE: MIT

---

# SECTION 1: OVERVIEW

WHAT: Prizm is a self-maintaining documentation system where AI reads, generates, updates, and loads project context progressively.
WHY: Reduce AI hallucinations, minimize token waste, ensure AI has accurate project knowledge at all times.
HOW: Three-level progressive loading (L0 -> L1 -> L2) with auto-update before every commit.

CORE_PRINCIPLES:
- Token efficiency over human readability
- Progressive disclosure (load only what is needed)
- Self-updating (docs stay fresh via commit-time hooks)
- Universal (language and framework agnostic)
- Append-only history (decisions and changelog never lose information)
- Size-enforced (hard limits per level prevent bloat)
- Lazy L2 generation (detail docs created on first modification, not during init)

---

# SECTION 2: ARCHITECTURE

## 2.1 Progressive Loading Levels

LEVELS:
- L0: Root index. ALWAYS loaded at session start. Max 4KB.
  FILE: .prizm-docs/root.prizm
  CONTAINS: project meta, module index with pointers, build commands, tech stack, top rules

- L1: Module index. Loaded ON DEMAND when AI works in a module area. Max 3KB each.
  FILE: .prizm-docs/<mirrored-path>.prizm (mirrors source directory structure)
  CONTAINS: module responsibility, subdirs with pointers, key files, interfaces, dependencies, rules

- L2: Detail doc. Loaded ONLY when AI modifies files in that sub-module. Max 5KB each.
  FILE: .prizm-docs/<mirrored-path>/<submodule>.prizm
  CONTAINS: full file inventory, domain-specific sections, decisions log, traps, rejected approaches

- Changelog: Append-only change log. Loaded at L0. No size limit but keep last 50 entries.
  FILE: .prizm-docs/changelog.prizm

## 2.2 Directory Layout

STRUCTURE: Mirrors source tree under .prizm-docs/

EXAMPLE (Go project):
  .prizm-docs/
    root.prizm                            # L0
    changelog.prizm                       # L0
    internal/
      logic.prizm                         # L1 for internal/logic/
      model.prizm                         # L1 for internal/model/
      repo.prizm                          # L1 for internal/repo/
      service.prizm                       # L1 for internal/service/
      common.prizm                        # L1 for internal/common/
      logic/
        statemachine.prizm                # L2 for internal/logic/statemachine/
        session.prizm                     # L2 for internal/logic/session/
        ivr.prizm                         # L2 for internal/logic/ivr/
      repo/
        rpc.prizm                         # L2 for internal/repo/rpc/
        store.prizm                       # L2 for internal/repo/store/
      service/
        http.prizm                        # L2 for internal/service/http/
        sso.prizm                         # L2 for internal/service/sso/

EXAMPLE (JS/TS project):
  .prizm-docs/
    root.prizm                            # L0
    changelog.prizm                       # L0
    src/
      components.prizm                    # L1 for src/components/
      hooks.prizm                         # L1 for src/hooks/
      services.prizm                      # L1 for src/services/
      components/
        auth.prizm                        # L2 for src/components/auth/
        dashboard.prizm                   # L2 for src/components/dashboard/

EXAMPLE (Python project):
  .prizm-docs/
    root.prizm                            # L0
    changelog.prizm                       # L0
    app/
      models.prizm                        # L1 for app/models/
      views.prizm                         # L1 for app/views/
      services.prizm                      # L1 for app/services/
      services/
        payment.prizm                     # L2 for app/services/payment/

---

# SECTION 3: DOCUMENT FORMAT SPECIFICATION

## 3.1 L0: root.prizm

TEMPLATE:

  PRIZM_VERSION: 1
  PROJECT: <name>
  LANG: <primary language>
  FRAMEWORK: <primary framework or "none">
  BUILD: <build command>
  TEST: <test command>
  ENTRY: <entry point file(s)>
  UPDATED: <YYYY-MM-DD>

  ARCHITECTURE: <layer1> -> <layer2> -> <layer3> -> ...
  LAYERS:
  - <layer-name>: <one-line description>

  TECH_STACK:
  - runtime: <list>
  - deps: <key external dependencies>
  - infra: <infrastructure: databases, queues, caches, etc.>

  MODULE_INDEX:
  - <source-path>: <file-count> files. <one-line description>. -> .prizm-docs/<mirrored-path>.prizm

  ENTRY_POINTS:
  - <name>: <file-path> (<protocol/port if applicable>)

  RULES:
  - MUST: <project-wide mandatory rule>
  - NEVER: <project-wide prohibition>
  - PREFER: <project-wide preference>

  PATTERNS:
  - <pattern-name>: <one-line description of code pattern used across project>

  DECISIONS:
  - [YYYY-MM-DD] <project-level architectural decision and rationale>
  - REJECTED: <rejected approach + why>

CONSTRAINTS:
- Max 4KB (roughly 100 lines)
- Every line must be a KEY: value pair or a list item
- MODULE_INDEX must have arrow pointer (->) for every entry
- RULES limited to 5-10 most critical conventions
- No prose paragraphs

## 3.2 L1: module.prizm

TEMPLATE:

  MODULE: <source-path>
  FILES: <count>
  RESPONSIBILITY: <one-line>
  UPDATED: <YYYY-MM-DD>

  SUBDIRS:
  - <name>/: <one-line description>. -> .prizm-docs/<child-path>.prizm

  KEY_FILES:
  - <filename>: <role/purpose>

  INTERFACES:
  - <function/method signature>: <what it does>

  DEPENDENCIES:
  - imports: <internal modules this module uses>
  - imported-by: <internal modules that depend on this>
  - external: <third-party packages used>

  RULES:
  - MUST: <module-specific mandatory rule>
  - NEVER: <module-specific prohibition>
  - PREFER: <module-specific preference>

  DATA_FLOW:
  - <numbered step describing how data moves through this module>

CONSTRAINTS:
- Max 3KB
- INTERFACES lists only PUBLIC/EXPORTED signatures
- DEPENDENCIES has 3 sub-categories (imports, imported-by, external)
- SUBDIRS entries must have arrow pointer (->) if L2 doc exists
- KEY_FILES lists only the most important files (max 10-15)

## 3.3 L2: detail.prizm

TEMPLATE:

  MODULE: <source-path>
  FILES: <comma-separated list of all files>
  RESPONSIBILITY: <one-line>
  UPDATED: <YYYY-MM-DD>

  <DOMAIN-SPECIFIC SECTIONS>
  (AI generates these based on what the module does. Examples below.)

  KEY_FILES:
  - <filename>: <detailed description, line count, complexity notes>

  DEPENDENCIES:
  - uses: <external lib>: <why/how used>
  - imports: <internal module>: <which interfaces consumed>

  DECISIONS:
  - [YYYY-MM-DD] <decision made within this module and rationale>
  - REJECTED: <approach that was tried/considered and abandoned + why>

  TRAPS:
  - <gotcha: something that looks correct but is wrong or dangerous>
  - <non-obvious coupling, race condition, or side effect>

  CHANGELOG:
  - YYYY-MM-DD | <verb>: <description of recent change to this module>

DOMAIN_SPECIFIC_SECTION_EXAMPLES:
- For state machines: STATES, TRIGGERS, TRANSITIONS
- For API handlers: ENDPOINTS, REQUEST_FORMAT, RESPONSE_FORMAT, ERROR_CODES
- For data stores: TABLES, QUERIES, INDEXES, CACHE_KEYS
- For config modules: CONFIG_KEYS, ENV_VARS, DEFAULTS
- For UI components: PROPS, EVENTS, SLOTS, STYLES

CONSTRAINTS:
- Max 5KB
- DOMAIN-SPECIFIC SECTIONS are flexible, not prescribed
- DECISIONS is append-only (never delete, archive if >20 entries)
- TRAPS section is CRITICAL for preventing AI from making known mistakes
- REJECTED entries prevent AI from re-proposing failed approaches
- FILES lists all files, not just key ones

## 3.4 changelog.prizm

TEMPLATE:

  CHANGELOG:
  - YYYY-MM-DD | <module-path> | <verb>: <one-line description>

VERBS: add, update, fix, remove, refactor, rename, deprecate
RETENTION: Keep last 50 entries. Archive older entries to changelog-archive.prizm if needed.

EXAMPLE:
  CHANGELOG:
  - 2026-03-02 | internal/logic/timer | add: retry logic with exponential backoff
  - 2026-03-01 | internal/service/sso | update: create_robot handler validates chatbot config
  - 2026-02-28 | internal/model/chatbot | add: DeepSeek provider model definition
  - 2026-02-27 | internal/repo/rpc | fix: Hunyuan API timeout not respected

---

# SECTION 4: FORMAT CONVENTIONS

HEADERS: ALL CAPS followed by colon (MODULE:, FILES:, RESPONSIBILITY:, etc.)
VALUES: Single space after colon, value on same line (KEY: value)
LISTS: Dash-space prefix for items within a section (- item)
POINTERS: Arrow notation (->) to reference other .prizm files
DATES: [YYYY-MM-DD] in square brackets for timestamps
CHANGELOG_SEPARATOR: Pipe (|) between date, module, and description
NESTING: Indent 2 spaces for sub-keys within a section
COMMENTS: None. Every line carries information. No comments in .prizm files.

---

# SECTION 5: PATH MAPPING RULES

## 5.1 Mapping Algorithm

RULE: Mirror the source directory tree under .prizm-docs/
RULE: L1 file for directory D = .prizm-docs/<D>.prizm
RULE: L2 file for subdirectory D/S = .prizm-docs/<D>/<S>.prizm
RULE: Root index = .prizm-docs/root.prizm (always)
RULE: Changelog = .prizm-docs/changelog.prizm (always)

## 5.2 Examples

SOURCE_PATH                   L1_PRIZM_FILE                            L2_PRIZM_FILES
internal/logic/               .prizm-docs/internal/logic.prizm         .prizm-docs/internal/logic/*.prizm
internal/logic/session/       (described in L1 logic.prizm SUBDIRS)    .prizm-docs/internal/logic/session.prizm
internal/repo/store/          (described in L1 repo.prizm SUBDIRS)     .prizm-docs/internal/repo/store.prizm
src/components/               .prizm-docs/src/components.prizm         .prizm-docs/src/components/*.prizm
src/components/auth/          (described in L1 components.prizm)       .prizm-docs/src/components/auth.prizm
app/services/                 .prizm-docs/app/services.prizm           .prizm-docs/app/services/*.prizm

## 5.3 Discovery Rule

FOR any source file at path P:
  1. Walk up directory tree to find the first ancestor D where .prizm-docs/<D>.prizm exists
  2. That file is the L1 doc for this source file
  3. If P is inside a subdirectory S of D, check if .prizm-docs/<D>/<S>.prizm exists for L2
  4. If no .prizm doc found, the module is undocumented (may need prizmkit.doc.update)

---

# SECTION 6: PROGRESSIVE LOADING PROTOCOL

## 6.1 When to Load

ON_SESSION_START:
  ALWAYS: Read .prizm-docs/root.prizm (L0) if it exists
  PURPOSE: Get the project map, understand architecture, know where to look

ON_TASK_RECEIVED:
  IF task references specific file or directory:
    LOAD: L1 for the containing module
  IF task is broad (e.g., "refactor auth", "improve performance"):
    LOAD: L1 for all matching modules from MODULE_INDEX
  IF task is exploratory (e.g., "explain the codebase", "how does X work"):
    LOAD: L0 only, then navigate via pointers as needed
  IF task is cross-cutting (e.g., "add logging everywhere"):
    LOAD: L1 for affected modules, check DEPENDENCIES.imported-by

ON_FILE_MODIFICATION:
  BEFORE editing any source file:
    LOAD: L2 for the containing sub-module (if exists and not already loaded)
    READ: TRAPS section (prevent known mistakes)
    READ: DECISIONS section (understand prior choices)
    READ: REJECTED entries (avoid re-proposing failed approaches)

## 6.2 Loading Rules

NEVER: Load all L1 and L2 docs at session start (defeats progressive loading)
NEVER: Load L2 for modules not being modified (wastes context window)
NEVER: Skip L0 (it is the map for everything else)
PREFER: Load L1 before L2 (understand module context before diving into details)
PREFER: Load minimum docs needed for the task
BUDGET: Typical task should consume 3000-5000 tokens of prizm docs total

---

# SECTION 7: AUTO-UPDATE PROTOCOL

## 7.1 Trigger

WHEN: Before every commit (detected automatically via hook, or manually via prizmkit.doc.update)
GOAL: Keep prizm docs synchronized with source code

## 7.2 Update Decision Logic

ALGORITHM: prizm_update

1. GET_CHANGES:
   Run: git diff --cached --name-status
   If nothing staged: Run: git diff --name-status
   Result: List of (status, file_path) pairs

2. MAP_TO_MODULES:
   FOR EACH changed file:
     Find its module by matching against MODULE_INDEX in root.prizm
     Group changes by module

3. CLASSIFY_CHANGES:
   FOR EACH changed file:
     A (added): May need new entries in KEY_FILES, INTERFACES
     D (deleted): Remove from KEY_FILES, update FILES count
     M (modified): Check if public interfaces or dependencies changed
     R (renamed): Update all path references in affected docs

4. UPDATE_DOCS:
   FOR EACH affected module:
     a. IF L2 doc exists for this module:
        UPDATE: KEY_FILES (add/remove/modify)
        UPDATE: INTERFACES (if signatures changed)
        UPDATE: DEPENDENCIES (if imports changed)
        APPEND: CHANGELOG entry
        UPDATE: UPDATED timestamp
     b. IF L1 doc exists:
        UPDATE: FILES count
        UPDATE: KEY_FILES (if major files added/removed)
        UPDATE: INTERFACES (if public API changed)
        UPDATE: DEPENDENCIES (if module-level deps changed)
        UPDATE: UPDATED timestamp
     c. UPDATE root.prizm (L0):
        UPDATE: MODULE_INDEX file counts
        ONLY IF: module added, removed, or project-wide structural change
        UPDATE: UPDATED timestamp

5. SKIP_CONDITIONS:
   SKIP if: Only internal implementation changed (no interface/dependency change)
   SKIP if: Only comments, whitespace, or formatting changed
   SKIP if: Only test files changed (unless test patterns doc exists)
   SKIP if: Only .prizm files changed (avoid circular updates)

6. CREATE_NEW_DOCS:
   IF new directory with 3+ source files appears AND matches no existing module:
     CREATE: L1 doc immediately
     ADD: entry to MODULE_INDEX in root.prizm
     DEFER: L2 creation to first modification

7. SIZE_ENFORCEMENT:
   AFTER each update, check file sizes:
   L0 > 4KB: Consolidate MODULE_INDEX entries, remove lowest-value RULES
   L1 > 3KB: Move implementation details to L2, keep only signatures in INTERFACES
   L2 > 5KB: Split into sub-module docs or archive old CHANGELOG entries

8. STAGE_DOCS:
   Run: git add .prizm-docs/
   (Prizm docs are committed alongside source code changes)

## 7.3 Changelog Update

ALWAYS append to .prizm-docs/changelog.prizm after any doc update.
FORMAT: - YYYY-MM-DD | <module-path> | <verb>: <one-line description>
VERBS: add, update, fix, remove, refactor, rename, deprecate

---

# SECTION 8: ANTI-PATTERNS

WHAT_NOT_TO_PUT_IN_PRIZM_DOCS:

NEVER: Prose paragraphs or explanatory text (use KEY: value or bullet lists)
NEVER: Code snippets longer than 1 line (reference file_path:line_number instead)
NEVER: Human-readable formatting (emoji, ASCII art, markdown tables, horizontal rules)
NEVER: Duplicate information across levels (L0 summarizes, L1 details, L2 deep-dives)
NEVER: Implementation details in L0 or L1 (those belong in L2 only)
NEVER: Stale information (update or delete, never leave outdated entries)
NEVER: Full file contents or large code blocks (summarize purpose and interfaces)
NEVER: TODO items or future plans (those belong in issue trackers)
NEVER: Session-specific context or conversation history (docs are session-independent)
NEVER: Flowcharts, diagrams, mermaid blocks, or ASCII art (wastes tokens, AI cannot parse visually)
NEVER: Markdown headers (## / ###) inside .prizm files (use ALL CAPS KEY: format instead)
NEVER: Rewrite entire .prizm files on update (modify only affected sections)

---

# SECTION 9: INITIALIZATION PROCEDURE

## 9.1 Algorithm

COMMAND: prizmkit.doc.init
PRECONDITION: No .prizm-docs/ directory exists (or user confirms overwrite)

ALGORITHM: prizm_init

INPUT: Project root directory
OUTPUT: .prizm-docs/ with root.prizm, changelog.prizm, and L1 docs for discovered modules

STEPS:

1. DETECT_PROJECT:
   SCAN project root for build system files:
   - go.mod -> Go
   - package.json -> JavaScript/TypeScript
   - requirements.txt, pyproject.toml, setup.py -> Python
   - Cargo.toml -> Rust
   - pom.xml, build.gradle -> Java
   - *.csproj, *.sln -> C#
   IDENTIFY: primary language, framework, build command, test command
   FIND: entry points by convention:
   - Go: main.go, cmd/*/main.go
   - JS/TS: package.json "main"/"bin", index.ts, index.js
   - Python: __main__.py, manage.py, app.py
   - Rust: main.rs, lib.rs
   - Java: *Application.java, Main.java

2. DISCOVER_MODULES:
   SCAN source directories:
   - Find directories containing 3+ source files of the primary language
   - Recognize common patterns: controllers/, services/, models/, components/, hooks/, utils/, lib/, pkg/, internal/, cmd/, api/, routes/, middleware/
   - Each qualifying directory = one module candidate
   - EXCLUDE: vendor/, node_modules/, .git/, build/, dist/, __pycache__/, target/, bin/
   IF module count > 30: ASK user for include/exclude patterns

3. CREATE_DIRECTORY_STRUCTURE:
   Create .prizm-docs/ directory
   Create subdirectories mirroring source module tree

4. GENERATE_ROOT (L0):
   Fill: PROJECT, LANG, FRAMEWORK, BUILD, TEST, ENTRY from step 1
   Build: MODULE_INDEX from step 2 (one entry per module with file count and pointer)
   Extract: RULES from existing CODEBUDDY.md, README, .editorconfig, linter configs
   Extract: PATTERNS from common code patterns observed in step 2
   Set: PRIZM_VERSION: 1, UPDATED: today's date

5. GENERATE_L1_DOCS:
   FOR EACH module in MODULE_INDEX:
     SCAN module directory:
     - Count all source files
     - Identify exported/public interfaces (language-specific: exported funcs in Go, export in JS/TS, public in Java, pub in Rust)
     - Trace import/require/use statements for DEPENDENCIES
     - Identify subdirectories for SUBDIRS
     - Identify 5-10 most important files for KEY_FILES
     WRITE: .prizm-docs/<mirrored-path>.prizm

6. SKIP_L2:
   DO NOT generate L2 docs during initialization.
   RATIONALE: L2 requires deep code understanding. Generating shallow L2 docs during init would produce misleading content and create false confidence. L2 docs are generated lazily when AI first modifies files in a sub-module.

7. CREATE_CHANGELOG:
   Write .prizm-docs/changelog.prizm with single entry:
   - YYYY-MM-DD | root | add: initialized prizm documentation framework

8. VALIDATE:
   CHECK: All generated files are within size limits (L0 <= 4KB, L1 <= 3KB)
   CHECK: Every MODULE_INDEX pointer resolves to an existing .prizm file
   CHECK: No circular dependencies in DEPENDENCIES sections
   CHECK: UPDATED timestamps are set on all files

9. CONFIGURE_HOOK:
   Add UserPromptSubmit hook to .codebuddy/settings.json (see Section 11)

10. UPDATE_CODEBUDDY_MD:
    Append Prizm protocol section to CODEBUDDY.md (see Section 12)

11. REPORT:
    Output summary: modules discovered, L1 docs generated, files excluded, warnings

## 9.2 Post-Init Behavior

After initialization, L2 docs are created incrementally:
- First time AI modifies a file in sub-module S within module M:
  IF .prizm-docs/<M>/<S>.prizm does not exist:
    AI reads the source files in S, generates L2 doc, then proceeds with modification
- This ensures L2 docs have real depth, written when AI has actual context

---

# SECTION 10: SKILL DEFINITION

## 10.1 SKILL.md Template

Place at: .codebuddy/skills/prizm/SKILL.md

CONTENT:

  ---
  name: "prizm"
  description: "AI-only documentation framework for progressive context loading. Manages .prizm-docs/ directory. Use 'prizmkit.doc.init' to bootstrap for a new project, 'prizmkit.doc.update' to sync docs with code changes, 'prizmkit.doc.status' to check freshness, 'prizmkit.doc.rebuild <module>' to regenerate a specific module's docs."
  ---

  # Prizm - AI Documentation Framework

  ## Commands

  ### prizmkit.doc.init
  Bootstrap .prizm-docs/ for the current project.
  PRECONDITION: No .prizm-docs/ directory exists, or user confirms overwrite.
  EXECUTE: Follow PRIZM-SPEC.md Section 9 initialization algorithm.
  STEPS:
  1. Detect project type (language, framework, build system)
  2. Discover modules (directories with 3+ source files)
  3. Create .prizm-docs/ directory structure mirroring source tree
  4. Generate root.prizm (L0) with project meta and module index
  5. Generate L1 .prizm files for each discovered module
  6. Create empty changelog.prizm
  7. Configure UserPromptSubmit hook in .codebuddy/settings.json
  8. Add Prizm protocol section to CODEBUDDY.md
  9. Validate all generated docs (size limits, pointer resolution)
  10. Report summary to user
  OUTPUT: List of generated files and module count.

  ### prizmkit.doc.update
  Update .prizm-docs/ to reflect recent code changes.
  PRECONDITION: .prizm-docs/ exists with root.prizm.
  EXECUTE: Follow PRIZM-SPEC.md Section 7 auto-update protocol.
  STEPS:
  1. Get changed files from git diff (staged and unstaged)
  2. If no git changes, do full rescan comparing code against existing docs
  3. Map changed files to modules
  4. Update affected L2, L1, and L0 docs per update decision logic
  5. Append entries to changelog.prizm
  6. Enforce size limits
  7. Stage updated .prizm files
  OUTPUT: List of updated/created/skipped docs.

  ### prizmkit.doc.status
  Check freshness of all .prizm docs.
  EXECUTE:
  1. Read root.prizm UPDATED timestamp
  2. Count commits since that timestamp via git log
  3. For each L1/L2 doc, compare UPDATED timestamp against latest git modification of source files in that module
  4. Classify each doc as: FRESH (updated after latest source change), STALE (source changed since last update), MISSING (module exists but no doc)
  OUTPUT: Freshness report table.

  ### prizmkit.doc.rebuild <module-path>
  Regenerate docs for a specific module from scratch.
  USE WHEN: Doc has drifted too far from code reality.
  EXECUTE:
  1. Delete existing L1 and L2 docs for the specified module
  2. Re-scan the module directory
  3. Generate fresh L1 doc
  4. Generate L2 doc (unlike init, rebuild generates L2 immediately)
  5. Update MODULE_INDEX in root.prizm
  6. Append rebuild entry to changelog.prizm
  OUTPUT: Regenerated doc summary.

---

# SECTION 11: HOOK CONFIGURATION

## 11.1 Mechanism

HOOK_TYPE: prompt (LLM-evaluated, not script-based)
EVENT: UserPromptSubmit
BEHAVIOR: Detects commit intent in user prompt, injects doc update reminder
ALWAYS_RETURNS: ok: true (never blocks the user prompt)
INJECTION: When commit intent detected, "reason" field carries update instructions that AI sees as additional context

## 11.2 Configuration Template

Place in: .codebuddy/settings.json (project-level)

JSON:
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "You are a commit-intent detector for the Prizm documentation framework. Analyze the user prompt and determine if the user intends to COMMIT, PUSH, FINISH, SHIP, MERGE, or create a PULL REQUEST.\n\nUser prompt: $ARGUMENTS\n\nIF commit intent detected, respond with:\n{\"ok\": true, \"reason\": \"PRIZM_UPDATE_REQUIRED: Before committing, you MUST update .prizm-docs/. Steps: 1) Run git diff --cached --name-status. 2) Map changed files to modules via root.prizm MODULE_INDEX. 3) Read and update affected .prizm files (only changed sections). 4) Append to changelog.prizm. 5) Stage .prizm files. 6) Then commit. RULES: Never rewrite entire files. Never add prose. Only update affected sections.\"}\n\nIF no commit intent, respond with:\n{\"ok\": true}\n\nJSON only.",
            "timeout": 10
          }
        ]
      }
    ]
  }
}

## 11.3 How It Works

FLOW:
1. User types prompt (e.g., "commit these changes" or "push to main")
2. UserPromptSubmit hook fires before AI processes the prompt
3. Fast LLM (Haiku) evaluates the prompt against commit-intent keywords
4. IF commit intent: Returns {ok: true, reason: "PRIZM_UPDATE_REQUIRED: ..."}
   - The "reason" content is injected into AI's context as additional instructions
   - AI sees the update instructions and executes them before committing
5. IF no commit intent: Returns {ok: true} with no reason
   - AI proceeds normally, no extra context injected

KEYWORDS_DETECTED: commit, push, finish, done, ship, merge, PR, pull request, /commit, auto-committer, save changes

## 11.4 Adapting for Other AI Tools

The hook configuration above is specific to CodeBuddy Code.
For other AI coding assistants:
- Cursor: Use .cursorrules file to add the auto-update protocol as a rule
- Aider: Use .aider.conf.yml conventions section
- Continue: Use .continue/config.json customInstructions
- Generic: Add the auto-update protocol text to whatever system prompt or rules file the tool supports

The core requirement is: before any commit operation, AI must update affected .prizm-docs/ files.

---

# SECTION 12: CODEBUDDY.MD TEMPLATE

## 12.1 Template Section

Append the following to any project's CODEBUDDY.md during prizmkit.doc.init:

TEXT:

  ## Prizm Documentation Framework

  This project uses Prizm for AI-optimized, progressive context loading.
  Full specification: PRIZM-SPEC.md

  ### Progressive Loading Protocol
  - ON SESSION START: Always read .prizm-docs/root.prizm first
  - ON TASK: Read L1 (.prizm-docs/<module>.prizm) for relevant modules referenced in MODULE_INDEX
  - ON FILE EDIT: Read L2 (.prizm-docs/<module>/<submodule>.prizm) before modifying files. Pay attention to TRAPS and DECISIONS.
  - NEVER load all .prizm docs at once. Load only what is needed for the current task.

  ### Auto-Update Protocol
  - BEFORE EVERY COMMIT: Update affected .prizm-docs/ files per PRIZM-SPEC.md Section 7
  - The UserPromptSubmit hook will remind you automatically
  - If hook is not active, you MUST still follow the update protocol manually

  ### Doc Format Rules
  - All .prizm files use KEY: value format, not prose
  - Size limits: L0 = 4KB, L1 = 3KB, L2 = 5KB
  - Arrow notation (->) indicates load pointers to other .prizm docs
  - DECISIONS and CHANGELOG are append-only (never delete entries)

  ### Creating New L2 Docs
  - When you first modify files in a sub-module that has no L2 doc:
    1. Read the source files in that sub-module
    2. Generate a new L2 .prizm file following PRIZM-SPEC.md Section 3.3
    3. Add a pointer in the parent L1 doc's SUBDIRS section

---

# SECTION 13: LANGUAGE-SPECIFIC INITIALIZATION HINTS

## 13.1 Module Boundary Detection

LANGUAGE          MODULE_BOUNDARY                         ENTRY_POINT_DETECTION
Go                Directories with .go files              main.go, cmd/**/main.go
JavaScript/TS     Directories with index.ts/js/tsx/jsx    package.json main/bin
Python            Directories with __init__.py            __main__.py, manage.py, app.py, wsgi.py
Rust              Directories with mod.rs                 main.rs, lib.rs
Java              src/main/java/* package directories     *Application.java, Main.java
C#                Directories with *.cs files             Program.cs, Startup.cs

## 13.2 Interface Detection

LANGUAGE          EXPORTED_INTERFACE_PATTERN
Go                Capitalized function/type names (func Foo, type Bar)
JavaScript/TS     export/export default declarations
Python            Functions/classes without underscore prefix
Rust              pub fn, pub struct, pub enum, pub trait
Java              public class, public interface, public method
C#                public class, public interface, public method

## 13.3 Dependency Detection

LANGUAGE          IMPORT_PATTERN
Go                import "path/to/package"
JavaScript/TS     import ... from "...", require("...")
Python            import ..., from ... import ...
Rust              use crate::..., use super::..., extern crate
Java              import package.Class
C#                using Namespace

---

# SECTION 14: MINIMAL VIABLE PRIZM

For any project, the minimum viable Prizm setup is:

FILES:
  .prizm-docs/root.prizm        # Project meta + module index (L0)
  .prizm-docs/changelog.prizm   # Change log

This is enough to give AI a project overview and track changes.
L1 and L2 docs can be added incrementally as AI works in specific areas.

BOOTSTRAP_COMMAND:
  prizmkit.doc.init

Or manually create these two files following the templates in Section 3.

---

# SECTION 15: VERSION HISTORY

V1 (2026-03-02): Initial specification
- 3-level progressive loading (L0, L1, L2)
- KEY: value format, AI-only audience
- UserPromptSubmit hook with type: prompt for auto-update
- Mirrored directory structure under .prizm-docs/
- Lazy L2 generation strategy
- Universal language support
