# 🧠 SDD Memory Index (Tier 1 — Always Loaded)

> **HARD LIMIT:** This file MUST stay under 50 lines. No frontmatter. Index only.
> **Auto-consolidation:** If this file exceeds 40 lines → trigger `/dream` immediately.

## Active Project State

<!-- Agents update this section on every significant decision -->

- Stack: [not configured] — run `/start` to populate
- Last session: 2026-04-17 14:55 · agents=4 · commits=4
- Current focus: _(agent fills in at session start)_

## Tier 2 — Load On Demand (max 3 files per session)

<!-- Keyword match is NOT enough — use the Load Decision Matrix in context-management.md -->

- [User Profile](user_role.md) — How should agents adapt style and tone for this user?
- [Tech Decisions](project_tech_decisions.md) — What architecture decisions and stack constraints must survive context resets?
- [Feedback Rules](feedback_rules.md) — What mistakes or rules has the user corrected that agents must never repeat?
- [Reference Links](reference_links.md) — Where are the staging URLs, external tools, and project resource links?
- [GitNexus Registry](gitnexus-registry.md) — Is the GitNexus index fresh enough to trust for impact analysis on this repo?
- [Annotations](annotations.md) — Are there known gotchas or caveats for this API, library, or integration?

## Tier 2.5 — Specialist Namespace (1 file max, active agent only)

- See [structure.md](structure.md) for full specialist list.

## Tier 3 — Search Archive (Do NOT load proactively)

- Session logs: `.claude/memory/archive/sessions/`
- Consolidated decisions: `.claude/memory/archive/decisions/`

## Tier 4 — Semantic Storage (Permanent)

- [Supermemory MCP](mcp:supermemory) — [long-term recall, cross-project knowledge]

## Rules: Tier 1 always in. Tier 2 max 3. Tier 2.5 max 1. Full rules in `rules/context-management.md`.
