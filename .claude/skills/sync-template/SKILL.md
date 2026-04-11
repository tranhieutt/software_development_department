---
name: sync-template
description: "Syncs the .claude/ directory from an upstream template repository, showing a diff and applying new or modified files without overwriting local customizations. Use when updating SDD template files or when the user mentions template sync or upstream update."
argument-hint: "[upstream-repo-url]"
user-invocable: true
allowed-tools: Read, Bash, Glob
effort: 3
when_to_use: "Use when updating the .claude/ directory from an upstream SDD template repository, or when the user mentions template sync or upstream update."
---

Sync the `.claude/` directory from an upstream template repository into this project.

## Determine the upstream URL

If `$ARGUMENTS` is provided, use it as the upstream repository URL.

If `$ARGUMENTS` is empty, check `CLAUDE.md` for a line like:

```text
**Template upstream**: <url>
```

If no URL is found in either place, ask the user:
> "What is the upstream template repository URL to sync from? (e.g. https://github.com/owner/repo)"

Do not proceed until a URL is confirmed.

---

## Steps

### 1. Fetch the upstream template

Run:
```bash
SYNC_TMP=$(mktemp -d /tmp/template-sync-XXXXXX)
git clone --filter=blob:none --sparse "$UPSTREAM_URL" "$SYNC_TMP" 2>&1
cd "$SYNC_TMP" && git sparse-checkout set .claude
```

If the clone fails (no internet, repo moved, auth required, etc.) stop immediately and report the error clearly. Do not attempt fallbacks.

### 2. Show a diff summary

Compare `$SYNC_TMP/.claude/` against the project's `.claude/` directory and report:

- **New files** — present in upstream but not locally (will be added)
- **Modified files** — present in both but with different content (will be overwritten)
- **Local-only files** — present locally but not in upstream (will be **kept unchanged** — these are project-specific customizations)

If there are no differences, say so and skip to clean-up.

### 3. Ask for confirmation

Present the diff summary and ask:

> "Apply these changes from `<upstream-url>`? Type **yes** to apply or **no** to cancel."

Do not proceed until the user explicitly confirms with "yes".

### 4. Apply the changes

From the project root, run:
```bash
cp -r "$SYNC_TMP/.claude/." .claude/
```

This will:

- **Overwrite** files that exist in both upstream and locally
- **Add** new files from upstream
- **Preserve** all local-only files (project-specific agents, skills, rules, hooks)

### 5. Report

List each file that was added or updated, grouped by type:

- Added: `[file list]`
- Updated: `[file list]`

### 6. Clean up

```bash
rm -rf "$SYNC_TMP"
```

Confirm: "Sync complete. Temp directory removed."

---

## Important constraints

- Never delete local files that don't exist in upstream — they may be project-specific customizations (agents, skills, rules, hooks added after the template was cloned)
- Never modify `CLAUDE.md`, `PRD.md`, `TODO.md`, or any files outside `.claude/` — this skill only touches `.claude/`
- If the user's `.claude/` has meaningful customizations to a file that upstream has also changed, flag it specifically: "Note: `[file]` was modified locally — upstream changes will overwrite. Review diff before confirming if you want to preserve local changes."
