---
name: debate
description: Start an adversarial debate to stress-test and harden a plan, proposal, or review through iterative attack-defense cycles
---

Load the `adversarial-debate` skill. If the skill fails to load, inform the user
and stop — do not attempt an ad-hoc debate.

Execute the adversarial debate workflow for the user's request. The skill defines
five phases:

1. **Phase 0 — Suitability Check**: Confirm the request is a concrete, bounded,
   high-stakes proposal. If unsuitable, tell the user why and suggest alternatives
   (e.g., standard @oracle review).
2. **Phase 1 — Initialize**: Derive a slug following the skill's validation rules,
   check for existing ledgers and proposal files, spawn @oracle as Proposer to
   create the initial draft, persist the proposal to
   `.opencode/debate-proposal-{slug}.md`, and initialize the Issue Ledger at
   `.opencode/debate-ledger-{slug}.md`.
3. **Phase 2 — Debate Loop**: Iterative rounds of Adversary (@oracle) attacks
   from a selected lens → Arbiter (@oracle) independently verifies → Proposer
   (@oracle) revises. The loop terminates on convergence, deadlock, or exhaustion.
   Deadlock triggers a sub-cycle (Proposer final chance → Deadlock Arbiter re-check)
   before termination; see the skill for the complete protocol.
4. **Phase 3 — Resolution**: Present a final report with the hardened proposal,
   attack resolution summary, statistics, and unresolved weaknesses.

Track all state in `.opencode/debate-ledger-{slug}.md`. The current proposal is
persisted to `.opencode/debate-proposal-{slug}.md` for crash-safe recovery — on
resume the orchestrator reads the proposal from this file rather than relying on
in-memory state. The ledger includes an explicit `phase_step` field for
crash-safe resume within a round and an `oscillation` field for deadlock detection
across rounds. Inform the user that a full 4-round debate requires approximately
12 sequential @oracle calls (more if format retries, oracle failures, or deadlock
sub-cycles occur). Warn the Proposer not to use the reserved section headers
`## Verdict`, `## Coverage`, `## Attacks`, or `## Revision Log` in the proposal body.

Refer to the `adversarial-debate` skill for the complete protocol specification,
agent prompt templates, lens pool, error handling, and convergence rules.
