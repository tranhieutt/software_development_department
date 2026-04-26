# F3 — Architecture Doc Drift Cleanup

**Date:** 2026-04-26
**Scope:** Reconcile active architecture, onboarding, reference, hook, agent, and
skill docs with the current SDD runtime agent roster.
**Continuation of:** F2 follow-up item for legacy `qa-tester` and
`investigator`/`verifier`/`solver` references.

---

## Summary

F3 removes active references to retired agent names from architecture and
operational documentation:

- `qa-tester` is replaced by `qa-engineer`.
- `investigator` / `verifier` / `solver` are replaced by `diagnostics`
  Investigation, Verification, and Solution roles.

The cleanup keeps historical "Replaces ..." descriptions in the actual
replacement agents:

- `.claude/agents/qa-engineer.md`
- `.claude/agents/diagnostics.md`

Those lines document migration history and are not dispatch targets.

---

## Files Updated

- `.claude/agents/backend-developer.md`
- `.claude/agents/frontend-developer.md`
- `.claude/agents/fullstack-developer.md`
- `.claude/agents/mobile-developer.md`
- `.claude/docs/agent-coordination-map.md`
- `.claude/docs/context-management-guide.md`
- `.claude/docs/hooks-reference/pre-commit-code-quality.md`
- `.claude/docs/hooks-reference/pre-push-test-gate.md`
- `.claude/docs/quick-start.md`
- `.claude/docs/skills-reference.md`
- `.claude/skills/diagnose/SKILL.md`
- `docs/onboarding/WORKFLOW-GUIDE.md`
- `docs/reference/AI_AGENT_SDD_TERM_MAP.md`
- `docs/reference/DANH_SACH_LENH.md`
- `docs/reference/templates/workflow-graph.md`
- `docs/technical/COLLABORATIVE-DESIGN-PRINCIPLE.md`
- `docs/technical/CONTROL_PLANE_MAP.md`

---

## Verification

- Legacy-reference scan across active docs, agents, and skills: only expected
  residual matches remain.
- `powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1`:
  126/126 pass.
- `node scripts\harness-audit.js --compact`: 120/120 pass with 7 non-blocking
  permission warnings.
- `powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1`:
  pass with working-tree warning.

Residual expected matches:

- Historical replacement notes in `.claude/agents/qa-engineer.md` and
  `.claude/agents/diagnostics.md`.
- Generic prose such as "truth verifier" in `test-driven-development`.
