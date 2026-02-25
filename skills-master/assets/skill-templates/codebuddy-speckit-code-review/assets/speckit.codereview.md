---
description: Review implemented code against the feature spec, plan, and coding standards. Run after speckit.implement completes.
handoffs:
  - label: Archive Feature
    agent: speckit.summarize
    prompt: Generate feature summary and update the registry
    send: true
  - label: Fix Issues
    agent: speckit.implement
    prompt: Fix review findings and continue implementation
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). User may specify focus areas (e.g., "focus on security", "only check API routes").

## Outline

1. **Prerequisites Check**: Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute.

2. **Load review context** from FEATURE_DIR:
   - **Required**: spec.md (what was specified), tasks.md (what was implemented)
   - **Required**: plan.md (architecture decisions, tech stack, file structure)
   - **Optional**: data-model.md (expected data structures), contracts/ (API contracts), research.md (design decisions)
   - **Optional**: `.specify/memory/constitution.md` (project principles)

3. **Analyze implementation status** from tasks.md:
   - Count completed `[X]` vs incomplete `[ ]` tasks
   - If <50% tasks completed, **WARN**: "Only X% of tasks are done. A full review may be premature. Continue? (yes/no)"
   - Extract file paths from completed tasks — these are the **expected** files

4. **Collect actual code changes** (dual-source strategy):

   ### 4.1 Git Diff (primary source)
   Run `git diff main --name-status` (or the branch this feature branched from) to get the **actual** changed files list. Then run `git diff main` to get the full diff content.

   - If git is not available or not a git repo, fall back to tasks.md file list only
   - Parse diff output to classify files: **A** (added), **M** (modified), **D** (deleted), **R** (renamed)
   - For **modified** files: focus review on changed hunks (lines with `+`/`-`), while reading surrounding context for understanding
   - For **added** files: review full content
   - For **deleted** files: verify deletion is intentional per spec

   ### 4.2 Cross-reference with tasks.md
   Compare git diff file list against tasks.md referenced files:
   - **In diff but not in tasks**: Files changed but not tracked in tasks — flag as "untracked changes" (possible scope creep or missed task entries)
   - **In tasks but not in diff**: Tasks marked `[X]` but no corresponding file change — flag as "phantom completion" (task marked done but no code change detected)
   - **In both**: Normal — proceed with review

   Output a **Change Scope Summary**:
   ```text
   ┌─ Change Scope ────────────────────────────┐
   │ Files from git diff:    [N]                │
   │ Files from tasks.md:    [N]                │
   │ Matched:                [N]                │
   │ Untracked (diff only):  [N] ⚠️             │
   │ Phantom (tasks only):   [N] ⚠️             │
   │ Added / Modified / Deleted: [A] / [M] / [D]│
   └────────────────────────────────────────────┘
   ```

5. **Impact & Ripple Analysis**:

   For each **modified** or **deleted** file, analyze downstream impact:

   ### 5.1 Export/Import Tracing
   - Identify what the changed file **exports** (functions, types, components, constants)
   - Search the codebase for files that **import** from the changed file
   - Check if those consuming files need updates (e.g., renamed export, changed function signature, removed export)

   ### 5.2 Plan Coverage Check
   - Compare actual changes against plan.md's file structure section
   - Flag files that plan.md says should be changed but are **missing from diff**
   - Flag files changed that are **not mentioned in plan.md** (unexpected changes)

   ### 5.3 Type/Interface Propagation
   - If type definitions or interfaces were modified, trace all files using those types
   - Check if type changes are reflected everywhere they're consumed

   ### 5.4 Route/API Consistency
   - If API routes changed, check if corresponding client-side calls are updated
   - If data models changed, check if API endpoints and UI forms reflect the changes

   Output an **Impact Report** (only if issues found):
   ```text
   ⚠️ Potential Ripple Effects:
   - [file] exports `functionName` which is imported by [N files] — verify compatibility
   - [file] was planned in plan.md but has no changes in diff
   - Type `TypeName` was modified but [file] still uses the old shape
   ```

6. **Review across dimensions** (focus on changed code from step 4, use impact analysis from step 5):

   ### 6.1 Spec Compliance
   - Does the implementation cover all user stories in spec.md?
   - Are there features implemented that weren't specified (scope creep)?
   - Are there specified features that are missing or incomplete?

   ### 6.2 Plan Adherence
   - Does the file/directory structure match plan.md?
   - Are the specified technologies and patterns used correctly?
   - Are data models consistent with data-model.md?
   - Do API implementations match contracts/?

   ### 6.3 Code Quality
   - Naming consistency (variables, functions, files, CSS classes)
   - Error handling coverage (are errors caught and handled gracefully?)
   - Code duplication (significant repeated patterns that should be extracted)
   - Type safety (proper TypeScript usage, no `any` abuse)

   ### 6.4 Security
   - Input validation on API routes and forms
   - Authentication/authorization checks where required
   - SQL injection prevention (parameterized queries only)
   - Sensitive data exposure (no secrets in code, proper env var usage)
   - XSS prevention (proper output encoding)

   ### 6.5 Consistency
   - Coding style consistency across all new files
   - Consistent patterns for similar operations (e.g., all API routes follow same structure)
   - Import organization and module boundaries
   - CSS/styling approach consistency

   ### 6.6 Constitution Alignment (if constitution.md exists)
   - Check implementation against project principles
   - Flag any violations of declared standards

7. **Generate review report**:

   ```text
   ┌─────────────────────────────────────────────────────┐
   │          Code Review: [Feature Name]                 │
   ├─────────────────────────────────────────────────────┤
   │ Files Reviewed:    [N files]                         │
   │ Tasks Covered:     [X/Y tasks]                       │
   ├─────────────────────────────────────────────────────┤
   │ Findings:                                            │
   │   🔴 CRITICAL:  [N]                                  │
   │   🟠 HIGH:      [N]                                  │
   │   🟡 MEDIUM:    [N]                                  │
   │   🔵 LOW:       [N]                                  │
   ├─────────────────────────────────────────────────────┤
   │ Verdict: [PASS / PASS WITH WARNINGS / NEEDS FIXES]  │
   └─────────────────────────────────────────────────────┘
   ```

8. **Detail findings** (grouped by severity):

   For each finding:
   ```
   ### [SEVERITY] [SHORT_TITLE]
   - **File**: path/to/file.ext (lines X-Y)
   - **Dimension**: [Spec Compliance | Code Quality | Security | ...]
   - **Issue**: Clear description of the problem
   - **Suggestion**: Concrete fix recommendation
   ```

   **Severity definitions**:
   - **CRITICAL**: Security vulnerabilities, data loss risks, spec violations that break core functionality
   - **HIGH**: Missing error handling, significant spec deviations, broken patterns
   - **MEDIUM**: Code quality issues, minor inconsistencies, missing edge cases
   - **LOW**: Style nits, naming suggestions, minor improvements

9. **Verdict logic**:
   - **PASS**: 0 CRITICAL, 0 HIGH findings
   - **PASS WITH WARNINGS**: 0 CRITICAL, but has HIGH or MEDIUM findings
   - **NEEDS FIXES**: Has CRITICAL findings

10. **Offer handoff**:
   - If NEEDS FIXES: "Fix critical issues first → `/speckit.implement`"
   - If PASS or PASS WITH WARNINGS: "Ready to archive → `/speckit.summarize`"

## Quality Rules

1. **Be specific**: Every finding must reference an exact file and line range. No vague "improve error handling somewhere".
2. **Be actionable**: Every finding must include a concrete suggestion. Not "this could be better" but "extract this into a shared utility at lib/utils/X.ts".
3. **No false positives**: Only flag genuine issues. Don't nitpick formatting if the project uses a formatter.
4. **Respect project conventions**: Review against the project's own standards (constitution, plan), not abstract ideals.
5. **Proportional depth**: Spend more review effort on security-critical code (auth, payments, data access) than on UI polish.
6. **Max 30 findings**: If more issues exist, prioritize by severity and consolidate related items.
7. **Read actual code**: Don't just check file existence — read implementations, verify logic, trace data flows.
