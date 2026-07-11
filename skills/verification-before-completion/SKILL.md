---
name: verification-before-completion
description: Enforces fresh, claim-specific evidence before declaring a workspace change, implementation, configuration, build, test result, or artifact/deliverable ready. Use for engineering completion claims.
---

# Verification Before Completion

## Overview

Completion is a claim that must be supported by new evidence, not confidence.
For every meaningful claim, choose a check that could disprove it, run that
check in the current state, inspect its exit code and important output, and
report failures or limits plainly.

## When to Use

- Before saying a workspace change, bug fix, feature implementation, or test
  result is complete
- Before handing off an engineering change, opening a review, or declaring a
  build, artifact, or deliverable ready
- After editing configuration, versions, generated output, or deployment inputs
- When the task has multiple acceptance criteria or non-obvious side effects

## When Not to Use

Do not skip this gate for small engineering changes. Scale it down when the
claim is strictly limited: an exact file-content inspection can verify a typo
fix without a test command. In every case, perform the chosen check after the
final relevant edit. This skill does not schedule multi-stage work
(`deepwork`), run callbacks or execution loops (`loop-engineering`), or define
release-package smoke procedures (`release-smoke-test`).

## Claim-to-Evidence Method

1. List the requested outcomes as separate claims, using the user's wording.
2. For each claim, select the narrowest meaningful command or inspection that
   can fail if the claim is false.
3. Perform it after the final relevant edit; do not rely on an earlier run.
4. When the check uses a command, read its process exit code and key output,
   not just the command name.
5. Match the evidence to the claim and mark anything unverified or partial.

Use a table when useful:

| Claim | Fresh check | Result | Evidence / limitation |
|---|---|---|---|
| behavior works | focused test or scenario | pass/fail | relevant output |
| build is valid | build/typecheck command | pass/fail | exit code and summary |
| requirement is met | checklist or targeted inspection | yes/no | file or output |

## Select Verification by Risk

Start narrow, then widen according to blast radius:

- Text or documentation: inspect exact content, links/examples, and docs build
  when available.
- Pure configuration: parse/schema-check it, then verify the effective setting
  is loaded by the intended runtime or tool.
- Local behavior: run focused tests, then related tests and type/build checks.
- Public or integration behavior: run the integration/contract scenario and
  inspect externally visible output, errors, and side effects.
- High-risk changes: add the repository's broader suite, static checks, and a
  safe representative smoke scenario.

Do not run a broad suite as a substitute for a focused check that directly
proves the changed behavior.

## Verify Actual Effect

Presence is not activation. When changing configuration, versions, dependencies,
generated files, permissions, or artifacts:

- Confirm the parser accepts the exact file that will be loaded.
- Confirm precedence, environment selection, and effective values.
- Confirm the installed/resolved version rather than only the manifest text.
- Confirm generated output is current and consumed by the target command.
- Confirm the artifact contains the intended files and metadata when relevant.

For command-based checks, capture enough output to distinguish a real pass from
a skipped test, cached result, warning-only path, or empty test selection.

## Requirements Review

Before reporting completion, revisit every requirement:

- Match each requested file, behavior, constraint, and exception to evidence.
- Check names, paths, interfaces, and user-visible wording exactly where called
  out.
- Check scope: no unrelated files or formatting were changed.
- Check negative requirements only within the specified interface, changed
  paths, and relevant search/test scope; report what remains unobservable.
- Identify assumptions and remaining unverified environments or scopes.

Diff inspection is useful for scope and review, but a diff alone cannot prove
runtime behavior. Agent self-report, “looks right,” and lint alone are not
completion evidence.

## Honest Failure Reporting

If a check fails, investigate or report the failure; do not convert it into a
pass by hiding output, ignoring the exit code, weakening the assertion, or
claiming an unrelated check covers it. If a check cannot run, say why and state
what remains unverified. Distinguish:

- **Passed**: the intended check completed successfully with supporting output.
- **Failed**: the check ran and disproved the claim.
- **Not run**: no fresh evidence was collected.
- **Partial**: only a narrower or indirect check succeeded.

## Completion Checklist

- [ ] Every requested outcome is written as a separate claim
- [ ] Each claim has a fresh, proportionate check
- [ ] Checks were performed after the final relevant change
- [ ] For command-based checks, exit codes and key output were inspected
- [ ] Actual configuration/version/artifact effect was verified where relevant
- [ ] Focused checks and appropriate broader checks passed
- [ ] Scope and bounded negative requirements were reviewed, with unobservable scope reported
- [ ] Failures, skips, limitations, and uncertainty are reported accurately

The final report should name the checks performed and avoid stronger language
than the evidence supports.
