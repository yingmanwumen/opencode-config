---
name: systematic-debugging
description: Drives evidence-based diagnosis from reproduction to root-cause repair and regression proof. Use when behavior is failing, errors are unclear, or a fix must be distinguished from a symptom patch.
---

# Systematic Debugging

## Overview

Debugging is an investigation, not a sequence of guesses. Preserve evidence,
reduce the problem, test one hypothesis at a time, and repair the cause at the
lowest sensible boundary. Keep the runtime execution loop owned by
`loop-engineering`; this skill governs diagnosis and repair, not orchestration.

## When to Use

- A test, build, command, or production path fails unexpectedly
- A regression appeared after a code, dependency, configuration, or data change
- Failures are intermittent, environment-specific, or difficult to localize
- A proposed fix needs proof that it addresses the cause rather than the symptom

## When Not to Use

- There is no failure or suspicious behavior to investigate; use normal delivery
- The task is a behavior change with a known contract; use
  `test-driven-development` as appropriate
- The work is only behavior-preserving cleanup; use `simplify`
- A release artifact needs package-level smoke testing; use `release-smoke-test`

## Evidence-First Workflow

### 1. Read the Whole Failure

Capture enough of the complete error, stack trace, command, exit code,
timestamps, and relevant environment to support the diagnosis. Redact secrets,
credentials, personal data, customer payloads, and internal protected values.
If raw sensitive output is needed, reference its secure storage location and
access controls; do not paste it into the debugging record. Read surrounding
output rather than reacting to the last line, and separate observed fact from
interpretation.

### 2. Reproduce Reliably

Run the smallest repeatable reproduction. Record inputs, starting state,
frequency, expected result, and actual result. If it is intermittent, collect
enough runs to characterize the rate and preserve a failing sample.

### 3. Isolate the Fault Boundary

Narrow the path by comparing a known-good case with a failing case. Trace data
from input through validation, transformation, storage, side effects, and
output. Check both sides of each boundary: types, defaults, encoding, ordering,
nullability, retries, and error propagation.

### 4. Check Recent Changes and Edge Data

Inspect recent commits, dependency/configuration changes, feature flags, and
environment drift. Compare the first known good revision with the first bad
one when possible. Exercise empty, maximum, malformed, duplicate, delayed,
and reordered data where those cases are plausible.

### 5. State One Falsifiable Hypothesis

Write one sentence in the form: “Because **cause**, **condition** produces
**observed effect**.” Name the evidence supporting it and the observation that
would disprove it. Do not combine several possible causes into one vague theory.

### 6. Run the Smallest Experiment

Change or instrument only what distinguishes the hypothesis. Prefer a targeted
test, assertion, trace, fixture, or controlled comparison over a new log. Any
diagnostic instrumentation must be temporary or clearly removable, redact
sensitive values, and avoid high-frequency sensitive logging in production.
Change one variable at a time and preserve a sanitized experiment output. If it
fails to support the hypothesis, discard it and form the next one; do not
silently expand it.

### 7. Fix the Root Cause

Repair the earliest controllable and responsibility-correct boundary, while
preserving valid behavior and error semantics. Keep the patch minimal. Add a
regression test when a stable oracle exists; do not hide the failure with a
broader catch, retry, timeout, filter, or mock unless that is the actual
contract.

### 8. Verify the Regression and Neighboring Paths

Re-run the original reproduction, the new regression test, and relevant nearby
tests. Check the original failure is gone, the expected behavior is restored,
and no boundary or error path regressed. Record commands and their outcomes.

## Production Incident Exception

During an active incident, first reduce user harm: rollback, disable a feature,
rate-limit, isolate bad traffic, or apply another reversible mitigation. Record
the mitigation and its scope. Then return to reproduction, evidence, root-cause
repair, and regression validation. A mitigation is not proof that the defect is
fixed; follow-up ownership and verification must remain explicit.

## Debugging Record Template

```text
Symptom:
Impact / scope:
First known good / first known bad:
Reproduction command or scenario:
Expected:
Actual:
Complete sanitized evidence (error, exit code, relevant output):
Secure raw evidence reference (if any; never paste sensitive values):
Boundary where behavior diverges:
Recent changes / environment differences:
Edge data considered:
Hypothesis (one sentence):
Discriminating experiment:
Result and interpretation:
Root cause:
Minimal fix:
Regression and neighboring checks:
Remaining uncertainty / follow-up:
```

## Anti-Patterns

- Randomly changing several files and keeping the first green result
- Reading only the final error line or ignoring exit codes
- Fixing a symptom with suppression, retries, or weakened assertions
- Assuming the most recent change is guilty without a comparison
- Treating correlation as causation or an unreplicated manual observation as proof
- Applying endless patches without updating the hypothesis

## Exit Checklist

- [ ] The failure is reproduced or the limitation is recorded
- [ ] Evidence is sufficient, sanitized, and includes exit status; sensitive raw evidence is referenced securely
- [ ] One hypothesis was tested by one minimal experiment
- [ ] Root cause is distinguished from symptom
- [ ] The fix is minimal and regression coverage exists where practical
- [ ] Original, focused, and neighboring checks pass
- [ ] Incident mitigations, uncertainty, and follow-up are recorded
