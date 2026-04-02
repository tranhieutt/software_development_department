# GitNexus Integration Plan — SDD

**Date:** 2026-04-02
**Author:** Integration Planning Session
**Status:** Approved — ready to execute

---

## Objective

Wire GitNexus as a first-class capability of the Software Development Department.
GitNexus provides a code knowledge graph with 7 MCP tools that give SDD agents
architectural visibility they currently lack.

---

## Phase 1 — Activate (Prerequisites)

> Unlocks all MCP tools and skills. Do this first — everything else depends on it.

| # | File | Change | Priority |
|---|------|--------|----------|
| 1 | `.mcp.json` (create) | Register GitNexus MCP server | CRITICAL |
| 2 | `.claude/settings.json` | Add MCP tool permissions + `Bash(npx gitnexus*)` | CRITICAL |
| 3 | `.claude/settings.local.json` | Add GitNexus skills dir to `additionalDirectories` | HIGH |

### 1. `.mcp.json`
```json
{
  "mcpServers": {
    "gitnexus": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "gitnexus@latest", "mcp"]
    }
  }
}
```

### 2. `settings.json` — add to `permissions.allow`
```json
"mcp__gitnexus__query(*)",
"mcp__gitnexus__context(*)",
"mcp__gitnexus__impact(*)",
"mcp__gitnexus__detect_changes(*)",
"mcp__gitnexus__list_repos(*)",
"mcp__gitnexus__cypher(*)",
"mcp__gitnexus__rename(*)",
"Bash(npx gitnexus*)"
```

### 3. `settings.local.json` — add to `additionalDirectories`
```json
"D:\GitNexus\.claude\skills"
```

---

## Phase 2 — Hooks

> Automated blast-radius awareness at commit and edit time.

| # | File | Change |
|---|------|--------|
| 4 | `hooks/validate-commit.sh` | Add blast-radius warning on staged changes |
| 5 | `hooks/session-start.sh` | Show indexed repos list at session start |
| 6 | `hooks/pre-refactor-impact.sh` (create) | Remind agents to run impact check when editing `src/**` |
| 7 | `settings.json` | Wire new PreToolUse hook for Write\|Edit |

### Hook design principles
- All hooks exit 0 (warn-only) — consistent with existing SDD hook philosophy
- Degrade gracefully when GitNexus not installed or index is stale
- No blocking impact calls on every edit (too slow) — nudge to skill instead

---

## Phase 3 — Agent Augmentation

> 7 of 27 agents gain GitNexus awareness. Only agents that touch or review code.

| Agent | Change | Priority |
|-------|--------|----------|
| `lead-programmer.md` | Add skills + GitNexus code intelligence section | HIGH |
| `security-engineer.md` | Add auth flow mapping requirement | HIGH |
| `qa-lead.md` | Add risk-based test planning from affected processes | HIGH |
| `technical-director.md` | Add architecture exploration with graph tools | MEDIUM |
| `devops-engineer.md` | Add index refresh in post-merge pipeline | LOW |
| `release-manager.md` | Add blast-radius report in release checklist | LOW |
| `tools-programmer.md` | Add CLI ownership for index maintenance | LOW |

---

## Phase 4 — Memory & Docs

| # | File | Change |
|---|------|--------|
| 8 | `memory/gitnexus-registry.md` (create) | Track indexed repos + last analysis date |
| 9 | `memory/MEMORY.md` | Add registry pointer |
| 10 | `docs/skills-reference.md` | Add GitNexus command table |
| 11 | `docs/hooks-reference.md` | Add new hooks to reference table |

---

## Phase 5 — Polish (Nice-to-have)

| File | Change |
|------|--------|
| `rules/src-code.md` (create) | Impact check requirement for all `src/**` edits |
| `rules/test-standards.md` | Add coverage mapping with GitNexus |
| `docs/quick-start.md` | Add GitNexus commands to skill table |
| `docs/agent-coordination-map.md` | Add GitNexus steps to PR review + release patterns |
| `docs/setup-requirements.md` | Add GitNexus as optional dependency |

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Skills via `additionalDirectories` | No duplication; survives GitNexus updates automatically |
| Hooks warn-only (exit 0) | Consistent with SDD hook philosophy; blocking would frustrate small refactors |
| 7 agents, not all 27 | Only code-touching agents benefit; noise for PM/UX/community roles |
| Registry in memory, not docs | Agents can read/update across sessions; docs are reference-only |
| `.mcp.json` at root, not in `settings.json` | Claude Code reads MCP config from `.mcp.json`; `settings.json` handles hooks/permissions only |

---

## Rollback

All Phase 1 changes are reversible:
- Delete `.mcp.json` → MCP tools gone
- Revert `settings.json` permission entries → tools require approval again
- Revert `settings.local.json` additionalDirectories → GitNexus skills hidden

No hooks are blocking, so no rollback risk from Phases 2–5.
