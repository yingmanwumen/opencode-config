---
description: Review, commit, and push changes
---

Review all tracked and untracked changes with git.

Flag an issue only when all of these are true:

- It affects correctness, security, performance, or maintainability in a meaningful way.
- It is discrete and actionable.
- It was introduced by the reviewed change.
- The affected scenario or call path can be demonstrated from the code.
- The author would probably fix it if they knew about it.

Do not invent a finding to fill the result. If issues are found, collect them into a list and then report it, ask the user how to proceed, and stop. After that, continue or restart this review routine.

For issues, you should provide the root cause and the reasonable error propagation path. If you're not able to show how error may occur and propagate, it means this is not an issue and should be ignored.

If clean, split unrelated changes into atomic commits, and then state the changes and intentions by atomic group. After stating, ask the user question by invoking `question` tool instead of pure text for confirmation:
- single commit
- atomic commits

Skip confirmation if all changes belong to one logical group. Then commit each with a concise English Conventional Commit message and push to its upstream branch.
