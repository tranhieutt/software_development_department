---
name: diagnose
type: reference
description: "Diagnostic pipeline for complex/intermittent bugs. Uses diagnostics roles for Investigation, Verification, and Solution before Lead Programmer handoff. Use ONLY for non-obvious failures (root cause unclear, reproduction unstable, fixes reverted). NOT for trivial bugs with known cause — fix them directly."
paths: []
effort: 4
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task
user-invocable: true
when_to_use: "When a bug is reproducible but cause is unknown, when a 'fix' has been reverted 2+ times, or when a symptom appears in unfamiliar code. Do NOT use for typos, obvious nulls, or one-line logic errors."
---

# Skill: /diagnose — Complex Bug Diagnostic Pipeline

## When to invoke (and when NOT to)

### Use `/diagnose` when:
- Bug reproduces but **root cause is unclear** after one read-pass of the failing code
- Previous fix attempts have been **reverted ≥ 2 times** (symptoms return)
- Failure is **intermittent** (flaky test, race condition, timing-dependent)
- Failure occurs in **unfamiliar code** (agent has no prior context)
- User has explicitly requested `/diagnose` or "deep investigation"
- Circuit Breaker (Rule 14) tripped on the specialist agent that normally handles this domain

### Do NOT use `/diagnose` when:
- Cause is obvious (null ref, typo, missing import, incorrect import path)
- Fix is < 10 LOC and has a clear success check
- Bug is in code you just wrote this session (read-pass + local reasoning is faster)
- User wants a quick patch and has accepted the tradeoff

## Pipeline overview

```
Feedback Loop -> Investigation -> Verification -> Solution -> Lead Programmer
  (signal)         (hypothesis)    (devil's adv.)   (tradeoffs)   (assign + exec)

  repro/check command      investigation.json      verification.json      solution.json          implementation
  (fast deterministic      (root_cause,           (status: confirmed |    (3 options:           (delegates to
   pass/fail signal)       evidence[],            refuted | inconclusive, Quick/Strategic/     backend-developer,
                           confidence)            reproduction_steps)    Future-Proof)         qa-engineer, etc.)
```

Each stage produces a **required artifact** saved to `.investigations/<task_id>/` and a **handoff contract** (per Rule 16) to the next agent.

## Stage 0 — Feedback Loop

**Goal:** Build the fastest reliable pass/fail signal for the exact symptom
before explaining the cause.

The feedback loop is the highest-leverage part of diagnosis. Do not proceed to
root-cause analysis until there is a loop that can reproduce the user's symptom
or a documented reason why no loop is possible.

Try these in roughly this order:

1. Failing test at the seam that reaches the bug.
2. CLI or script invocation with fixture input and expected output.
3. Curl/HTTP request against a running service.
4. Headless browser script with DOM, console, or network assertions.
5. Replay of a captured payload, event, HAR, log, or trace.
6. Throwaway harness that calls the affected code path in isolation.
7. Property/fuzz loop for broad wrong-output symptoms.
8. Bisection or differential loop between known-good and known-bad states.

Improve the loop before investigating:

- Faster: remove unrelated setup and narrow the command.
- Sharper: assert the specific symptom, not merely "does not crash".
- More deterministic: pin time, seed randomness, isolate filesystem/network, or
  raise intermittent reproduction frequency with stress runs.

If no credible loop can be built, stop and report what was tried. Ask for access
to the reproducing environment, a captured artifact, or permission to add
temporary instrumentation. Do not proceed on a vibe.

## Stage 1 — Investigation

**Agent:** `diagnostics` (Investigation role)
**Goal:** Produce ranked falsifiable root-cause hypotheses backed by empirical evidence.

### Inputs
- Symptom description (from user or TODO.md bug ID)
- Reproduction steps (or "cannot reproduce" + environment)
- Relevant log lines, stack traces, error IDs
- Feedback loop command/check from Stage 0, or a documented reason no loop can
  currently be built

### Required output — `investigation.json`
```json
{
  "task_id": "BUG-417",
  "symptom": "POST /api/orders returns 500 when cart has ≥10 items",
  "reproduction": {
    "steps": ["...", "..."],
    "frequency": "100% | intermittent (~30%) | once",
    "environment": "staging-eu-west-1"
  },
  "feedback_loop": {
    "command": "npm test -- checkout.e2e.test.ts",
    "signal": "Fails with timeout before hydration marker appears",
    "reliable": true
  },
  "ranked_hypotheses": [
    {
      "rank": 1,
      "cause": "Test clicks #submit before React hydration completes on slow CI runners",
      "prediction": "Waiting for the hydration marker will make the failure disappear without adding a fixed sleep"
    },
    {
      "rank": 2,
      "cause": "Submit button selector matches a hidden stale node",
      "prediction": "Asserting the visible button count will expose multiple matching nodes"
    }
  ],
  "hypothesis": {
    "root_cause": "OrderService.calculateTotal() N+1 query exhausts pool when cart.items.length > 9",
    "confidence": "high | medium | low",
    "falsifiable_by": "Run with pool_size=50; if error disappears, cause confirmed"
  },
  "evidence": [
    {"type": "log", "ref": ".investigations/BUG-417/pg-pool-exhausted.log", "summary": "..."},
    {"type": "code", "ref": "src/services/order.service.ts:142", "summary": "Unbounded .map+await"}
  ],
  "unknowns": ["Why only eu-west-1?", "When did this start?"],
  "next_agent": "diagnostics",
  "next_stage": "verification"
}
```

### Quality gate (Lead Programmer rejects if):
- `feedback_loop` is missing and no blocked-loop explanation exists
- `ranked_hypotheses` has fewer than 3 items unless the evidence makes a single
  cause unavoidable
- Any hypothesis lacks a falsifiable prediction
- `hypothesis.falsifiable_by` is vague ("check if it works")
- `evidence` has fewer than 2 items (unverifiable)
- `unknowns` is empty but `confidence: low` (contradictory)

## Stage 2 — Verification

**Agent:** `diagnostics` (Verification role)
**Goal:** Attempt to **refute** the hypothesis. Only confirmed if refutation fails.

### Inputs
- `investigation.json` (from Stage 1)
- Access to staging/test environment
- The Stage 0 feedback loop, rerun before and after each meaningful probe

### Required output — `verification.json`
```json
{
  "task_id": "BUG-417",
  "status": "confirmed | refuted | inconclusive",
  "triangulation": [
    {"method": "reproduce_with_fix_applied", "result": "Error gone with pool_size=50"},
    {"method": "reproduce_without_fix", "result": "Error returns at 10 items"},
    {"method": "adjacent_test_case", "result": "9 items = OK, 10 items = fail → threshold confirmed"}
  ],
  "counter_hypotheses_ruled_out": [
    "DB slowness (ruled out: p99 < 50ms)",
    "Network flaps (ruled out: no packet loss in window)"
  ],
  "confidence": "high",
  "recommendation": "Proceed to Solution stage — cause confirmed necessary AND sufficient"
}
```

### Decision flow
| `status`       | Next action                                                          |
| -------------- | -------------------------------------------------------------------- |
| `confirmed`    | Proceed to Solution stage (same `diagnostics` agent)                 |
| `refuted`      | Return to Investigation stage with counter-evidence. Max 2 round-trips. |
| `inconclusive` | STOP. Surface to user with all evidence. Do NOT proceed to Solution stage. |

## Stage 3 — Solution

**Agent:** `diagnostics` (Solution role)
**Goal:** Generate 3 solution options with explicit tradeoffs; never pick silently.

### Required output — `solution.json`
```json
{
  "task_id": "BUG-417",
  "options": [
    {
      "name": "Quick",
      "description": "Increase pool_size from 20 → 50 in db.ts",
      "scope_loc": 1,
      "risk_tier": "Low",
      "tradeoff": "Masks root cause; higher RAM; future growth hits same wall"
    },
    {
      "name": "Strategic",
      "description": "Rewrite calculateTotal() to batch via IN-clause",
      "scope_loc": 40,
      "risk_tier": "Medium",
      "tradeoff": "Fixes N+1 permanently; requires regression test on discount logic"
    },
    {
      "name": "Future-Proof",
      "description": "Introduce DataLoader pattern across service layer",
      "scope_loc": 300,
      "risk_tier": "High",
      "tradeoff": "Eliminates entire class of N+1 bugs; 2-3 day refactor; needs ADR"
    }
  ],
  "recommendation": "Strategic — best risk/value ratio. Quick only if release is < 24h."
}
```

### Quality gate
- All 3 options must have distinct scope (not three flavors of the same fix)
- `tradeoff` must state what is **sacrificed**, not just "takes longer"
- `recommendation` must cite a criterion (time budget, risk tier, blast radius)
- The selected option's acceptance criteria must include rerunning the original
  feedback loop from Stage 0 and a regression test when a correct seam exists

## Stage 4 — Finalization

**Agent:** `lead-programmer`
**Goal:** Select option, assign specialist, track execution.

### Actions
1. Review `solution.json` with user (if `risk_tier: High` or `scope_loc > 100`)
2. Select option → write selection to `.investigations/<task_id>/decision.md`
3. Create A2A handoff contract (Rule 16) via `/handoff`:
   - `lead-programmer → backend-developer` (or `frontend-developer`, `data-engineer`)
   - Acceptance criteria derived from `investigation.hypothesis.falsifiable_by`
4. Append ledger entry (Rule 15) to `production/traces/decision_ledger.jsonl`:
```jsonl
{"ts":"2026-04-17T14:22:00Z","session":"main","agent_id":"lead-programmer","task_id":"BUG-417","request":"/diagnose BUG-417","reasoning":"Verified N+1 as necessary+sufficient; selected Strategic per Solution-stage recommendation","choice":"Strategic refactor of calculateTotal()","outcome":"pass","risk_tier":"Medium","duration_s":1840}
```

## Artifact storage

All intermediate reports MUST be saved to `.investigations/<task_id>/`:

```
.investigations/
└── BUG-417/
    ├── investigation.json     # Stage 1 output
    ├── verification.json      # Stage 2 output
    ├── solution.json          # Stage 3 output
    ├── decision.md            # Stage 4 — human-readable rationale
    ├── evidence/              # logs, screenshots, traces referenced in reports
    └── handoffs/              # A2A contracts (copied from .tasks/handoffs/)
```

**Retention:** Keep until bug is closed + 30 days, then archive to `.investigations/archive/`.

## Escalation paths

| Trigger                                           | Escalate to                                    |
| ------------------------------------------------- | ---------------------------------------------- |
| `diagnostics` circuit OPEN in Investigation (Rule 14) | Surface raw symptom to user; skip pipeline, request manual triage |
| Verification stage returns `inconclusive` twice   | Surface to user; request manual reproduction   |
| Solution stage cannot produce 3 distinct options  | Escalate to `technical-director` — scope unclear |
| User rejects all 3 options                        | Return to Investigation stage; hypothesis likely wrong |
| Bug reoccurs after fix merges                     | Restart `/diagnose` with new `task_id`; link prior investigation in `unknowns[]` |

## Integration with coordination rules

- **Rule 6 (Layered Recovery):** If any stage fails once, retry with fresh context before escalating
- **Rule 14 (Circuit Breaker):** Read `production/session-state/circuit-state.json` before invoking each agent
- **Rule 15 (Decision Ledger):** Every stage transition logs to `decision_ledger.jsonl`
- **Rule 16 (A2A Handoff):** Stage 1→2, 2→3, 3→4 each require a handoff contract in `.tasks/handoffs/`

## Concrete example — "Flaky checkout test"

**Symptom:** `checkout.e2e.test.ts` fails ~20% of CI runs; local always passes.

```
/diagnose flaky-checkout-e2e
  ↓
Stage 1 → Investigation (diagnostics)
  hypothesis: "Test clicks #submit before React hydration completes on slow CI runners"
  evidence: [CI traces showing hydration marker missing, local has DevTools overhead masking timing]
  confidence: medium (cannot reproduce locally)
  ↓
Stage 2 → Verification (diagnostics)
  triangulation:
    - Inject 500ms delay before click → test passes 50/50 runs ✓
    - Remove delay → fails 9/50 ✗
    - Check for hydration marker instead of fixed delay → passes 50/50 ✓
  status: confirmed
  ↓
Stage 3 → Solution (diagnostics)
  Quick: add sleep(500ms)              [masks issue]
  Strategic: waitFor hydration marker  [addresses root cause]
  Future-Proof: custom test util that always waits for RSC boundary [reusable]
  recommendation: Strategic
  ↓
Stage 4 → lead-programmer
  selects Strategic; assigns to qa-engineer
  handoff contract: "qa-engineer updates checkout.e2e.test.ts to use waitFor(hydrationMarker)"
  acceptance_criteria: ["10 CI runs in a row pass", "no sleep() in test"]
  ledger entry written
```

## Common pitfalls

| Pitfall                                       | Fix                                                                         |
| --------------------------------------------- | --------------------------------------------------------------------------- |
| Hypothesizing before building a loop           | Return to Stage 0. A diagnosis without a signal is speculation.             |
| Skipping Verification ("cause is obvious")    | Verifier exists specifically to catch "obvious but wrong" hypotheses        |
| Investigator produces only 1 hypothesis       | Reject unless evidence makes alternatives impossible; require ranked hypotheses and predictions |
| Solver picks Quick fix without naming tradeoff| Reject — all 3 options required for explicit tradeoff comparison            |
| No artifact written to `.investigations/`     | Reject — verbal diagnosis is not auditable                                  |
| Running `/diagnose` in parallel on same bug   | Only one active investigation per `task_id`; concurrent runs create race   |

## Output to user

After Stage 4 completes, summarize in ≤ 5 lines:

```
/diagnose BUG-417 complete.
Root cause: Unbounded .map+await in OrderService.calculateTotal() exhausts pg pool.
Selected: Strategic (batch via IN-clause, ~40 LOC, Medium risk).
Assigned: @backend-developer; acceptance = load test with 50 items passes.
Artifacts: .investigations/BUG-417/
```
