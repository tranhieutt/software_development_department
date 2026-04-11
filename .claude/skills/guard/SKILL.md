---
name: guard
description: "Enforces project safety constraints by blocking risky operations outside their approved scope during active development. Use when activating a safety guard or constraint for the current session."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Bash
effort: 1
agent: release-manager
when_to_use: "Before merging PR, deploying, or pushing to main/develop when unsure if a freeze is active"
---

# Guard Check

Check the freeze status of the codebase. Use as a gate check before any operations on the main branch.

## Workflow

### 1. Read `.freeze`

**If it does not exist:**

```
✅ CLEAR — No active freeze.
Development and merging can proceed normally.
```

Stop here.

**If it exists**, proceed to step 2.

### 2. Display Freeze Warning

```
🔒 CODEBASE IS FROZEN

Reason  : [REASON from .freeze]
Since   : [FROZEN_AT]
Branch  : [BRANCH]
Duration: [calculated from FROZEN_AT to current time]

⚠️  Non-critical merges are blocked during a freeze period.
```

### 3. Categorize the Request

Ask:
> "What type of operation is this?"
>
> **A) Urgent Hotfix** — production bug, security patch
> **B) Release Artifact** — changelog, version bump, release notes
> **C) Non-critical** — feature, refactor, chore, normal docs

**If A or B:** Allow to proceed with a note:
> "⚠️ Permitted to proceed. Note that this is a freeze period — execute only necessary operations."

**If C:** Block and instruct:
> "🚫 Non-critical changes must wait until after `/unfreeze`.
> Save your work and continue after the release is complete."

### 4. Suggestions

- `/unfreeze` — If the release is finished
- `/release-checklist` — If currently in the release process
- `/hotfix` — If an urgent fix deployment is needed

## Edge Cases

- **No .freeze**: Just report CLEAR, ask no further questions.
- **User unsure of operation type**: Ask for more details to categorize correctly before deciding.

## Related Skills

- `/freeze` — Lock codebase
- `/unfreeze` — Remove freeze
- `/hotfix` — Urgent deployment during freeze
- `/release-checklist` — Full release workflow
