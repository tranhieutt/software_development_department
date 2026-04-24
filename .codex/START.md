# Codex SDD Start

Use this file as the first prompt in a new Codex session for this repository.

Paste this message into Codex:

```text
Use the SDD Codex adapter for this repo.

Read AGENTS.md, .claude/skills/codex-sdd/SKILL.md, .claude/skills/using-sdd/SKILL.md,
docs/technical/SDD_LIFECYCLE_MAP.md, and .claude/skills/start/SKILL.md.

Then run the equivalent of Claude's /start workflow:
- silently inspect the repo state first
- do not edit files
- ask me the onboarding A/B/C/D project-state question from the start skill
- route me to the next SDD workflow based on my answer
- do not auto-run the next workflow until I confirm
```

Short form if you already trust the adapter:

```text
Use codex-sdd, then route through using-sdd, then run the start workflow for this repo.
```

Expected behavior:

1. Codex treats `AGENTS.md` as the repo entrypoint.
2. Codex uses `codex-sdd` only for adapter behavior.
3. Codex routes through `using-sdd`.
4. If this is a first session or project state is unclear, Codex follows `start`.
5. Codex asks the onboarding question instead of writing code.

This artifact is additive. It does not replace Claude Code slash commands or
Claude hook behavior.
