# Architecture Review Report by GPT-5.5

**Project:** `E:\SDD-Upgrade`  
**Date:** 2026-04-24  
**Scope:** Overall SDD architecture review, focused on runtime routing, hook
parity, task-state integrity, and audit/ledger consistency.  
**Mode:** Read-only architecture review findings captured as a follow-up report.

---

## Executive Summary

The SDD harness architecture is fundamentally sound: the core Claude-native
control plane, skill registry, Codex adapter, audit scripts, and trace integrity
checks are present and mostly healthy.

The main upgrade need is not a full rewrite. The current priority is to reduce
runtime drift between documented architecture and executable artifacts:

1. Agent routing still references removed/merged agents.
2. Windows hook parity is weaker than the PRD promises.
3. Backlog task-state links point to missing `.tasks` files.
4. One ledger hook still bypasses the shared append helper.

These issues are fixable with targeted upgrades.

---

## Verification Evidence

Fresh checks from the architecture review:

| Check | Result |
| --- | --- |
| `powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1` | Pass |
| `powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1` | 126 pass, 0 fail, 0 warn |
| `node scripts\harness-audit.js repo` | 120/120, 0 blocked, 7 warnings |
| `node scripts\coordination-audit.js` | Pass |
| `node scripts\trace-integrity-check.js` | Pass |
| `git diff --check` | Pass |
| `node tests\hooks\bash-guard.test.js` | Failed locally, 34/34 failed due shell/runtime issue |
| `node tests\hooks\validate-commit.test.js` | Skipped on Windows |

Harness warnings are limited to sensitive credential paths not denied in
`.claude/settings.json`: `.ssh`, `.aws`, `.config/gcloud`, `.azure`, `.gnupg`,
`.docker/config.json`, and `.kube/config`.

---

## Findings

### Finding 1: Diagnostic Skill Routes to Removed Agents

**Priority:** P1  
**File:** `.claude/skills/diagnose/SKILL.md`  
**Line:** 49  

The actual agent registry contains `diagnostics`, but the diagnostic workflow
still routes through `investigator`, `verifier`, `solver`, and `qa-tester`.
Those agents were merged or removed. If `/diagnose` dispatches literally, it can
target non-existent subagents.

**Impact:** High. This affects incident/debugging workflow reliability and can
break the most important recovery path.

**Recommended upgrade:**

- Rewrite `diagnose/SKILL.md` to use `diagnostics` as the unified agent.
- Update examples and handoff text that still mention `investigator`,
  `verifier`, `solver`, or `qa-tester`.
- Add an audit check that skill-declared agent names exist in `.claude/agents`.

---

### Finding 2: Hook Runtime Assumes Unavailable Shells Locally

**Priority:** P1  
**File:** `.claude/settings.json`  
**Line:** 128  

The hook command starts with `pwsh` and falls back to `bash`. On this machine,
`pwsh` is unavailable and `bash` resolves to the Windows WSL launcher, which
fails with `E_ACCESSDENIED`. As a result, `bash-guard.test.js` failed 34/34
locally.

**Impact:** High. The PRD requires Windows and Linux/macOS platform parity, and
security hooks are part of the critical runtime contract.

**Recommended upgrade:**

- Prefer `powershell` fallback when `pwsh` is missing on Windows.
- Detect Git Bash vs WSL Bash explicitly.
- Add `codex-preflight` checks for `pwsh`, `powershell`, Git Bash, WSL Bash,
  `jq`, and `node`.
- Add tests for `.ps1` hook mirrors, not only `.sh` hooks.

---

### Finding 3: TODO Links Point to Missing Task Files

**Priority:** P2  
**File:** `TODO.md`  
**Line:** 10  

`TODO.md` links to `.tasks/001...011`, and later states that every TODO item
must have a matching task file. The `.tasks` directory currently only contains
`TASK_TEMPLATE.md` and placeholder files.

**Impact:** Medium. This breaks producer task-state recovery and weakens the
backlog-to-execution chain.

**Recommended upgrade:**

- Create `.tasks/000...011` from `TASK_TEMPLATE.md`, or update `TODO.md` to
  match actual tracked tasks.
- Add a coordination-audit rule that fails when a TODO task link is missing.
- Keep `.tasks` files in sync whenever producer changes TODO state.

---

### Finding 4: Ledger Writer Bypasses Shared Append Helper

**Priority:** P2  
**File:** `.claude/hooks/decision-ledger-writer.sh`  
**Line:** 23  

`decision-ledger-writer.sh` still requires `jq` and appends directly to
`production/traces/decision_ledger.jsonl`, instead of using
`scripts/ledger-append.sh`. This leaves the ledger-orchestrator cleanup partly
unfinished.

**Impact:** Medium. Ledger writes work today, but schema and fallback behavior
are split across multiple write paths.

**Recommended upgrade:**

- Route `decision-ledger-writer.sh` through `scripts/ledger-append.sh`.
- Preserve fail-open behavior, but use the helper's `jq` or `node` fallback.
- Update `CONTROL_PLANE_MAP.md` and `skills-precedence.md` after the write path
  is unified.

---

## Upgrade Priority

| Priority | Upgrade | Reason |
| --- | --- | --- |
| P1 | Align agent routing with actual `.claude/agents` | Prevent non-existent agent dispatch |
| P1 | Harden Windows hook runtime and tests | Restore platform parity and guard reliability |
| P2 | Restore TODO to `.tasks` invariant | Preserve producer recovery and task auditability |
| P2 | Unify decision ledger write path | Reduce schema drift and dependency split |
| P2 | Add sensitive path denies | Resolve remaining harness audit warnings |
| P3 | Refresh stale docs/counts | Reduce contributor confusion |

---

## Overall Verdict

**Verdict:** Approved with required upgrades before claiming full runtime parity.

The project does not need an architectural rewrite. The right next move is a
targeted hardening pass focused on runtime/documentation alignment:

1. Fix agent-name drift.
2. Fix Windows shell/runtime assumptions.
3. Reconnect backlog items to task files.
4. Consolidate ledger writes.
5. Close the remaining permission warnings after explicit approval.

