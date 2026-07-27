# Publish a Pull Request

Use this workflow when the user asks to publish local changes, create a PR, or update an existing PR.

1. Check `gh --version`, `gh auth status`, `git status -sb`, the current branch, remotes, and the diff. Preserve unrelated user changes.
2. Confirm the intended scope. If the worktree is mixed, do not stage everything silently; ask which files belong in the PR.
3. If on the default branch and branch creation is needed, create a descriptive feature branch; otherwise stay on the current branch.
4. Run relevant tests or checks before publishing.
5. Stage only the confirmed files and commit intentionally.
6. Push with `git push -u origin <branch>`.
7. Create or update the PR with `gh pr create` or `gh pr edit`; default to a draft PR unless the user requests ready-for-review.

Use a concise title and a body covering what changed, why, impact, testing, and known limitations. Do not force-push or merge unless explicitly requested. Verify the resulting PR with `gh pr view` and `gh pr checks`.
