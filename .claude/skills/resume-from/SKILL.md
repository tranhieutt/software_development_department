---
name: resume-from
type: workflow
description: "Restores cognitive state from an atomic checkpoint in .tasks/checkpoints/[task_id].md, enabling instant recovery at the exact point of failure without re-running the full task."
argument-hint: "<task_id>"
user-invocable: true
allowed-tools: Read, Write, Glob, Bash
effort: 2
when_to_use: "Use after an agent crash, session restart, or context compaction when a specific task was interrupted mid-execution. Requires a checkpoint previously written by /save-state <task_id>."
---

# Resume From Checkpoint

Restore the working context of a specific task from its atomic checkpoint at `.tasks/checkpoints/[task_id].md`, then continue execution from the exact next step — without re-running completed work.

## Steps

### 1. Validate argument

`$ARGUMENTS` must contain a `task_id`. If missing or empty:

```text
❌ Usage: /resume-from <task_id>
   Example: /resume-from 042
   Example: /resume-from auth-api

Available checkpoints:
[Run: ls .tasks/checkpoints/ and list files excluding .gitkeep]
```

Stop here if no `task_id` is provided.

### 2. Load checkpoint

Read `.tasks/checkpoints/[task_id].md`.

If the file does not exist:

```text
❌ No checkpoint found for task: [task_id]
   Expected: .tasks/checkpoints/[task_id].md

Available checkpoints:
[List files in .tasks/checkpoints/ excluding .gitkeep]

Tip: Run /save-state [task_id] first to create a checkpoint.
```

Stop here if file is missing.

### 3. Parse and surface checkpoint

Extract the following fields from the checkpoint and display them clearly:

```text
🔁 Resuming task: [task_id]
   Agent:         [agent_id]
   Saved at:      [saved_at]
   Retry count:   [retry_count]

📄 Output Snapshot (last known state):
   [output_snapshot content]

✅ Completed Steps:
   [completed steps list]

⏭️  Next Step:
   [next_step content]

❓ Open Questions:
   [open_questions content — or "None" if empty]

📁 Files Modified So Far:
   [files_modified list]
```

### 4. Apply exponential backoff if retrying

Check `retry_count` in the checkpoint frontmatter:

- `retry_count = 0` → proceed immediately, no wait
- `retry_count = 1` → wait 2s before continuing
- `retry_count = 2` → wait 4s before continuing
- `retry_count = 3` → wait 8s before continuing
- `retry_count >= 4` → surface a warning:

```text
⚠️  This task has failed [retry_count] times.
    Continuing, but consider escalating to a senior agent or the user
    if the same error recurs.
```

Then increment `retry_count` and update `backoff_next_s` (double the previous value, max 64s) in the checkpoint file before proceeding.

### 5. Resume execution

Hand off context to the appropriate agent (`agent_id` from checkpoint) with the following instruction:

> "You are resuming task `[task_id]`. The completed steps and output snapshot above are already done — do NOT repeat them. Your only job is to execute the **Next Step** listed above and continue from there."

### 6. Update checkpoint on success

When the task completes successfully, update `.tasks/checkpoints/[task_id].md`:

- Set `status: completed`
- Set `completed_at: [ISO timestamp]`
- Append to `## Completed Steps`

Print:

```text
✅ Task [task_id] completed successfully.
   Checkpoint updated → .tasks/checkpoints/[task_id].md (status: completed)
```

---

## Checkpoint lifecycle

```
/save-state [task_id]   → creates  .tasks/checkpoints/[task_id].md (status: in_progress)
/resume-from [task_id]  → reads checkpoint, increments retry_count, resumes
                        → on success: sets status: completed
```

Completed checkpoints are kept for audit — they are never auto-deleted.
To list all checkpoints: `ls .tasks/checkpoints/`
