# Hook Responsibility Matrix

> **Spec ref:** §15.4 — required artifact for hook surface legibility.
> **Source of truth:** `.claude/settings.json` (registered hooks) + `.claude/hooks/` (implementations).
> **Last updated:** 2026-04-19 (v1.41.0)

Each hook is mapped to: lifecycle event → trigger matcher → file → responsibility → files it reads/writes → execution order within slot.

---

## Legend

| Symbol | Meaning                                                      |
| ------ | ------------------------------------------------------------ |
| ✅      | Registered in `settings.json`                                |
| 🔧      | Utility — invoked by another hook, NOT directly by lifecycle |
| ❌      | Not registered (PS1 mirror or orphan)                        |
| R      | Reads file                                                   |
| W      | Writes file                                                  |
| RW     | Reads and writes file                                        |

---

## SessionStart

| Order | Hook                 | Matcher | Responsibility                                         | Reads                                | Writes                      | Timeout |
| ----- | -------------------- | ------- | ------------------------------------------------------ | ------------------------------------ | --------------------------- | ------- |
| 1     | `session-start.sh` ✅ | _(all)_ | Bootstrap `active.md` if absent; display session state | `production/session-state/active.md` | `active.md`                 | 10s     |
| 2     | `detect-gaps.sh` ✅   | _(all)_ | Scan for spec drift — missing files, broken refs       | `.claude/` tree                      | `hook-errors.log` (if gaps) | 10s     |

---

## UserPromptSubmit

| Order | Hook                  | Matcher | Responsibility                                                     | Reads                               | Writes                | Timeout |
| ----- | --------------------- | ------- | ------------------------------------------------------------------ | ----------------------------------- | --------------------- | ------- |
| 1     | `prompt-context.sh` ✅ | _(all)_ | Inject Tier 2 memory context into prompt based on keyword triggers | `.claude/memory/*.md` (conditional) | — (stdout injection)  | 10s     |
| 2     | `persist-memory.sh` ✅ | _(all)_ | Detect and persist new facts spoken in prompt to memory files      | `.claude/memory/`                   | `.claude/memory/*.md` | 5s      |

> **Ordering note:** `prompt-context.sh` must run before `persist-memory.sh` — read before write to avoid injecting mid-write state.

---

## PreToolUse

| Order | Hook                       | Matcher       | Responsibility                                                                         | Reads                               | Writes                           | Timeout |
| ----- | -------------------------- | ------------- | -------------------------------------------------------------------------------------- | ----------------------------------- | -------------------------------- | ------- |
| 1     | `bash-guard.sh` ✅          | `Bash`        | Deny-list enforcement — blocks dangerous commands before execution                     | `settings.json` deny rules          | `hook-errors.log` (on violation) | 5s      |
| 2     | `validate-commit.sh` ✅     | `Bash`        | Intercepts `git commit` — validates message format, branch rules, jq-schema for ledger | —                                   | stderr (on validation fail)      | 30s     |
| 3     | `validate-push.sh` ✅       | `Bash`        | Intercepts `git push` — validates remote target, branch protection                     | —                                   | stderr (on violation)            | 10s     |
| 4     | `circuit-guard.sh` ✅       | `Task`        | Check circuit-breaker state before dispatching subagents                               | `.claude/memory/circuit-state.json` | — (blocks task if OPEN)          | 5s      |
| 5     | `pre-refactor-impact.sh` ✅ | `Write\|Edit` | Run GitNexus impact check on files about to be written                                 | GitNexus index                      | `active.md` (impact warning)     | 10s     |
| 6     | `file-history.sh` ✅        | `Read`        | Log which files are being read for partial-read tracking                               | —                                   | `active.md` §Partial Reads       | 5s      |

---

## PostToolUse

| Order | Hook                          | Matcher       | Responsibility                                                                   | Reads        | Writes                                    | Timeout |
| ----- | ----------------------------- | ------------- | -------------------------------------------------------------------------------- | ------------ | ----------------------------------------- | ------- |
| 1     | `log-writes.sh` ✅             | `Write\|Edit` | Append written file to `active.md` §Files This Session                           | —            | `active.md`                               | 5s      |
| 2     | `validate-assets.sh` ✅        | `Write\|Edit` | Validate markdown/JSON assets after write (schema, frontmatter)                  | Written file | `hook-errors.log` (on invalid)            | 10s     |
| 3     | `log-commit.sh` ✅             | `Bash`        | If command was `git commit`, append `ledger/v1` entry to `decision_ledger.jsonl` | git log      | `production/traces/decision_ledger.jsonl` | 5s      |
| 4     | `decision-ledger-writer.sh` ✅ | `Task`        | After subagent Task completes, write structured `ledger/v1` entry                | task result  | `production/traces/decision_ledger.jsonl` | 5s      |
| 5     | `circuit-updater.sh` ✅        | `Task`        | Update circuit-breaker state based on task outcome (SUCCESS/FAIL)                | task result  | `.claude/memory/circuit-state.json`       | 5s      |

> **Overlap note (P1.5):** `log-commit.sh` (Bash matcher) and `decision-ledger-writer.sh` (Task matcher) both append to `decision_ledger.jsonl` at different event slots. No conflict today (different matchers), but consolidation into a shared `ledger-append.sh` helper is tracked as P1.5.

---

## PreCompact

| Order | Hook               | Matcher | Responsibility                                     | Reads       | Writes                                   | Timeout |
| ----- | ------------------ | ------- | -------------------------------------------------- | ----------- | ---------------------------------------- | ------- |
| 1     | `pre-compact.sh` ✅ | _(all)_ | Snapshot session state before context is compacted | `active.md` | `active.md` (COMPACT marker), `archive/` | 10s     |

---

## Stop (SessionStop)

| Order | Hook                | Matcher | Responsibility                                                                  | Reads                    | Writes                           | Timeout |
| ----- | ------------------- | ------- | ------------------------------------------------------------------------------- | ------------------------ | -------------------------------- | ------- |
| 1     | `session-stop.sh` ✅ | _(all)_ | Write final session summary; invoke `auto-dream.sh` if memory approaching limit | `active.md`, `MEMORY.md` | `archive/sessions/`, `MEMORY.md` | 10s     |

> **Implicit invocation:** `session-stop.sh` calls `auto-dream.sh` at lines 53–56 with error trap writing to `hook-errors.log` on failure.

---

## SubagentStart

| Order | Hook             | Matcher | Responsibility                                                        | Reads | Writes      | Timeout |
| ----- | ---------------- | ------- | --------------------------------------------------------------------- | ----- | ----------- | ------- |
| 1     | `log-agent.sh` ✅ | _(all)_ | Log subagent invocation (agent id, task) to `active.md` §Subagent Log | —     | `active.md` | 5s      |

---

## Utilities (Not Lifecycle Hooks)

| File              | Classification | Invoked By                                                     | Responsibility                                                                                                                         |
| ----------------- | -------------- | -------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `fork-join.sh` 🔧  | **Utility**    | Agent via `Bash(bash .claude/hooks/fork-join.sh *)` allow-list | Dispatch parallel subagents and collect results. NOT a lifecycle hook — registered in `allow` list, not `hooks` block. See §P2.6 note. |
| `auto-dream.sh` 🔧 | **Utility**    | `session-stop.sh` (implicit call)                              | Consolidate MEMORY.md when approaching 40-line limit. Not in `hooks` block by design — invoked conditionally.                          |

---

## PS1 Mirrors (Unregistered — Windows Parity)

| File                    | Status         | Bash Equivalent      | Decision                                                                                                                                   |
| ----------------------- | -------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `bash-guard.ps1` ❌      | Not registered | `bash-guard.sh`      | Sync contract: kept as fallback for PowerShell-only environments. Must be manually kept in sync with bash version. See P2.4 decision note. |
| `session-start.ps1` ❌   | Not registered | `session-start.sh`   | Same as above.                                                                                                                             |
| `validate-commit.ps1` ❌ | Not registered | `validate-commit.sh` | Same as above.                                                                                                                             |

> **P2.4 Decision (2026-04-19):** PS1 hooks are **retained as manual-sync mirrors**, not deleted. Rationale: Windows-without-WSL environments need them. Risk: logic drift between .sh and .ps1 versions. Mitigation: document sync obligation here. Owner: any contributor modifying the bash version must update the .ps1 version in the same commit.

---

## Summary Counts

| Category                            | Count                               |
| ----------------------------------- | ----------------------------------- |
| Registered lifecycle hooks          | 18                                  |
| Utility scripts (not lifecycle)     | 2 (`fork-join.sh`, `auto-dream.sh`) |
| PS1 mirrors (not registered)        | 3                                   |
| **Total files in `.claude/hooks/`** | **23**                              |
