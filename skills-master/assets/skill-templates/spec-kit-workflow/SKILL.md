---
name: "spec-kit-workflow"
description: "Guides the development process using GitHub Spec Kit methodology: Specify -> Plan -> Tasks -> Implement. Invoke when user wants to start a new feature or strictly follow the spec-driven workflow."
---

# Spec Kit Workflow

This skill facilitates the Spec-Driven Development workflow using the installed GitHub Spec Kit tools.

## When to Use

Invoke this skill when:
- The user wants to start a new feature ("I want to add login").
- The user asks to "use spec kit" or "follow the spec process".
- The user wants to break down a complex task into specifications and plans first.

## Workflow Phases

The process follows a strict linear progression. Always complete the current phase before moving to the next.

### Phase 1: Specify (`/speckit.specify`)

**Goal**: Define WHAT to build and WHY (Functional Requirements).

1.  **Ask** the user for a feature description if not provided.
2.  **Action**:
    -   Generate a short-name (e.g., `001-user-auth`). Everytime you start a new feature, increment the number.
    -   Create/Update the spec file in `.specs/` (using `assets/.specify/templates/spec-template.md`).
    -   Define: User Scenarios, Functional Requirements, Success Criteria.
3.  **Output**: A filled `spec.md`.

### Phase 2: Plan (`/speckit.plan`)

**Goal**: Define HOW to build it (Technical Implementation).

1.  **Prerequisite**: Phase 1 complete.
2.  **Action**:
    -   **Context Loading**: Read `docs/AI_CONTEXT/ARCHITECTURE.md` and `docs/AI_CONTEXT/CONSTITUTION.md` to ensure architectural alignment.
    -   Analyze `spec.md`.
    -   Create `plan.md` (using `assets/.specify/templates/plan-template.md`).
    -   Define: Tech Stack, Architecture, Data Models, API Contracts.
    -   Resolve "NEEDS CLARIFICATION" items.
3.  **Output**: `plan.md`, `data-model.md`, `contracts/`.

### Phase 3: Tasks (`/speckit.tasks`)

**Goal**: Break down plan into actionable steps.

1.  **Prerequisite**: Phase 2 complete.
2.  **Action**:
    -   Generate `tasks.md` (using `assets/.specify/templates/tasks-template.md`).
    -   **Rule**: Organize tasks by **User Story**.
    -   **Format**: `- [ ] [TaskID] [P?] [Story?] Description with file path`.
    -   Identify parallelizable tasks `[P]`.
3.  **Output**: `tasks.md` with a checklist.

### Phase 4: Implement (`/speckit.implement`)

**Goal**: Execute the code.

1.  **Prerequisite**: Phase 3 complete.
2.  **Action**:
    -   Read `tasks.md`.
    -   Execute tasks sequentially (or in parallel if marked `[P]`).
    -   **Update** `tasks.md` status as you go (mark as `[x]`).
    -   Verify each task after completion.

## Helper Instructions for Agent

-   **Files**: Always look for templates in `assets/.specify/templates/`.
-   **Context**: Always read the output of the previous phase before starting the next.
-   **Tools**: You can use `RunCommand` to execute helper scripts in `assets/.specify/scripts/` if needed, or manually create the markdown files if the CLI is not available/reliable.
-   **Path Resolution**: All paths starting with `assets/` in this document are relative to this skill's installation directory. You must determine the skill's location (e.g., `skills/spec-kit-workflow/` or `.trae/skills/spec-kit-workflow/`) and prepend it to access these files.
-   **Constitution**: Always check `docs/AI_CONTEXT/CONSTITUTION.md` to ensure architectural alignment.

## Example Interaction

**User**: "I want to add a rate limiter to the API."

**Agent (You)**:
1.  "Starting Spec Kit Workflow for 'rate-limiter'..."
2.  (Phase 1) Create `specs/00X-rate-limiter/spec.md`. Content: Define rate limits, error codes, headers.
3.  (Phase 2) Create `specs/00X-rate-limiter/plan.md`. Content: Redis implementation, middleware logic.
4.  (Phase 3) Create `specs/00X-rate-limiter/tasks.md`. Content: `[ ] T001 Install redis`, `[ ] T002 Implement middleware`.
5.  (Phase 4) Start coding T001...
