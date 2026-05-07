# ADR-008: Adopt agent-style as an Opt-in Prose Review Gate

## Status
Accepted

## Date
2026-05-07

## Deciders
User, @technical-director

## Context
SDD produces many prose artifacts that affect engineering quality: specs, ADRs,
PR descriptions, release notes, runbooks, and completion summaries. These
artifacts need clarity, precise claims, and evidence discipline, but SDD also
has existing voice and runtime constraints.

`AGENTS.md` controls Codex behavior, including terse caveman-style responses for
this workspace. `CLAUDE.md` remains the Claude-native constitution. Changing
either file to load a global style pack would risk altering normal agent voice
and weakening the Claude-native boundary.

## Prior Decision Check
Relevant prior decision: ADR-007 keeps SDD as one shared core with separate
Claude and Codex execution lanes. Any prose-quality upgrade must preserve that
shared core and avoid introducing a competing runtime instruction system.

## Decision Drivers
- Must improve important SDD prose without changing ordinary agent responses.
- Must preserve `AGENTS.md` and `CLAUDE.md` as existing runtime entry points.
- Must keep source documents unchanged unless the user accepts edits.
- Should pin upstream content so future diffs are reviewable.
- Should work as an SDD REVIEW or SHIP gate, not as a global style mode.

## Considered Options
### Option 1: Opt-in `style-review` skill
Pros: Improves important prose on demand; avoids conflicts with user tone;
keeps source files untouched by default; fits REVIEW and SHIP phases.
Cons: Requires explicit invocation and an installed `agent-style` CLI for
deterministic audit.

### Option 2: Soft enforcement in `AGENTS.md` and `CLAUDE.md`
Pros: Every agent draft sees the rules automatically.
Cons: Conflicts with caveman mode, can change casual responses, and edits both
runtime instruction files.

### Option 3: Do not adopt agent-style
Pros: No new maintenance burden.
Cons: SDD keeps relying on ad hoc prose review for specs, ADRs, and PR bodies.

## Decision
Adopt `agent-style` v0.3.5 as an opt-in prose review gate through the SDD
`style-review` skill. Vendor the pinned rule pack and review references under
`.agent-style/`, but do not enable global soft enforcement in `AGENTS.md` or
`CLAUDE.md`.

## Consequences
**Positive:** SDD gains a repeatable prose-quality gate for specs, ADRs, PR
bodies, release notes, and docs without changing normal runtime behavior.

**Negative:** Users or agents must invoke `style-review` explicitly, and full
deterministic audits require the external `agent-style` CLI on PATH.

**Risks:** Upstream rules may drift from the vendored copy. Mitigation: pin the
source to v0.3.5 in `.agent-style/UPSTREAM.md` and review future upgrades as a
separate change.

## Related ADRs
- ADR-007: Shared SDD Core with Dual Execution Lanes for Claude and Codex
