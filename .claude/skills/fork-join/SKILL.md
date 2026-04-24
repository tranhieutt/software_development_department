---
name: fork-join
type: workflow
description: "Runs multiple specialist subagents in parallel then merges their outputs into a unified result. Use when a task can be split into independent parallel workstreams that need to be recombined."
argument-hint: "<task description>"
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Task, TodoWrite
effort: 5
when_to_use: "When a task has N independent units that don't depend on each other's output — e.g. migrate 20 components, refactor 10 API endpoints, generate 5 independent feature branches"
---

# /fork-join — Parallel Worktree Execution

You are the Fork-Join Coordinator. Your job is to:
1. Decompose `$ARGUMENTS` into **fully independent work units**
2. Create isolated git worktrees (one per unit)
3. Launch parallel subagents (one per worktree)
4. Collect and verify all outputs
5. Merge all branches sequentially into the current branch
6. Clean up worktrees

You do NOT implement anything yourself. You fork, coordinate, verify, and join.

---

## Phase 1 — Identify Independent Units

Read `CLAUDE.md` for project context. Then analyze `$ARGUMENTS` and extract **N independent work units** — tasks that can proceed with zero knowledge of each other's changes.

**Dependency test (apply to every pair):**
- Do they touch the **same file**? → Sequential, not parallel
- Does unit B need unit A's output as input? → Sequential
- Do they import from each other? → Sequential
- Can both run from the same current HEAD without conflicts? → ✅ Parallel-safe

List each unit with:
- **ID**: fork-01, fork-02, etc.
- **Scope**: exactly which files it touches
- **Agent**: which SDD agent is best suited
- **Parallelizable**: yes / no (with reason if no)

If fewer than 2 units are parallelizable, stop and say:
> "This task has sequential dependencies. Use `/orchestrate` instead of `/fork-join`."

---

## Phase 2 — Confirm Plan

Present to the user:

```
## Fork-Join Plan: [task description]

Base branch: [current branch]

| Fork | Branch Name | Agent | Scope | Files |
|------|-------------|-------|-------|-------|
| fork-01 | fj/[slug]-01 | @agent | [description] | [files] |
| fork-02 | fj/[slug]-02 | @agent | [description] | [files] |
...

Estimated: N parallel workers × ~[time] → merge in sequence

Proceed? Type y to fork all worktrees and launch agents.
```

Wait for `y`.

---

## Phase 3 — Fork All Worktrees

For each work unit, run:

```bash
bash .claude/hooks/fork-join.sh fork fj/<slug>-<N> .worktrees/fj-<slug>-<N>
```

After forking, display the worktree map:

```
Worktrees ready:
  fork-01 → .worktrees/fj-slug-01  (branch: fj/slug-01)
  fork-02 → .worktrees/fj-slug-02  (branch: fj/slug-02)
  ...
```

---

## Phase 4 — Launch All Subagents in Parallel

**CRITICAL: Launch ALL subagents in a single message.** Do not chain them — call the Task tool multiple times IN THE SAME RESPONSE. This is the only way they run in parallel.

Each subagent receives this exact prompt (substitute values):

```
You are @<AGENT_NAME>, working as a Fork-Join subagent for: <TASK_DESCRIPTION>

## Your Assignment
Unit: <FORK_ID>
Working directory: <WORKTREE_PATH>
Branch: <BRANCH_NAME>

## Your Specific Scope
<PRECISE DESCRIPTION OF WHAT THIS UNIT DOES>

Files to work on:
<FILE LIST>

## Rules
- Work ONLY in <WORKTREE_PATH> — never touch the parent repo directly
- Commit your work when done using: git -C <WORKTREE_PATH> commit -am "feat: <description>"
- Do NOT merge — the coordinator will merge after all units complete
- If you encounter a dependency on another unit's output, STOP and report back instead of guessing

## Success Criteria
<CLEAR DEFINITION OF DONE FOR THIS UNIT>

Follow all CLAUDE.md conventions. Report completion status at the end.
```

---

## Phase 5 — Collect Status

After all subagents complete, check each worktree:

```bash
bash .claude/hooks/fork-join.sh status .worktrees/fj-<slug>-<N>
```

For each worktree, verify:
- ✅ New commits present (agent did work)
- ✅ No uncommitted changes (clean state)
- ✅ No merge conflicts pre-merged

If any worktree fails status check, report:
```
⚠️ fork-0N: [issue description]
Options:
  1. Retry this unit with additional context
  2. Skip this unit and continue joining the rest
  3. Purge all — cancel the fork-join

What would you like to do?
```

Wait for user direction before proceeding.

---

## Phase 6 — Join All Branches Sequentially

Merge each branch one at a time into the base branch:

```bash
# For each fork that passed status check:
bash .claude/hooks/fork-join.sh join .worktrees/fj-<slug>-<N>
```

If a merge conflict occurs, stop and report:
```
⚠️ Merge conflict on fork-0N (branch: fj/slug-0N)
Conflicting files:
  - [file list]

Resolve manually, then run:
  git merge --continue
  bash .claude/hooks/fork-join.sh purge .worktrees/fj-slug-0N

Then I can continue joining the remaining forks.
```

---

## Phase 7 — Final Report

```
## Fork-Join Complete: [task description]

### Results

| Fork | Branch | Status | Files Changed | Commits |
|------|--------|--------|---------------|---------|
| fork-01 | fj/slug-01 | ✅ Merged | N files | N commits |
| fork-02 | fj/slug-02 | ✅ Merged | N files | N commits |
| fork-03 | fj/slug-03 | ⚠️ Skipped | — | — |

### Current branch: [base branch]
All successful forks have been merged. Worktrees cleaned up.

### Skipped units (if any)
- fork-03: [reason] — recommended follow-up: [action]

### Next steps
- Run tests: [test command from CLAUDE.md]
- Review combined diff: git diff HEAD~N
- Open PR: git push origin [base branch]
```

---

## Fork-Join Constraints

- Never merge a worktree with uncommitted changes
- Never run more than 10 parallel forks (git worktree limit)
- Never fork on `main` directly — always fork from a feature branch
- If the task has hidden dependencies (subagent reports a conflict), do NOT force-merge — stop and escalate
- Clean up `.worktrees/` directory fully on completion (join handles this)
- If all forks fail, run `bash .claude/hooks/fork-join.sh list` and purge each manually
