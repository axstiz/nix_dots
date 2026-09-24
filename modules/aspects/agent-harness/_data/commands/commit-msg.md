---
description: Generate a commit message for staged changes
agent: plan
subtask: true
---

Generate a clear and concise commit message for the currently staged changes.

Instructions:

1. First, check the repository state with `git status`.
2. Inspect the staged changes using `git diff --cached`.
3. If there are no staged changes, clearly tell the user that nothing is staged and stop. Do not generate a commit message.
4. If staged changes exist, understand the intent and scope of the changes.
5. Write a commit message following conventional commits style.
6. Use the format: `<type>(<scope>): <description>`
   - Common types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`, `build`, `ci`.
   - Scope is optional but preferred when the change affects a specific module or area.
   - Description should be imperative and lowercase after the colon.
7. If the change is large or complex, add a body explaining the "why" and "what".
8. Do NOT commit the changes yourself.
9. Present the final message clearly so the user can copy and use it.

Example output:

```
feat(auth): add password reset endpoint

Adds a new POST /auth/reset-password endpoint that sends a reset
token via email. Includes input validation and rate limiting.
```

Start by showing a brief status summary, then the diff summary, then propose the message. If nothing is staged, clearly say so and stop.
