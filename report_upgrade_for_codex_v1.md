# Report: SDD Codex Compatibility Status v2

**Project:** `E:\SDD-Upgrade`
**Date:** `2026-04-24`
**Goal:** Keep SDD usable in both Claude Code and Codex without weakening the
Claude-native runtime.
**Non-negotiable constraint:** Do not weaken, rename, relocate, or rewire the
current Claude Code control plane for Codex-only reasons.

---

## 1. Executive Summary

The Codex adapter baseline is now implemented and usable.

Codex can:

- ~~enter through `AGENTS.md`~~,
- ~~follow the SDD lifecycle and pre-code gate rules~~,
- ~~discover the existing skill set through `.codex/INSTALL.md`~~,
- ~~use `.claude/skills/codex-sdd/SKILL.md` as the adapter skill~~,
- ~~run `scripts/codex-preflight.ps1` or `.sh` before risky work~~,
- ~~and verify changes with the same validator and harness audit used by Claude~~.

Claude remains the runtime owner. The `.claude/` tree and `CLAUDE.md` are still
the canonical source of truth.

---

## 2. Implemented

### 2.1 Codex Adapter Surface

Implemented and present in the repo:

- ~~`AGENTS.md`~~
- ~~`.codex/INSTALL.md`~~
- ~~`docs/codex-compatibility.md`~~
- ~~`.claude/skills/codex-sdd/SKILL.md`~~
- ~~`scripts/codex-preflight.ps1`~~
- ~~`scripts/codex-preflight.sh`~~
- ~~README guidance for Codex users~~

### 2.2 Codex Operating Contract

The adapter now documents and enforces:

- ~~`.claude/` remains the source of truth.~~
- ~~Codex must route through `using-sdd`.~~
- ~~Codex must state a pre-code gate before implementation edits.~~
- ~~Codex uses the Claude-to-Codex tool mapping.~~
- ~~Claude hooks do not auto-run in Codex.~~
- ~~Codex must use fresh verification before completion claims.~~

### 2.3 Metadata and Audit Hardening

Completed in this pass:

- ~~Added missing `type` metadata across skill frontmatter.~~
- ~~Added missing `when_to_use` metadata for remaining skill gaps.~~
- ~~Fixed `scripts/harness-audit.js` so UTF-8 BOM-prefixed `SKILL.md` files are
  parsed correctly.~~
- ~~Added missing recommended `skills` metadata to the remaining warned agent
  definitions.~~
- ~~Fixed `.mcp.json` so the `gitnexus` stdio server declares its `npx` command.~~

---

## 3. Verification Status

Fresh verification from this pass:

- ~~`powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1`~~
  - Result: `126 pass`, `0 fail`, `0 warn`
- ~~`node scripts\harness-audit.js --compact`~~
  - Result: `120/120`, `0 blocked`, `7 warning`
- ~~`powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1`~~
  - Result: pass
  - Note: preflight still warns while the working tree has uncommitted changes
    during active development
- ~~`git diff --check`~~
  - Result: no diff errors; only LF/CRLF normalization warnings from Git

What the remaining harness warnings are:

- `permissions.sensitive_path_not_denied` for several credential paths in
  `.claude/settings.json`

These were intentionally not changed in this pass because the Codex adapter
must not rewrite Claude runtime permission policy without explicit approval for
broader Claude-side changes.

---

## 4. Current Gap Assessment

### 4.1 Closed

These are no longer open gaps:

- ~~No root Codex entrypoint~~
- ~~No Codex install/discovery instructions~~
- ~~No Codex adapter skill~~
- ~~No Codex preflight command~~
- ~~No Codex compatibility documentation~~
- ~~Skill metadata warnings blocking clean Codex discovery~~
- ~~BOM-related false positives in the harness audit~~
- ~~Missing recommended `skills` metadata on the remaining warned agents~~
- ~~Missing stdio command for the `gitnexus` MCP entry~~

### 4.2 Remaining by Design

These are still manual or Claude-only by design:

- Claude hook execution remains Claude-only
- Codex still relies on manual/preflight enforcement instead of native hooks
- Optional local junction setup under `~/.agents/skills/sdd` is still a
  user-machine install step
- Claude permission policy remains governed by `.claude/settings.json`

---

## 5. Recommendation

Treat the Codex adapter as **baseline complete for practical use**.

The remaining work is no longer "make Codex usable." It is now one of:

1. Optional Claude-side permission hardening in `.claude/settings.json`
2. Further documentation refinement
3. Ongoing maintenance to keep Codex docs aligned with future SDD changes

The core strategy remains correct:

```text
Do not make SDD less Claude-native.
Make Codex understand and verify the existing SDD contract.
```
