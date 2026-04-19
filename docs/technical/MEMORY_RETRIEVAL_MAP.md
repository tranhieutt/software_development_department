# Memory Retrieval Map

> **Spec ref:** §15.5 — required artifact to centralize scattered retrieval logic.
> **Canonical rules source:** `.claude/docs/context-management.md` (§ Incremental Context Loading)
> **Last updated:** 2026-04-19 (v1.41.0)

This document is a single reference for **when and how each memory tier is loaded** — replacing the need to re-derive this from context-management.md during every session.

---

## Tier Architecture

```
CLAUDE.md load sequence
  └─► MEMORY.md (Tier 1)          ← ALWAYS loaded, every session
        └─► Tier 2 files          ← On-demand, max 3 per session
              └─► Tier 2.5 files  ← On-demand, max 1 per turn (agent-bound)
                    └─► Tier 3    ← Only on explicit user request
                          └─► Tier 4 (Supermemory MCP) ← Long-term recall
```

---

## Tier 1 — Always Loaded

| File                       | Load trigger                    | Content                                            |
| -------------------------- | ------------------------------- | -------------------------------------------------- |
| `.claude/memory/MEMORY.md` | Every session (via `CLAUDE.md`) | Index of all tiers; project state; retrieval rules |

**Hard limit:** Must stay under 50 lines. Auto-consolidation via `/dream` if ≥ 40 lines.

---

## Tier 2 — On-Demand Topic Files

**Cap:** Max **3 files** per session. If a 4th is needed, summarize the least-used one to 3 bullets and release it.

### 3-Question Relevance Gate (must pass ALL before loading)

1. **Does this task ACTUALLY require this file's content?** (keyword match alone ≠ load)
2. **Will I use this within the next 3 agent turns?** ("maybe later" = skip)
3. **Is a subset sufficient?** (prefer `view_file(start_line, end_line)` over full load)

### Load Decision Matrix

| Task type                               | Load                                   | Skip                                                |
| --------------------------------------- | -------------------------------------- | --------------------------------------------------- |
| Bug fix in existing code                | `annotations.md` (if API-related)      | `user_role.md`, `project_tech_decisions.md`         |
| New API / SDK integration               | `annotations.md`, `reference_links.md` | `gitnexus-registry.md`, `user_role.md`              |
| Architecture / stack decision           | `project_tech_decisions.md`            | `feedback_rules.md`, `reference_links.md`           |
| Code review / PR feedback               | `feedback_rules.md`                    | `project_tech_decisions.md`, `gitnexus-registry.md` |
| Codebase impact analysis                | `gitnexus-registry.md`                 | all others                                          |
| Style / personalization request         | `user_role.md`                         | all others                                          |
| Debugging unknown gotcha                | `annotations.md`                       | all others                                          |
| Specialist agent executing a task       | `specialists/[agent-name].md`          | all other specialist files                          |
| Cross-agent handoff or multi-agent plan | `consensus/merged-decisions.md`        | individual specialist files                         |

### Tier 2 File Catalog

| File                        | Search Query                                                                     | Type        | Trigger keywords                                                    |
| --------------------------- | -------------------------------------------------------------------------------- | ----------- | ------------------------------------------------------------------- |
| `user_role.md`              | *How should agents adapt style and tone for this user?*                          | `user`      | personalization, style, tone, language, user preference             |
| `project_tech_decisions.md` | *What architecture decisions and stack constraints must survive context resets?* | `project`   | architecture, stack, tech decision, infrastructure, constraint      |
| `feedback_rules.md`         | *What mistakes or rules has the user corrected that agents must never repeat?*   | `feedback`  | do/don't, rule, guideline, mistake, corrected, must not             |
| `reference_links.md`        | *Where are the staging URLs, external tools, and project resource links?*        | `reference` | staging, URL, link, tool, environment, credential                   |
| `gitnexus-registry.md`      | *Is the GitNexus index fresh enough to trust for impact analysis on this repo?*  | `project`   | gitnexus, impact, blast radius, dependency, repo index              |
| `annotations.md`            | *Are there known gotchas or caveats for this API, library, or integration?*      | `reference` | api, sdk, gotcha, caveat, workaround, quirk, bug, limit, deprecated |

---

## Tier 2.5 — Specialist Namespace (Agent-Bound)

**Cap:** Max **1 specialist file** per session turn. Never load two simultaneously.

### Namespace Isolation Rules

1. Load `specialists/[agent].md` ONLY when that agent is the **active executor**
2. ✅ `@backend-developer` executing → load `specialists/backend-developer.md`
3. ❌ Task mentions "API" → do NOT load `specialists/backend-developer.md` for a different agent
4. Before cross-domain work (2+ agents): read `consensus/merged-decisions.md` first
5. When a specialist decision affects other agents → notify `@technical-director` to merge into `consensus/merged-decisions.md`

### Write-back Protocol

When a specialist makes a persistent decision: write to their namespace file **immediately** — do not wait until session end.

---

## Tier 3 — Search Archive (Never Proactive)

**Load trigger:** ONLY when user explicitly asks *"what did we decide about X?"* or *"show me session history for Y"*.

| Path                                | Contents                                            |
| ----------------------------------- | --------------------------------------------------- |
| `.claude/memory/archive/sessions/`  | Daily session logs (YYYY-MM-DD.md format)           |
| `.claude/memory/archive/decisions/` | Consolidated decision archives (grows via `/dream`) |

---

## Tier 4 — Semantic Cloud Memory

| Tool                            | When to call                                                                    | Action                                            |
| ------------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------- |
| `mcp_supermemory_recall`        | Before planning a refactor, solving an obscure bug, or deep architecture review | Pull related long-term contexts                   |
| `mcp_supermemory_memory` (save) | After completing a major feature or resolving a hard bug                        | Save lesson summary with `containerTag: sdd-core` |

---

## Full Loading Sequence

```
Task received
  1. MEMORY.md               ← already loaded (via CLAUDE.md)
  2. Relevance gate          ← apply 3 questions to each Tier 2 candidate
  3. Load matched Tier 2     ← max 3, subsections preferred over full files
  3a. Namespace check        ← if specialist agent active → load specialists/[agent].md
  3b. Cross-agent check      ← if task involves 2+ agents → load consensus/merged-decisions.md
  4. Budget check            ← if context < 30% remaining → stop, summarize loaded
  5. Tier 3                  ← only if user explicitly asks "what did we decide about X"
  6. Tier 4 (Supermemory)   ← before any deep architecture/refactor/obscure bug work
```

---

## Hard Limits Summary

| Limit                             | Value                                          |
| --------------------------------- | ---------------------------------------------- |
| Tier 1 file max lines             | 50                                             |
| Tier 1 auto-consolidation trigger | 40 lines                                       |
| Tier 2 cap per session            | 3 files                                        |
| Tier 2.5 cap per turn             | 1 file                                         |
| Tier 2 max inject per query       | 5 topic files                                  |
| Tier 3 load condition             | Explicit user request only                     |
| Prefer subsection reads           | Always — use `view_file(start_line, end_line)` |
