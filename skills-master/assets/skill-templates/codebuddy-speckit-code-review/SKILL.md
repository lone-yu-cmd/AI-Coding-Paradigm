---
name: codebuddy-speckit-code-review
description: Adds a `speckit.codereview` command to the Speckit pipeline for automated code review after implementation. Reviews code against the feature spec, plan, and best practices. Sits between implement and summarize in the pipeline. Trigger keywords include speckit, review, code review, CR.
---

# Codebuddy Speckit Code Review

## Overview

This skill extends the Speckit pipeline with an automated **Code Review** step. After `speckit.implement` completes all tasks, `/speckit.codereview` reviews the implemented code against the feature spec, plan, and coding standards — catching issues before the feature is archived via `/speckit.summarize`.

## Pipeline Position

```
speckit.implement → speckit.codereview (NEW) → speckit.summarize
```

## What This Skill Provides

### 1. New Command: `speckit.codereview`

Install `assets/speckit.codereview.md` to `.codebuddy/commands/speckit.codereview.md`.

Runs after `speckit.implement` completes:
- Reads spec.md, plan.md, tasks.md, and all design documents for review context
- Scans implemented code files referenced in tasks.md
- Reviews against multiple dimensions: spec compliance, code quality, security, consistency
- Outputs a structured review report with actionable findings
- Categorizes issues by severity (CRITICAL / HIGH / MEDIUM / LOW)

### 2. Project Rule: `speckit-code-review`

Install `assets/speckit-code-review-rule.md` to `.codebuddy/rules/speckit-code-review.md`.

This always-apply rule injects code review awareness into the Speckit pipeline **without modifying original command files**:
- `speckit.implement`: After completion, suggest running `/speckit.codereview` before summarize
- `speckit.summarize`: Warn if `/speckit.codereview` hasn't been run for the current feature

## Installation

To install this skill into a project that uses Speckit:

1. Copy `assets/speckit.codereview.md` → `.codebuddy/commands/speckit.codereview.md`
2. Copy `assets/speckit-code-review-rule.md` → `.codebuddy/rules/speckit-code-review.md`

## Uninstallation

Remove these two files to cleanly uninstall:
- `.codebuddy/commands/speckit.codereview.md`
- `.codebuddy/rules/speckit-code-review.md`

No Speckit original command files are modified, so no restoration is needed.
