# Agent Coordination Rules

**Coordination-policy read gate:** Before changing this file, weakening an
existing coordination protocol, or removing a MUST/SHOULD rule, query prior
blocked and failed decisions with `/trace-history --outcome blocked --last 20`
and `/trace-history --outcome fail --last 20`. The PR or change note must cite
the relevant history or state that no relevant prior blocked/failed decision was
found. If `/trace-history` is unavailable, document the equivalent ledger query
used instead.

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
   agents must attempt recovery in this order - from least to most disruptive:
   1. Re-read the relevant files and retry with fresh context
   2. Delegate to a specialized subagent with the full diagnosis in the prompt
   3. For High-risk retries after a failed orchestration or repeated blocked
      attempt, query `/trace-history --outcome blocked --last 20` and
      `/trace-history --outcome fail --last 20` before retrying. Record
      `prior_blocked_query: true` and `prior_failed_query: true`, or an
      equivalent note, in the retry ledger entry.
   4. Run `/compact` if context may be stale, then retry once more
   5. Only after all recovery steps fail -> surface to user with every attempted
      step documented
7. **Subagent Concurrency Classification**: Before spawning multiple subagents,
   classify each by its side-effect profile:
   - **Concurrent-safe** (read-only - no file writes, no commands): Explore, research,
     Grep/Glob/Read agents -> batch and run in parallel
   - **State-modifying** (writes files, runs commands, modifies DB): backend-developer,
     frontend-developer, data-engineer -> run sequentially, never overlap on the same domain
8. **Withheld Error Pattern**: Agents must not surface intermediate errors directly to
   the user. Apply layered recovery (Rule 6) first. Only expose the error when all
   recovery options are exhausted - include the full recovery attempt history in the
   report so the user can understand what was tried.
9. **Fail-Open for Optional Agents**: Any subagent handling a background or optional
   task (memory extraction, summary generation, documentation update) must fail-open:
   - If the subagent fails, errors out, or times out -> log the failure in `active.md`
     and continue the main workflow without blocking
   - Never let an optional background agent gate a required foreground task
   - Background failures are surfaced as warnings, not blockers
10. **Worktree Isolation for Risky Changes**: Use `isolation: 'worktree'` for any
    subagent task that carries risk of breaking working code:
    - Large refactors touching 5+ files
    - Experimental approaches not yet validated
    - Database migrations or schema changes
    - Changes the agent is not confident about
    The worktree gives a fully isolated copy - review the diff, merge if good, discard
    if not. Never let uncertainty be a reason to avoid attempting a task.
11. **Permission Mode Selection**: Choose the appropriate permission mode before
    starting a task - do not default to the most permissive mode:
    - `plan` - explore and review code without any writes or command execution
    - `default` - normal development; prompt before each side-effecting tool call
    - `acceptEdits` - batch file edits already reviewed; skips per-file prompts
    - `bypassPermissions` - CI pipelines and automation only, with `--allowedTools`
      whitelist specified explicitly
    Never use `bypassPermissions` interactively. Prefer `plan` mode for all
    read-only research tasks to prevent accidental writes.
12. **Verifiable Plan Format**: For any multi-step task, present a plan before
    implementing. Each step must include an inline verification criterion:

    ```text
    1. [Step] -> verify: [check]
    2. [Step] -> verify: [check]
    3. [Step] -> verify: [check]
    ```

    - The verification criterion must be concrete and testable - not "make sure it works"
    - Examples of strong criteria: "tests pass", "endpoint returns 201", "no TS errors"
    - Examples of weak criteria: "looks good", "should be fine", "works as expected"
    - Do not begin implementation until the plan has been presented and approved
    - Single-step tasks with obvious success criteria are exempt

13. **Fullstack Vertical Slicing**: When implementing fullstack features, plan work in vertical slices:
    - Each slice is a functional unit covering database, backend, and frontend.
    - API contracts between layers must be locked (via Design Doc or ADR) before implementation.
    - A slice is not complete until it is integrated and verified end-to-end.
    - Prefer multiple small vertical slices over one large monolithic fullstack task.

14. **Circuit Breaker Routing for Agent Failures**: When persistent Task execution
    failures occur, route around weak spots instead of retrying infinitely.

    **Mechanism authority:**
    - Circuit state, thresholds, TTL, and transitions are defined by
      `docs/internal/adr/ADR-004-unified-failure-state-machine.md`
    - Conflict resolution and Rule 14 scope are defined by
      `docs/internal/adr/ADR-005-resolve-rule14-vs-adr004-conflict.md`
    - The single source of truth state file is `.claude/memory/circuit-state.json`

    **Fallback pairs:**

    | Primary agent | Fallback agent |
    | :--- | :--- |
    | `backend-developer` | `fullstack-developer` |
    | `frontend-developer` | `fullstack-developer` |
    | `qa-engineer` | `fullstack-developer` |
    | `data-engineer` | `backend-developer` |

    **Routing semantics:**
    - Circuit Breaker activates **after** Rule 6 layered recovery is exhausted.
      Rule 6 handles transient failures; the circuit handles persistent execution-health
      degradation.
    - When the circuit is `HALF_OPEN`, the orchestrator MAY route non-critical sub-tasks
      to the fallback agent. For critical sub-tasks, prefer the primary agent because
      `HALF_OPEN` is the probe phase.
    - When the circuit is `OPEN`, the orchestrator SHOULD route Task dispatches to the
      fallback agent or surface to the human if no suitable fallback exists.

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

    **Allowed extension fields:** High-risk retry entries may include
    `prior_blocked_query: true` and `prior_failed_query: true` when the retry
    followed the read gate in Rule 6.

    **What NOT to log:** Trivial style choices, obvious one-line fixes, read-only
    exploration steps. Keep the ledger focused on decisions worth auditing.

    **Audit tool:** Run `/trace-history` to view the ledger with filters by agent,
    risk tier, task, outcome, or date range.

16. **A2A Handoff Contracts** *(SHOULD — recommended practice, not enforced)*:
    When one agent completes its slice and passes work to another agent, a handoff
    summary is recommended before the receiving agent begins work.

    **When a handoff summary is strongly recommended:**
    - Any work crossing domain boundaries (backend -> QA, frontend -> lead-programmer)
    - Any work with `risk_tier` High
    - Any partial artifact (`artifact_status: partial | draft`) passed between agents

    **When a handoff summary can be skipped:**
    - `risk_tier` Low or Medium with same-domain work
    - Minor corrections passed back within the same agent turn
    - Read-only review requests with no artifact transfer

    **Lightweight protocol (default):**
    1. Sending agent states exactly three fields: what was built, what's missing, acceptance criteria
    2. `/orchestrate` should auto-carry this 3-field summary into the downstream cross-domain prompt
    3. Receiving agent acknowledges and verifies the criteria before starting work
    4. Formal contract file in `.tasks/handoffs/` is optional — use only for High-risk cross-domain work or when a durable artifact is explicitly requested

    > **Note (2026-04-21):** Downgraded from MUST to SHOULD — no handoff contracts were
    > generated across multiple sessions, indicating the full protocol has too much friction.
    > Lightweight text summaries achieve 80% of the value with near-zero overhead.

    **Protocol removal/weaken gate:** Before deleting this rule, weakening its
    scope further, or removing any existing protocol, query
    `/trace-history --outcome blocked --last 20` and cite the adoption/failure
    history in the PR or change note.
