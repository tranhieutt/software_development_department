---
name: postmortem-writing
type: workflow
description: "Writes blameless postmortems with root cause analysis, incident timelines, contributing factors, and action items. Use when conducting incident reviews or when the user mentions postmortem, root cause analysis, or blameless review."
when_to_use: "When conducting incident reviews, writing blameless postmortems, or documenting root cause analysis after production incidents"
allowed-tools: Read, Glob, Grep, Bash
argument-hint: "[incident description or ticket ID]"
user-invocable: true
effort: 3
---

# Postmortem Writing

## Blameless mindset: the non-obvious part

> "Blame-focused: Who caused this? â†’ Blameless: What conditions allowed this?"

Engineers don't fail â€” systems create conditions where failures become inevitable. The goal is improving systems, not punishing people.

## Triggers (when to write one)

- SEV1/SEV2 incidents
- Customer-facing outage > 15 minutes
- Data loss or security incident
- Novel failure modes worth sharing

## Timeline: Day 0 â†’ Day 7

```
Day 0:   Incident occurs
Day 1-2: Draft postmortem (memory is freshest)
Day 3-5: Postmortem meeting
Day 5-7: Finalize + create tickets
Week 2+: Action item completion
```

## Standard template

```markdown
# Postmortem: [Title]

**Date**: YYYY-MM-DD | **Severity**: SEV2 | **Duration**: 47 min
**Authors**: @alice, @bob | **Status**: Draft

## Executive Summary
[2-3 sentences: what broke, impact, how resolved]

**Impact**: [N customers, N minutes, revenue loss, no data loss]

## Timeline (UTC)

| Time  | Event |
|-------|-------|
| 14:23 | v2.3.4 deployed to production |
| 14:31 | Alert: payment_error_rate > 5% |
| 14:33 | On-call @alice acknowledges |
| 14:45 | Root cause identified: DB connections |
| 14:52 | Decision to rollback |
| 15:10 | Rollback complete, error rate normalizing |
| 15:18 | Service recovered |

## Root Cause Analysis

### What happened
[Technical description of failure]

### 5 Whys
- Why did service fail? â†’ DB connections exhausted
- Why exhausted? â†’ Each request opened new connection
- Why new connections? â†’ Code bypassed connection pool
- Why bypassed? â†’ Developer unfamiliar with DB patterns
- Why unfamiliar? â†’ No documentation on connection management

### Contributing factors
- Code review missed the infrastructure change
- No integration tests for connection pool behavior
- Staging traffic too low to expose the issue
- Alert threshold too high (90%, should be 70%)

## What worked / what didn't

| Worked | Didn't work |
|---|---|
| Alert fired within 8 min | Took 10 min to correlate with deployment |
| Clear Grafana dashboard | No deployment-correlated alerting |
| Fast rollback decision | No canary deployment |

## Action items

| Priority | Action | Owner | Due | Ticket |
|---|---|---|---|---|
| P0 | Integration test for connection pool | @alice | 2024-01-22 | ENG-1234 |
| P0 | Lower DB alert threshold to 70% | @bob | 2024-01-17 | OPS-567 |
| P1 | Document connection management patterns | @alice | 2024-01-29 | DOC-89 |
| P2 | Evaluate canary deployment | @charlie | 2024-02-15 | ENG-1235 |
```

## Quick template (SEV3, < 30 min)

```markdown
# Quick Postmortem: [Title]
**Date**: YYYY-MM-DD | **Duration**: 12 min | **Severity**: SEV3

**What happened**: Cache flush caused thundering herd â€” all requests missed cache simultaneously.
**Timeline**: 10:00 flush â†’ 10:02 alerts â†’ 10:05 identified â†’ 10:08 warming enabled â†’ 10:12 normal
**Root cause**: Full flush used for minor config update.
**Fixes**: Immediate: enabled warming. Long-term: partial invalidation (ENG-999).
**Lesson**: Never full-flush production cache; use targeted invalidation.
```

## Meeting structure (60 min)

1. **Opening** (5 min) â€” state blameless norms explicitly
2. **Timeline review** (15 min) â€” chronological walkthrough
3. **Analysis** (20 min) â€” what failed, why, what conditions allowed it
4. **Action items** (15 min) â€” brainstorm â†’ prioritize â†’ assign owners
5. **Close** (5 min) â€” confirm owners, schedule follow-up

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| "Human error" as root cause | Always dig deeper â€” why did the system allow it? |
| Shallow analysis (1 why) | Doesn't prevent recurrence |
| No action items | Meeting was a waste of time |
| Unrealistic actions | Never completed |
| No follow-up tracking | Actions forgotten |

## Output

Save to `docs/technical/postmortem-YYYY-MM-DD-[slug].md`

Deliver: timeline + 1-sentence root cause + max 5 action items with owner and deadline
