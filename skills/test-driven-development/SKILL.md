---
name: test-driven-development
description: Guides implementation with a deliberate RED, GREEN, REFACTOR cycle. Use when adding or changing behavior that has a stable, automatable oracle and tests can express the intended contract.
---

# Test-Driven Development

## Overview

Use tests to make the intended behavior observable before implementation details
start to drift. Work in a small loop: make the requirement fail, make it pass
with the smallest useful change, then improve the design while keeping the
contract protected.

## When to Use

- Adding a feature, bug fix, validation rule, or externally visible behavior
- Changing a public API or a boundary with clear inputs and outputs
- Reproducing a regression that can be captured by a deterministic test
- Refactoring behavior where an existing test suite can act as a safety net

## When Not to Use

TDD is not mandatory when there is no stable oracle or a test would only encode
noise. Valid exceptions include:

- Documentation-only edits: verify rendered links, examples, or the relevant
  documentation build instead.
- Pure configuration changes: validate schema, parsing, and effective runtime
  settings rather than inventing unit tests.
- Exploration or disposable prototypes: record the experiment and run the
  smallest useful manual or comparative check before deciding what to keep.
- Interactive work with no stable oracle: use a repeatable scenario, captured
  output, screenshot, or explicit manual checklist, and state the limitation.

Do not use an exception merely because writing the test is inconvenient. If a
small deterministic seam can be created without distorting the design, prefer
the test.

Pure behavior-preserving refactoring is a separate case. First establish or
confirm a trustworthy test baseline, then refactor and run the relevant tests
after each meaningful step. Do not manufacture a failing test just to create a
RED phase when the behavior and contract are intentionally unchanged.

## The RED → GREEN → REFACTOR Loop

### 1. RED: State and Observe the Failure (When Behavior Changes)

1. Read nearby tests and project conventions before choosing a test location.
2. Write one focused test for one behavior, including the important boundary
   case or failure mode.
3. Run that exact test (or the narrowest available command).
4. Confirm it fails for the expected reason: a missing behavior, not a syntax,
   fixture, import, or environment error.

For new behavior, behavior changes, and regression fixes, if RED cannot be
observed, stop and fix the test setup or explain why the oracle is unavailable.
A test that has never failed has not demonstrated that it protects the
requested behavior. This requirement does not apply to pure refactoring;
there, the confirmed baseline and post-refactor comparison are the evidence.

### 2. GREEN: Make the Smallest Useful Change

- Implement only enough behavior to satisfy the new contract.
- Prefer the existing abstractions and public seams over test-only shortcuts.
- Avoid speculative options, unrelated cleanup, and broad rewrites.
- Run the focused test after the change, then run related tests to catch local
  integration mistakes.

GREEN means the intended test passes and the result is not merely a weakened
  assertion, an over-broad mock, or a bypass around production behavior.

### 3. REFACTOR: Improve Without Changing the Contract

Refactor only after GREEN. Remove duplication, clarify names, and align the
implementation with local conventions. Keep each refactor small enough that a
failure identifies the change that caused it. Re-run the focused test and all
relevant tests after refactoring.

The `simplify` skill is the appropriate companion when the goal is behavior-
preserving clarity reduction. For that case, it complements the baseline and
post-refactor tests rather than requiring a new RED failure.

## Test Quality Checks

- Assert outcomes at the public boundary, not private implementation trivia.
- Keep fixtures minimal and names descriptive of the behavior under test.
- Control time, randomness, network, filesystem, and other nondeterminism.
- Include meaningful invalid, empty, boundary, and repeated-use cases where
  they are part of the contract.
- Keep mocks narrow; verify real integration at the appropriate test layer.

## Anti-Patterns

- Writing the implementation first and calling the first passing test “RED”
- Making the assertion less precise until an incorrect implementation passes
- Adding multiple unrelated behaviors before running the loop
- Refactoring during RED or GREEN and losing causal feedback
- Testing private details that prevent valid implementation changes
- Treating a green test as proof that untested requirements are complete

## Output and Verification Checklist

- [ ] The behavior and oracle are stated in plain language
- [ ] A focused test was added or identified, or a trustworthy baseline was confirmed for pure refactoring
- [ ] For new behavior, behavior changes, or regression fixes, RED was actually run and failed for the expected reason
- [ ] GREEN uses the smallest production change that satisfies the contract
- [ ] Focused and related tests pass after implementation or refactoring
- [ ] Pure refactoring began from a confirmed baseline and was followed by the same relevant tests
- [ ] Any exception to TDD has a recorded alternative verification method

Keep this skill focused on the implementation loop. Do not duplicate a general
completion gate or a scheduling workflow from `deepwork` or `loop-engineering`.
