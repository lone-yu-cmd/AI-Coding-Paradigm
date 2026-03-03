---
name: "app-planner"
description: "Interactive app planning that produces feature-list.json for dev-pipeline. Invoke when user wants to plan an app, design features, or prepare for automated development."
---

# App Planner

This skill guides an AI assistant through a structured, interactive conversation with the user to plan a new application from scratch. The final output is a validated `feature-list.json` file that serves as the input contract for the `dev-pipeline` module, which will autonomously implement each feature via multi-agent team sessions.

## Installation

The `${SKILL_DIR}` placeholder represents the absolute path to this skill's directory. It is automatically resolved by the environment when the skill is invoked.

## When to Use

**Trigger this skill when the user says any of the following (or similar):**

- "Plan an app", "Design a new application", "I want to build an app"
- "Create a feature list", "Prepare for dev-pipeline", "Generate feature-list.json"
- "Let's plan what to build", "Help me scope out my project"
- "I have an app idea", "Break down my app into features"

Chinese triggers (zhong wen chu fa):
- "规划一个应用", "设计一个新项目", "帮我拆分功能"
- "生成功能列表", "准备 dev-pipeline 输入"

**DO NOT use this skill when:**

- The user wants to add a single feature to an existing, already-planned project
- The user is fixing a bug or doing a refactor
- A `feature-list.json` already exists and the user has not asked to re-plan
- The user just wants to run the dev-pipeline (direct them to `./dev-pipeline/run.sh` instead)

## Prerequisites

Before starting the planning conversation, check for optional context files. These are NOT required -- the skill works on blank projects.

1. **Existing project context** (optional): If `.prizm-docs/root.prizm` exists, read it for architecture and tech stack context.
2. **Existing config** (optional): If `.prizmkit/config.json` exists, read it for pre-configured tech stack preferences.
3. **Existing spec** (optional): If the user mentions a specification document, read it and use it to pre-populate feature ideas.

If none of these exist, proceed directly to Phase 1. Do not block on missing files.

## Interactive Planning Workflow

CRITICAL: This is a conversation-driven skill. You MUST ask questions and wait for user responses at each phase. Do NOT generate the entire plan in one shot. The value of this skill is the iterative dialogue.

---

### Phase 1: App Vision (1-3 questions)

**Goal**: Understand the core purpose, audience, and differentiation of the application.

Ask these questions one at a time (or grouped if the user prefers concise interaction):

1. **What is the app?** -- "Describe the application you want to build. What problem does it solve?"
2. **Who are the target users?** -- "Who will use this app? What are their primary needs?"
3. **What makes it unique?** -- "What is the core value proposition? What differentiates it from existing solutions?"

**AI Behavior:**
- Summarize the user's vision back to them in 2-3 sentences before proceeding.
- If the vision is vague, ask follow-up questions to clarify scope.
- If the user provides a spec document, extract answers from it and confirm with the user.

---

### Phase 2: Tech Stack Decision (1-2 questions)

**Goal**: Establish the technical foundation that will populate `global_context` in the output.

Present a structured choice for each category. Suggest defaults based on the app type, but let the user override.

**Categories to decide:**

| Category | Common Options | Default Suggestion |
|----------|---------------|-------------------|
| Frontend | React/Next.js, Vue/Nuxt, Svelte/SvelteKit, Angular | Next.js 14 |
| Backend | Express, FastAPI, Django, NestJS, Go/Gin | Express.js |
| Database | PostgreSQL, MySQL, MongoDB, SQLite | PostgreSQL |
| ORM | Prisma, TypeORM, Drizzle, SQLAlchemy | Prisma |
| Auth | NextAuth, Clerk, Supabase Auth, custom JWT | NextAuth |
| Design System | shadcn/ui, Ant Design, Material UI, Chakra UI | shadcn/ui + Tailwind CSS |
| Testing | Jest + Playwright, Vitest + Cypress, pytest | Jest + Playwright |
| Language | TypeScript, Python, Go | TypeScript |

**AI Behavior:**
- Present the table above (adapted to the app type) and let the user confirm or modify.
- If the user has no preference, use the defaults.
- Record the final tech stack -- it maps directly to `global_context` in the output.
- If `.prizmkit/config.json` was read in Prerequisites, pre-fill from that config.

---

### Phase 3: Feature Brainstorming (iterative)

**Goal**: Collaboratively build a comprehensive, well-structured feature list.

**Step 3a: Initial Proposal**

Based on the app vision and tech stack, propose an initial feature breakdown. Follow these rules:

- Feature F-001 MUST be "Project Infrastructure Setup" (scaffolding, configs, CI basics). This is always the first feature with zero dependencies.
- Feature F-002 is typically "User Authentication" (if applicable).
- Subsequent features should follow a logical build order.
- Aim for 5-12 features for an MVP. Fewer than 5 usually means features are too coarse. More than 15 usually means features are too granular.

Present each feature as:

```
F-001: Project Infrastructure Setup
  Description: Initialize the project with [framework], database connection, linting, and CI config.
  Complexity: medium
  Dependencies: (none)
  Acceptance Criteria:
    - [framework] app runs on expected port
    - Database connection verified
    - TypeScript compiles without errors
    - Linter and formatter configs applied
```

**Step 3b: User Review**

Ask the user to review the proposed features:
- Add any missing features
- Remove features that are out of scope
- Modify descriptions or acceptance criteria
- Split features that are too large
- Merge features that are too small

**Step 3c: Detail Refinement**

For each feature (after the user approves the overall list), ensure:

1. **Description** is detailed enough for a development team to implement without additional context. It should describe WHAT to build, not HOW to build it.
2. **Acceptance Criteria** follow Given/When/Then style where applicable, with a minimum of 3 criteria per feature. Examples:
   - "Given a logged-in user, when they click 'Create Task', then a new task form appears"
   - "Users can register with email and password"
   - "API returns 401 for unauthenticated requests"
3. **Dependencies** are explicitly listed by F-NNN ID.
4. **Complexity** is estimated as low/medium/high.

Iterate on Step 3b and 3c until the user says they are satisfied.

---

### Phase 4: Dependency Graph and Ordering

**Goal**: Validate the dependency chain and confirm execution order.

**Step 4a: Dependency Validation**

Check the proposed dependencies for:
- **No cycles**: Dependencies MUST form a Directed Acyclic Graph (DAG). If a cycle is detected, ask the user to resolve it.
- **No orphans with unmet deps**: Every dependency target must exist in the feature list.
- **F-001 has no dependencies**: The infrastructure feature is always the root.

**Step 4b: Execution Order Visualization**

Present the dependency chain as a text-based graph:

```
F-001: Project Infrastructure Setup
  |
  +-- F-002: User Authentication
  |     |
  |     +-- F-003: Task CRUD Operations
  |           |
  |           +-- F-004: Project & Team Management
  |           |
  |           +-- F-005: Real-time Updates
  |                 |
  |                 +-- F-006: Analytics Dashboard (also depends on F-004)
```

**Step 4c: Priority Assignment**

Assign priority numbers (1 = highest) based on dependency order and user input. Features with no dependents and early in the chain get higher priority.

Ask the user: "Does this execution order look correct? Any features you want prioritized differently?"

---

### Phase 5: Granularity Decision

**Goal**: Determine whether complex features need sub-feature decomposition.

Apply these rules to each feature:

| Condition | Action |
|-----------|--------|
| More than 8 acceptance criteria | Consider splitting into sub_features |
| Touches more than 3 distinct modules (e.g., API + DB + UI + auth) | Consider splitting into sub_features |
| Estimated complexity is "high" | Recommend sub_features with `session_granularity: "auto"` |
| Infrastructure or setup feature | Always use `session_granularity: "feature"` |
| Simple CRUD or utility feature | Use `session_granularity: "feature"` |

When splitting, create sub_features with IDs like `F-004-A`, `F-004-B`, etc. Each sub_feature needs:
- `id`: F-NNN-X pattern (X is uppercase letter)
- `title`: concise title
- `description`: what this sub-feature covers

Present the granularity decisions to the user and get confirmation.

---

### Phase 6: Generate Output

**Goal**: Produce the validated `feature-list.json` file.

**Step 6a: Construct the JSON**

Build the complete JSON object following this exact schema:

```json
{
  "$schema": "dev-pipeline-feature-list-v1",
  "app_name": "<from Phase 1>",
  "app_description": "<1-2 sentence summary from Phase 1>",
  "created_at": "<current ISO 8601 datetime>",
  "created_by": "app-planner",
  "source_spec": "<path to spec file if one was used, otherwise omit>",
  "features": [
    {
      "id": "F-001",
      "title": "<feature title>",
      "description": "<detailed description>",
      "priority": 1,
      "estimated_complexity": "low | medium | high",
      "dependencies": [],
      "acceptance_criteria": [
        "<criterion 1>",
        "<criterion 2>",
        "<criterion 3>"
      ],
      "status": "pending",
      "session_granularity": "feature | sub_feature | auto",
      "sub_features": []
    }
  ],
  "global_context": {
    "tech_stack": "<from Phase 2, e.g. Next.js 14 + Express.js + PostgreSQL + Prisma>",
    "design_system": "<from Phase 2, e.g. shadcn/ui + Tailwind CSS>",
    "testing_strategy": "<from Phase 2, e.g. Jest (unit) + Playwright (e2e)>",
    "language": "<from Phase 2, e.g. TypeScript>"
  }
}
```

**Step 6b: Write and Validate**

1. Write the JSON to the user's preferred output path. Default: `.dev-pipeline/feature-list.json`
2. Ask the user if they want a different output path before writing.
3. Run the validation script:

```bash
python3 ${SKILL_DIR}/scripts/validate-and-generate.py --input <path-to-written-file> --output <final-output-path>
```

4. If validation fails, report the errors and fix them.
5. If validation succeeds, proceed to the summary.

**Step 6c: Summary Table**

Present a summary table of the plan:

```
+-------+-----------------------------------+----------+--------+--------------+
| ID    | Title                             | Priority | Cmplx  | Dependencies |
+-------+-----------------------------------+----------+--------+--------------+
| F-001 | Project Infrastructure Setup      | 1        | medium | (none)       |
| F-002 | User Authentication               | 2        | medium | F-001        |
| F-003 | Task CRUD Operations              | 3        | medium | F-002        |
| ...   | ...                               | ...      | ...    | ...          |
+-------+-----------------------------------+----------+--------+--------------+
Total features: N | Estimated sessions: M
```

Where "Estimated sessions" counts features plus sub_features (each sub_feature is one session when granularity is "auto").

---

### Phase 7: Integration with dev-pipeline

**Goal**: Tell the user how to proceed.

After the feature-list.json is generated and validated, present these next steps:

1. **Review the file**: "The feature list has been saved to `<output-path>`. Please review it before running the pipeline."

2. **Run the pipeline**:
   ```bash
   ./dev-pipeline/run.sh run <output-path>
   ```

3. **Monitor progress**:
   ```bash
   ./dev-pipeline/run.sh status <output-path>
   ```

4. **Adjust if needed**: "You can edit the feature-list.json manually at any time. The pipeline will pick up changes on the next iteration."

If the dev-pipeline directory does not exist in the project, inform the user that they need to set it up first and point them to the dev-pipeline documentation.

## Output Format Specification

The `feature-list.json` MUST conform to the `dev-pipeline-feature-list-v1` schema. Here is the complete field reference:

### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `$schema` | string | Yes | Must be `"dev-pipeline-feature-list-v1"` |
| `app_name` | string | Yes | Application name (min 1 char) |
| `app_description` | string | No | Brief description of the application |
| `created_at` | string | No | ISO 8601 datetime of creation |
| `created_by` | string | No | Should be `"app-planner"` |
| `source_spec` | string | No | Path to source specification file |
| `features` | array | Yes | Array of feature objects (min 1) |
| `global_context` | object | No | Shared context for all features |

### Feature Object Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Pattern: `F-NNN` or `F-NNN-X` (e.g., F-001, F-004-A) |
| `title` | string | Yes | Concise feature title |
| `description` | string | Yes | Detailed implementation description |
| `priority` | integer | Yes | Execution priority (1 = highest) |
| `estimated_complexity` | string | No | `"low"`, `"medium"`, or `"high"` |
| `dependencies` | array | Yes | Array of F-NNN IDs this feature depends on |
| `acceptance_criteria` | array | Yes | Array of testable criteria (min 1, recommend 3+) |
| `status` | string | Yes | Always `"pending"` for new plans |
| `session_granularity` | string | No | `"feature"`, `"sub_feature"`, or `"auto"` (default: `"feature"`) |
| `sub_features` | array | No | Array of sub-feature objects for complex features |

### Sub-Feature Object Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Pattern: `F-NNN-X` (e.g., F-004-A) |
| `title` | string | Yes | Sub-feature title |
| `description` | string | Yes | What this sub-feature covers |

### Global Context Fields

| Field | Type | Description |
|-------|------|-------------|
| `tech_stack` | string | Frameworks and databases |
| `design_system` | string | UI framework and CSS approach |
| `testing_strategy` | string | Testing tools and approach |
| Any additional keys | string | Deployment strategy, language, etc. |

## Quality Guidelines

These rules MUST be enforced when generating the feature list:

1. **Minimum acceptance criteria**: Every feature MUST have at least 3 acceptance criteria. Aim for 5 on medium/high complexity features.
2. **Valid DAG**: Dependencies MUST NOT contain cycles. Run a topological sort check before finalizing.
3. **Root feature**: F-001 MUST have an empty dependencies array. It is always the infrastructure/setup feature.
4. **Implementable scope**: Each feature should be implementable in a single prizm-dev-team session (typically 1-2 hours of AI work). If it cannot be, split it into sub_features.
5. **Self-contained descriptions**: Feature descriptions MUST contain enough detail for a development team to implement the feature without asking clarifying questions. Include data models, API endpoints, and UI behavior where relevant.
6. **No status assumptions**: All features in a new plan MUST have `"status": "pending"`. The dev-pipeline manages status transitions.
7. **Consistent IDs**: Feature IDs MUST be sequential (F-001, F-002, ...). Sub-feature IDs MUST use the parent ID prefix (F-004-A, F-004-B).
8. **Dependency completeness**: Every ID referenced in a `dependencies` array MUST exist as a feature `id` in the same file.

## Validation Script Usage

After constructing the feature-list.json, validate it:

```bash
python3 ${SKILL_DIR}/scripts/validate-and-generate.py --input <draft.json> --output <validated.json>
```

The script performs:
- JSON schema validation against `dev-pipeline-feature-list-v1`
- Dependency cycle detection
- ID format and uniqueness checks
- Acceptance criteria minimum count enforcement
- Dependency reference integrity checks

If `--input` is omitted, the script reads from stdin. If `--output` is omitted, it writes to stdout.

On success, the script writes the validated JSON and exits with code 0.
On failure, it prints error details to stderr and exits with code 1.

## Example: Well-Formed Feature

```json
{
  "id": "F-003",
  "title": "Task CRUD Operations",
  "description": "Core task management: create, read, update, delete tasks. Tasks have title, description, status (todo/in-progress/done), priority, due date, and assignee. The API should expose RESTful endpoints under /api/tasks. The UI should include a task list view with filtering by status and a task detail modal for editing.",
  "priority": 3,
  "estimated_complexity": "medium",
  "dependencies": ["F-002"],
  "acceptance_criteria": [
    "Create task with title, description, status, priority, due date, and assignee fields",
    "List tasks with server-side pagination (default 20 per page)",
    "Filter tasks by status, priority, and assignee",
    "Update task fields individually via PATCH /api/tasks/:id",
    "Delete task with confirmation dialog and soft-delete in database",
    "Task validation enforced on both client form and server API"
  ],
  "status": "pending",
  "session_granularity": "feature",
  "sub_features": []
}
```

## Error Recovery

If the planning conversation is interrupted or the user wants to restart:

1. **Resume**: If a partial `feature-list.json` exists at the output path, offer to load it and continue from where the user left off.
2. **Restart**: If the user explicitly says "start over" or "re-plan", discard any existing draft and begin from Phase 1.
3. **Amend**: If the user wants to modify a completed plan, load the existing file, present the current features, and allow targeted edits without re-doing the entire workflow.
