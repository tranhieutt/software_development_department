---
paths:
  - "src/**"
---

# Source Code Standards

Applies to all files under `src/`.

## Before Modifying Any Public Symbol

Before editing a public function, class, method, or interface that other files depend on:

1. Check if the repository is indexed: `npx gitnexus status`
2. If indexed, assess blast radius with `/gitnexus-impact-analysis`
3. If risk is HIGH or CRITICAL, pause and report to the user before proceeding

This is required for any change that renames, removes, or alters the signature of a
symbol used by other files.

## Multi-File Renames

Multi-file renames MUST use `mcp__gitnexus__rename` with `dry_run: true` first,
rather than find-and-replace. Manual find-and-replace misses dynamic references
and string-based lookups — use the call graph to find 100% of references.

## Pre-Commit Check

Before committing a non-trivial changeset, run `mcp__gitnexus__detect_changes`
with `scope: "staged"` to confirm the actual blast radius matches what you intended.

## Surgical Changes

Every changed line must trace directly to the user's request. No exceptions.

**Permitted:**

- Modifying code the task explicitly targets
- Removing imports/variables/functions that YOUR changes made unused

**Not permitted without explicit instruction:**

- Refactoring adjacent code that "could be cleaner"
- Fixing unrelated formatting, indentation, or style
- Renaming variables/functions outside the task scope
- Deleting pre-existing dead code (mention it instead — don't touch it)
- Adding comments, docstrings, or type annotations to code you didn't change

**If you spot a problem outside scope:** Report it as a note at the end of your
response. Do not fix it silently.

The test before committing: Can you justify each changed line by pointing to
a specific part of the user's request? If not, revert that line.
