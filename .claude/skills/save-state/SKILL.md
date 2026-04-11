---
name: save-state
description: "Saves current working context to production/session-state/active.md to survive context compaction, /clear, or session restart. Run before any major context reset, when context usage exceeds 60%, or when ending a work session."
argument-hint: "[optional note]"
user-invocable: true
allowed-tools: Read, Write, Glob, Bash
effort: 3
when_to_use: "Use before any major context reset, when context usage exceeds 60%, or when ending a session to preserve working context across compaction or restart."
---

Dump the current working context into `production/session-state/active.md` as a structured checkpoint.

This file is automatically read by `session-start.sh` at the next session start and surfaced by `pre-compact.sh` before context compaction.

## Steps

### 1. Gather context

Before writing anything, collect the following from the current conversation and working state:

- **Current task**: What is the primary task being worked on right now?
- **Progress**: What has been completed in this session? List key milestones.
- **Decisions made**: What architectural, design, or implementation decisions were made? (These are the most important to preserve.)
- **Files modified**: Run `git diff --name-only && git diff --staged --name-only && git ls-files --others --exclude-standard` to get the current working tree state.
- **Open questions**: What is unresolved or blocked?
- **Next step**: What is the very next action to take when resuming?

If `$ARGUMENTS` is provided, append it as an additional note in the "Notes" section.

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

### 4. Confirm

Print:
```
Session state saved to production/session-state/active.md
[If memory was extracted]: Durable memories extracted to .claude/memory/MEMORY.md
Resume with: read active.md first to recover full context.
```

---

## When to run `/save-state`

- Before `/clear` or starting a new unrelated task
- When context usage feels high (>60%)
- After completing a major milestone (phase, feature, design section)
- Before ending a work session
- When `pre-compact.sh` warns about no active session state

> The `session-start.sh` hook automatically detects and previews `active.md` at the start of each new session.
> The `pre-compact.sh` hook reads it before compaction to inject it into the summary.
