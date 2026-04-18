---
name: architecture-decision-records
description: "Manages the ADR (Architecture Decision Record) registry. Use when recording tech-stack choices, design patterns, or infrastructure decisions with context, alternatives, and rationale. Supports listing, searching, or creating formal ADR documents."
context: fork
agent: technical-director
allowed-tools: Read, Glob, Grep, Write, Bash
argument-hint: "[title or decision topic]"
user-invocable: true
effort: 4
when_to_use: "When needing to make a formal technology decision and record the underlying reasoning in docs/architecture/."
---

# Architecture Decision Records

## Workflow Protocol

1. **Determine the next ADR number** by scanning `docs/architecture/` for existing ADRs.
2. **Gather context** by reading related code and existing ADRs.
3. **Guide the user through the decision** by asking clarifying questions if the title alone is insufficient.
4. **Generate the ADR** following the template below.
5. **Save the ADR** to `docs/architecture/adr-[NNNN]-[slug].md`.
6. **Update the Index** Table in `docs/architecture/README.md` or `docs/technical/DECISIONS.md`.

## When to write an ADR vs skip

| Write ADR | Skip ADR |
|---|---|
| New framework/database adoption | Minor version upgrades |
| API design patterns | Bug fixes |
| Security architecture | Implementation details |
| Integration patterns | Routine maintenance |

## ADR lifecycle

```
Proposed → Accepted → Deprecated → Superseded
              ↓
           Rejected
```

## Template (MADR format — use this)

```markdown
# ADR-NNNN: [Title]

## Status
Accepted | Proposed | Deprecated | Superseded by ADR-XXXX

## Context
[Problem statement, current situation, constraints, scale]

## Decision Drivers
- [Must/Should/Could requirement]

## Considered Options
### Option 1: [Name] — [one-line summary]
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
- ADR-XXXX: [relationship]
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
docs/adr/
├── README.md              # Index table
├── template.md
├── 0001-use-postgresql.md
└── 0003-mongodb-deprecated.md  # [SUPERSEDED by 0020]
```

## Index table (maintain in README.md)

| ADR | Title | Status | Date |
|---|---|---|---|
| 0001 | Use PostgreSQL | Accepted | 2024-01-10 |
| 0003 | MongoDB for profiles | Deprecated | 2023-06-15 |

## Key rules

- **Never modify accepted ADRs** — write a new one to supersede
- **Write early** — before implementation starts, not after
- **Max 1-2 pages** — if longer, decision scope is too broad
- **State real cons** — an ADR without honest tradeoffs has no value
- **Update status** — mark deprecated when superseded; link the new ADR

## Automation

```bash
# With adr-tools
adr init docs/adr
adr new "Use PostgreSQL as Primary Database"
adr new -s 3 "Deprecate MongoDB"   # -s supersedes ADR 3
adr generate toc > docs/adr/README.md
```
