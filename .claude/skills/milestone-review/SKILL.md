---
name: milestone-review
type: workflow
description: "Conducts a structured milestone review analyzing delivered features, metrics, blockers, and readiness for the next phase. Use when completing a milestone or when the user mentions milestone review or phase gate."
argument-hint: "[milestone-name|current]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
effort: 3
when_to_use: "When reviewing milestone progress, assessing feature completeness, or making a go/no-go recommendation for a deadline"
---

When this skill is invoked:

1. **Read the milestone definition** from `production/milestones/`.

2. **Read all sprint reports** for sprints within this milestone from
   `production/sprints/`.

3. **Scan the codebase** for TODO, FIXME, HACK markers that indicate
   incomplete work.

4. **Check the risk register** at `production/risk-register/`.

5. **Generate the milestone review**:

```markdown
# Milestone Review: [Milestone Name]

## Overview
- **Target Date**: [Date]
- **Current Date**: [Today]
- **Days Remaining**: [N]
- **Sprints Completed**: [X/Y]

## Feature Completeness

### Fully Complete
| Feature | Acceptance Criteria | Test Status |
|---------|-------------------|-------------|

### Partially Complete
| Feature | % Done | Remaining Work | Risk to Milestone |
|---------|--------|---------------|------------------|

### Not Started
| Feature | Priority | Can Cut? | Impact of Cutting |
|---------|----------|----------|------------------|

## Quality Metrics
- **Open S1 Bugs**: [N] -- [List]
- **Open S2 Bugs**: [N]
- **Open S3 Bugs**: [N]
- **Test Coverage**: [X%]
- **Performance**: [Within budget? Details]

## Code Health
- **TODO count**: [N across codebase]
- **FIXME count**: [N]
- **HACK count**: [N]
- **Technical debt items**: [List critical ones]

## Risk Assessment
| Risk | Status | Impact if Realized | Mitigation Status |
|------|--------|-------------------|------------------|

## Velocity Analysis
- **Planned vs Completed** (across all sprints): [X/Y tasks = Z%]
- **Trend**: [Improving / Stable / Declining]
- **Adjusted estimate for remaining work**: [Days needed at current velocity]

## Scope Recommendations
### Protect (Must ship with milestone)
- [Feature and why]

### At Risk (May need to cut or simplify)
- [Feature and risk]

### Cut Candidates (Can defer without compromising milestone)
- [Feature and impact of cutting]

## Go/No-Go Assessment

**Recommendation**: [GO / CONDITIONAL GO / NO-GO]

**Conditions** (if conditional):
- [Condition 1 that must be met]
- [Condition 2 that must be met]

**Rationale**: [Explanation of the recommendation]

## Action Items
| # | Action | Owner | Deadline |
|---|--------|-------|----------|
```

## Protocol

- **Question**: Reads milestone name or `current` from argument
- **Options**: Skip
- **Decision**: Skip — Go/No-Go is a recommendation, not a gate
- **Draft**: Full review shown in conversation before saving
- **Approval**: "May I write to `production/milestones/[milestone]-review.md`?"

## Output

Deliver exactly:

- **Feature completeness** score (X/Y features done)
- **Quality metrics**: test pass rate, known bug count by severity
- **Top 3 risks** with probability and impact
- **Recommendation**: `GO` / `CONDITIONAL GO` / `NO-GO` with rationale
- **Action items table** — numbered, with owner and deadline
