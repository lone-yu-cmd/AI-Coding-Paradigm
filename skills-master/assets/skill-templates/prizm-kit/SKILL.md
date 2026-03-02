---
name: "prizm-kit"
description: "Full-lifecycle dev toolkit. Covers spec-driven development, Prizm context docs, code quality, debugging, deployment, and knowledge management. Use 'prizmkit.*' for help. (project)"
---

# PrizmKit — Full-Lifecycle Development Toolkit

PrizmKit is a comprehensive, independent AI development toolkit that covers the complete development lifecycle from project inception to delivery and maintenance. It can take over any project and keep documentation in sync with code.

## Quick Start

```
prizmkit.init          # Take over a project (scan, assess, generate docs)
prizmkit.specify       # Create feature specification
prizmkit.plan          # Generate implementation plan
prizmkit.tasks         # Break down into executable tasks
prizmkit.analyze       # Cross-document consistency check (recommended)
prizmkit.implement     # Execute implementation
prizmkit.commit        # Commit with auto doc update
```

## When to Use the Full Workflow

**Use full workflow (specify -> plan -> tasks -> implement):**
- New features or user-facing capabilities
- Multi-file coordinated changes
- Architectural decisions
- Data model or API changes

**Use fast path (implement -> commit directly):**
- Bug fixes with clear root cause
- Single-file config or typo fixes
- Simple refactors (rename, extract)
- Documentation-only changes
- Test additions for existing code

For fast-path changes, you can directly use `prizmkit.implement` with inline task description, then `prizmkit.commit`.

## Architecture

PrizmKit produces two complementary knowledge layers:

```
.prizm-docs/           → Project "what is" (static: structure, interfaces, rules, traps, decisions)
.prizmkit/specs/       → Feature "what to do" (workflow: spec → plan → tasks → code)
```

## Skill Inventory (26 skills)

### Foundation
- **prizmkit-init** — Project takeover: scan → assess → generate docs → initialize

### Documentation
- **prizmkit-prizm-docs** — Prizm documentation framework: `prizmkit.doc.init`, `prizmkit.doc.update`, `prizmkit.doc.status`, `prizmkit.doc.rebuild`, `prizmkit.doc.validate`, `prizmkit.doc.migrate`

### Spec-Driven Workflow
- **prizmkit-specify** — Create structured feature specifications from natural language
- **prizmkit-clarify** — Interactive requirement clarification
- **prizmkit-plan** — Generate technical plan + data model + API contracts
- **prizmkit-tasks** — Break plan into executable task list
- **prizmkit-analyze** — Cross-document consistency analysis (spec ↔ plan ↔ tasks)
- **prizmkit-implement** — Execute tasks following TDD approach
- **prizmkit-code-review** — Review code against spec and plan
- **prizmkit-summarize** — Archive completed features to REGISTRY.md

### Commit & Retrospective
- **prizmkit-committer** — Commit workflow with automatic Prizm doc update
- **prizmkit-retrospective** — Post-feature learning: extract lessons → update Prizm docs

### Quality Assurance
- **prizmkit-tech-debt-tracker** — [Tier 1] Technical debt identification and tracking via code pattern analysis
- **prizmkit-security-audit** — [Tier 2] AI-assisted security review checklist via static analysis
- **prizmkit-dependency-health** — [Tier 2] Dependency review based on manifest files

### Operations & Deployment
- **prizmkit-ci-cd-generator** — [Tier 2] Generate CI/CD pipeline config templates
- **prizmkit-deployment-strategy** — [Tier 2] Deployment planning with rollback procedures
- **prizmkit-db-migration** — [Tier 2] Database migration script generation
- **prizmkit-monitoring-setup** — [Tier 2] Generate monitoring config templates

### Debugging & Troubleshooting
- **prizmkit-bug-reproducer** — [Tier 1] Generate minimal reproduction scripts and test cases
- **prizmkit-error-triage** — [Tier 2] Error categorization and root cause analysis
- **prizmkit-log-analyzer** — [Tier 2] Log pattern recognition via text analysis
- **prizmkit-perf-profiler** — [Tier 2] Static analysis for performance issues

### Knowledge Management
- **prizmkit-adr-manager** — [Tier 1] Architecture Decision Records management
- **prizmkit-onboarding-generator** — [Tier 2] Generate developer onboarding guides
- **prizmkit-api-doc-generator** — [Tier 2] Extract API documentation from source code

### Tier Definitions

- **Tier 1**: AI can perform well independently — these tasks align with AI's core strengths (documentation, code pattern analysis, test generation)
- **Tier 2**: Useful as guidance/checklist — AI provides static analysis and recommendations, but lacks access to real external tools (scanners, profilers, package registries, runtime environments)
- **Core skills** (no tier label): The 12 foundational, documentation, spec-driven workflow, and commit skills that form PrizmKit's primary value

## Installation

Install PrizmKit to your project:
```bash
python3 ${SKILL_DIR}/scripts/install-prizmkit.py --target <project-skills-dir>
```

Or install individual skills:
```bash
python3 ${SKILL_DIR}/scripts/install-prizmkit.py --skill prizmkit-init --target <project-skills-dir>
```

## Hook Configuration

PrizmKit uses CodeBuddy's native `type: prompt` hooks for automatic doc updates before commits.
The hook is configured automatically by `prizmkit-init`. See `assets/hooks/prizm-commit-hook.json` for the template.
