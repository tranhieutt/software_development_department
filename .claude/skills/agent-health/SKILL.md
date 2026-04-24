---
name: agent-health
type: workflow
description: "Reads production/traces/agent-metrics.jsonl and displays a per-agent performance summary table for the current or a specified session. Highlights agents with high error rates or OPEN circuit breaker state."
argument-hint: "[--session <branch>] [--agent <name>] [--since <YYYY-MM-DD>] [--log]"
user-invocable: true
allowed-tools: Read, Write, Bash
effort: 1
when_to_use: "Run at the end of a session, sprint, or after repeated agent failures to identify which agents are struggling. Also useful before dispatching a multi-agent workflow to check circuit breaker states."
---

# Agent Health

Display a performance summary table from `production/traces/agent-metrics.jsonl`,
cross-referenced with `production/session-state/circuit-state.json` for live
circuit breaker states.

## Steps

### 1. Parse arguments

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--session <branch>` | current branch | Filter entries by `session` field |
| `--agent <name>` | all | Show only this agent |
| `--since <date>` | no limit | Only entries with `date >= YYYY-MM-DD` |
| `--log` | false | If set, append a fresh metrics snapshot to `agent-metrics.jsonl` |

Get current branch: `git branch --show-current`.

### 2. Read data sources

Read both files in parallel:

- `production/traces/agent-metrics.jsonl` â€” historical metrics per agent per session
- `production/session-state/circuit-state.json` â€” live circuit breaker states

If `agent-metrics.jsonl` contains only the schema header line (no actual entries):

```text
ðŸ“­ No agent metrics recorded yet for this session.
   Metrics are written when agents use /agent-health --log
   or at the end of a session via /save-state.

Circuit breaker states (live):
[show table from circuit-state.json only]
```

### 3. Aggregate metrics

For each agent, compute across the filtered entries:

- `total_tasks` = `tasks_completed` + `tasks_failed` + `tasks_blocked`
- `success_rate` = `tasks_completed / total_tasks * 100` (0 if no tasks)
- `error_rate` = latest `error_rate` field value
- `circuit_state` = from `circuit-state.json` (live, not from log)

### 4. Render health table

```text
ðŸ¥ Agent Health Report â€” session: <branch> Â· <date range>
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”

Agent                  Tasks  âœ… Done  âŒ Failed  â›” Blocked  Success%  Circuit
â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
backend-developer          8       7          1          0      87.5%   ðŸŸ¢ CLOSED
frontend-developer         5       5          0          0     100.0%   ðŸŸ¢ CLOSED
qa-engineer                  6       4          2          0      66.7%   ðŸŸ¡ HALF-OPEN
data-engineer              2       2          0          0     100.0%   ðŸŸ¢ CLOSED
diagnostics                1       0          1          0       0.0%   ðŸ”´ OPEN
â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
TOTAL                     22      18          4          0      81.8%

âš ï¸  Agents needing attention:
  ðŸ”´ diagnostics      â€” Circuit OPEN Â· fallback: surface to user
  ðŸŸ¡ qa-engineer        â€” Circuit HALF-OPEN Â· 2 failures this session
```

Circuit state icons:
- `ðŸŸ¢ CLOSED` â€” healthy
- `ðŸŸ¡ HALF-OPEN` â€” recovering, monitor closely
- `ðŸ”´ OPEN` â€” bypassed, routed to fallback

Flag agents as needing attention if:
- `circuit_state` is `OPEN` or `HALF-OPEN`
- `success_rate` < 70%
- `tasks_failed` >= 2

### 5. Log snapshot (if --log)

If `--log` flag was passed, append one entry per active agent to
`production/traces/agent-metrics.jsonl`:

```jsonl
{"date":"<YYYY-MM-DD>","session":"<branch>","agent":"<agent>","tasks_completed":<N>,"tasks_failed":<N>,"tasks_blocked":<N>,"avg_tokens_est":<N>,"error_rate":<0.0-1.0>,"circuit_state":"CLOSED|OPEN|HALF-OPEN","notes":"<optional>"}
```

Get `circuit_state` from `circuit-state.json`. Estimate `avg_tokens_est` from
decision ledger entry count Ã— 800 tokens (rough estimate per entry) if no exact
token data is available. Note this is an estimate and mark with `_est` suffix.

Print after logging:

```text
âœ… Metrics snapshot logged â†’ production/traces/agent-metrics.jsonl
   [N] agents recorded Â· <date>
```

### 6. Suggest actions

After the table, if any agents need attention:

```text
ðŸ’¡ Suggested actions:
  â€¢ /resume-from <task_id>        â€” recover failed task checkpoint
  â€¢ /trace-history --risk High    â€” audit high-risk decisions
  â€¢ Check circuit-state.json      â€” update OPEN agents once issue resolved
```

---

## How metrics get into the file

Agents append entries in two ways:

1. **Manual:** Run `/agent-health --log` at end of session
2. **Via `/save-state`:** When saving state with a `task_id`, metrics for the
   active agent are appended automatically

The file grows one JSON line per agent per session. Use `--since` to filter
to recent sessions and avoid reading stale data from weeks ago.

---

## Quick examples

```bash
# Summary for current session
/agent-health

# Check one agent across all time
/agent-health --agent qa-engineer

# Log a fresh snapshot and view it
/agent-health --log

# Review last 7 days
/agent-health --since 2026-04-09
```
