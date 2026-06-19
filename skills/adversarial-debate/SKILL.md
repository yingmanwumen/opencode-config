---
name: adversarial-debate
version: 6.5.0
description: >
  Adversarial debate workflow for hardening plans, reviews, and proposals through
  iterative attack-defense cycles with independent verification. Use when user wants
  to stress-test an idea, validate a plan, or find weaknesses through structured
  adversarial dialogue. Triggered by `/debate` command or when user asks to
  "stress-test", "adversarial review", or "debate this plan".
---

# Adversarial Debate Skill

## Glossary

- **@oracle**: Built-in OpenCode agent for architecture, review, debugging. Used here
  as Proposer, Adversary, and Arbiter via standard task delegation.
- **Issue Ledger**: The append-only structured record of all attacks, stored at
  `.opencode/debate-ledger-{slug}.md`. It is the single source of truth for debate
  state, including the current `phase_step` for crash-safe resume, the
  `oscillation` field for deadlock detection, and the `adversary_verdict`,
  `arbiter_verdict`, and `arbiter_thoroughness` fields for crash-safe re-evaluation
  of the decision tree.
- **Proposal File**: The current proposal persisted to disk at
  `.opencode/debate-proposal-{slug}.md`. Created in Phase 1c and overwritten with every
  Proposer revision. Enables crash-safe resume: a fresh orchestrator reads the
  proposal from this file rather than relying on in-memory state, which would be
  lost on crash.
- **Round**: One cycle of Adversary → Arbiter → (Proposer revision).
- **phase_step**: A field in the ledger YAML frontmatter that tracks the orchestrator's
  current sub-step within a round. Updated *before* each agent call so that crash
  recovery can deterministically identify the step to retry.

## Overview

A structured adversarial debate loop between three oracle agents:

- **Proposer** (@oracle): Creates and revises the output
- **Adversary** (@oracle): Attacks the output to find weaknesses
- **Arbiter** (@oracle): Independently verifies adversarial claims
- **Deadlock Arbiter** (@oracle): Specialized Arbiter for evaluating whether
  oscillating attacks are definitively resolved in the deadlock sub-cycle

The orchestrator acts as referee. All agents run in **fresh oracle sessions each round**
to avoid state pollution.

**Cost**: 3 oracle calls per round. Typical debates converge in 2-4 rounds.

---

## Phase 0: Suitability Check

Evaluate whether adversarial debate is the right tool.

### Use adversarial debate when ALL of:

1. The user has a **concrete proposal** to harden (not exploring options)
2. Undetected weaknesses would be costly
3. The proposal is bounded enough to attack meaningfully

### Do NOT use adversarial debate when ANY of:

1. The user is **exploring options** or brainstorming — no concrete proposal exists.
   → Suggest standard @oracle review or structured decision analysis.
2. The proposal is **trivial or low-stakes** — the cost of the debate exceeds the
   value of hardening. → Suggest a quick single-pass @oracle review.
3. The proposal is **too vague** to attack meaningfully (e.g., "make it better" with
   no specifics). → Ask the user to provide a concrete, written proposal first.
4. **Quick feedback** is more valuable than thorough hardening (e.g., a first draft
   needing directional input, not adversarial stress-testing).
   → Suggest a lightweight @oracle review.
5. The proposal is **very small** (fewer than ~50 lines of code or less than ~1 page
   of prose). → A standard @oracle review with self-critique is usually sufficient.

### Comparison Table

| Attribute | Adversarial Debate | Standard @oracle Review | Self-Review | Human Peer Review |
|-----------|-------------------|------------------------|-------------|-------------------|
| **Depth** | Iterative, multi-lens attack-defense | Single-pass expert review | Variable (depends on author) | Deep but limited by reviewer expertise |
| **Cost (oracle calls)** | 3-17 calls (1-5 rounds; early exit at 3 calls if CONVERGED+CONFIRMED in round 1) | 1 call | 0 calls | 0 calls (but human time) |
| **Best for** | High-stakes hardening, finding blind spots | Directional feedback, small proposals | Quick sanity checks | Novel domains, political/ethical judgment |
| **Bias mitigation** | Independent Arbiter cross-checks Adversary | Single perspective | Self-bias risk | Reviewer bias possible |
| **Crash safety** | Ledger + proposal file + phase_step | N/A (stateless) | N/A | Manual notes |
| **Turnaround** | 3+ sequential calls, minutes | 1 call, seconds | Seconds | Hours to days |
| **Skill threshold** | Requires concrete proposal, bounded scope | Any request | Any request | Requires available expert |

If uncertain, ask the user.

---

## Phase 1: Initialize

### 1a: Create a short slug for this debate

Derive from the user's request topic (e.g., `pg-migration`, `auth-redesign`).
The slug must satisfy: ASCII lowercase letters, digits, and hyphens only; 2-50
characters; no leading, trailing, or consecutive hyphens. If the derived slug
violates these rules, sanitize by lowercasing, replacing invalid characters with
hyphens, and collapsing consecutive hyphens to one. The ledger file will be
`.opencode/debate-ledger-{slug}.md` and the proposal file will be
`.opencode/debate-proposal-{slug}.md`.

### 1b: Check for existing state

If `.opencode/debate-ledger-{slug}.md` already exists (prior incomplete debate),
ask: "A debate ledger for '{slug}' exists. Overwrite or resume?"
If resume, skip to Phase 2 with the ledger's current `round` and `phase_step`.
Read the current proposal from `.opencode/debate-proposal-{slug}.md`.

### 1c: Proposer generates initial draft

Delegate to @oracle as Proposer:

```
You are a PROPOSER. Produce a structured, detailed initial draft for:
{user_request}

Your output must:
1. State all explicit and implicit assumptions
2. Include section-by-section structure with clear rationale
3. Identify known limitations and risks (self-critique)
4. Format as structured markdown with clear section headers

IMPORTANT: Do NOT use the following as section headers in your proposal body:
## Verdict, ## Coverage, ## Attacks, ## Revision Log.
These headers are reserved for debate agent outputs and grep-based extraction.
```

After receiving the Proposer's output, write it to `.opencode/debate-proposal-{slug}.md`.
This file is the persistent source of truth for the current proposal. Every subsequent
Proposer revision must overwrite this file.

### 1d: Initialize Issue Ledger

Create `.opencode/debate-ledger-{slug}.md`:

```markdown
# Debate Issue Ledger: {slug}

---
round: 1
status: in_progress
phase_step: starting
lenses_used: []
max_rounds: 5
oscillation: []
adversary_verdict: null
arbiter_verdict: null
arbiter_thoroughness: null
---
```

### 1e: Set round counter

Read `round` from the ledger. The ledger (specifically the YAML frontmatter)
is the single source of truth for round number, `phase_step`, and debate state.
Do not maintain a separate in-memory counter.

---

## Phase 2: Debate Loop

```
FOR each round:

  IF round > max_rounds:
    SET status = exhausted
    SET phase_step = final
    → Phase 3

  SET phase_step = adversary

  STEP 1 — ADVERSARY ATTACK
    Select lens → spawn @oracle Adversary → receive attack report
    → Store adversary_verdict in ledger frontmatter

  SET phase_step = arbiter

  STEP 2 — ARBITER VERIFY
    Spawn @oracle Arbiter → evaluate attacks → receive verdict + validated_attacks
    → Store arbiter_verdict and arbiter_thoroughness in ledger frontmatter

  SET phase_step = updating_ledger

  STEP 3 — UPDATE LEDGER
    Append validated attacks to ledger with round-scoped IDs
    Update lenses_used and oscillation field (if any)

  SET phase_step = evaluating

  STEP 4 — DECISION

    Evaluate the Adversary's Verdict AND the Arbiter's Verdict/Thoroughness
    (read from ledger frontmatter: adversary_verdict, arbiter_verdict,
     arbiter_thoroughness):

    ┌─ Arbiter Verdict == CONVERGED?
    │    ├─ Round ≥ 2 → SET phase_step = final → Phase 3
    │    └─ Round == 1
    │         ├─ thoroughness == CONFIRMED → SET phase_step = final → Phase 3 (early exit)
    │         └─ thoroughness == GAPS_FOUND → SET phase_step = starting → increment round → next round (use different lens)
    │
    ├─ Adversary Verdict == NO_ISSUES AND Arbiter Thoroughness == GAPS_FOUND?
    │    (The Adversary claimed no issues but the Arbiter found skipped sections.
    │     The Arbiter's formal Verdict is ISSUES_FOUND in this case, but there are
    │     zero validated attacks to pass to the Proposer. No Proposer revision is
    │     needed — nothing to revise against.)
    │    → SET phase_step = starting → increment round → next round (use a different
    │      lens to cover the skipped sections)
    │
    ├─ Arbiter Verdict == ISSUES_FOUND (with validated attacks)?
    │    → SET phase_step = proposer → Proposer revises
    │    → Overwrite `.opencode/debate-proposal-{slug}.md` with revised proposal
    │    → Update attack statuses in ledger from Revision Log
    │    → SET phase_step = starting → increment round → next round
    │
    └─ Arbiter Verdict == DEADLOCK?
         → SET phase_step = deadlock_proposer → deadlock sub-cycle
         (see Deadlock Sub-Cycle below)
```

### phase_step Lifecycle

The orchestrator updates `phase_step` in the ledger frontmatter **immediately before**
each agent call or critical action. This guarantees that on crash recovery, the
ledger tells us exactly which step to retry:

| phase_step | Meaning | Resume action |
|------------|---------|---------------|
| `starting` | Ready to begin Step 1 | Proceed to Step 1 |
| `adversary` | Adversary spawned, awaiting output | Re-run Step 1 |
| `arbiter` | Arbiter spawned, awaiting output | Re-run Step 2 |
| `updating_ledger` | Arbiter verdict received, about to append attacks | Re-run Step 2 (Arbiter), then proceed to Step 3 with deduplication by attack ID. This is count-aware: a binary "attacks exist?" check can silently lose partially-appended data from a mid-write crash. See Step 3 dedup details below. |
| `proposer` | Proposer spawned, awaiting revision | Check if `.opencode/debate-proposal-{slug}.md` was updated after the time of the last `## Attack` entry for the current round. If yes → increment round, set phase_step = starting → Step 1. If no → re-run Proposer |
| `evaluating` | Performing decision tree evaluation | Re-evaluate decision using `adversary_verdict`, `arbiter_verdict`, and `arbiter_thoroughness` from the ledger frontmatter (stored after Steps 1 and 2) |
| `deadlock_proposer` | Deadlock sub-cycle: Proposer spawned for final chance | Check if a deadlock Revision Log exists in the proposal file for current oscillation entries. If yes → proceed to deadlock_arbiter. If no → re-run deadlock Proposer |
| `deadlock_arbiter` | Deadlock sub-cycle: Deadlock Arbiter spawned for re-check | Re-run deadlock Arbiter |
| `final` | Debate terminated, entering Phase 3 | Proceed to Phase 3 |

### Step Details

**Step 1 — Adversary Attack**:

Select a lens from the pool (unused first, then cycle to unresolved-attack domains).
Spawn @oracle Adversary with the prompt from Agent Specifications below. Pass
`{current_proposal}` read from `.opencode/debate-proposal-{slug}.md`.

After receiving the Adversary's output, extract the `## Verdict` value and write it
to the ledger frontmatter as `adversary_verdict` (one of `ISSUES_FOUND`, `NO_ISSUES`).
This value is required for crash-safe re-evaluation of the decision tree when
resuming from `phase_step: evaluating`.

**Step 2 — Arbiter Verify**:

Spawn @oracle Arbiter with the Adversary's output. Pass `{current_proposal}` read
from `.opencode/debate-proposal-{slug}.md`. Arbiter evaluates: substantiveness,
redundancy, oscillation, thoroughness.

After receiving the Arbiter's output, extract the `## Verdict` value and write it
to the ledger frontmatter as `arbiter_verdict` (one of `CONVERGED`, `ISSUES_FOUND`,
`DEADLOCK`). Also extract the `## Thoroughness` value and write it as
`arbiter_thoroughness` (one of `CONFIRMED`, `GAPS_FOUND`). These values are required
for crash-safe re-evaluation of the decision tree when resuming from
`phase_step: evaluating`.

**Mismatch handling**:
- Adversary says NO_ISSUES but Arbiter finds GAPS_FOUND → handled in Step 4 decision
  tree (NO_ISSUES + GAPS_FOUND branch): continue loop without Proposer revision;
  next round uses a different lens for uncovered sections.
- Arbiter discards ALL attacks as REDUNDANT/NITPICK → Arbiter Verdict is CONVERGED.

**Step 3 — Update Ledger**:

Append each validated attack with the round-scoped ID format `R{round}_{adversary_id}`.
Example: `R1_A1`, `R1_A2`, `R2_A1`.

**Crash-safe deduplication**: When resuming from `phase_step: updating_ledger`,
the Arbiter is re-run and Step 3 re-executes. Before appending each attack, scan
the ledger for an existing `## Attack R{N}_{id}` header where N matches the current
round. If the ID already exists with a well-formed entry, skip it (preserve the
original). Append only new IDs. This protects against partial-write data loss without
needing the orchestrator to count expected attacks.

If the Arbiter reports oscillation (see Arbiter prompt `## Oscillation` section),
populate the ledger's `oscillation` field with entries (see Oscillation Entry Format
in the Issue Ledger section below).

After Proposer revision (Step 4 ISSUES_FOUND path), update attack statuses based
on the Revision Log. Cross-check that every validated attack appears in the log;
flag discrepancies in the ledger.

**Step 4 — Decision**:

Branch on Adversary Verdict + Arbiter Verdict/Thoroughness, reading these values
from the ledger frontmatter (`adversary_verdict`, `arbiter_verdict`, `arbiter_thoroughness`).
The decision tree is shown in the diagram above. The Proposer revision path goes:
Proposer → overwrite proposal file → update ledger attack statuses → set
phase_step = starting → increment round → back to Step 1. Exhaustion is checked
at the top of the loop body (not in the decision tree), so incrementing round past
max_rounds causes termination on the next iteration.

All branches that continue to the next round MUST set `phase_step = starting` before
incrementing round, ensuring the next iteration begins at the correct step.

### Deadlock Sub-Cycle

When the Arbiter detects oscillation (same core claim recurring after being marked
RESOLVED in a previous round), the orchestrator initiates the deadlock sub-cycle
instead of a standard Proposer revision:

1. **SET phase_step = deadlock_proposer**
2. **Proposer Final Chance**: Spawn @oracle Proposer with the deadlock-specific
   prompt (see Deadlock Proposer Prompt in Agent Specifications). Pass the
   oscillation history from the ledger's `oscillation` field. The Proposer gets
   one final opportunity to address the oscillating attacks definitively.
   Overwrite `.opencode/debate-proposal-{slug}.md` with the revised proposal.
3. **SET phase_step = deadlock_arbiter**
4. **Deadlock Arbiter Re-check**: Spawn @oracle as Deadlock Arbiter with the
   specialized Deadlock Arbiter Prompt (see Agent Specifications). The Deadlock
   Arbiter evaluates specifically whether each oscillating attack has been
   definitively resolved — it does NOT evaluate new attacks (the standard
   Arbiter handles that in the next round if the deadlock is resolved).
5. **Decision**:
   - If Deadlock Arbiter Verdict == RESOLVED → clear the `oscillation` field,
     increment round → continue the debate loop (next round with standard flow)
   - If Deadlock Arbiter Verdict == STILL_OSCILLATING → SET phase_step = final,
     status = deadlocked → Phase 3

The deadlock sub-cycle adds exactly 2 oracle calls to the debate.

---

## Lens Pool

Select one lens per round. Track used lenses in the ledger.

| Lens | Focus |
|------|-------|
| **Pessimistic Operator** | Production failure modes, recovery gaps, monitoring blind spots |
| **Hostile Attacker** | Exploitable surfaces, abuse vectors, security weaknesses |
| **Budget Controller** | Cost-effectiveness, resource waste, cheaper alternatives |
| **Domain Expert** | Incorrect assumptions, boundary misunderstandings, compliance gaps |
| **Systems Thinker** | Emergent behaviors, coupling, cascading failures, feedback loops |
| **Implementation Realist** | Buildability, missing details, unrealistic implementation assumptions |
| **Maintainer's Nightmare** | Technical debt, documentation gaps, bus factor, long-term burden |
| **Edge Case Hunter** | Boundary conditions, null/empty states, concurrency, race conditions |

**Selection**: Round 1 picks the most domain-relevant lens. Subsequent rounds:
1. Pick any unused lens from the pool
2. If all lenses used, cycle back to the one most relevant to unresolved attacks
   in the ledger (match lens focus to attack domains)

---

## Agent Specifications

All agent prompts use these substitutions by the orchestrator before sending:

| Variable | Source | Description |
|----------|--------|-------------|
| `{N}` | Ledger `round` | Current round number |
| `{MAX}` | Constraints `max_rounds` (5) | Maximum round count |
| `{lens_name}` | Lens Pool selection | Name of the selected adversarial lens |
| `{current_proposal}` | `.opencode/debate-proposal-{slug}.md` | Latest version of the proposal (read from file) |
| `{proposal}` | `.opencode/debate-proposal-{slug}.md` | Same as `{current_proposal}`; used in Arbiter prompt |
| `{issue_ledger_content}` | `.opencode/debate-ledger-{slug}.md` | Complete contents of the ledger file |
| `{adversary_output}` | Adversary response (Step 1) | Raw output from the Adversary agent |
| `{validated_attacks}` | Arbiter `## Validated Attacks` | Content of the Arbiter's validated attacks section |
| `{oscillation_entries}` | Ledger `oscillation` field | Formatted oscillation history (for deadlock prompts) |
| `{user_request}` | Phase 1 user input | The original user request for the debate |
| `{slug}` | Phase 1a derivation | The debate slug |

### Adversary Prompt

```
You are an ADVERSARY (round {N}/{MAX}, lens: {lens_name}).

Attack the following proposal from this perspective. Be thorough — examine EVERY section.

RULES:
- Do NOT repeat attacks marked RESOLVED in the Issue Ledger unless the
  claimed fix appears cosmetic or insufficient
- If you find NO substantive issues, state that explicitly

PROPOSAL:
{current_proposal}

ISSUE LEDGER:
{issue_ledger_content}

OUTPUT FORMAT — use these exact markdown sections:

## Verdict
ISSUES_FOUND | NO_ISSUES

## Coverage
### Examined
- {section name}
### Skipped
- {section name}: {reason, or "none"}

## Attacks  (ONLY if ISSUES_FOUND — omit if NO_ISSUES)
### Attack A{N}: {brief title}
- **Severity**: CRITICAL | HIGH | MEDIUM | LOW
- **Core Claim**: {one-sentence summary}
- **Description**: {detailed reasoning}
- **Evidence**: {concrete evidence}

(Repeat ### Attack for each attack, numbering A1, A2, A3...)

## No-Issues Justification  (ONLY if NO_ISSUES — omit if ISSUES_FOUND)
{What was examined and why no substantive weaknesses were found}
```

### Arbiter Prompt

```
You are an ARBITER (round {N}/{MAX}).

Evaluate the Adversary's attacks. You do NOT attack or defend — you verify.

PROPOSAL:
{proposal}

ADVERSARY OUTPUT:
{adversary_output}

ISSUE LEDGER:
{issue_ledger_content}

EVALUATION:
1. SUBSTANTIVE? (concrete weakness with non-trivial negative impact)
2. REDUNDANT? (core claim already resolved in Issue Ledger)
3. OSCILLATION? (same core claim recurs after claimed resolution)
4. THOROUGH? (all proposal sections examined?)

OUTPUT FORMAT — use these exact markdown sections:

## Verdict
CONVERGED | ISSUES_FOUND | DEADLOCK

## Thoroughness
CONFIRMED | GAPS_FOUND
{explanation}

## Oscillation
true | false
{If true, for each oscillating attack:
- **Current Attack**: R{N}_{id}
- **Oscillates With**: R{M}_{id} (resolved in round {M})
- **Core Claim**: {one-sentence summary}
- **Evidence**: {why the resolution in round {M} was insufficient}}

## Validated Attacks  (if any — omit if none)
### R{N}_{adversary_id} ({severity}): {brief title}
- **Core Claim**: {preserved for Issue Ledger}
- **Validation**: {why substantive and non-redundant}

## Discarded Attacks  (if any — omit if none)
### {adversary_id}
- **Reason**: REDUNDANT | NITPICK | UNSUBSTANTIATED
- **Explanation**: {why discarded}
```

### Proposer Prompt (revision only — skip on Round 1)

```
You are a PROPOSER (round {N}/{MAX}).

Revise the proposal to address the Arbiter-validated attacks below.

ORIGINAL REQUEST:
{user_request}

CURRENT PROPOSAL:
{current_proposal}

VALIDATED ATTACKS:
{validated_attacks}

ISSUE LEDGER:
{issue_ledger_content}

INSTRUCTIONS:
For each validated attack, you MUST either:
  a) Revise the proposal AND explain how your revision resolves it, OR
  b) Explain why it cannot/will not be addressed (DECLINED)

CRITICAL: This time you MUST produce the COMPLETE, ACTUAL content of all output
files exactly as they should appear on disk. Do NOT describe changes or use
summaries — write the full file text. Every claim in the Revision Log must
correspond to observable changes in the output files.

OUTPUT:
1. The complete revised proposal
2. A "## Revision Log" section listing EVERY validated attack by its
   round-scoped ID (R{N}_{id}) with [RESOLVED], [DECLINED], or [PREVIOUSLY_RESOLVED]

IMPORTANT: Do NOT use `## Verdict`, `## Coverage`, `## Attacks`, or
`## Revision Log` as section headers WITHIN the proposal body itself. The
Revision Log must be a separate top-level section AFTER the proposal.
```

### Deadlock Proposer Prompt

```
You are a PROPOSER — DEADLOCK FINAL CHANCE (round {N}/{MAX}).

The debate has detected OSCILLATION: one or more attacks previously marked
RESOLVED have recurred in a subsequent round, indicating the prior fix was
insufficient. This is your FINAL opportunity to address these oscillating
attacks before the debate terminates as DEADLOCKED.

ORIGINAL REQUEST:
{user_request}

CURRENT PROPOSAL:
{current_proposal}

OSCILLATION HISTORY (from ledger):
{oscillation_entries}

ISSUE LEDGER:
{issue_ledger_content}

INSTRUCTIONS:
For each oscillating attack, you MUST:
  a) Revise the proposal to DEFINITIVELY resolve it, AND explain your fix, OR
  b) State explicitly why it cannot be resolved (DECLINED), OR
  c) Propose a structural change that eliminates the attack surface entirely

CRITICAL: If the same core claim recurs after this revision, the debate will
terminate as DEADLOCKED regardless of other progress. This is your only chance.

OUTPUT:
1. The complete revised proposal
2. A "## Revision Log" section listing EVERY oscillating attack by its
   round-scoped ID (R{N}_{id}) with [RESOLVED], [DECLINED], or [PREVIOUSLY_RESOLVED]

IMPORTANT: Do NOT use `## Verdict`, `## Coverage`, `## Attacks`, or
`## Revision Log` as section headers WITHIN the proposal body itself. The
Revision Log must be a separate top-level section AFTER the proposal.
```

### Deadlock Arbiter Prompt

```
You are a DEADLOCK ARBITER (round {N}/{MAX}).

The debate has entered the deadlock sub-cycle. One or more attacks have been
detected as OSCILLATING: their core claim was previously marked RESOLVED but
recurred in a subsequent round. The Proposer has been given a final chance to
definitively resolve these oscillating attacks.

Your role: evaluate whether the Proposer's deadlock revision has definitively
resolved each oscillating attack. You do NOT evaluate new attacks or check
thoroughness — those are handled by the standard Arbiter in the next round
if the deadlock is resolved.

CURRENT PROPOSAL (after deadlock revision):
{current_proposal}

OSCILLATION HISTORY (from ledger):
{oscillation_entries}

ISSUE LEDGER:
{issue_ledger_content}

EVALUATION:
For each oscillating attack in the oscillation history:
1. Does the deadlock revision substantively change the part of the proposal
   related to this attack?
2. Does the change definitively remove the attack surface, or is it cosmetic?
3. Is the core claim still applicable to the revised proposal?

OUTPUT FORMAT — use these exact markdown sections:

## Verdict
RESOLVED | STILL_OSCILLATING

## Oscillation Evaluation
(Repeat for each oscillating attack)
### {attack_id}
- **Status**: RESOLVED | STILL_OSCILLATING
- **Reasoning**: {specific evidence from the revision}
- **Core Claim Persists**: true | false
```

---

## Issue Ledger

**File**: `.opencode/debate-ledger-{slug}.md`

**Format** (single canonical spec):

```markdown
# Debate Issue Ledger: {slug}

---
round: {N}
status: in_progress | converged | deadlocked | exhausted
phase_step: starting | adversary | arbiter | updating_ledger | proposer | evaluating | deadlock_proposer | deadlock_arbiter | final
lenses_used: [{lens}, ...]
max_rounds: 5
oscillation: []
adversary_verdict: null | ISSUES_FOUND | NO_ISSUES
arbiter_verdict: null | CONVERGED | ISSUES_FOUND | DEADLOCK
arbiter_thoroughness: null | CONFIRMED | GAPS_FOUND
---

## Attack R{N}_{adversary_id} ({severity})
- **Lens**: {lens_name}
- **Core Claim**: {one sentence}
- **Arbiter Validation**: {why substantive}
- **Status**: UNRESOLVED | RESOLVED | DECLINED | OSCILLATING
- **Resolution**: {explanation or "pending"}
```

Each attack is a `## Attack` entry. Group visually by round (the round is in the ID).

### Frontmatter verdict fields

The `adversary_verdict`, `arbiter_verdict`, and `arbiter_thoroughness` fields
enable crash-safe resumption of the decision tree (Step 4) when recovering from
`phase_step: evaluating`. They are populated as follows:

- `adversary_verdict`: Written after Step 1, extracted from the Adversary's
  `## Verdict` output. Value: `ISSUES_FOUND` or `NO_ISSUES`.
- `arbiter_verdict`: Written after Step 2, extracted from the Arbiter's
  `## Verdict` output. Value: `CONVERGED`, `ISSUES_FOUND`, or `DEADLOCK`.
- `arbiter_thoroughness`: Written after Step 2, extracted from the Arbiter's
  `## Thoroughness` output. Value: `CONFIRMED` or `GAPS_FOUND`.

All three fields are initialized to `null` in Phase 1d and are overwritten each round.
Together with `round` and `oscillation`, they provide the complete state needed to
re-run the Step 4 decision tree after a crash.

### Oscillation Entry Format

The `oscillation` field in the ledger frontmatter is an array of objects. Each entry
records an attack whose core claim recurred after being marked RESOLVED in a
previous round. The orchestrator populates this field from the Arbiter's
`## Oscillation` output.

```yaml
oscillation:
  - attack_id: "R{N}_{id}"
    core_claim: "{one-sentence summary of the recurring claim}"
    first_seen_round: {N}
    arbiter_notes: "{brief rationale from Arbiter's Oscillation output}"
```

Field descriptions:
- **attack_id**: The round-scoped ID of the current attack that triggered oscillation
  detection (e.g., `R3_A1`).
- **core_claim**: The recurring claim in one sentence.
- **first_seen_round**: The round number where this core claim first appeared
  (derived from the `## Oscillation` output's "Oscillates With" reference).
- **arbiter_notes**: The Arbiter's evidence and reasoning for why the claim is
  oscillating.

The orchestrator passes the `oscillation` array verbatim to the Deadlock Proposer
as `{oscillation_entries}` and to the Deadlock Arbiter for evaluation. The
`oscillation` field is cleared when the deadlock sub-cycle resolves the oscillation;
if the sub-cycle fails to resolve it, the field is preserved for the final report.

**Orchestrator responsibilities**:
1. Update `phase_step` BEFORE each agent call (see phase_step Lifecycle table above)
2. After Step 1 (Adversary): extract `## Verdict` and write `adversary_verdict` to
   the ledger frontmatter
3. After Step 2 (Arbiter): extract `## Verdict` and `## Thoroughness`, write
   `arbiter_verdict` and `arbiter_thoroughness` to the ledger frontmatter; append
   new `## Attack` entries with round-scoped IDs, using deduplication by ID
   (see Step 3 crash-safe deduplication)
4. After each Arbiter verdict: if oscillation is reported, populate the `oscillation`
   field using the Oscillation Entry Format
5. After Proposer revision: overwrite `.opencode/debate-proposal-{slug}.md` with the
   revised proposal; update each attack's `Status` and `Resolution` in the ledger
   from the Revision Log
6. After deadlock Proposer revision: overwrite `.opencode/debate-proposal-{slug}.md`;
   update oscillating attacks' `Status` and `Resolution`; if resolved, clear the
   `oscillation` field
7. Best-effort cross-check: verify that validated attacks appear in the Revision Log.
   Flag gaps but do not halt — the next round's Arbiter will catch unresolved attacks.
8. Update the YAML frontmatter (`round`, `status`, `phase_step`, `lenses_used`,
   `oscillation`, `adversary_verdict`, `arbiter_verdict`, `arbiter_thoroughness`)
9. Pass the **full ledger file contents** to all agents each round
10. Read `{current_proposal}` from `.opencode/debate-proposal-{slug}.md` before each
    agent call — never rely on in-memory state for the proposal
11. On termination: update `status` to final value, set `phase_step` to `final`,
    keep files for audit trail

**Resume protocol**: On skill activation, check for existing ledger. If `status:
in_progress`, ask user to resume or restart. If resume:
1. Read `round` and `phase_step` from the ledger frontmatter
2. Read the current proposal from `.opencode/debate-proposal-{slug}.md`
3. Use the phase_step Lifecycle table to determine the exact action:
   - `phase_step: adversary` → re-run Step 1 (Adversary call was lost)
   - `phase_step: arbiter` → re-run Step 2 (Arbiter call was lost)
   - `phase_step: updating_ledger` → re-run Step 2 (Arbiter), then Step 3 with
     deduplication by attack ID (see Step 3 details above). This is count-aware:
     the old binary check "attacks exist?" silently loses partially-appended data.
   - `phase_step: proposer` → check if `.opencode/debate-proposal-{slug}.md` was
     modified after the last `## Attack` entry for the current round; if yes,
     increment round and proceed to Step 1; if no, re-run Proposer
   - `phase_step: evaluating` → proceed to Step 4 decision logic using
     `adversary_verdict`, `arbiter_verdict`, and `arbiter_thoroughness` from
     the ledger frontmatter, plus the current proposal file
   - `phase_step: deadlock_proposer` → check if proposal file contains a deadlock
     Revision Log for current oscillation entries; if yes, proceed to
     deadlock_arbiter; if no, re-run deadlock Proposer
   - `phase_step: deadlock_arbiter` → re-run deadlock Arbiter
   - `phase_step: final` → proceed to Phase 3
4. Continue the debate loop from the determined step

---

## Convergence & Termination

### CONVERGED
- Round ≥ 2 AND Arbiter verdict is CONVERGED, OR
- Round = 1 AND Arbiter thoroughness = CONFIRMED (early exit)

When all Adversary attacks are discarded as REDUNDANT/NITPICK, Arbiter outputs CONVERGED.

If Round = 1, Arbiter verdict is CONVERGED, but thoroughness is GAPS_FOUND, the
debate continues to the next round with a different lens (not converged). See the
Phase 2 decision tree for the complete branching logic.

### DEADLOCK
When the Arbiter detects oscillation (same core claim recurring after being marked
RESOLVED in a previous round), the orchestrator initiates the deadlock sub-cycle
(see Deadlock Sub-Cycle in Phase 2):

1. The Proposer receives a final-chance prompt with the oscillation history
2. The Deadlock Arbiter (specialized prompt) evaluates the revised proposal
   specifically for the oscillating attacks

If the Deadlock Arbiter's Verdict is RESOLVED: the `oscillation` field is cleared,
round is incremented, and the debate loop continues. If STILL_OSCILLATING: the debate terminates as
DEADLOCKED and the `oscillation` field is preserved for the final report.

### EXHAUSTION
Round > max_rounds, checked at the top of each loop iteration. Terminate as EXHAUSTED.

---

## Phase 3: Resolution

Produce a final report:

```markdown
# Adversarial Debate: Final Report

## Status
{CONVERGED | DEADLOCKED | EXHAUSTED} after {N} rounds

## Hardened Proposal
{final proposal read from .opencode/debate-proposal-{slug}.md}

## Issue Ledger Summary
| Attack ID | Round | Lens | Severity | Core Claim | Status |
|-----------|-------|------|----------|------------|--------|

## Unresolved Weaknesses
{unresolved/declined attacks with Proposer's last response}

## Statistics
| Metric | Value |
|--------|-------|
| Rounds | {N} |
| Attacks raised | {M} |
| Resolved | {X} / Declined | {Y} / Unresolved | {Z} |
| Lenses used | {list} |
```

Include:

> ⚠️ The Arbiter's reasoning is not independently verified. CRITICAL findings and
> DEADLOCK resolutions should be reviewed by a human before acting on this report.

### Post-Report Cleanup

After presenting the final report, use the `question` tool to ask the user
whether to clean up the debate files. Do NOT ask verbally — the `question` tool
presents structured options and captures the user's choice.

```
question:
  header: "Cleanup debate files?"
  question: "The ledger `.opencode/debate-ledger-{slug}.md` and proposal file
`.opencode/debate-proposal-{slug}.md` are still on disk."
  options:
    - label: "Delete both"
      description: "Remove ledger and proposal files. No audit trail remains."
    - label: "Keep for audit"
      description: "Leave both files on disk as an audit trail."
```

- If the user chooses **"Delete both"**: delete both files.
- If the user chooses **"Keep for audit"**: leave both files as-is.

---

## Error Handling

- **Oracle timeout/failure**: Retry once. On second failure, produce error report
  with ledger state and last known proposal (from proposal file if available).
- **Output format deviation**: Use `grep` to extract key sections by header pattern.
  Documented patterns: `^## Verdict`, `^## Coverage`, `^## Attacks`,
  `^## Validated Attacks`, `^## Discarded Attacks`, `^## Thoroughness`,
  `^## Oscillation`, `^## Oscillation Evaluation`, `^## No-Issues Justification`,
  `^## Revision Log`. Maximum 2 format retries per agent call; on third failure,
  treat as call failure.
- **Ledger integrity**: Before each round, verify file exists and is readable.
  If missing/unparseable, report error with last known state, offer recovery.
- **Proposal file integrity**: Before each round, verify `.opencode/debate-proposal-{slug}.md`
  exists and is readable. If missing, re-derive from the ledger (if a previous
  proposal was appended) or re-run the Proposer from the original request.
- **Partial progress**: If ≥1 complete round exists, offer user the option to
  accept the last hardened proposal as-is.

---

## Constraints

| Constraint | Value |
|------------|-------|
| max_rounds | 5 |
| Oracle calls/round | 3 (Adversary, Arbiter, Proposer) |
| Deadlock sub-cycle calls | 2 (Deadlock Proposer, Deadlock Arbiter) |
| Max total oracle calls | 17 successful calls (15 regular + 2 deadlock sub-cycle); format retries add ≤2 per call (theoretical worst case +34, practical expectation ≤+6) |
| Max format retries per call | 2 |
| Oracle retry on failure | 1 |
| Ledger location pattern | `.opencode/debate-ledger-{slug}.md` |
| Proposal file location pattern | `.opencode/debate-proposal-{slug}.md` |

---

## Known Limitations

1. **Arbiter infinite regress**: The verifier is unverified. Mitigated via transparent
   reasoning, cross-round ledger consistency, and human review flags.
2. **Single-threaded execution**: Agents run sequentially. A 4-round debate takes
   12+ sequential calls. Inform user of expected duration.
3. **Output format compliance**: LLMs deviate from specified formats. Grep-based
   extraction with capped retries mitigates this.
4. **Oscillation detection**: Core claim comparison is semantic (free text), not
   structural. False positives/negatives possible.
5. **Revision verification**: Adversary sees only the current proposal, not the
   before/after diff. Best-effort verification.
6. **Phase 0 routing**: Suitability check is an LLM judgment. If uncertain, ask user.
7. **Proposal section headers**: Avoid `## Verdict`, `## Coverage`, `## Attacks`,
   `## Revision Log` as proposal section headers to prevent grep ambiguity.
   The orchestrator notes this when presenting the initial draft.
8. **Deadlock sub-cycle cost**: The deadlock sub-cycle adds up to 2 extra oracle
   calls. Worst-case total is 17 successful calls (15 regular + 2 deadlock), plus
   format retries: ≤2 per call, theoretical worst case +34 additional calls.
9. **Proposal persistence**: The proposal is persisted to a companion file
   (`.opencode/debate-proposal-{slug}.md`) for crash safety. If both the ledger
   and the proposal file are lost, full recovery is impossible — the orchestrator
   must re-run Phase 1 from the original user request.
