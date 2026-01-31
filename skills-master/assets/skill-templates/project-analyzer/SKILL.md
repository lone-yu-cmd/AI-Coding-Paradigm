---
name: "project-analyzer"
description: "Scans project structure to infer technology stack and architecture, then generates AI-optimized Context-First documentation. Invoke when initializing a new project or refreshing docs."
---

# Project Analyzer

## PURPOSE
Bootstraps **Context-First Architecture** for any project by analyzing structure and generating AI-optimized documentation.

## WHEN_TO_USE
- Onboarding a new project
- Initializing `docs/AI_CONTEXT/` structure
- Project structure changes significantly

## INSTRUCTIONS

### Step 1: Run Analysis
```bash
python3 skills/project-analyzer/scripts/analyze.py
```

### Step 2: Review & Refine
- OUTPUT_FILES:
  - `docs/AI_CONTEXT/ARCHITECTURE.md` → Project structure and tech stack
  - `docs/AI_CONTEXT/CONSTITUTION.md` → Coding rules and constraints
- MUST: Replace all `(placeholder)` markers with actual project details
- MUST: Verify generated content matches current codebase state

### Step 3: Integrate
- Other skills (e.g., `context-aware-coding`) auto-read these files as source of truth

## OUTPUT_FORMAT_RULES
Generated docs follow AI-optimized format specification:
- MUST: Use `MUST/NEVER/PREFER` semantic keywords for rules
- MUST: Use `PATH → PURPOSE` mapping for directory structures
- MUST: Use numbered steps for flows, not ASCII diagrams
- NEVER: Use ASCII art, tree diagrams, or visual decorations
- REFER: `assets/AI_DOCUMENT_SPECIFICATION.md` for complete format guide
