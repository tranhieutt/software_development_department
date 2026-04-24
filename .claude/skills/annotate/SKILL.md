---
name: annotate
type: workflow
description: "Records unexpected API behaviors, undocumented caveats, version bugs, or non-obvious workarounds into .claude/memory/annotations.md. Use immediately when an undocumented behavior or surprising caveat is discovered during development."
argument-hint: "<service-or-library> <what-you-discovered>"
user-invocable: true
allowed-tools: Read, Edit, Bash
effort: 1
when_to_use: "When you encounter: unexpected API behavior, undocumented caveats, version incompatibilities, rate limit quirks, authentication edge cases, or any non-obvious workaround that took time to discover"
---

# /annotate — Persist a Learned Lesson

You are adding a persistent annotation to the project's learned knowledge base.
Annotations survive across sessions and auto-load when working with relevant services.

**Arguments:** `$ARGUMENTS` — format: `<service> <description of gotcha/caveat>`

---

## Phase 1 — Parse the Annotation

Extract from `$ARGUMENTS`:
- **Service/Library**: The specific service, library, or area (e.g., `stripe`, `next.js`, `postgresql`)
- **Annotation text**: The gotcha, caveat, or learned lesson

If `$ARGUMENTS` is empty or unclear, ask:
> "What service/library does this apply to, and what did you discover?"

---

## Phase 2 — Format the Entry

Format the annotation as:

```
- [YYYY-MM-DD] <clear, specific description of the issue> — <workaround if applicable>
```

**Good example:**
```
- [2026-04-07] Stripe webhook signature verification requires raw body buffer, not parsed JSON. 
  Pass rawBody to stripe.webhooks.constructEvent() instead of req.body
```

**Bad example:**
```
- Stripe webhooks broken  ← too vague, no date, no solution
```

Apply this quality check before writing:
- ✅ Specific enough to be actionable without additional research?
- ✅ Includes the date?
- ✅ Includes workaround if one exists?
- ✅ Would a new developer understand this without context?

---

## Phase 3 — Find or Create the Section

Read `.claude/memory/annotations.md`.

1. Find the existing section that matches the service (case-insensitive)
2. If no matching section exists, create one:

```markdown
## <Service Name>

- [YYYY-MM-DD] <your annotation>
```

3. If the section exists and has `*(no annotations yet)*`, replace that line with the entry.
4. If the section exists with entries, append the new entry below the last one.

---

## Phase 4 — Write and Confirm

Edit `.claude/memory/annotations.md` with the new entry.

Then confirm:

```
✅ Annotation saved to .claude/memory/annotations.md

Service: <service>
Entry: [YYYY-MM-DD] <annotation text>

This will auto-load in future sessions when working with <service>.
```

---

## Annotation Quality Rules

- **Never** write vague entries like "be careful with X" — always explain WHY
- **Always** include the date (use current date: 2026-04-07)
- **Always** include the workaround if you found one
- **Prefer** short entries (1-2 lines) — link to docs if more context needed
- **Mark** if issue is version-specific: `(affects v2.x, fixed in v3.0)`
- **Group** related gotchas under the same service header

---

## When Agents Should Use This Automatically

You do NOT need to wait for `/annotate` to be called explicitly.
**Proactively** add annotations when you:

1. Spend more than 10 minutes debugging an unexpected API or library behavior
2. Find that official docs are wrong, incomplete, or misleading
3. Discover a version incompatibility not mentioned in release notes
4. Work around a bug with a non-obvious solution
5. Find that a library's "default" behavior causes problems in this project's setup

> **Pattern from Context Hub:** The value compounds over time.
> Each annotation means the NEXT session starts smarter — not from zero.
