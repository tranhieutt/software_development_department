---
name: gitnexus-registry
description: Which repositories are indexed in GitNexus, their last analysis date, and whether embeddings are enabled. Check before running impact analysis tools — stale or missing index means tool output is unreliable.
type: project
---

# GitNexus Indexed Repositories

| Repo Name | Path | Last Analyzed | Embeddings | Notes |
|-----------|------|---------------|------------|-------|
| _(empty — run `npx gitnexus list` to populate)_ | | | | |

## How to Update This File

After running `npx gitnexus analyze` in a repository, update the table above:
- **Repo Name**: as shown by `npx gitnexus list`
- **Path**: absolute path to the repo root
- **Last Analyzed**: date of the last `analyze` run (YYYY-MM-DD)
- **Embeddings**: Yes / No (whether `--embeddings` flag was used)

## Staleness Policy

An index older than 7 days, or created before a major merge, should be refreshed
before running impact analysis. Run `npx gitnexus analyze` from the repo root.

**Why:** Stale indexes miss recently added callers — impact reports will under-report
blast radius, giving false confidence.

**How to apply:** Before calling any `mcp__gitnexus__impact` or `mcp__gitnexus__detect_changes`
tool, check this file. If the last analyzed date is >7 days ago or pre-dates the last
merge, run `npx gitnexus analyze` first and update this table.

## Quick Commands

```bash
npx gitnexus list              # List all indexed repos
npx gitnexus status            # Check if current repo is indexed and fresh
npx gitnexus analyze           # Index or refresh current repo
npx gitnexus analyze --force   # Force full re-index
```
