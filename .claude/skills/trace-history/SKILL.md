---
name: trace-history
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

## Steps

### 1. Parse arguments

Parse `$ARGUMENTS` for the following optional flags:

| Flag | Default | Meaning |
| :--- | :--- | :--- |
| `--agent <name>` | all | Filter by `agent_id` (e.g. `backend-developer`) |
| `--risk <tier>` | all | Filter by `risk_tier`: `High`, `Medium`, or `Low` |
| `--task <id>` | all | Filter by `task_id` |
| `--outcome <value>` | all | Filter by `outcome`: `pass`, `fail`, `blocked`, `skipped` |
| `--since <date>` | no limit | Only entries with `ts >= YYYY-MM-DD` |
| `--last <N>` | 20 | Show only the last N entries after other filters |

If no arguments are provided, show the last 20 entries across all agents.

### 2. Read the ledger

Read `production/traces/decision_ledger.jsonl`.

If the file is empty or contains only the schema header line:

```text
📭 Decision ledger is empty — no decisions have been traced yet.
   Decisions are written automatically when agents use /save-state or
   make High/Medium risk choices per coordination-rules.md Rule 15.
```

Skip the first line (schema header — starts with `"_schema"`).

### 3. Apply filters

Filter entries by the parsed flags. Each entry is one JSON object per line with fields:
`ts`, `session`, `agent_id`, `task_id`, `request`, `reasoning`, `choice`, `outcome`, `risk_tier`, `duration_s`.

### 4. Render timeline

Display results in this format:

```text
📋 Decision Trace — [applied filters summary]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[ts] [risk_tier badge] @[agent_id] · task:[task_id]
  Request  : [request]
  Reasoning: [reasoning]
  Choice   : [choice]
  Outcome  : [outcome emoji] [outcome] ([duration_s]s)

─────────────────────────────────────────────
[repeat for each entry]

Total: [N] decisions shown · [H] High · [M] Medium · [L] Low risk
```

Risk tier badges:
- `High` → `🔴`
- `Medium` → `🟡`
- `Low` → `🟢`

Outcome emojis:
- `pass` → `✅`
- `fail` → `❌`
- `blocked` → `⛔`
- `skipped` → `⏭️`

### 5. Suggest follow-up

After displaying results, if any `fail` or `blocked` outcomes are shown:

```text
💡 Failed decisions above may have checkpoints in .tasks/checkpoints/
   Run: /resume-from <task_id> to recover.
```

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
- Any Circuit Breaker state transition (CLOSED → OPEN → HALF-OPEN)
- Any cross-agent handoff with a non-trivial acceptance criteria
- Task completion or failure (final outcome of a checkpoint)

**Low-risk decisions** (trivial style choices, obvious fixes) may be omitted to keep
the ledger focused on decisions worth auditing.
