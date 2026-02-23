---
description: Bootstrap specs/REGISTRY.md by scanning the existing codebase. Use this when adopting Speckit on a project that already has code.
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

## Purpose

Bootstrap `specs/REGISTRY.md` for an existing project that is adopting Speckit for the first time. Scans the codebase and generates an initial `000 - Existing System` entry capturing all existing routes, API endpoints, data tables, and key directories.

## Steps

1. **Guard check**:
   - Read `specs/REGISTRY.md`. If it already contains entries between `<!-- FEATURES START -->` and `<!-- FEATURES END -->`, **STOP** and tell the user: "REGISTRY.md already has entries. Use `/speckit.summarize` to add new features, or delete existing entries first if you want to re-initialize."

2. **Scan the codebase** to understand what already exists:

   **Routes**: Scan `app/` directory structure for `page.tsx` and `route.ts` files. Map directory paths to URL routes (respect Next.js Route Groups — parenthesized dirs don't appear in URL).

   **API Endpoints**: Scan `app/api/` for `route.ts` files. Read each to identify exported HTTP methods (GET, POST, PUT, DELETE, PATCH).

   **Data Tables**: Scan `supabase/migrations/` (or equivalent migration directory) for CREATE TABLE statements. Extract table names.

   **Key Directories**: Identify top-level functional directories (components/, lib/, app/ subdirectories, etc.) and their purposes.

   **Tech Stack**: Read `package.json` (dependencies), `tsconfig.json`, `next.config.*`, etc. to identify the technology stack.

3. **Generate a single `000 - Existing System` entry**:

   ```markdown
   ## 000 - Existing System [completed]

   - **Summary**: [One sentence describing what the project does based on codebase scan]
   - **Routes**: [All discovered routes, comma-separated]
   - **API Endpoints**: [All discovered endpoints, e.g. GET/POST /api/ideas, ...]
   - **Data Tables**: [All discovered tables, comma-separated]
   - **Key Directories**: [Top-level directories, comma-separated]
   ```

   Field rules: only include fields with actual values, use directory-level granularity.

4. **Write to `specs/REGISTRY.md`**:
   - If file doesn't exist, create it from `.specify/templates/registry-template.md`
   - Insert the `000 - Existing System` entry between `<!-- FEATURES START -->` and `<!-- FEATURES END -->`

5. **Output summary report**:

   ```text
   ┌─────────────────────────────────────────────┐
   │     REGISTRY Initialized: Existing System    │
   ├─────────────────────────────────────────────┤
   │ Routes:        [N routes discovered]         │
   │ API Endpoints: [N endpoints discovered]      │
   │ Data Tables:   [N tables discovered]         │
   │ Key Dirs:      [N directories cataloged]     │
   ├─────────────────────────────────────────────┤
   │ Created: specs/REGISTRY.md                   │
   └─────────────────────────────────────────────┘
   ```

6. **Suggest next step**: "REGISTRY initialized. You can now use `/speckit.specify` to plan new features — it will reference this registry to avoid conflicts."

## Quality Rules

1. **Be comprehensive but concise**: Capture ALL routes and endpoints, but keep descriptions to one line each.
2. **Don't guess feature boundaries**: Everything goes into a single `000` entry. Feature separation happens organically as new features are added via `/speckit.summarize`.
3. **Respect Route Groups**: `app/(auth)/login/page.tsx` → route is `/login`, not `/(auth)/login`.
4. **Read actual code**: Don't just list file paths — read migration files for table names, read route.ts for HTTP methods.
5. **Directory-level granularity**: List `app/(dashboard)/` not every file inside it.
