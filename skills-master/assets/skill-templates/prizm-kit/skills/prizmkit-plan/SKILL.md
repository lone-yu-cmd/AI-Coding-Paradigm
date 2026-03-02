---
name: "prizmkit-plan"
description: "Generate technical implementation plan from feature spec. Creates plan.md, data-model.md, API contracts, and research docs. Invoke after 'specify' when ready to plan. (project)"
---

# PrizmKit Plan

Generate a comprehensive technical implementation plan from a feature specification. Produces plan.md with architecture approach, component design, data model, API contracts, testing strategy, and risk assessment.

## Commands

### prizmkit.plan

Create a technical implementation plan for a specified feature.

**PRECONDITION:** `spec.md` exists in `.prizmkit/specs/###-feature-name/`, `.prizm-docs/root.prizm` exists

**STEPS:**

**Phase 0 — Research:**
1. Read `spec.md` and `.prizm-docs/root.prizm` for project context
2. Read relevant `.prizm-docs/` L1/L2 docs for affected modules
3. Resolve any remaining `[NEEDS CLARIFICATION]` by proposing solutions
4. Research technical approach based on project's tech stack

**Phase 1 — Design:**
5. Generate `plan.md` from template (`${SKILL_DIR}/assets/plan-template.md`):
   - Architecture approach (how feature fits into existing structure)
   - Component design (new/modified components)
   - Data model changes (new entities, modified schemas)
   - API contract (endpoints, request/response formats)
   - Integration points (external services, internal modules)
   - Testing strategy (unit, integration, e2e)
   - Risk assessment
6. Generate supporting docs as needed:
   - `data-model.md` (if data changes needed)
   - `contracts/` directory with API specs (if API changes)
   - `research.md` (technical research findings)
   - `quickstart.md` (key validation scenarios)

**Phase 2 — Validation:**
7. Cross-check plan against spec: every user story MUST map to plan components
8. Check alignment with project rules from `.prizm-docs/root.prizm` RULES section
9. Output: `plan.md` path and summary of design decisions

**KEY RULES:**
- Every user story in spec.md MUST have a corresponding component or task in the plan
- Architecture decisions MUST align with existing project patterns from `.prizm-docs/`
- Risk assessment MUST include at least one risk with mitigation strategy
- Supporting docs are only generated when relevant (do not create empty files)

**HANDOFF:** `prizmkit.tasks` or `prizmkit.code-review`

## Template

The plan template is located at `${SKILL_DIR}/assets/plan-template.md`.

## Output

All outputs are written to `.prizmkit/specs/###-feature-name/`:
- `plan.md` — The implementation plan
- `data-model.md` — Data model details (if applicable)
- `contracts/` — API contract specs (if applicable)
- `research.md` — Technical research findings (if applicable)
- `quickstart.md` — Key validation scenarios (if applicable)
