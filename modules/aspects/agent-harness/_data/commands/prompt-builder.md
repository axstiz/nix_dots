---
description: Refine an idea into a COSTAR or AUTOMATE prompt
mode: command
---

Use the `prompt-crafter` subagent to interview the user and produce a well-structured prompt.

Steps:

1. Ask the user what task or idea they want to turn into a prompt.
2. Use `question` to gather missing details: goal, audience, tone, constraints, output format, examples.
3. Let the user choose between COSTAR and AUTOMATE frameworks.
4. Generate the final prompt accordingly.
5. Present it in a code block and offer to refine or save it.

Never edit files unless the user explicitly asks.
