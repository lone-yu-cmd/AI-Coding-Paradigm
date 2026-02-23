---
description: Generate a structured feature summary and append it to the Feature Registry after implementation is complete.
handoffs:
  - label: Start New Feature
    agent: speckit.specify
    prompt: Start a new feature specification
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Prerequisites Check**: Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute.

2. **Load design documents**: Read from FEATURE_DIR:
   - **Required**: spec.md (user stories, feature description), tasks.md (completion status)
   - **Required**: plan.md (tech stack, architecture, project structure)
   - **Optional**: data-model.md (entities and tables), contracts/ (API endpoints), research.md (design decisions), quickstart.md (integration scenarios)

3. **Analyze task completion status**:
   - Count total tasks, completed `[X]` tasks, and incomplete `[ ]` tasks
   - Calculate completion percentage
   - Determine feature status:
     - **completed**: 100% tasks done
     - **in-progress**: >0% but <100% tasks done
     - **planned**: 0% tasks done
   - If status is not "completed", **WARN** the user: "Feature is not fully implemented (X/Y tasks done). Summarize current state anyway? (yes/no)"
   - Wait for user response if not completed. If user declines, halt execution.

4. **Extract feature metadata** by reading the design documents:

   From **spec.md**:
   - Feature name and one-line summary (from title and description)
   - User stories list (US1, US2, US3... with short titles)

   From **plan.md**:
   - Tech stack additions (new languages, frameworks, libraries introduced)
   - Architecture decisions (key patterns chosen)

   From **data-model.md** (if exists):
   - Database tables/entities introduced

   From **contracts/** (if exists):
   - API routes introduced (grouped by resource)

   From **tasks.md**:
   - Completion statistics
   - Phase breakdown

   From **actual codebase** (scan the project):
   - Key directories and files created/modified for this feature
   - Focus on top-level route/page paths, component directories, and API directories
   - Do NOT list every single file — summarize at the directory level

5. **Generate or update `specs/REGISTRY.md`**:

   **If REGISTRY.md does not exist**: Create it using the template at `.specify/templates/registry-template.md`

   **If REGISTRY.md exists**: Append or update the entry for the current feature.

   **Entry format** (MUST follow exactly):

   ```markdown
   ## [NNN] - [Feature Name] [status]

   - **Summary**: [One sentence describing the feature's purpose and what it delivers]
   - **Routes**: [Key application routes, comma-separated]
   - **API Endpoints**: [Key API routes, comma-separated]
   - **Data Tables**: [Database tables introduced, comma-separated]
   - **Key Directories**: [Top-level directories this feature owns/touches]
   - **Design Docs**: specs/[NNN-feature-name]/
   ```

   **Field notes**:
   - `[status]` in heading: one of `[completed]`, `[in-progress]`, `[planned]`
   - Only include fields that have actual values (e.g., skip API Endpoints if none)

   **Update rules**:
   - If the feature entry already exists in REGISTRY.md:
     - Update the status tag in heading
     - Update other fields only if they have materially changed
   - If the feature entry does not exist: Append the full entry before `<!-- FEATURES END -->`
   - Preserve all other existing entries unchanged

6. **Update CODEBUDDY.md** (or equivalent agent context file):
   - Find the `## Completed Features` section (or create it if missing)
   - Add or update the one-line entry for this feature:
     ```
     - [NNN-feature-name]: [One-line summary of what was delivered]
     ```
   - Do NOT modify other sections of the file
   - If the section contains `<!-- MANUAL ADDITIONS START -->`, place the entry BEFORE that marker

7. **Output summary report** to the conversation:

   ```text
   ┌─────────────────────────────────────────────┐
   │         Feature Summary: [Feature Name]      │
   ├─────────────────────────────────────────────┤
   │ Status:       [completed|in-progress]        │
   │ Tasks:        [X/Y completed (Z%)]           │
   │ User Stories: [N stories]                    │
   │ Routes:       [N routes]                     │
   │ API Endpoints:[N endpoints]                  │
   │ Data Tables:  [N tables]                     │
   ├─────────────────────────────────────────────┤
   │ Updated:                                     │
   │   ✓ specs/REGISTRY.md                        │
   │   ✓ CODEBUDDY.md                             │
   └─────────────────────────────────────────────┘
   ```

8. **Offer handoff**: Suggest next steps:
   - If feature is completed: "Ready to start a new feature? → /speckit.specify"
   - If feature is in-progress: "Continue implementation? → /speckit.implement"

## Quality Rules

1. **Conciseness**: Each field in the REGISTRY entry should be a single line. The entire entry for one feature should be 10-15 lines, not a wall of text.
2. **No duplication**: REGISTRY.md is an INDEX, not a copy of spec.md. It links to `specs/NNN-feature-name/` for details.
3. **Only append to Changelog**: Never modify existing changelog entries. Only append new entries.
4. **Deterministic**: Running summarize twice on the same feature with no changes should produce identical output (idempotent).
5. **Directory-level granularity**: For "Key Directories", list `app/(dashboard)/` not every file inside it.
6. **Preserve formatting**: When updating REGISTRY.md, preserve all existing content and formatting of other entries.
