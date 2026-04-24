---
name: trace-history
type: workflow
description: "Reads and filters production/traces/decision_ledger.jsonl to display a timeline of agent decisions. Supports filtering by agent, risk_tier, task_id, outcome, and date range."
argument-hint: "[--agent <name>] [--risk High|Medium|Low] [--task <task_id>] [--outcome pass|fail|blocked] [--since YYYY-MM-DD] [--last <N>]"
user-invocable: true
allowed-tools: Read, Bash
effort: 1
when_to_use: "Use to audit why a decision was made, debug a failed task, review high-risk choices, or produce a timeline of agent activity for a session or sprint."
---

# Trace History

Read `production/traces/decision_ledger.jsonl` and display a filtered, human-readable
timeline of agent decisions.

## Execution

The rendering and filtering logic is implemented in `scripts/trace-history.sh`.
This skill delegates to that script â€” do NOT re-implement parsing here.

### 1. Run the backing script

Invoke exactly once, passing `$ARGUMENTS` through unchanged:

```bash
bash scripts/trace-history.sh $ARGUMENTS
```

The script handles: flag parsing, filtering, rendering (pretty or JSON),
empty-ledger short-circuit, and invalid-argument rejection. Return the script's
stdout verbatim to the user.

### 2. Supported flags (all optional)

| Flag | Default | Meaning |
| :--- | :--- | :--- |
| `--agent <name>` | all | Filter by `agent_id` |
| `--risk <High\|Medium\|Low>` | all | Filter by `risk_tier` |
| `--task <id>` | all | Substring match on `task_id` |
| `--outcome <pass\|fail\|blocked\|skipped>` | all | Filter by `outcome` |
| `--since <YYYY-MM-DD>` | no limit | Only entries with `ts >= date` |
| `--last <N>` | 20 | Keep last N after other filters |
| `--format <pretty\|json>` | pretty | Output format |

### 3. Output format

**Pretty (default):** timeline with risk badges (ðŸ”´ðŸŸ¡ðŸŸ¢) and outcome emojis
(âœ…âŒâ›”â­ï¸), grouped with separators and totals. Failed/blocked entries trigger
a `/resume-from` hint automatically.

**JSON:** raw matching entries as a JSON array â€” use when piping to another tool.

### 4. Empty or no-match

The script emits `ðŸ“­` messages for an empty ledger or zero-match filter. Return
those messages as-is; do not fabricate data.

---

## How decisions get into the ledger

Agents append one JSON line per significant decision to `production/traces/decision_ledger.jsonl`.

**Append format:**

```jsonl
{"ts":"2026-04-16T10:30:00Z","session":"main","agent_id":"backend-developer","task_id":"042","request":"Choose JWT signing algorithm","reasoning":"RS256 supports multi-service verification without sharing secrets","choice":"RS256 over HS256","outcome":"pass","risk_tier":"Medium","duration_s":18}
```

**When to write a ledger entry (per coordination-rules.md Rule 15):**

- Any decision with `risk_tier` Medium or High
- Any decision that was disputed or required fallback
- Any Circuit Breaker state transition (CLOSED â†’ OPEN â†’ HALF-OPEN)
- Any cross-agent handoff with a non-trivial acceptance criteria
- Task completion or failure (final outcome of a checkpoint)

**Low-risk decisions** (trivial style choices, obvious fixes) may be omitted to keep
the ledger focused on decisions worth auditing.
