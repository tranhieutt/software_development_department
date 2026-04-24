---
name: diagnose
type: reference
description: "Multi-agent diagnostic pipeline for complex/intermittent bugs. Orchestrates Investigator â†’ Verifier â†’ Solver â†’ Lead Programmer with enforced handoff contracts. Use ONLY for non-obvious failures (root cause unclear, reproduction unstable, fixes reverted). NOT for trivial bugs with known cause â€” fix them directly."
paths: []
effort: 4
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task
user-invocable: true
when_to_use: "When a bug is reproducible but cause is unknown, when a 'fix' has been reverted 2+ times, or when a symptom appears in unfamiliar code. Do NOT use for typos, obvious nulls, or one-line logic errors."
---

# Skill: /diagnose â€” Complex Bug Diagnostic Pipeline

## When to invoke (and when NOT to)

### âœ… Use `/diagnose` when:
- Bug reproduces but **root cause is unclear** after one read-pass of the failing code
- Previous fix attempts have been **reverted â‰¥ 2 times** (symptoms return)
- Failure is **intermittent** (flaky test, race condition, timing-dependent)
- Failure occurs in **unfamiliar code** (agent has no prior context)
- User has explicitly requested `/diagnose` or "deep investigation"
- Circuit Breaker (Rule 14) tripped on the specialist agent that normally handles this domain

### âŒ Do NOT use `/diagnose` when:
- Cause is obvious (null ref, typo, missing import, incorrect import path)
- Fix is < 10 LOC and has a clear success check
- Bug is in code you just wrote this session (read-pass + local reasoning is faster)
- User wants a quick patch and has accepted the tradeoff

## Pipeline overview

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”     â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”     â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”     â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Investigator   â”‚ â”€â”€â–º â”‚    Verifier     â”‚ â”€â”€â–º â”‚    Solver    â”‚ â”€â”€â–º â”‚ Lead Programmer  â”‚
â”‚  (hypothesis)   â”‚     â”‚ (devil's adv.)  â”‚     â”‚  (tradeoffs) â”‚     â”‚  (assign + exec) â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
       â”‚                       â”‚                       â”‚                       â”‚
       â–¼                       â–¼                       â–¼                       â–¼
  investigation.json      verification.json      solution.json          implementation
  (root_cause,           (status: confirmed |    (3 options:           (delegates to
   evidence[],            refuted | inconclusive, Quick/Strategic/     backend-developer,
   confidence)            reproduction_steps)    Future-Proof)         qa-tester, etc.)
```

Each stage produces a **required artifact** saved to `.investigations/<task_id>/` and a **handoff contract** (per Rule 16) to the next agent.

## Stage 1 â€” Investigation

**Agent:** `investigator`
**Goal:** Produce a falsifiable root-cause hypothesis backed by empirical evidence.

### Inputs
- Symptom description (from user or TODO.md bug ID)
- Reproduction steps (or "cannot reproduce" + environment)
- Relevant log lines, stack traces, error IDs

### Required output â€” `investigation.json`
```json
{
  "task_id": "BUG-417",
  "symptom": "POST /api/orders returns 500 when cart has â‰¥10 items",
  "reproduction": {
    "steps": ["...", "..."],
    "frequency": "100% | intermittent (~30%) | once",
    "environment": "staging-eu-west-1"
  },
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
  "next_agent": "verifier"
}
```

### Quality gate (Lead Programmer rejects if):
- `hypothesis.falsifiable_by` is vague ("check if it works")
- `evidence` has fewer than 2 items (unverifiable)
- `unknowns` is empty but `confidence: low` (contradictory)

## Stage 2 â€” Verification

**Agent:** `verifier`
**Goal:** Attempt to **refute** the hypothesis. Only confirmed if refutation fails.

### Inputs
- `investigation.json` (from Stage 1)
- Access to staging/test environment

### Required output â€” `verification.json`
```json
{
  "task_id": "BUG-417",
  "status": "confirmed | refuted | inconclusive",
  "triangulation": [
    {"method": "reproduce_with_fix_applied", "result": "Error gone with pool_size=50"},
    {"method": "reproduce_without_fix", "result": "Error returns at 10 items"},
    {"method": "adjacent_test_case", "result": "9 items = OK, 10 items = fail â†’ threshold confirmed"}
  ],
  "counter_hypotheses_ruled_out": [
    "DB slowness (ruled out: p99 < 50ms)",
    "Network flaps (ruled out: no packet loss in window)"
  ],
  "confidence": "high",
  "recommendation": "Proceed to solver â€” cause confirmed necessary AND sufficient"
}
```

### Decision flow
| `status`       | Next action                                                          |
| -------------- | -------------------------------------------------------------------- |
| `confirmed`    | Hand off to `solver`                                                 |
| `refuted`      | Return to `investigator` with counter-evidence. Max 2 round-trips.   |
| `inconclusive` | STOP. Surface to user with all evidence. Do NOT proceed to solver.   |

## Stage 3 â€” Solution

**Agent:** `solver`
**Goal:** Generate 3 solution options with explicit tradeoffs; never pick silently.

### Required output â€” `solution.json`
```json
{
  "task_id": "BUG-417",
  "options": [
    {
      "name": "Quick",
      "description": "Increase pool_size from 20 â†’ 50 in db.ts",
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
  "recommendation": "Strategic â€” best risk/value ratio. Quick only if release is < 24h."
}
```

### Quality gate
- All 3 options must have distinct scope (not three flavors of the same fix)
- `tradeoff` must state what is **sacrificed**, not just "takes longer"
- `recommendation` must cite a criterion (time budget, risk tier, blast radius)

## Stage 4 â€” Finalization

**Agent:** `lead-programmer`
**Goal:** Select option, assign specialist, track execution.

### Actions
1. Review `solution.json` with user (if `risk_tier: High` or `scope_loc > 100`)
2. Select option â†’ write selection to `.investigations/<task_id>/decision.md`
3. Create A2A handoff contract (Rule 16) via `/handoff`:
   - `lead-programmer â†’ backend-developer` (or `frontend-developer`, `data-engineer`)
   - Acceptance criteria derived from `investigation.hypothesis.falsifiable_by`
4. Append ledger entry (Rule 15) to `production/traces/decision_ledger.jsonl`:
```jsonl
{"ts":"2026-04-17T14:22:00Z","session":"main","agent_id":"lead-programmer","task_id":"BUG-417","request":"/diagnose BUG-417","reasoning":"Verified N+1 as necessary+sufficient; selected Strategic per solver recommendation","choice":"Strategic refactor of calculateTotal()","outcome":"pass","risk_tier":"Medium","duration_s":1840}
```

## Artifact storage

All intermediate reports MUST be saved to `.investigations/<task_id>/`:

```
.investigations/
â””â”€â”€ BUG-417/
    â”œâ”€â”€ investigation.json     # Stage 1 output
    â”œâ”€â”€ verification.json      # Stage 2 output
    â”œâ”€â”€ solution.json          # Stage 3 output
    â”œâ”€â”€ decision.md            # Stage 4 â€” human-readable rationale
    â”œâ”€â”€ evidence/              # logs, screenshots, traces referenced in reports
    â””â”€â”€ handoffs/              # A2A contracts (copied from .tasks/handoffs/)
```

**Retention:** Keep until bug is closed + 30 days, then archive to `.investigations/archive/`.

## Escalation paths

| Trigger                                           | Escalate to                                    |
| ------------------------------------------------- | ---------------------------------------------- |
| `investigator` fails 3Ã— (Rule 14 OPEN)            | Fallback to `solver` with raw symptom          |
| `verifier` returns `inconclusive` twice           | Surface to user; request manual reproduction   |
| `solver` cannot produce 3 distinct options        | Escalate to `technical-director` â€” scope unclear |
| User rejects all 3 options                        | Return to `investigator`; hypothesis likely wrong |
| Bug reoccurs after fix merges                     | Restart `/diagnose` with new `task_id`; link prior investigation in `unknowns[]` |

## Integration with coordination rules

- **Rule 6 (Layered Recovery):** If any stage fails once, retry with fresh context before escalating
- **Rule 14 (Circuit Breaker):** Read `production/session-state/circuit-state.json` before invoking each agent
- **Rule 15 (Decision Ledger):** Every stage transition logs to `decision_ledger.jsonl`
- **Rule 16 (A2A Handoff):** Stage 1â†’2, 2â†’3, 3â†’4 each require a handoff contract in `.tasks/handoffs/`

## Concrete example â€” "Flaky checkout test"

**Symptom:** `checkout.e2e.test.ts` fails ~20% of CI runs; local always passes.

```
/diagnose flaky-checkout-e2e
  â†“
Stage 1 â†’ investigator
  hypothesis: "Test clicks #submit before React hydration completes on slow CI runners"
  evidence: [CI traces showing hydration marker missing, local has DevTools overhead masking timing]
  confidence: medium (cannot reproduce locally)
  â†“
Stage 2 â†’ verifier
  triangulation:
    - Inject 500ms delay before click â†’ test passes 50/50 runs âœ“
    - Remove delay â†’ fails 9/50 âœ—
    - Check for hydration marker instead of fixed delay â†’ passes 50/50 âœ“
  status: confirmed
  â†“
Stage 3 â†’ solver
  Quick: add sleep(500ms)              [masks issue]
  Strategic: waitFor hydration marker  [addresses root cause]
  Future-Proof: custom test util that always waits for RSC boundary [reusable]
  recommendation: Strategic
  â†“
Stage 4 â†’ lead-programmer
  selects Strategic; assigns to qa-tester
  handoff contract: "qa-tester updates checkout.e2e.test.ts to use waitFor(hydrationMarker)"
  acceptance_criteria: ["10 CI runs in a row pass", "no sleep() in test"]
  ledger entry written
```

## Common pitfalls

| Pitfall                                       | Fix                                                                         |
| --------------------------------------------- | --------------------------------------------------------------------------- |
| Skipping Verification ("cause is obvious")    | Verifier exists specifically to catch "obvious but wrong" hypotheses        |
| Investigator produces only 1 hypothesis       | Reject â€” require `counter_hypotheses_ruled_out[]` list in Stage 2           |
| Solver picks Quick fix without naming tradeoff| Reject â€” all 3 options required for explicit tradeoff comparison            |
| No artifact written to `.investigations/`     | Reject â€” verbal diagnosis is not auditable                                  |
| Running `/diagnose` in parallel on same bug   | Only one active investigation per `task_id`; concurrent runs create race   |

## Output to user

After Stage 4 completes, summarize in â‰¤ 5 lines:

```
/diagnose BUG-417 complete.
Root cause: Unbounded .map+await in OrderService.calculateTotal() exhausts pg pool.
Selected: Strategic (batch via IN-clause, ~40 LOC, Medium risk).
Assigned: @backend-developer; acceptance = load test with 50 items passes.
Artifacts: .investigations/BUG-417/
```
