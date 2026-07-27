---
description: GitHub workflows using the gh CLI for repositories, issues, pull requests, code review, GitHub Actions, stacked PRs, branching, and repository automation. Use when a task requires inspecting or changing GitHub state.
license: MIT
metadata:
    author: Callstack
    github-path: skills/github
    github-ref: refs/heads/main
    github-repo: https://github.com/callstackincubator/agent-skills
    github-tree-sha: 34031971dfe21b86cbfbe9149df1520b0c656994
    tags: github, gh-cli, pull-request, stacked-pr, squash, rebase
name: github
---
# GitHub Workflows

## Tools

Use only the local `gh` CLI for GitHub operations and ordinary `git` commands for local repository state.

Before mutating remote state, inspect the repository, current branch, working tree, authentication, and relevant PR status. Ask before making an operation with material or irreversible impact when the user's request does not clearly authorize it.

For repository and issue triage, use `gh repo view`, `gh pr view/list`, and `gh issue view/list`. Resolve the repository from the current Git remote or an explicit user-provided owner/repo; do not guess an ambiguous target.

## Workflow routing

Read only the reference needed for the task:

| Task | Reference |
| --- | --- |
| Create, inspect, or publish a PR | [publish-pull-request.md](references/publish-pull-request.md) |
| Address review comments | [address-review-comments.md](references/address-review-comments.md) |
| Diagnose or fix failed GitHub Actions | [fix-github-actions.md](references/fix-github-actions.md) |
| Merge a stacked PR chain | [stacked-pr-workflow.md](references/stacked-pr-workflow.md) |

## Quick Commands

```bash
# Create a PR from the current branch
gh pr create --title "feat: add feature" --body "Description"

# Squash-merge a PR
gh pr merge <PR_NUMBER> --squash --title "feat: add feature (#<PR_NUMBER>)"

# View PR status and checks
gh pr status
gh pr checks <PR_NUMBER>
```

## Quick Reference

| File | Description |
| --- | --- |
| [publish-pull-request.md](references/publish-pull-request.md) | Inspect, commit, push, and create/update a PR |
| [address-review-comments.md](references/address-review-comments.md) | Inspect and address actionable review feedback |
| [fix-github-actions.md](references/fix-github-actions.md) | Inspect failed checks and implement approved fixes |
| [stacked-pr-workflow.md](references/stacked-pr-workflow.md) | Merge stacked PRs into main as individual squash commits |

## Problem -> Skill Mapping

| Problem | Start With |
| --- | --- |
| Merge stacked PRs cleanly | [stacked-pr-workflow.md](references/stacked-pr-workflow.md) |
