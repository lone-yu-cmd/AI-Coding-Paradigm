---
description: Injects Feature Registry awareness into Speckit pipeline commands. Ensures specify, plan, and implement commands consult specs/REGISTRY.md.
globs: "**/*.md"
alwaysApply: true
---

# Speckit Feature Registry Integration

## When executing `speckit.specify`

Before generating a new feature specification, read `specs/REGISTRY.md` (if it exists) to understand all existing features. Use this context to:
- Avoid duplicating or conflicting with existing routes, API endpoints, and data tables
- Identify reusable components, routes, and data models
- Ensure the new feature integrates coherently with the existing system
- Reference existing features when defining scope boundaries

## When executing `speckit.plan`

When loading context in step 2, also read `specs/REGISTRY.md` (if it exists) alongside the feature spec and constitution. Use the registry to:
- Understand existing routes, API endpoints, and data tables to avoid conflicts
- Identify reusable components and shared infrastructure
- Plan integration points with existing features
- Ensure data model consistency with established tables

## When executing `speckit.implement`

After all tasks are completed, remind the user to run `/speckit.summarize` to archive the feature into the Feature Registry.
