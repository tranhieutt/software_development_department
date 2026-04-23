---
name: save-state
type: workflow
description: "Saves current working context to production/session-state/active.md AND writes an atomic per-task checkpoint to .tasks/checkpoints/[task_id].md. Run before any major context reset, when context usage exceeds 60%, or when ending a work session."
argument-hint: "[task_id] [optional note]"
user-invocable: true
allowed-tools: Read, Write, Glob, Bash
context: main
effort: 3
agent: technical-director
when_to_use: "Use before any major context reset, when context usage exceeds 60%, or when ending a session. If a task_id is provided, also writes an atomic checkpoint to .tasks/checkpoints/ for fine-grained recovery via /resume-from."
---

Dump the current working context into `production/session-state/active.md` as a session checkpoint, AND write an atomic per-task checkpoint to `.tasks/checkpoints/[task_id].md` when a task ID is provided.

Session checkpoint is automatically read by `session-start.sh` at the next session start and surfaced by `pre-compact.sh` before context compaction.
Per-task checkpoints are used by `/resume-from [task_id]` to restore granular cognitive state at the exact point of failure.

## Steps

### 1. Parse arguments

Parse `$ARGUMENTS` to extract:

- **task_id** (optional): First token matching pattern `^\d{3}` or a word without spaces (e.g. `042`, `auth-api`). If present, an atomic checkpoint will be written.
- **note** (optional): Remaining text after task_id, used as a note.

### 2. Gather context

Before writing anything, collect the following from the current conversation and working state:

- **Current task**: What is the primary task being worked on right now?
- **agent_id**: Which agent is currently executing (e.g. `backend-developer`, `qa-tester`)?
- **Progress**: What has been completed in this session? List key milestones.
- **Decisions made**: What architectural, design, or implementation decisions were made? (These are the most important to preserve.)
- **Files modified**: Run `git diff --name-only && git diff --staged --name-only && git ls-files --others --exclude-standard` to get the current working tree state.
- **output_snapshot**: A concise snapshot of the last significant output — last file written, last test result, last API response shape, or last command output.
- **Open questions**: What is unresolved or blocked?
- **Next step**: What is the very next action to take when resuming.

If a `note` was parsed from `$ARGUMENTS`, append it to the "Notes" section.

### 2. Extract Durable Memory (Native System)
Are there any lessons learned, coding patterns established, constraints added, or technical decisions made in this session that apply globally to the project?
If so, before writing active.md, extract them to the `.claude/memory/` directory:
- Write or update a specific topic file (e.g. `project_tech_decisions.md` or `feedback_rules.md`), ensuring it has the required YAML frontmatter (`name`, `description`, `type`).
- Update `.claude/memory/MEMORY.md` with a pointer to that file if it's not already listed.

### 3. Write `production/session-state/active.md`

Overwrite the file with this structure:

```markdown
# Session State

> Saved: [ISO timestamp]
> Branch: [current git branch]

## Current Task

[One sentence describing what is being worked on]

<!-- STATUS -->
Epic: [epic name or leave blank]
Feature: [feature name or leave blank]
Task: [specific task or leave blank]
<!-- /STATUS -->

## Progress (This Session)

[Bulleted list of what was completed]

## Key Decisions Made

[Bulleted list — include the decision AND the rationale. These survive context loss.]

## Files Being Actively Worked On

[List of files currently modified or in progress]

## Open Questions / Blockers

[List of unresolved items. Mark with [BLOCKED] if waiting on someone.]

## Next Step

[The single most important next action to take when resuming]

## Notes

[$ARGUMENTS if provided, otherwise omit this section]
```

### 4. Write Atomic Checkpoint (only if task_id was provided)

If a `task_id` was parsed in Step 1, write `.tasks/checkpoints/[task_id].md`:

```markdown
---
task_id: [task_id]
agent_id: [agent currently executing]
saved_at: [ISO timestamp]
status: in_progress
retry_count: 0
backoff_next_s: 2
---

# Checkpoint: [task_id]

## Output Snapshot

[Concise snapshot of the last significant output — last file written, last test result,
last command output, or last API response shape. Max 10 lines.]

## Completed Steps

[Bulleted list of sub-steps already done within this task]

## Next Step

[The exact next action to resume from — be specific enough that a cold-start agent can continue]

## Open Questions

[Unresolved items blocking progress, if any]

## Files Modified

[List of files touched so far in this task]
```

### 5. Confirm

Print:

```text
✅ Session state saved → production/session-state/active.md
[If task checkpoint written]: ✅ Atomic checkpoint saved → .tasks/checkpoints/[task_id].md
[If memory was extracted]:    ✅ Durable memories updated → .claude/memory/MEMORY.md

To resume this task: /resume-from [task_id]
To resume session:   read production/session-state/active.md first
```

---

## When to run `/save-state`

- Before `/clear` or starting a new unrelated task
- When context usage feels high (>60%)
- After completing a major milestone (phase, feature, design section)
- Before ending a work session
- When `pre-compact.sh` warns about no active session state
- **After any agent failure** — pass the `task_id` to create a recoverable checkpoint

> The `session-start.sh` hook automatically detects and previews `active.md` at the start of each new session.
> The `pre-compact.sh` hook reads it before compaction to inject it into the summary.
> Use `/resume-from [task_id]` to recover a specific task without re-reading the full session.
