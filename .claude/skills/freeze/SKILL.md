---
name: freeze
description: "Locks the codebase to prevent unintended writes during a freeze period such as before a release or during an incident. Use when the user mentions freezing, code lock, or release lockdown."
argument-hint: "[reason]"
user-invocable: true
allowed-tools: Read, Write, Bash
effort: 1
agent: release-manager
when_to_use: "Before release cut, hotfix deployment, or when a stabilization period is needed"
---

# Code Freeze

Lock the codebase in preparation for a release. Create a `.freeze` file containing freeze information.

## Workflow

### 1. Read Current Status

Check if `.freeze` already exists by reading the file. If it exists, display the information and ask:
> "The codebase is currently frozen for: [REASON]. Do you want to override the current freeze? (yes/no)"

If no, stop.

### 2. Get Freeze Reason

If no argument is provided, ask:
> "What is the reason for the freeze? (e.g., 'Release v2.1.0', 'Hotfix deployment', 'Sprint end')"

### 3. Create `.freeze` File

Write the following content:

```
FROZEN=true
REASON=[reason]
FROZEN_AT=[ISO timestamp]
BRANCH=[current branch from git rev-parse --abbrev-ref HEAD]
```

### 4. Notification

Display:

```
🔒 CODEBASE FROZEN
Reason : [reason]
Time   : [timestamp]
Branch : [branch]

Non-critical merges are blocked. Only hotfixes are permitted.
To unlock: /unfreeze
```

### 5. Suggested Next Steps

- `/release-checklist` — Run the full release checklist
- `/guard` — Check the freeze status at any time
- `/unfreeze` — Unlock after the release is complete

## Edge Cases

- **Existing freeze**: Ask for override confirmation before overwriting.
- **No git repository**: Still create `.freeze` but omit the BRANCH field.

## Related Skills

- `/guard` — Check freeze status before merge/deploy
- `/unfreeze` — Remove freeze after release
- `/release-checklist` — Full release workflow
- `/hotfix` — Deploy urgent fixes during a freeze
