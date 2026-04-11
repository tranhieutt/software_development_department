---
name: update-codemap
description: "Updates docs/technical/CODEMAP.md by scanning the current codebase structure. Run after a significant feature merge, refactor, or when CODEMAP feels stale."
argument-hint: "[optional: specific module or area to update]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
effort: 3
when_to_use: "Use after a significant feature merge, refactor, or directory restructure to keep CODEMAP.md accurate, or when the user says the codemap feels stale."
---

Update `docs/technical/CODEMAP.md` to accurately reflect the current state of the codebase.

A stale CODEMAP misleads agents more than having none. Run this skill after any significant feature merge, refactor, or directory restructure.

## Steps

### 1. Determine scope

If `$ARGUMENTS` is provided, update only the section(s) relevant to the named module or area.

If `$ARGUMENTS` is empty, perform a full CODEMAP refresh.

### 2. Read current CODEMAP

Read `docs/technical/CODEMAP.md` to understand what is currently documented.

### 3. Scan the codebase

Run the following to get the current structure:

```bash
# Top-level src/ structure
find src/ -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" 2>/dev/null | sort | head -100

# API routes / handlers
grep -r "router\.\|app\.\|@Get\|@Post\|@Put\|@Delete\|@Patch" src/ --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null

# Exported utilities
grep -r "^export function\|^export const\|^def \|^func " src/ --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -30
```

Also read `docs/technical/API.md` and `docs/technical/DATABASE.md` if they exist — they contain authoritative specs for the API and schema sections.

### 4. Update CODEMAP sections

For each section in CODEMAP.md, update the table rows to reflect what actually exists:

- **Application Modules**: One row per top-level module/feature directory in `src/`
- **API Endpoints**: One row per route group (not every individual endpoint — use route prefixes)
- **Shared Utilities**: One row per utility file or helper module
- **Data Models**: One row per major entity/table
- **External Integrations**: One row per third-party service

**Rules:**
- Remove rows for modules/files that no longer exist
- Add rows for new modules/files
- Keep descriptions concise — one sentence max
- If a section has no entries yet, keep the `*(not yet populated)*` placeholder row
- Do not over-document — only include modules that other agents would need to find

### 5. Update Revision History

Append a row to the Revision History table:

```
| [today's date] | @lead-programmer (or @technical-director) | [brief summary: "added X module, removed Y, updated API section"] |
```

### 6. Confirm

Print:
```
CODEMAP updated. [N] modules documented across [M] sections.
Stale entries removed: [list or "none"]
New entries added: [list or "none"]
```

---

## Staleness indicators

CODEMAP should be re-run when:
- A new feature directory is added to `src/`
- An existing module is renamed, moved, or deleted
- New API route groups are added
- New third-party integrations are wired in
- An agent says "I couldn't find X" when X should exist

> **Tip**: After running `/orchestrate` on a large feature, run `/update-codemap` as the final step before closing the feature branch.
