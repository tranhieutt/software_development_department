# Codex Session Context

> Codex does not auto-inject `@.claude/` context. Read this file at the start
> of each Codex session, then consult the source files below when depth is
> needed. If this summary disagrees with a Claude source file, the Claude source wins.

---

## Canonical Sources

- `CLAUDE.md`
- `.claude/skills/using-sdd/SKILL.md`
- `.claude/skills/codex-sdd/SKILL.md`
- `docs/technical/SDD_LIFECYCLE_MAP.md`
- `.claude/docs/coding-standards.md`
- `.claude/docs/coordination-rules.md`
- `.claude/docs/technical-preferences.md`
- `.claude/memory/MEMORY.md`

---

## Coding Standards

- Public APIs need doc comments.
- Systems need a corresponding ADR in `docs/architecture/`.
- Configuration belongs in data/config files, not hardcoded constants.
- Secrets and environment variables follow `.claude/rules/secrets-config.md`.
- Public methods must be unit-testable.
- New features and behavior changes require verification-first discipline.
- External API calls need defensive handling and meaningful fallback/retry.
- Before adding dependencies, verify module compatibility and pin core versions.

---

## Coordination

- Use vertical delegation for complex decisions.
- Specialists must stay inside delegated domain and file scope.
- Do not make unilateral cross-domain changes.
- When work overlaps or agents disagree, escalate to the shared parent,
  `cto`, `technical-director`, coordinator, or user as appropriate.
- Do not overwrite unrelated work. Resolve conflicts with explicit coordination.
- Do not commit or push unless the user explicitly asks.

---

## Technical Preferences

- Project stack is not fully configured in `.claude/docs/technical-preferences.md`.
- For current constraints, read `CLAUDE.md` and the full technical-preferences file.
- Do not infer language, runtime, framework, formatter, or test framework from
  this summary.
- Preserve surgical-change discipline: minimal necessary edits, existing
  patterns first, no drive-by refactors.

---

## Memory

- `.claude/memory/MEMORY.md` is the Tier 1 memory index.
- Tier 2 memory files load only on actual need.
- Do not bulk-load memory archive files.
- When context is stale or large, route through `context-engineering` or
  `save-state`.

---

## Lifecycle

Use SDD's six-phase map:

```text
DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP
```

- DEFINE: clarify outcome, source of truth, and non-goals.
- PLAN: produce executable tasks with verification.
- BUILD: edit only after the pre-code gate is satisfied.
- VERIFY: prove the exact claim with fresh evidence.
- REVIEW: classify and resolve quality/safety findings.
- SHIP: commit, PR, release, or handoff only with user-approved action.
