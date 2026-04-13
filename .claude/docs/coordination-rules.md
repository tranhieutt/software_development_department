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
