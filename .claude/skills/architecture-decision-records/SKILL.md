---
name: architecture-decision-records
type: workflow
description: "Manages the ADR (Architecture Decision Record) registry. Use when recording tech-stack choices, design patterns, or infrastructure decisions with context, alternatives, and rationale. Supports listing, searching, or creating formal ADR documents."
context: fork
agent: technical-director
allowed-tools: Read, Glob, Grep, Write, Bash
argument-hint: "[title or decision topic]"
user-invocable: true
effort: 4
when_to_use: "When needing to make a formal technology decision and record the underlying reasoning in docs/internal/adr/."
---

# Architecture Decision Records

## Workflow Protocol

1. **Determine the next ADR number** by scanning `docs/internal/adr/` for existing ADRs.
2. **Run the decision-ledger read gate** before drafting:
   `/trace-history --risk High --last 20`.
   Include relevant prior decisions, or state that no relevant high-risk prior
   decision was found.
3. **Gather context** by reading related code and existing ADRs.
4. **Guide the user through the decision** by asking clarifying questions if the title alone is insufficient.
5. **Generate the ADR** following the template below.
6. **Save the ADR** to `docs/internal/adr/ADR-[NNN]-[slug].md`.
7. **Update the Index** Table in `docs/technical/DECISIONS.md`.

## When to write an ADR vs skip

| Write ADR | Skip ADR |
|---|---|
| New framework/database adoption | Minor version upgrades |
| API design patterns | Bug fixes |
| Security architecture | Implementation details |
| Integration patterns | Routine maintenance |

## ADR lifecycle

```
Proposed â†’ Accepted â†’ Deprecated â†’ Superseded
              â†“
           Rejected
```

## Template (MADR format â€” use this)

```markdown
# ADR-NNN: [Title]

## Status
Accepted | Proposed | Deprecated | Superseded by ADR-NNN

## Context
[Problem statement, current situation, constraints, scale]

## Prior Decision Check
[Result of `/trace-history --risk High --last 20`; cite relevant prior entries
or state "No relevant prior high-risk decisions found."]

## Decision Drivers
- [Must/Should/Could requirement]

## Considered Options
### Option 1: [Name] â€” [one-line summary]
Pros: ... | Cons: ...

### Option 2: [Name]
Pros: ... | Cons: ...

## Decision
We will use **[Option N]** because [key rationale].

## Consequences
**Positive:** ...
**Negative:** ...
**Risks:** ... Mitigation: ...

## Related ADRs
- ADR-NNN: [relationship]
```

## Quick examples

**Lightweight ADR (for clear-cut decisions):**
```markdown
# ADR-0012: Adopt TypeScript for Frontend

**Status**: Accepted | **Date**: 2024-01-15 | **Deciders**: @alice, @bob

## Context
50+ React components with prop-type-mismatch bugs. PropTypes are runtime-only.

## Decision
TypeScript for all new frontend code. Migrate incrementally with `allowJs: true`.

## Consequences
Good: Compile-time errors, better IDE support.
Bad: Learning curve, initial slowdown.
```

**Y-Statement (for concise formal record):**
```markdown
In the context of **building a microservices architecture**,
facing **need for centralized auth and rate limiting**,
we decided for **Kong Gateway**
and against **AWS API Gateway and custom Nginx**,
to achieve **vendor independence and plugin extensibility**,
accepting **we manage Kong infrastructure ourselves**.
```

## File structure

```
docs/internal/adr/
â”œâ”€â”€ ADR-0001-use-postgresql.md
â””â”€â”€ ADR-0003-mongodb-deprecated.md  # [SUPERSEDED by ADR-0020]
```

## Index table (maintain in docs/technical/DECISIONS.md)

| ADR | Title | Status | Date |
|---|---|---|---|
| 0001 | Use PostgreSQL | Accepted | 2024-01-10 |
| 0003 | MongoDB for profiles | Deprecated | 2023-06-15 |

## Key rules

- **Never modify accepted ADRs** â€” write a new one to supersede
- **Write early** â€” before implementation starts, not after
- **Max 1-2 pages** â€” if longer, decision scope is too broad
- **State real cons** â€” an ADR without honest tradeoffs has no value
- **Update status** â€” mark deprecated when superseded; link the new ADR

## Automation

```bash
# Custom repo path:
# 1. Create docs/internal/adr/ADR-[NNN]-[slug].md
# 2. Append one summary row and one summary entry to docs/technical/DECISIONS.md
# 3. Do not overwrite docs/technical/DECISIONS.md; it is append-only
```
