# 🧠 SDD Memory Index (Tier 1 — Always Loaded)

> **HARD LIMIT:** This file MUST stay under 50 lines. No frontmatter. Index only.
> **Auto-consolidation:** If this file exceeds 40 lines → trigger `/dream` immediately.

## Active Project State

<!-- Agents update this section on every significant decision -->

- Stack: [not configured] — run `/start` to populate
- Last session: 2026-04-17 11:16 · agents=4 · commits=1
- Current focus: _(agent fills in at session start)_

## Tier 2 — Load On Demand (max 3 files per session)

<!-- Keyword match is NOT enough — use the Load Decision Matrix in context-management.md -->

- [User Profile](user_role.md) — [user preferences, coding style, personalization]
- [Tech Decisions](project_tech_decisions.md) — [architecture, stack choice, infrastructure]
- [Feedback Rules](feedback_rules.md) — [do/don't, code review, repeated mistakes]
- [Reference Links](reference_links.md) — [staging URL, external tools, credentials]
- [GitNexus Registry](gitnexus-registry.md) — [gitnexus, impact analysis, repo index]
- [Annotations](annotations.md) — [api, sdk, gotcha, caveat, workaround, integration, version]

## Tier 2.5 — Specialist Namespace (1 file max, active agent only)

- [Backend](specialists/backend-developer.md)
- [Frontend](specialists/frontend-developer.md)
- [QA Tester](specialists/qa-tester.md)
- [Data Engineer](specialists/data-engineer.md)
- [Fullstack](specialists/fullstack-developer.md)
- [Investigator](specialists/investigator.md)
- [Technical Director](specialists/technical-director.md)
- [Merged Decisions](consensus/merged-decisions.md)

## Tier 3 — Search Archive (Do NOT load proactively)

- Session logs: `.claude/memory/archive/sessions/`
- Consolidated decisions: `.claude/memory/archive/decisions/`

## Tier 4 — Semantic Storage (Permanent)

- [Supermemory MCP](mcp:supermemory) — [long-term recall, cross-project knowledge]

## Rules: Tier 1 always in. Tier 2 max 3. Tier 2.5 max 1. Full rules in `rules/context-management.md`.
