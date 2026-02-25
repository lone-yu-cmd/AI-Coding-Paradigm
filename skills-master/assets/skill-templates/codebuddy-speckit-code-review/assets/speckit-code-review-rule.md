---
description: Injects Code Review awareness into the Speckit pipeline. Ensures implement suggests review, and summarize checks for review completion.
globs: "**/*.md"
alwaysApply: true
---

# Speckit Code Review Integration

## When executing `speckit.implement`

After all tasks are completed, remind the user to run `/speckit.codereview` to review the implementation before archiving:
- "Implementation complete. Run `/speckit.codereview` to review the code before archiving with `/speckit.summarize`."

## When executing `speckit.summarize`

Before generating the feature summary, check if a code review has been performed:
- If the user has not mentioned running `/speckit.codereview` in the current conversation, **WARN**: "No code review detected for this feature. Consider running `/speckit.codereview` first. Continue with summarize anyway? (yes/no)"
- If the user confirms or has already run the review, proceed normally.
