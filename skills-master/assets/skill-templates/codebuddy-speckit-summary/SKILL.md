---
name: codebuddy-speckit-summary
description: Extends the Speckit pipeline with a Feature Registry system. This skill should be used when working with Speckit commands (speckit.specify, speckit.plan, speckit.implement) to maintain a centralized feature index. It adds a `speckit.summarize` command for archiving completed features and injects REGISTRY.md awareness into existing Speckit commands via a project rule. Trigger keywords include speckit, summarize, feature registry, REGISTRY.md.
---

# Codebuddy Speckit Summary

## Overview

This skill extends the Speckit specification pipeline with a **Feature Registry** system. It creates a knowledge loop: completed features are archived into `specs/REGISTRY.md`, and new features consult the registry to avoid conflicts and reuse existing components.

## What This Skill Provides

### 1. New Command: `speckit.summarize`

Install `assets/speckit.summarize.md` to `.codebuddy/commands/speckit.summarize.md`.

Runs after `speckit.implement` completes:
- Reads all spec design documents (spec.md, plan.md, data-model.md, contracts/, tasks.md)
- Extracts feature metadata (routes, API endpoints, data tables, key directories)
- Appends a structured entry to `specs/REGISTRY.md`
- Updates `CODEBUDDY.md` with a one-line feature summary

### 2. New Command: `speckit.summarize.init`

Install `assets/speckit.summarize.init.md` to `.codebuddy/commands/speckit.summarize.init.md`.

Bootstraps REGISTRY for existing projects adopting Speckit for the first time:
- Scans the entire codebase (routes, APIs, migrations, directories, package.json)
- Generates a single `000 - Existing System` entry capturing the current state
- Creates `specs/REGISTRY.md` from template if it doesn't exist
- Has guard check: refuses to run if REGISTRY already has entries

### 3. Registry Template

Install `assets/registry-template.md` to `.specify/templates/registry-template.md`.

The template defines the standard format for `specs/REGISTRY.md`, including entry structure and field rules.

### 4. Project Rule: `speckit-registry`

Install `assets/speckit-registry-rule.md` to `.codebuddy/rules/speckit-registry.md`.

This always-apply rule injects REGISTRY.md awareness into existing Speckit commands **without modifying their source files**:
- `speckit.specify`: Must read `specs/REGISTRY.md` before generating new specs
- `speckit.plan`: Must include `specs/REGISTRY.md` when loading context
- `speckit.implement`: Must suggest running `speckit.summarize` after completion

## Installation

To install this skill into a project that uses Speckit:

1. Copy `assets/speckit.summarize.md` → `.codebuddy/commands/speckit.summarize.md`
2. Copy `assets/speckit.summarize.init.md` → `.codebuddy/commands/speckit.summarize.init.md`
3. Copy `assets/registry-template.md` → `.specify/templates/registry-template.md`
4. Copy `assets/speckit-registry-rule.md` → `.codebuddy/rules/speckit-registry.md`
5. If `specs/REGISTRY.md` does not exist, create it from the template.
6. **For existing projects**: Run `/speckit.summarize.init` to scan the codebase and generate an initial `000 - Existing System` entry in the registry.

## Uninstallation

Remove these four files to cleanly uninstall:
- `.codebuddy/commands/speckit.summarize.md`
- `.codebuddy/commands/speckit.summarize.init.md`
- `.specify/templates/registry-template.md`
- `.codebuddy/rules/speckit-registry.md`

No Speckit original command files are modified, so no restoration is needed.
