# Agent Coordination and Delegation Map

## Organizational Hierarchy

```
                           [Human Developer]
                                 |
                 +---------------+---------------+
                 |               |               |
                cto      technical-director   producer
                 |               |               |
        +--------+        +------+------+    (coordinates all)
        |                 |      |      |
 product-manager    lead-programmer  qa-lead  release-manager
        |                 |
   ux-designer     +------+------+------+------+------+------+
   ux-researcher   |      |      |      |      |      |      |
                frontend backend  full  data   ai    net   tools
                -devlpr -devlpr stack  -engr  -prg   -prg  -prg
                           |
                    ui-programmer

  Additional Specialists (report to relevant leads):
    devops-engineer       -- CI/CD, infrastructure, deployment pipelines
    security-engineer     -- Code security, auth audit, threat modeling
    performance-analyst   -- Profiling, load testing, Core Web Vitals
    analytics-engineer    -- Event tracking, dashboards, usage metrics
    accessibility-specialist -- WCAG, keyboard nav, screen readers
    tech-writer           -- API docs, changelogs, developer guides
    community-manager     -- User comms, feedback synthesis, release announcements
    prototyper            -- Rapid PoC builds, technical spikes
```

## Delegation Rules

### Who Can Delegate to Whom

| From | Can Delegate To |
|------|----------------|
| `cto` | `technical-director`, `product-manager`, `producer` |
| `technical-director` | `lead-programmer`, `devops-engineer`, `security-engineer`, `performance-analyst` |
| `producer` | Any agent (task assignment within their domain only) |
| `product-manager` | `ux-designer`, `ux-researcher`, `tech-writer`, `community-manager` |
| `lead-programmer` | `frontend-developer`, `backend-developer`, `fullstack-developer`, `data-engineer`, `ai-programmer`, `network-programmer`, `tools-programmer`, `ui-programmer` |
| `qa-lead` | `qa-tester` |
| `release-manager` | `devops-engineer` (build/deploy), `qa-lead` (release testing), `tech-writer` (release notes) |
| `security-engineer` | `lead-programmer` (secure patterns), `devops-engineer` (infra security) |
| `accessibility-specialist` | `ux-designer` (accessible flows), `frontend-developer` (implementation), `qa-tester` (a11y testing) |
| `prototyper` | *(works independently, reports findings to leads)* |
| `community-manager` | *(works with product-manager for approval, release-manager for timing)* |

### Escalation Paths

| Situation | Escalate To |
|-----------|------------|
| API design disagreement | `lead-programmer`, then `technical-director` |
| Product vs engineering scope conflict | `producer`, then `cto` |
| Code architecture disagreement | `technical-director` |
| Cross-system integration conflict | `lead-programmer`, then `technical-director` |
| Schedule conflict between teams | `producer` |
| Scope exceeds capacity | `producer`, then `cto` for priority decisions |
| Quality gate disagreement | `qa-lead`, then `technical-director` |
| Performance regression | `performance-analyst` flags, `technical-director` decides |
| Security vulnerability found | `security-engineer` leads, `technical-director` signs off |

## Common Workflow Patterns

### Pattern 0: Multi-Agent Orchestration (via `/orchestrate`)

Use `/orchestrate <task>` when a task spans multiple agents and you want automatic dependency analysis, wave planning, and backlog registration.

```
Phase 1  — Ground: read CLAUDE.md, DECISIONS.md, ARCHITECTURE.md, TODO.md, PRD.md
Phase 2  — Decompose: identify which agents are needed + their deliverables
Phase 3  — Dependency analysis: sequential vs parallel per hard rules
Phase 4  — Wave plan presented to user → explicit "y" required to proceed
Phase 5  — producer registers tasks in TODO.md + .tasks/ files
Phase 5b — feature branch created automatically
Phase 6  — TodoWrite tracking per wave
Phase 7  — Execute wave by wave; stop and ask on failure
Phase 8  — Synthesis report with PR suggestion
```

**Hard sequential rules enforced by orchestrator:**

- `technical-director` → all implementation agents (architecture before code)
- `data-engineer` → `backend-developer` (schema before queries)
- `ux-designer` → `frontend-developer` (spec before implementation)
- `backend-developer` → `frontend-developer` (API before integration)
- `backend-developer` → `security-engineer` (implementation before review)
- All implementation → `tech-writer` (docs last)

**When to use `/orchestrate` vs `/team-*` skills:**

- `/orchestrate` — open-ended task, unknown agent mix, needs dependency analysis
- `/team-feature`, `/team-backend`, etc. — known fixed team, faster for standard patterns

### Pattern 1: New Feature (Full Pipeline)

```
1. product-manager    -- Writes PRD with requirements and acceptance criteria
2. cto / tech-dir     -- Reviews technical feasibility and architectural impact
3. producer           -- Schedules work, identifies dependencies
4. lead-programmer    -- Designs API contracts and interfaces
5. ux-designer        -- Creates UI/UX flows and wireframes (if UI involved)
6. [specialist devs]  -- Implement frontend, backend, or fullstack
7. qa-tester          -- Writes and executes test cases
8. qa-lead            -- Reviews test coverage and signs off
9. lead-programmer    -- Code review
10. devops-engineer   -- Deploys to staging / production
11. producer          -- Marks feature complete
```

### Pattern 2: Bug Fix

```
1. qa-tester          -- Files bug report with /bug-report
2. qa-lead            -- Triages severity and priority
3. producer           -- Assigns to sprint (if not P0/P1)
4. lead-programmer    -- Identifies root cause, assigns to developer
5. [developer]        -- Fixes the bug
6. lead-programmer    -- Code review
7. qa-tester          -- Verifies fix and runs regression
8. qa-lead            -- Closes bug
```

### Pattern 3: API Design / Backend Feature

```
1. product-manager    -- Defines requirements and consumer needs
2. lead-programmer    -- Runs /api-design to define endpoint contracts
2b. lead-programmer   -- Runs /gitnexus-impact-analysis on existing symbols being changed
3. backend-developer  -- Implements API
4. qa-tester          -- Tests API endpoints
5. tech-writer        -- Documents API in developer docs
6. lead-programmer    -- Final code review
```

### Pattern 4: Database Schema Change

```
1. data-engineer      -- Runs /db-review to design schema change
2. technical-director -- Reviews migration strategy
3. data-engineer      -- Writes migration scripts
4. backend-developer  -- Updates ORM models and queries
5. qa-tester          -- Tests data integrity and migration
6. devops-engineer    -- Runs migration in staging, then production
```

### Pattern 5: Sprint Cycle

```
1. producer           -- Plans sprint with /sprint-plan new
2. [All agents]       -- Execute assigned tasks
3. producer           -- Daily status with /sprint-plan status
4. qa-lead            -- Continuous testing during sprint
5. lead-programmer    -- Continuous code review during sprint
6. producer           -- Sprint retrospective
7. producer           -- Plans next sprint incorporating learnings
```

### Pattern 6: Milestone Checkpoint

```
1. producer           -- Runs /milestone-review
2. cto                -- Reviews technical health and architectural alignment
3. product-manager    -- Reviews product goals and user feedback
4. technical-director -- Reviews system stability and tech debt
5. qa-lead            -- Reviews quality metrics
6. producer           -- Facilitates go/no-go discussion
7. [All leads]        -- Agree on scope adjustments if needed
8. producer           -- Documents decisions and updates plans
```

### Pattern 7: Release Pipeline

```
1. producer             -- Declares release candidate, confirms milestone criteria met
2. release-manager      -- Cuts release branch, generates /release-checklist
2b. lead-programmer     -- Runs /gitnexus-pr-review on release branch vs main, attaches risk report to QA request
3. qa-lead              -- Runs full regression against affected flows, signs off on quality
4. performance-analyst  -- Confirms performance benchmarks within targets
5. security-engineer    -- Runs final security scan
6. devops-engineer      -- Builds release artifacts, runs deployment pipeline
7. tech-writer          -- Generates /changelog and release notes
8. community-manager    -- Drafts user-facing release announcement
9. technical-director   -- Final sign-off on major releases
10. release-manager     -- Deploys and monitors for 48 hours
11. producer            -- Marks release complete
```

### Pattern 8: Technical Spike / Prototype

```
1. product-manager      -- Defines the hypothesis and success criteria
2. prototyper           -- Scaffolds prototype with /prototype
3. prototyper           -- Builds minimal implementation (hours, not days)
4. lead-programmer      -- Evaluates prototype against technical criteria
5. prototyper           -- Documents findings report
6. cto                  -- Go/no-go decision on proceeding to production
7. producer             -- Schedules production work if approved
```

### Pattern 9: New Developer Onboarding

```
1. producer             -- Runs /onboard to initialize setup docs
2. tech-writer          -- Ensures documentation is current
3. devops-engineer      -- Validates development environment setup guide
4. lead-programmer      -- Reviews coding standards and architecture overview
5. qa-lead              -- Reviews test strategy and quality gates
```

## Cross-Domain Communication Protocols

### Requirements Change Notification

When a PRD changes, the `product-manager` must notify:
- `lead-programmer` (implementation impact assessment)
- `qa-lead` (test plan update needed)
- `producer` (schedule impact)
- `ux-designer` (UI/UX implications)

### Architecture Change Notification

When an ADR is created or modified, the `technical-director` must notify:
- `lead-programmer` (code changes needed)
- All affected specialist developers
- `qa-lead` (testing strategy may change)
- `producer` (schedule impact)

### Security Incident Notification

When a vulnerability is identified, `security-engineer` must notify:
- `technical-director` (severity assessment)
- `lead-programmer` (patch planning)
- `devops-engineer` (infrastructure impact)
- `producer` (schedule disruption)

## Anti-Patterns to Avoid

1. **Bypassing the hierarchy**: A specialist developer should never make architectural decisions that belong to `lead-programmer` or `technical-director` without consultation.
2. **Cross-domain implementation**: An agent should never modify files outside their designated area without explicit delegation.
3. **Shadow decisions**: All architectural decisions must be documented as ADRs. Verbal agreements without written records lead to contradictions.
4. **Monolithic tasks**: Every task assigned to an agent should be completable in 1–3 days. If it is larger, it must be broken down first.
5. **Assumption-based implementation**: If a spec is ambiguous, the implementer must ask the specifier rather than guessing.
6. **Prototype code in production**: Code from `prototyper` never goes into `src/` directly — it must be reimplemented cleanly by the appropriate specialist.
