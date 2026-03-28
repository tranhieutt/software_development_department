# Systems Index: [Application/Product Name]

> **Status**: [Draft / Under Review / Approved]
> **Created**: [Date]
> **Last Updated**: [Date]
> **Source Concept**: design/specs/product-requirements.md

---

## Overview

[One paragraph explaining the application's technical scope. What kind of systems
does this application need? Reference the core workflows and product pillars. This
should help any team member understand the "big picture" of what needs to be
designed and built.]

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | [e.g., API Gateway] | Core | MVP | [Not Started / In Design / In Review / Approved / Implemented] | [design/specs/api-gateway.md or "—"] | [e.g., Auth System, Database] |
| 2 | [e.g., Authentication System] | Core | MVP | Not Started | — | API Gateway |

[Add a row for every identified system. Use the categories and priority tiers
defined below. Mark systems that were inferred (not explicitly in the requirements
doc) with "(inferred)" in the system name.]

---

## Categories

| Category | Description | Typical Systems |
|----------|-------------|-----------------|
| **Core** | Foundation systems everything depends on | API gateway, input handling, database layer, configuration, service registry, state management |
| **Business Logic** | The systems that deliver product value | Authentication, authorization, user management, notifications, search, data processing |
| **User Progression** | Feature adoption and user growth | Onboarding flows, feature flags, usage tracking, milestones, user preferences |
| **Economy** | Resource and transaction management | Billing, subscriptions, usage metering, entitlements, payment processing |
| **Persistence** | Data storage and continuity | Database access layer, caching, file storage, cloud sync, session management |
| **UI** | User-facing information displays | Dashboard, navigation, settings panel, notification UI, data visualization |
| **Integrations** | Third-party and external system connections | OAuth providers, webhooks, external APIs, import/export, SDK |
| **Onboarding** | Tutorial flows, help system, in-app guidance | Onboarding wizard, contextual help, empty states, progressive disclosure |
| **Meta** | Systems outside the core product flow | Analytics, error tracking, accessibility options, admin panel, audit logging |

[Not every application needs every category. Remove categories that don't apply.
Add custom categories if needed.]

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | Required for the core workflow to function. Without these, you can't test "does this deliver value?" | First working prototype | Design FIRST |
| **Feature Demo** | Required for one complete, polished user flow. Demonstrates the full experience. | Feature demonstration / public beta | Design SECOND |
| **Alpha** | All features present in rough form. Complete functional scope, placeholder content OK. | Alpha milestone | Design THIRD |
| **Full Vision** | Polish, edge cases, nice-to-haves, and content-complete features. | Beta / Release | Design as needed |

---

## Dependency Map

[Systems sorted by dependency order — design and build from top to bottom.
Systems at the top are foundations; systems at the bottom are wrappers.]

### Foundation Layer (no dependencies)

1. [System] — [one-line rationale for why this is foundational]

### Core Layer (depends on foundation)

1. [System] — depends on: [list]

### Feature Layer (depends on core)

1. [System] — depends on: [list]

### Presentation Layer (depends on features)

1. [System] — depends on: [list]

### Polish Layer (depends on everything)

1. [System] — depends on: [list]

---

## Recommended Design Order

[Combining dependency sort and priority tiers. Design these systems in this
order. Each system's spec should be completed and reviewed before starting the
next, though independent systems at the same layer can be designed in parallel.]

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | [First system to design] | MVP | Foundation | product-manager | [S/M/L] |
| 2 | [Second system] | MVP | Foundation | technical-director | [S/M/L] |

[Effort estimates: S = 1 session, M = 2-3 sessions, L = 4+ sessions.
A "session" is one focused design conversation producing a complete spec.]

---

## Circular Dependencies

[List any circular dependency chains found during analysis. These require
special architectural attention — either break the cycle with an interface,
or design the systems simultaneously.]

- [None found] OR
- [System A <-> System B: Description of the circular relationship and
  proposed resolution]

---

## High-Risk Systems

[Systems that are technically unproven, design-uncertain, or scope-dangerous.
These should be prototyped early regardless of priority tier.]

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| [System] | [Technical / Design / Scope] | [What could go wrong] | [Prototype, research, or scope fallback] |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | [N] |
| Design docs started | [N] |
| Design docs reviewed | [N] |
| Design docs approved | [N] |
| MVP systems designed | [N/total MVP] |
| Feature Demo systems designed | [N/total FD] |

---

## Next Steps

- [ ] Review and approve this systems enumeration
- [ ] Design MVP-tier systems first (use `/design-system [system-name]`)
- [ ] Run `/design-review` on each completed spec
- [ ] Run `/gate-check pre-production` when MVP systems are designed
- [ ] Prototype the highest-risk system early (`/prototype [system]`)
