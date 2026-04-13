# 🧠 SDD Memory Index (Tier 1 — Always Loaded)

> **HARD LIMIT:** This file MUST stay under 50 lines. No frontmatter. Index only.
> **Auto-consolidation:** If this file exceeds 40 lines → trigger `/dream` immediately.

## Active Project State

<!-- Agents update this section on every significant decision -->

- Stack: [not configured] — run `/start` to populate
- Last session: 2026-04-13 12:09 · agents=1 · commits=1
- Current focus: _(agent fills in at session start)_

## Tier 2 — Load On Demand (max 3 files per session)

<!-- Keyword match is NOT enough — use the Load Decision Matrix in context-management.md -->

- [User Profile](user_role.md) — [user preferences, coding style, personalization]
- [Tech Decisions](project_tech_decisions.md) — [architecture, stack choice, infrastructure]
- [Feedback Rules](feedback_rules.md) — [do/don't, code review, repeated mistakes]
- [Reference Links](reference_links.md) — [staging URL, external tools, credentials]
- [GitNexus Registry](gitnexus-registry.md) — [gitnexus, impact analysis, repo index]
- [Annotations](annotations.md) — [api, sdk, gotcha, caveat, workaround, integration, version]

## Tier 3 — Search Archive (Do NOT load proactively)

<!-- grep -r "keyword" .claude/memory/archive/ — only on explicit user query -->

- Session logs: `.claude/memory/archive/sessions/`
- Consolidated decisions: `.claude/memory/archive/decisions/`
- Dream history: `.claude/memory/archive/dreams/`

## Loading Rules (Summary)

1. **Tier 1**: Always in context. Never exceed 50 lines.
2. **Tier 2**: Load ONLY files the current task actually needs. Max 3 per session.
3. **Tier 3**: Never load proactively. Grep-search only when user explicitly asks.
4. **Subsections**: Read line ranges, not whole files, when only 1 section needed.
5. **Compaction**: If context > 70% full → compress Tier 2 to 3-bullet summaries.
6. **Full rules**: See `context-management.md` → "Incremental Context Loading" section.
