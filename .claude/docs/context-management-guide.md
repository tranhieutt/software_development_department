# Context Management — Detailed Guide

Reference companion to `context-management.md` (the rules file injected into
every API call). This file is NOT injected — read it when you need examples,
rationale, or onboarding context.

---

## Table of Contents

1. [Session State File — Examples](#session-state-file--examples)
2. [Compaction Patterns](#compaction-patterns)
3. [Memory System Deep Dive](#memory-system-deep-dive)
4. [Subagent Patterns](#subagent-patterns)
5. [CLAUDE.md Writing Style](#claudemd-writing-style)
6. [Static vs Dynamic Content Strategy](#static-vs-dynamic-content-strategy)
7. [@include Chain Rules](#include-chain-rules)
8. [Stop Hook Taxonomy](#stop-hook-taxonomy)
9. [Session Startup Order](#session-startup-order)
10. [Common Misconceptions](#common-misconceptions)

---

## Session State File — Examples

### YAML Frontmatter

Every `active.md` must begin with a YAML frontmatter block for fast parsing by
agents and hooks — no need to read the full file to understand session context:

```yaml
---
session: feat-auth-revamp          # short slug for this work session
branch: feature/auth-v2            # git branch being worked on
tags: [auth, backend, breaking]    # searchable labels
started: 2026-04-01T09:00:00Z      # ISO timestamp session began
lastActive: 2026-04-01T10:30:00Z   # ISO timestamp of last update
---
```

### STATUS Block

When the project is in Production, Polish, or Release stage, include a structured
status block in `active.md` that the status line script can parse:

```markdown
<!-- STATUS -->
Epic: Combat System
Feature: Melee Combat
Task: Implement hitbox detection
<!-- /STATUS -->
```

- All three fields (Epic, Feature, Task) are optional — include only what applies
- Update this block when switching focus areas
- The status line displays it as a breadcrumb: `Combat System > Melee Combat > Hitboxes`
- Remove or empty the block when no active work focus exists

### Compact Boundary Marker

When running `/compact`, insert a boundary marker in `active.md` **before**
appending the new STATUS block. This mirrors Claude Code's `marble-origami-commit`
entry — agents recovering from crash only need to read from the last marker forward:

```markdown
<!-- COMPACT: 2026-04-01T10:30:00Z | Task: Implement auth middleware -->
--- Context archived above this line. Read only what follows for current state. ---
```

- Include the ISO timestamp and the task being worked on at time of compaction
- After recovery, skip everything above the last `<!-- COMPACT: ... -->` line
- Multiple markers are fine — they form an auditable compaction history

### Files Changed Attribution

Maintain a `## Files This Session` section in `active.md` — updated whenever a
file is created or modified. This mirrors Claude Code's `attribution-snapshot`
pattern and gives agents an instant map of what changed without running `git diff`:

```markdown
## Files This Session
- [src/auth/jwt.ts](src/auth/jwt.ts) — created
- [src/auth/middleware.ts](src/auth/middleware.ts) — modified (added refresh logic)
- [tests/auth.test.ts](tests/auth.test.ts) — created (test-first)
- [docs/technical/API.md](docs/technical/API.md) — updated (new /refresh endpoint)
```

Status values: `created`, `modified`, `deleted`, `renamed from X`.

### Partial File Read Log

When reading a large file that gets truncated (tool returns
`[Partial view: lines X-Y of Z]`), the agent must log it immediately in
`active.md`. This mirrors Claude Code's `isPartialView` pattern — the agent
knows context is incomplete and must not reason from the unread portion:

```markdown
## Partial Reads This Session
- [src/auth/middleware.ts](src/auth/middleware.ts) — read lines 1-500/1240 only, token refresh section unread
```

Before concluding about a file, check this list — if a partial read exists,
re-read the remaining portion or use Grep to find the exact section needed.

### Stale Cache Warning

When an agent caches a decision or value mid-session (feature flag, config value,
git branch name), mark it clearly in `active.md`. This mirrors Claude Code's
`getFeatureValue_CACHED_MAY_BE_STALE()` pattern — cached values may no longer be
correct if the environment changed while the session was running:

```markdown
## Cached Decisions (may be stale)
- Stack: TypeScript + Express (read at 09:00 — may be stale if config changed)
- DB schema version: v14 (read from migration file — not re-verified)
```

**Rule:** Before making an important decision based on a cached value, ask:
*"Could this value have changed since I read it?"* If yes — re-read first.

---

## Compaction Patterns

### Incremental File Writing

When creating multi-section documents (design docs, architecture docs):

1. Create the file immediately with a skeleton (all section headers, empty bodies)
2. Discuss and draft one section at a time in conversation
3. Write each section to the file as soon as it's approved
4. Update the session state file after each section
5. After writing a section, previous discussion about that section can be safely
   compacted — the decisions are in the file

This keeps the context window holding only the *current* section's discussion
(~3-5k tokens) instead of the entire document's conversation history (~30-50k tokens).

### Context Budget Rationale

- **Light (read/review): ~3k tokens** — enough for 1-2 file reads + response
- **Medium (implement feature): ~8k tokens** — file reads + code generation + tests
- **Heavy (multi-system refactor): ~15k tokens** — multiple systems, cross-cutting changes

---

## Memory System Deep Dive

### Explicit Feedback Capture

The `extractMemories` agent runs after each turn and decides what to save based on
conversation patterns. If the user stays silent after the agent makes a mistake,
the agent may extract the wrong approach as memory. Two cases require explicit feedback:

**When the agent made a mistake** — state it directly with the reason:
> *"Don't use this approach because it causes N+1 queries. Use eager loading instead."*

**When the agent did something right in a non-obvious way** — confirm:
> *"Yes, bundled PR is correct in this case. Continue in this direction."*

Both are extracted as `feedback` memory, applied to all future sessions.
`feedback` type has the highest ROI — one acknowledgment, permanent benefit.

### PII & Secret Safety for Memory Files

Before writing any content to `.claude/memory/`, the agent must self-check:

**Never save to memory:**

- API keys, tokens, passwords, private keys (`sk-...`, `ghp_...`, `-----BEGIN...`)
- Connection strings with credentials (`postgresql://user:pass@...`)
- User PII (email, phone number, real name if unrelated to work)
- Raw source code content (save insights only, not code)

**Save insights only, not raw data.** If unsure — skip it, don't save.
Reference `secrets-config.md` for the full list of forbidden patterns.

### Memory Taxonomy

- **`user`**: Information about the pilot (skills, role, preferences).
- **`feedback`**: Do's/Don'ts, coding rules, or specific feedback items that agents must learn.
- **`project`**: Tech decisions, deadlines, known bugs (bias towards the whole team).
- **`reference`**: Pointers to external tools, log files, or Linear/Jira boards.

---

## Subagent Patterns

### Forked Agent — Restricted Tool Access

When spawning background agents (memory extraction, documentation, summarization),
declare the tool scope explicitly in the prompt. This mirrors Claude Code's
`runForkedAgent({ tools: [...] })` pattern — background agents must not have
full tool access:

| Background Agent Type | Allowed Tools |
| --- | --- |
| Memory extraction | Read, Grep, Glob, Write (`.claude/memory/` only) |
| Documentation update | Read, Glob, Write (`docs/` only) |
| Code summarization | Read, Grep, Glob (read-only) |
| Test analysis | Read, Grep, Glob, Bash (read-only commands) |

**Rule:** Background agents must never use Edit/Write outside their designated
directory. Must not use Bash with state-modifying commands (git, npm install, rm...).

### Subagent Outcomes Log

After each subagent returns, append its result to the `## Subagent Log` section
in `active.md`. This mirrors Claude Code's `agent-{id}.meta.json` pattern —
a lightweight audit trail of what was delegated and what came back:

```markdown
## Subagent Log
| Time  | Agent              | Task                          | Outcome             |
|-------|--------------------|-------------------------------|---------------------|
| 10:15 | security-engineer  | Review auth middleware        | PASSED — no issues  |
| 10:22 | backend-developer  | Implement JWT refresh logic   | DONE — see jwt.ts   |
| 10:45 | qa-engineer        | Write auth test cases         | BLOCKED — needs DB  |
```

Outcome values: `DONE`, `PASSED`, `FAILED`, `BLOCKED`, `PARTIAL — <reason>`.

---

## CLAUDE.md Writing Style

CLAUDE.md is injected into **every API call**, not just the start of a session.
Every token in it costs budget. Write it like an effective prompt, not documentation:

```markdown
✅ "Always use TypeScript strict mode"
✅ "Don't mock the database in tests"
✅ "API response must follow format { data, error, meta }"

❌ "We use TypeScript in this project with strict mode enabled..."
❌ "Per team conventions, the database should not be mocked in tests because..."
```

**4 principles:**

1. **Imperative, concise** — rules, not explanations
2. **Most important rules first** — token budget affects the tail
3. **Reasoning goes in memory files** — do not stuff into CLAUDE.md
4. **Use `@file-path`** to reference long files instead of copying content

---

## Static vs Dynamic Content Strategy

Claude Code caches context in 2 zones separated by `SYSTEM_PROMPT_DYNAMIC_BOUNDARY`.
SDD should apply the same principle to optimize tokens and prevent context bloat:

**Static (cache-stable) — place in `@included` files:**

- Coding standards, naming conventions, forbidden patterns
- Agent coordination rules, security rules
- Directory structure, architecture decisions
- Content that changes per sprint/version — not within a session

**Dynamic (per-session) — place in `active.md` and memory files:**

- Current task, progress checklist, open questions
- Files changed this session, subagent outcomes
- Git branch, current sprint context
- Content that changes every turn

**Rule:** Never put session-specific state into `@included` static files.
Never duplicate stable rules into `active.md`.

---

## @include Chain Rules

Claude Code resolves `@path` in CLAUDE.md with cycle detection (Set of resolved
paths). SDD must follow 3 rules to avoid loops and context bloat:

1. **Maximum 2 levels of nesting:** `CLAUDE.md` → `@file-A.md` → `@file-B.md` — stop here.
   Do not let `file-B.md` `@include` additional files.
2. **No circular references:** File A must not `@include` any file that already includes A.
3. **Each file included only once:** If two files both `@include` a shared file,
   content will be duplicated in context. Use reference links instead of direct includes.

---

## Stop Hook Taxonomy

When a task or subagent completes, classify all follow-up operations before
executing them. This mirrors Claude Code's `handleStopHooks()` split between
fire-and-forget background jobs and blocking shell hooks:

**Background — fire-and-forget (non-blocking, run concurrently):**

- Memory extraction — save new user/project/feedback insights to `.claude/memory/`
- `autoDream` — consolidate `MEMORY.md` if it approaches the 200-line limit
- Session log append — write outcome to `## Subagent Log` in `active.md`

**Blocking — must complete before next task starts:**

- Shell/JS hooks configured in `settings.json`
- Git commit hooks (pre-commit, post-commit)
- Permission approval requests surfaced to the user

Never delay the main task waiting for background operations. Never skip blocking
operations to gain speed — they exist for data integrity and safety.

---

## Session Startup Order

When a session starts, operations must run in this order — mirrors Claude Code's
`main.tsx` initialization sequence (parallel first, sequential after):

```text
Phase 1 — Parallel (no dependencies):
  ├── Load MEMORY.md index + recall relevant topic files
  ├── Load active.md session state
  ├── Snapshot git status + recent commits
  └── Load feature flags / remote settings (fail-open on error)

Phase 2 — Sequential (depends on Phase 1):
  ├── Merge all CLAUDE.md layers (managed → user → project → local)
  ├── Resolve @include chains
  └── Build final context for first turn

Phase 3 — Background (fire-and-forget, non-blocking):
  ├── Check if autoDream gate passed (24h + 5 sessions)
  └── Queue memory extraction for last turn of previous session
```

**Rule:** Do not block Phase 2 because Phase 3 is unfinished. Do not skip Phase 1
for speed — missing git status or memory context leads to wrong decisions.

---

## Common Misconceptions

Most frequent misunderstandings — distilled from Claude Code source code analysis:

| Misconception | Reality |
| --- | --- |
| Claude "remembers" from previous sessions | No — only remembers if persistent memory files exist |
| ESC stops Write/Edit immediately | No — Write/Edit completes the file first before aborting (data integrity) |
| "prompt too long" error = must restart | No — try `/compact` first, there is a 4-layer recovery |
| Interrupting when Claude is "slow" | No — it may be running a recovery cycle |
| CLAUDE.md is read only at session start | No — injected into every API call |
| Git status auto-updates during session | No — snapshot at start, no real-time refresh |
| `/resume` only loads messages | No — loads file history, worktree state, todos, attribution |
| Any memory file can be recalled | No — only ≤5 files are selected based on `description` |
| MEMORY.md truncation shows a warning | No — line 201+ is silently dropped, no notification |
| Any agent can run in parallel | No — only read-only agents are concurrent-safe |
