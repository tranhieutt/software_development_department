---
name: map-workflow
description: "Generates a structured multi-agent workflow graph from a pattern and agent list. Supports Sequential, Parallel, Hierarchical, and Iterative patterns. Used by @producer to plan feature delivery before any implementation begins."
argument-hint: "--pattern <name> --agents <list> --task <description> [--max-iter <N>] [--save <filename>]"
user-invocable: true
allowed-tools: Read, Write, Bash
effort: 2
when_to_use: "Use at the start of any multi-agent feature or sprint wave. Always run BEFORE implementation. Output the graph for user approval before dispatching any agent."
---

# Map Workflow

Generate a workflow graph for a multi-agent task using one of four patterns.
Present the graph to the user for approval before any agent is dispatched.

## Steps

### 1. Parse arguments

Extract from `$ARGUMENTS`:

| Flag | Required | Default | Description |
| :--- | :--- | :--- | :--- |
| `--pattern` | yes | — | `Sequential`, `Parallel`, `Hierarchical`, or `Iterative` |
| `--agents` | yes | — | Comma-separated agent names in execution order |
| `--task` | yes | — | One-sentence description of what this workflow delivers |
| `--max-iter` | no | `3` | Max loop iterations (Iterative pattern only) |
| `--save` | no | none | If set, write the graph to `.tasks/[filename].workflow.md` |

If `--pattern` or `--agents` or `--task` is missing, print usage and stop:

```text
Usage: /map-workflow --pattern <Sequential|Parallel|Hierarchical|Iterative> \
                     --agents "<agent1,agent2,...>" \
                     --task "<what this workflow delivers>" \
                     [--max-iter <N>] [--save <filename>]

Patterns:
  Sequential   — linear pipeline, one agent after another
  Parallel     — fan-out to multiple agents simultaneously, then merge
  Hierarchical — supervisor delegates to specialists
  Iterative    — test-driven loop until quality gate passes

Reference: docs/templates/workflow-graph.md
```

### 2. Validate agents

For each agent name in `--agents`, verify it exists in `.claude/agents/`.
If an agent is not found, warn but continue:

```text
⚠️  Agent "foo-developer" not found in .claude/agents/ — check spelling.
    Proceeding with remaining agents.
```

### 3. Generate the workflow graph

Using the pattern and agents, fill in the workflow schema from
`docs/templates/workflow-graph.md`. Apply these rules per pattern:

**Sequential:** Each agent becomes one node. `on_pass` chains to the next agent.
`on_fail: stop` for all nodes.

**Parallel:** First agent in list becomes the `orchestrate` node. Last agent
becomes the `merge` node. All middle agents run in parallel from orchestrate
to merge. A `qa-tester` node is appended after merge if not already in the list.

**Hierarchical:** First agent becomes the `plan` (supervisor) node.
Remaining agents are parallel specialist nodes. First agent is also the final
`review` node. All specialists must complete before review.

**Iterative:** Exactly 2 agents required — first is the implementer,
second is the tester. Loop: implementer → tester → [fail→implementer | pass→done].
Cap at `--max-iter` iterations.

### 4. Display the graph

Show the filled YAML schema and an ASCII flow diagram:

```text
🗺️  Workflow Graph — [pattern] · [task]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[YAML schema — filled in]

Flow:
[ASCII diagram derived from nodes]

Agents dispatched: [N]
Estimated turns:   [N × 5 turns per agent, rough estimate]
Max iterations:    [N — Iterative only, else omit]

Verification criteria per node:
  [node-id] (@agent): [on_pass condition description]
```

### 5. Ask for approval

```text
✋ Does this workflow look correct?
   Reply "yes" to confirm and begin dispatching agents.
   Reply "edit [node-id] [field] [value]" to adjust a node.
   Reply "no" to cancel.
```

Do NOT dispatch any agent until the user confirms.

### 6. Save (if --save provided)

After approval, if `--save <filename>` was passed, write the graph to
`.tasks/<filename>.workflow.md` and print:

```text
✅ Workflow saved → .tasks/<filename>.workflow.md
```

### 7. Dispatch (after approval)

After the user confirms, hand off to `@producer` with the instruction:

> "Execute workflow `[id]` — dispatch agents in the order defined by the graph.
>  For each node: run the agent, check the outcome, follow on_pass/on_fail edges.
>  Write a ledger entry to `production/traces/decision_ledger.jsonl` at each
>  node completion. Save a checkpoint via `/save-state [task_id]` if any node fails."

---

## Quick Examples

```bash
# Simple 3-agent pipeline
/map-workflow --pattern Sequential \
  --agents "technical-director,backend-developer,qa-tester" \
  --task "Build JWT auth endpoint"

# Parallel frontend + backend
/map-workflow --pattern Parallel \
  --agents "backend-developer,frontend-developer" \
  --task "Login feature — API and UI"

# TDD loop, max 3 retries
/map-workflow --pattern Iterative \
  --agents "backend-developer,qa-tester" \
  --task "Payment service" --max-iter 3

# Save to .tasks/
/map-workflow --pattern Hierarchical \
  --agents "lead-programmer,backend-developer,frontend-developer,qa-tester" \
  --task "Sprint 04 wave 1" --save sprint-04-wave-1
```
