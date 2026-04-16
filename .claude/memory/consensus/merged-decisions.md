---
name: consensus-merged-decisions
description: "Cross-domain decisions merged by @technical-director from specialist namespaces. The single source of truth for decisions that affect more than one agent."
type: project
namespace: consensus
---

# Consensus Hub — Merged Decisions

> **Owner:** `@technical-director`
> **Updated:** After any cross-domain architectural decision or at end of sprint.
> **Loaded by:** Any agent when a decision may cross domain boundaries.

## How This File Works

When a specialist agent makes a decision that affects other domains, `@technical-director`:
1. Reviews the specialist's memory file (`.claude/memory/specialists/[agent].md`)
2. Extracts the cross-domain insight
3. Appends it here with source attribution
4. Updates `MEMORY.md` "Last consensus merge" date

Specialists read this file before starting work to avoid contradicting prior decisions.

---

## Active Cross-Domain Decisions

| Decision | Source Agent | Date | Affects |
| :--- | :--- | :--- | :--- |
| _(fill — e.g. "API uses RS256 JWT")_ | _(e.g. backend-developer)_ | _(YYYY-MM-DD)_ | _(e.g. frontend, mobile)_ |

---

## Deprecated Decisions

| Decision | Replaced By | Date Deprecated |
| :--- | :--- | :--- |
| _(fill)_ | _(fill)_ | _(YYYY-MM-DD)_ |

---

## Merge History

| Date | Agent | Files Merged | Notes |
| :--- | :--- | :--- | :--- |
| 2026-04-16 | technical-director | _(initial scaffold)_ | Namespace Isolation Upgrade #2 |
