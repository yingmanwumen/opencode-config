# Address Pull Request Review Comments

Use this workflow for requested changes, review comments, or unresolved feedback.

1. Identify the repository and PR with `gh pr view` or `gh pr list`; resolve the current branch first when the PR is implicit.
2. Confirm `gh auth status` and read the PR description, changed files, review comments, and current checks.
3. Use `gh api graphql` when thread-level state matters; inspect `reviewThreads`, `isResolved`, `isOutdated`, file, and line anchors. Do not treat flat comments as a complete thread view.
4. Separate actionable requests from questions, suggestions, approvals, already-resolved threads, outdated comments, and duplicates.
5. If the user did not explicitly request all fixes, present numbered actionable threads and ask which to address. If the user did request all, call out ambiguous or conflicting threads.
6. Implement only the selected, in-scope changes and add or update tests.
7. Run relevant checks and inspect the diff before committing and pushing fixes.
8. Reply to comments or resolve threads only when the user explicitly requests those GitHub write actions; otherwise summarize suggested replies.

Do not mark comments resolved without addressing them. Ask the user when feedback conflicts, is ambiguous, or requires a broader design change. Summarize addressed and intentionally open threads and the validation performed.
