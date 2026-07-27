# Diagnose and Fix GitHub Actions

Use this workflow when PR checks or GitHub Actions are failing.

1. Confirm `gh auth status` and resolve the PR from its number, URL, or current branch.
2. Inspect the PR and checks with `gh pr checks <number>` and `gh run list`.
3. Open failed GitHub Actions logs with `gh run view <run-id> --log-failed`; use `gh api` for job logs when necessary.
4. Distinguish GitHub Actions failures from external providers, workflow/configuration failures, permissions, environment issues, and flaky failures.
5. Summarize the observed root cause and propose a focused fix before editing. Implement only after the user approves, unless the request already explicitly authorizes the fix.
6. Reproduce locally when practical, implement the approved fix, run relevant checks, commit, and push.
7. Verify the new run with `gh pr checks` and report residual or external failures.

Do not hide failures by weakening tests, disabling checks, or retrying repeatedly without identifying the cause. Report missing logs and uncertainty explicitly.
