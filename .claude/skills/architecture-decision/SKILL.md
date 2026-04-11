---
name: architecture-decision
description: "Documents architectural and technology decisions as Architecture Decision Records (ADRs). Use when a significant tech-stack choice, design pattern, or infrastructure decision needs to be recorded with context and rationale."
argument-hint: "[title]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
context: fork
agent: cto
effort: 4
when_to_use: "When needing to make a technology decision and record the underlying reasoning"
---

When this skill is invoked:

1. **Determine the next ADR number** by scanning `docs/architecture/` for
   existing ADRs.

2. **Gather context** by reading related code and existing ADRs.

3. **Guide the user through the decision** by asking clarifying questions if
   the title alone is not sufficient.

4. **Generate the ADR** following this format:

```markdown
# ADR-[NNNN]: [Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Date
[Date of decision]

## Context

### Problem Statement
[What problem are we solving? Why does this decision need to be made now?]

### Constraints
- [Technical constraints]
- [Timeline constraints]
- [Resource constraints]
- [Compatibility requirements]

### Requirements
- [Must support X]
- [Must perform within Y budget]
- [Must integrate with Z]

## Decision

[The specific technical decision made, described in enough detail for someone
to implement it.]

### Architecture Diagram
[ASCII diagram or description of the system architecture this creates]

### Key Interfaces
[API contracts or interface definitions this decision creates]

## Alternatives Considered

### Alternative 1: [Name]
- **Description**: [How this would work]
- **Pros**: [Advantages]
- **Cons**: [Disadvantages]
- **Rejection Reason**: [Why this was not chosen]

### Alternative 2: [Name]
- **Description**: [How this would work]
- **Pros**: [Advantages]
- **Cons**: [Disadvantages]
- **Rejection Reason**: [Why this was not chosen]

## Consequences

### Positive
- [Good outcomes of this decision]

### Negative
- [Trade-offs and costs accepted]

### Risks
- [Things that could go wrong]
- [Mitigation for each risk]

## Performance Implications
- **CPU**: [Expected impact]
- **Memory**: [Expected impact]
- **Load Time**: [Expected impact]
- **Network**: [Expected impact, if applicable]

## Migration Plan
[If this changes existing code, how do we get from here to there?]

## Validation Criteria
[How will we know this decision was correct? What metrics or tests?]

## Related Decisions
- [Links to related ADRs]
- [Links to related design documents]
```

5. **Save the ADR** to `docs/architecture/adr-[NNNN]-[slug].md`.

6. **Cross-post a summary entry** to `docs/technical/DECISIONS.md` by appending the following block at the bottom of the file (above the closing comment line if present):

```markdown
## ADR-[NNN]: [Title]

**Date**: [Date]
**Status**: Accepted
**Deciders**: [Name(s) / @agent]
**Detailed ADR**: [docs/architecture/adr-[NNNN]-[slug].md](../architecture/adr-[NNNN]-[slug].md)

### Context
[One paragraph summary of the problem]

### Decision
[One paragraph summary of the decision and primary reason]

### Consequences
- **Positive**: [Key benefit]
- **Negative**: [Key trade-off accepted]
```

   Also update the **Decision Index** table in `docs/technical/DECISIONS.md` by replacing the placeholder row (or appending a new row) with:
   `| ADR-NNN | [Title] | Accepted | [Date] | [Decider] |`

## Protocol

- **Question**: Clarify title, context, constraints, and alternatives if the argument alone is insufficient
- **Options**: Alternatives Considered section — presents and evaluates 2+ options before deciding
- **Decision**: User confirms the decision to record before ADR is drafted
- **Draft**: Full ADR shown in conversation before saving
- **Approval**: "May I write to `docs/architecture/adr-[NNN]-[slug].md`?"

## Output

Deliver exactly:

- **ADR file** saved to `docs/architecture/adr-[NNNN]-[slug].md`
- **Decision Index** entry appended to `docs/technical/DECISIONS.md`
- **Summary** in 2 sentences: what was decided and why
- **Top risk** to watch from the Consequences section
