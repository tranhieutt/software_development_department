---
name: handoff
type: workflow
description: "Generates the lightweight 3-field handoff summary for cross-domain work and optionally persists a formal handoff artifact for High-risk transfers."
argument-hint: "<from-agent> <to-agent> <artifact> [task_id] [--risk Low|Medium|High] [--status complete|partial|draft] [--criteria \"crit1\" \"crit2\"] [--formal]"
user-invocable: true
allowed-tools: Read, Write, Bash
effort: 1
when_to_use: "Run when a cross-domain handoff needs an explicit 3-field summary, or when a High-risk transfer needs a durable handoff file in addition to the summary."
---

# Handoff

Generate the lightweight handoff summary (`what was built`, `what's missing`,
`acceptance criteria`) and, when needed, save a formal handoff artifact to
`.tasks/handoffs/`. The receiver verifies the summary before starting work.

## Steps

### 1. Parse arguments

Extract from `$ARGUMENTS`:

| Positional | Required | Description |
| :--- | :--- | :--- |
| `<from-agent>` | yes | Sending agent name (e.g. `backend-developer`) |
| `<to-agent>` | yes | Receiving agent name (e.g. `qa-engineer`) |
| `<artifact>` | yes | Primary file or path being handed off |
| `[task_id]` | no | Task ID to link checkpoint — auto-detected from active checkpoint if omitted |

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--risk` | `Medium` | Risk tier: `Low`, `Medium`, `High` |
| `--status` | `complete` | Artifact status: `complete`, `partial`, `draft` |
| `--criteria` | prompt | Acceptance criteria strings (can be multi-value) |
| `--formal` | off | Force writing a durable handoff file even when risk is not High |

If `from-agent`, `to-agent`, or `artifact` are missing, print usage and stop:

```text
Usage: /handoff <from-agent> <to-agent> <artifact> [task_id] \
                [--risk Low|Medium|High] \
                [--status complete|partial|draft] \
                [--criteria "criterion 1" "criterion 2"] \
                [--formal]

Example:
  /handoff backend-developer qa-engineer src/api/auth.ts 042 \
           --risk Medium --criteria "POST /auth returns 201" "Invalid creds → 401"

Schema reference: .claude/docs/handoff-schema.md
```

### 2. Validate agents

Check that `<from-agent>.md` and `<to-agent>.md` exist in `.claude/agents/`.
If either is missing, warn but continue:

```text
⚠️  Agent "<name>" not found in .claude/agents/ — check spelling.
```

### 3. Resolve task_id and context_snapshot

- If `task_id` was provided, check if `.tasks/checkpoints/<task_id>.md` exists.
  If yes, set `context_snapshot` to that path.
- If `task_id` was NOT provided, scan `.tasks/checkpoints/` for the most recently
  modified `.md` file (excluding `.gitkeep`) and use it as a suggestion.
- If no checkpoint exists, set `context_snapshot` to `null`.

### 4. Collect acceptance criteria

If `--criteria` flags were provided, use them directly.

If no criteria were provided, prompt:

```text
📋 Enter acceptance criteria for this handoff (one per line, blank line to finish):
>
```

Require at least 1 criterion. Reject vague criteria and ask for a rewrite:

- Contains "works correctly", "looks good", "should be fine", "seems OK" → reject
- Must describe a concrete, testable outcome

### 5. Get session info

Run `git branch --show-current` to get the current branch for the `session` field.
Get current ISO timestamp for `ts`.

### 6. Generate handoff summary

Build the 3-field summary per `.claude/docs/handoff-schema.md`:

```markdown
## Handoff Summary
- What was built: <artifact> is available with its current behavior/status
- What's missing: remaining gaps, partial work, or "Nothing blocking in current scope"
- Acceptance criteria:
  - <crit1>
  - <crit2>
```

Also prepare the formal JSON payload only when:
- `risk_tier` is `High` and the handoff crosses domains, or
- the caller passes `--formal`

When the formal artifact is needed, use this JSON:

```json
{
  "from": "<from-agent>",
  "to": "<to-agent>",
  "task_id": "<task_id or null>",
  "artifact": "<artifact>",
  "artifact_status": "<status>",
  "acceptance_criteria": ["<crit1>", "<crit2>"],
  "context_snapshot": "<path or null>",
  "risk_tier": "<risk>",
  "ts": "<ISO>",
  "session": "<branch>"
}
```

### 7. Save formal contract when required

If formal persistence is required, write to
`.tasks/handoffs/<from-agent>-to-<to-agent>-<task_id>.json`.
If `task_id` is null, use timestamp:
`.tasks/handoffs/<from-agent>-to-<to-agent>-<ts-compact>.json`.

If formal persistence is not required, do not create a file. The markdown
handoff summary is the default artifact.

### 8. Ledger entry (Medium / High risk only)

If `risk_tier` is `Medium` or `High`, append to `production/traces/decision_ledger.jsonl`:

```jsonl
{"ts":"<ISO>","session":"<branch>","agent_id":"<from-agent>","task_id":"<task_id>","request":"Handoff to <to-agent>","reasoning":"Artifact <artifact> is <status> — transferring ownership","choice":"Handoff summary prepared","outcome":"pass","risk_tier":"<risk>","duration_s":0}
```

### 9. Display and confirm

Print the summary first, then note whether a durable file was written:

```text
🤝 Handoff Summary Generated
━━━━━━━━━━━━━━━━━━━━━━━━━━

  From  : @<from-agent>
  To    : @<to-agent>
  Task  : <task_id>
  File  : <artifact> [<status>]
  Risk  : <risk_tier>

  What was built:
    <one-line built summary>

  What's missing:
    <one-line gap summary>

  Acceptance Criteria:
    - <criterion 1>
    - <criterion 2>

  Context Snapshot: <path or "none">
  [if formal]: Saved to .tasks/handoffs/<filename>.json
  [if Medium/High]: Ledger entry written.

📨 Ready to hand off. @<to-agent> should verify the summary above
   before starting work on <artifact>.
```

---

## Receiver Protocol

When an agent receives a handoff, it must:

1. Read the 3-field summary (and the formal file if one exists)
2. Verify each `acceptance_criterion` against the artifact
3. If all criteria pass → begin work
4. If any criterion fails → do NOT start work; reply to sender with:

```text
❌ Handoff rejected — criterion failed:
   "<failing criterion>"
   Artifact: <artifact>
   Action needed: <specific fix required>
```

---

## Quick Examples

```bash
# Basic handoff — backend to QA
/handoff backend-developer qa-engineer src/api/auth.ts 042

# With explicit criteria and risk
/handoff frontend-developer lead-programmer src/components/LoginForm.tsx 055 \
  --risk Low --status partial \
  --criteria "Form renders without errors" "Submit disabled when fields empty"

# Draft handoff for review before final delivery
/handoff data-engineer backend-developer src/db/migrations/004_add_users.sql 031 \
  --status draft --risk High --formal \
  --criteria "Migration runs without error on empty DB" "Down migration restores schema"
```
