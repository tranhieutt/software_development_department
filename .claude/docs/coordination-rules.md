# Agent Coordination Rules

1. **Vertical Delegation**: Leadership agents delegate to department leads, who
   delegate to specialists. Never skip a tier for complex decisions.
2. **Horizontal Consultation**: Agents at the same tier may consult each other
   but must not make binding decisions outside their domain.
3. **Conflict Resolution**: When two agents disagree, escalate to the shared
   parent. If no shared parent, escalate to `cto` for design
   conflicts or `technical-director` for technical conflicts.
4. **Change Propagation**: When a design change affects multiple domains, the
   `producer` agent coordinates the propagation.
5. **No Unilateral Cross-Domain Changes**: An agent must never modify files
   outside its designated directories without explicit delegation.
6. **Layered Recovery Before Escalation**: Before surfacing a blocker to the user,
   agents must attempt recovery in this order — from least to most disruptive:
   1. Re-read the relevant files and retry with fresh context
   2. Delegate to a specialized subagent with the full diagnosis in the prompt
   3. Run `/compact` if context may be stale, then retry once more
   4. Only after all three fail → surface to user with every attempted step documented
7. **Subagent Concurrency Classification**: Before spawning multiple subagents,
   classify each by its side-effect profile:
   - **Concurrent-safe** (read-only — no file writes, no commands): Explore, research,
     Grep/Glob/Read agents → batch and run in parallel
   - **State-modifying** (writes files, runs commands, modifies DB): backend-developer,
     frontend-developer, data-engineer → run sequentially, never overlap on the same domain
8. **Withheld Error Pattern**: Agents must not surface intermediate errors directly to
   the user. Apply layered recovery (Rule 6) first. Only expose the error when all
   recovery options are exhausted — include the full recovery attempt history in the
   report so the user can understand what was tried.
9. **Fail-Open for Optional Agents**: Any subagent handling a background or optional
   task (memory extraction, summary generation, documentation update) must fail-open:
   - If the subagent fails, errors out, or times out → log the failure in `active.md`
     and continue the main workflow without blocking
   - Never let an optional background agent gate a required foreground task
   - Background failures are surfaced as warnings, not blockers
10. **Worktree Isolation for Risky Changes**: Use `isolation: 'worktree'` for any
    subagent task that carries risk of breaking working code:
    - Large refactors touching 5+ files
    - Experimental approaches not yet validated
    - Database migrations or schema changes
    - Changes the agent is not confident about
    The worktree gives a fully isolated copy — review the diff, merge if good, discard
    if not. Never let uncertainty be a reason to avoid attempting a task.
11. **Permission Mode Selection**: Choose the appropriate permission mode before
    starting a task — do not default to the most permissive mode:
    - `plan` — explore and review code without any writes or command execution
    - `default` — normal development; prompt before each side-effecting tool call
    - `acceptEdits` — batch file edits already reviewed; skips per-file prompts
    - `bypassPermissions` — CI pipelines and automation only, with `--allowedTools`
      whitelist specified explicitly
    Never use `bypassPermissions` interactively. Prefer `plan` mode for all
    read-only research tasks to prevent accidental writes.
12. **Verifiable Plan Format**: For any multi-step task, present a plan before
    implementing. Each step must include an inline verification criterion:

    ```text
    1. [Step] → verify: [check]
    2. [Step] → verify: [check]
    3. [Step] → verify: [check]
    ```

    - The verification criterion must be concrete and testable — not "make sure it works"
    - Examples of strong criteria: "tests pass", "endpoint returns 201", "no TS errors"
    - Examples of weak criteria: "looks good", "should be fine", "works as expected"
    - Do not begin implementation until the plan has been presented and approved
    - Single-step tasks with obvious success criteria are exempt

13. **Fullstack Vertical Slicing**: When implementing fullstack features, plan work in vertical slices:
    - Each slice is a functional unit covering database, backend, and frontend.
    - API contracts between layers must be locked (via Design Doc or ADR) before implementation.
    - A slice is not complete until it is integrated and verified end-to-end.
    - Prefer multiple small vertical slices over one large monolithic fullstack task.

14. **Circuit Breaker for Agent Failures**: When an agent fails repeatedly on the same
    task, the system must isolate it and route to a fallback rather than retrying infinitely.

    **States:**
    - `CLOSED` — Agent is operating normally. All tasks routed to it as usual.
    - `OPEN` — Agent has failed 3+ consecutive times. Bypass it immediately; route to
      the designated fallback agent. Log the transition to
      `production/session-state/circuit-state.json`.
    - `HALF-OPEN` — After 10 minutes in OPEN state, allow exactly one retry attempt.
      If it succeeds → return to `CLOSED`. If it fails again → return to `OPEN`.

    **Exponential backoff before tripping OPEN:**
    Apply backoff between retries (do not trip OPEN immediately on first failure):
    - Retry 1: wait 2s
    - Retry 2: wait 4s
    - Retry 3: wait 8s → if still failing, trip to `OPEN`

    **Fallback pairs:**

    | Primary agent | Fallback agent |
    | :--- | :--- |
    | `backend-developer` | `fullstack-developer` |
    | `frontend-developer` | `fullstack-developer` |
    | `qa-tester` | `qa-lead` |
    | `data-engineer` | `backend-developer` |
    | `investigator` | `solver` |

    **Integration with Rule 6 (Layered Recovery):**
    Circuit Breaker activates **after** Rule 6 layered recovery is exhausted.
    Rule 6 handles transient failures (context stale, bad prompt). Circuit Breaker
    handles persistent failures (agent structurally unable to complete the task).

    **State file:** `production/session-state/circuit-state.json`
    Read this file at the start of any multi-agent task to check if a required agent
    is currently `OPEN` and should be bypassed.

    **Ledger obligation:** Every Circuit Breaker state transition must be appended to
    `production/traces/decision_ledger.jsonl` with `risk_tier: "High"`.

15. **Decision Tracing Ledger**: Agents must record significant decisions to
    `production/traces/decision_ledger.jsonl` for audit and debugging.

    **When to write a ledger entry:**
    - Any decision with `risk_tier` Medium or High
    - Any Circuit Breaker state transition (Rule 14)
    - Any cross-agent handoff with non-trivial acceptance criteria
    - Task completion or failure (final outcome of a checkpoint)
    - Any decision that overrides a prior decision in `consensus/merged-decisions.md`

    **Entry format (one JSON object per line):**

    ```jsonl
    {"ts":"<ISO>","session":"<branch>","agent_id":"<agent>","task_id":"<id>","request":"<what was asked>","reasoning":"<why this choice>","choice":"<decision made>","outcome":"pass|fail|blocked|skipped","risk_tier":"High|Medium|Low","duration_s":<N>}
    ```

    **What NOT to log:** Trivial style choices, obvious one-line fixes, read-only
    exploration steps. Keep the ledger focused on decisions worth auditing.

    **Audit tool:** Run `/trace-history` to view the ledger with filters by agent,
    risk tier, task, outcome, or date range.

16. **A2A Handoff Contracts**: When one agent completes its slice and passes work
    to another agent, a formal handoff contract must be generated before the
    receiving agent begins work.

    **When a handoff contract is required:**
    - Any work crossing domain boundaries (backend → QA, frontend → lead-programmer)
    - Any work with `risk_tier` Medium or High
    - Any partial artifact (`artifact_status: partial | draft`) passed between agents

    **When a handoff contract is optional (Low risk, same-domain):**
    - Minor corrections passed back within the same agent turn
    - Read-only review requests with no artifact transfer

    **Protocol:**
    1. Sending agent runs `/handoff <from> <to> <artifact> [task_id]`
    2. Contract is saved to `.tasks/handoffs/<from>-to-<to>-<task_id>.json`
    3. Receiving agent reads the contract and verifies all `acceptance_criteria`
       before starting work
    4. If any criterion fails → receiving agent rejects the handoff and returns
       specific failures to the sender; does NOT begin work on a failing artifact

    **Schema reference:** `.claude/docs/handoff-schema.md`
    **Contracts directory:** `.tasks/handoffs/`
