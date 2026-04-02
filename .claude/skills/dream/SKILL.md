---
name: dream
description: "Memory consolidation — 4-phase reflective pass: Orient → Gather → Consolidate → Prune. Scans session transcripts and daily logs for new signals, merges/deduplicates topic files, keeps MEMORY.md under 200 lines. Run after intensive sessions or when memories feel stale."
argument_hint: "[optional: topic keyword to focus on, e.g. 'feedback' or 'project']"
user_invocable: true
allowed-tools: Read, Write, Glob, Grep, Bash
effort: 4
when_to_use: "Clean up and consolidate the memory directory (MEMORY.md + topic files) after long sessions, when memories are duplicated, or when MEMORY.md is approaching the 200-line/25KB limit"
---

# Dream: Memory Consolidation

You are performing a dream — a reflective pass over your memory files. Synthesize what you've learned recently into durable, well-organized memories so that future sessions orient quickly.

**Memory directory:** find the path from your system prompt — look for the "auto memory" section which says "You have a persistent, file-based memory system at `<path>`". That is your memory directory. If no such section exists, default to `~/.claude/projects/<sanitized-cwd>/memory/` where `<sanitized-cwd>` is the current working directory with `/` replaced by `-`.

**Session transcripts:** look for `*.jsonl` files in the project directory inside `~/.claude/projects/` that corresponds to the current working directory. These are signal sources — grep narrowly, do NOT read whole files.

**If the user passed a topic argument** (e.g., `/dream feedback`), focus Phase 2–3 on that topic only. Still run Phase 1 and Phase 4 in full.

---

## Phase 1 — Orient

1. `mkdir -p` the memory directory if it doesn't exist yet.
2. `ls` the memory directory — note all existing topic files.
3. Read `MEMORY.md` (if it exists) to understand the current index. If it doesn't exist, this is a fresh start — you'll create it in Phase 4.
4. Skim existing topic files to build a picture of what's already recorded — so you improve rather than duplicate.
5. If `logs/` or `sessions/` subdirectories exist, note their presence for Phase 2.
6. Check for topic files missing mandatory YAML frontmatter (name, description, type) — flag these for repair in Phase 3.

Report: memory directory path, file count, MEMORY.md line count (or "new"), any frontmatter issues found.

---

## Phase 2 — Gather recent signal

Look for new information worth persisting. **Do NOT exhaustively read transcripts.** Look only for things you already suspect matter.

Sources in priority order:

1. **Daily logs** (`logs/YYYY/MM/YYYY-MM-DD.md`) if present — append-only stream, check recent entries first.
2. **Drifted facts** — scan existing memories for claims that may contradict the current codebase (file paths, function names, flags). Verify with Glob/Grep before marking as stale.
3. **Transcript search** — grep JSONL files narrowly for specific context:
   ```bash
   grep -rn "<narrow term>" ~/.claude/projects/ --include="*.jsonl" | tail -50
   ```
   Useful search terms: user corrections ("don't", "no not", "stop"), confirmations ("exactly", "perfect"), role signals ("I'm a", "I own"), decisions ("we're going with", "we decided"), deadlines, external system URLs.

**Signal categories to look for:**

| Category | Type | Trigger phrases |
|---|---|---|
| User corrections | feedback | "no", "don't", "stop doing", "not like that", "actually..." |
| Confirmed approaches | feedback | "yes exactly", "perfect", silent acceptance of unusual choice |
| Role / expertise | user | "I'm a ...", "I've been writing X for Y years", "I own the ..." |
| Project decisions | project | "we're going with", "we decided", deadlines, incidents |
| External pointers | reference | Dashboard URLs, issue trackers, Slack channels, doc links |

**What NOT to gather** (strict exclusions):
- Code patterns, architecture, file paths, project structure — derivable from reading code.
- Git history or who-changed-what — `git log` / `git blame` are authoritative.
- Debugging solutions — the fix is in the code; context is in the commit message.
- Anything already in CLAUDE.md files.
- Ephemeral task state or current conversation context.
- PR lists / activity summaries — save only what was *surprising* or *non-obvious*.

---

## Phase 3 — Consolidate

**Before making any file modifications, show the user a plan:**
- List files to be created, updated, merged, or deleted.
- Wait for user approval before proceeding.

After approval, execute:

### 3a. Repair missing frontmatter
For any topic file flagged in Phase 1, add the required YAML frontmatter:
```markdown
---
name: {{memory name}}
description: {{one-line description — used for future relevance matching, be specific}}
type: {{user | feedback | project | reference}}
---
```

### 3b. Merge duplicates and near-duplicates
If two or more files cover the same topic (e.g., `feedback_testing_1.md` and `feedback_testing_2.md`), merge them into one canonical file. Delete the originals after merging.

### 3c. Write / update memories for new signal
For each new signal found in Phase 2, either update an existing file or create a new one.

**Memory type conventions:**

- **feedback** — Lead with the rule, then `**Why:**` (the reason the user gave) and `**How to apply:**` (when/where this kicks in). Always include Why — it enables edge-case judgement instead of blind rule-following.
- **project** — Lead with the fact/decision, then `**Why:**` (motivation, constraint, deadline) and `**How to apply:**` (how this shapes suggestions). Convert all relative dates to absolute dates (e.g., "Thursday" → "2026-04-10").
- **user** — Factual profile: role, expertise, preferences, responsibilities.
- **reference** — Pointer + purpose. One or two lines.

### 3d. Fix contradictions
If today's investigation proves an old memory wrong, fix it at the source — edit or delete the old file. Do not leave contradicting entries.

---

## Phase 4 — Prune and index

Rebuild `MEMORY.md` so it stays **under 200 lines AND under ~25KB**.

Rules for the index:
- Each entry is exactly **one line**, under ~150 characters: `- [Title](file.md) — one-line hook`
- Never write memory content directly into `MEMORY.md` — it's an index, not a dump.
- Remove pointers to deleted or superseded files.
- If an index line is over ~200 chars, shorten it — move the detail into the topic file.
- Organize semantically by topic (user → feedback → project → reference), not chronologically.

---

## Output

Return a brief summary of what was consolidated, updated, merged, pruned, or repaired. If nothing changed (memories are already tight), say so explicitly.

End with a stats line in this exact format:

**Dream complete:** X memories total | Y created, Z updated, W merged, V pruned.

*(Omit categories with a count of 0.)*
