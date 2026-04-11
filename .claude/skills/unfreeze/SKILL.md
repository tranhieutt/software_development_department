---
name: unfreeze
description: "Unlocks the codebase after a release freeze or incident freeze period to resume normal development. Use when a freeze period ends or when the user mentions unfreezing or lifting the code freeze."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Write, Bash, Edit
effort: 1
agent: release-manager
when_to_use: "After a successful release or when normal development operations can resume"
---

# Code Unfreeze

Remove the code freeze, allowing merges and development to continue.

## Workflow

### 1. Check Status

Read `.freeze`. If it does not exist, notify and stop:
> "✅ Codebase is not currently frozen. Unfreeze is not needed."

### 2. Display Current Freeze Information

```
🔒 Current Freeze:
Reason     : [REASON from .freeze]
Frozen at  : [FROZEN_AT]
Branch     : [BRANCH]
Duration   : [calculated from FROZEN_AT to current time]
```

### 3. Confirmation

Ask:
> "Are you sure you want to unfreeze? Is the release/deployment complete? (yes/no)"

If "no", stop.

### 4. Remove `.freeze`

Use Bash to delete the file: `rm .freeze`

### 5. Log to Session State

Append to `production/session-state/active.md` (if it exists):

```markdown
## Unfreeze Log — [timestamp]
- Unfrozen at: [timestamp]
- Was frozen for: [duration]
- Reason was: [reason]
```

### 6. Notification

```
✅ CODEBASE UNFROZEN
Development can resume normally.
All merges and deployments are now permitted.
```

## Edge Cases

- **No freeze exists**: Notify clearly, take no further action.
- **active.md does not exist**: Skip the logging step, do not throw an error.

## Related Skills

- `/freeze` — Lock the codebase
- `/guard` — Check the current status
- `/release-checklist` — Full release workflow
