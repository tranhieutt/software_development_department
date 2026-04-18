# Architecture Spec / Technical Design Document

## Project
Software Development Department — `.claude` System Architecture

## Version
v1.0

## Status
Draft for review

## 1. Executive Summary

This project is not a conventional product application repository. It is a **Human-in-the-loop AI Software Development Operating System** centered around the `.claude` directory.

The system is designed to augment software development through:
- structured workflow gates
- specialized AI roles
- reusable skills and commands
- event-driven runtime hooks
- durable memory and session state
- governance, audit, and recovery mechanisms

The project is explicitly **not** designed as an autonomous multi-agent software factory. The **human is the primary orchestrator** and final decision-maker. AI components operate within bounded roles, procedural rules, and runtime safeguards.

In practical terms, `.claude` functions as the core operating layer for a software development department supported by AI.

---

## 2. Architectural Positioning

### 2.1 System Identity

The most accurate technical framing for this project is:

**Human-Orchestrated AI Software Development Operating System**

Alternative phrasing:
- Human-in-the-loop Development OS
- Human-governed AI Software Department Runtime

### 2.2 Core Design Intent

The architecture aims to solve these problems:
- reduce cognitive load on the human orchestrator
- standardize software development workflows
- prevent uncontrolled AI behavior
- preserve continuity across sessions and context compaction
- support role-based execution and cross-domain handoff
- create an auditable, recoverable development environment

### 2.3 Non-Goals

This system is not intended to:
- fully replace human orchestration
- let agents operate autonomously without approval boundaries
- serve as a pure code-generation repo without governance
- rely on conversation history as the primary source of truth

---

## 3. Architectural Principles

### 3.1 Human-in-the-loop Control
The human remains the true orchestrator. AI proposes, assists, executes within scope, and records state. Final direction, approval, and escalation remain human responsibilities.

### 3.2 Stage-Gated Workflow
Tasks should move through explicit workflow stages such as planning, specification, implementation, diagnosis, or context repair rather than free-form prompt execution.

### 3.3 Role-Based Execution
Work is segmented by specialist roles. Each role has a bounded domain, document ownership, escalation path, and expected skill usage.

### 3.4 Guarded Runtime Behavior
Potentially risky actions are intercepted by hooks, validations, permission policies, and coordination rules.

### 3.5 Durable File-Based Memory
Persistent knowledge lives in files and structured state, not in ephemeral conversation context.

### 3.6 Auditability and Recoverability
The system should support tracing, replaying decisions, understanding failures, and resuming work after crashes or context compaction.

---

## 4. High-Level Architecture

```text
Human Orchestrator
  ↓
CLAUDE.md (global constitution / semantic root)
  ↓
Skills / Commands (procedural entrypoints)
  ↓
Agents (specialized execution roles)
  ↓
Hooks (runtime safeguards and automation)
  ↓
Memory + Session State + Ledger (continuity and audit)
```

### 4.1 Control Model

The architecture is best understood as a human-controlled operating model:

- **Human**: chooses objectives, approves decisions, directs workflow transitions
- **CLAUDE.md**: defines the constitution and workflow gates
- **Skills**: provide standardized procedures for task types
- **Agents**: act as specialists within bounded domains
- **Hooks**: enforce runtime checks and lifecycle automation
- **Memory/State**: preserve continuity, audit trails, and recoverability

---

## 5. Core Components

## 5.1 `CLAUDE.md` — Global Constitution

`CLAUDE.md` is the semantic entrypoint of the system.

### Responsibilities
- defines critical rules that must apply on every turn
- defines workflow-gated commands such as `/plan`, `/spec`, `/tdd`, `/context`, `/diagnose`, `/vertical-slice`, `/ui-spec`
- injects durable project memory
- references project-wide standards and operational documentation

### Architectural Role
`CLAUDE.md` acts as the constitution of the `.claude` system. It prevents autopilot behavior and forces work into explicit stages.

### Key Effects
- reduces uncontrolled task execution
- establishes approval requirements
- creates a shared semantic baseline for all sessions

---

## 5.2 `.claude/settings.json` — Runtime Dispatcher

`settings.json` is the runtime entrypoint that connects Claude Code events to executable hooks and permission policies.

### Responsibilities
- configures allowed and denied tool patterns
- registers lifecycle hooks for session, prompt, tool, compaction, stop, and subagent events
- configures the status line runtime command

### Architectural Role
`settings.json` is the event dispatch layer of the architecture. If `CLAUDE.md` is the law, `settings.json` is the event wiring that makes the law operational.

---

## 5.3 `.claude/docs` — Specification Layer

The `docs` subtree under `.claude` is the specification and contract layer.

### Main Concerns Covered
- directory structure
- hooks reference
- skills reference
- rules reference
- coordination rules
- handoff schema
- context management
- coding standards
- setup requirements

### Architectural Role
This folder defines the operational contracts of the system. It is not secondary documentation; it is part of the architecture itself.

---

## 5.4 `.claude/agents` — Role Layer

The `agents` folder defines specialist roles such as:
- product-manager
- producer
- technical-director
- qa-lead
- qa-tester
- devops-engineer
- ui-programmer
- ux-designer
- other domain specialists

### Agent Model
Each agent typically declares:
- name and purpose
- tools
- model preference
- maximum turns
- memory mode
- associated skills
- document ownership
- read scope
- delegation map
- escalation behavior

### Architectural Role
Agents are not autonomous owners of the project. They are bounded specialist execution roles within a human-orchestrated system.

---

## 5.5 `.claude/skills` — Procedural Capability Layer

Skills provide reusable workflows and command-driven procedures.

### Examples of Skill Categories
- onboarding and setup
- planning and review
- API and database design
- hotfix and release preparation
- retrospective and milestone review
- orchestration and team-based execution
- GitNexus-based code intelligence

### Architectural Role
Skills provide standardized procedural entrypoints. They reduce ambiguity in how work should be executed and let the human trigger structured workflows instead of relying on ad hoc prompting.

---

## 5.6 `.claude/hooks` — Runtime Hook Layer

Hooks are the event-driven execution and safeguard layer.

### Responsibilities
- load session context on startup
- detect project gaps or missing documentation
- inject prompt context
- persist memory during interaction
- validate commands before commit/push
- warn before risky refactors
- log writes and commits
- preserve state before compaction
- summarize state on session stop

### Architectural Role
Hooks transform the system from a static set of instructions into a reactive runtime environment.

---

## 5.7 `.claude/memory` — Persistent Memory Layer

The memory system is a tiered knowledge architecture.

### Memory Tiers
- **Tier 1**: `MEMORY.md` index, always loaded baseline
- **Tier 2**: load-on-demand topic files
- **Tier 2.5**: specialist namespace, limited to the active agent
- **Tier 3**: archives for search-only historical recall
- **Tier 4**: semantic long-term memory via Supermemory MCP

### Architectural Role
Memory provides durable continuity. It prevents the system from depending on fragile chat history and supports bounded context retrieval.

---

## 5.8 `production/session-state` and `production/traces` — State and Audit Layer

This layer holds persistent runtime state outside conversation history.

### Key Files
- `production/session-state/active.md`
- `.claude/memory/circuit-state.json`
- `production/traces/decision_ledger.jsonl`

### Architectural Role
This layer provides:
- resumable checkpoints
- failure-state tracking
- auditable decision history

---

## 6. Dependency Model

## 6.1 Semantic Dependency Chain

```text
Human
  → CLAUDE.md
    → docs/*
    → memory/MEMORY.md
    → workflow gates
  → skills/*
    → agents/*
    → docs/*
    → TODO/.tasks/production artifacts
  → settings.json
    → hooks/*
  → hooks/*
    → session state / logs / validations / memory persistence
  → memory/*
    → context routing / specialist recall / consensus decisions
  → production/session-state/*
  → production/traces/*
  → .tasks/handoffs/*
```

## 6.2 Architectural Dependency Hubs

There are five major dependency hubs in the current architecture:

1. `CLAUDE.md` — semantic root
2. `.claude/settings.json` — runtime dispatcher
3. `.claude/docs/context-management.md` — memory governor
4. `.claude/docs/coordination-rules.md` — governance engine
5. `production/session-state/active.md` — live checkpoint nexus

---

## 7. Interaction Model

## 7.1 End-to-End Workflow

```text
Session starts
  ↓
SessionStart hooks recover state and detect project stage
  ↓
User submits prompt
  ↓
Prompt-context and memory-persistence hooks run
  ↓
CLAUDE.md applies workflow gate
  ↓
Skill/command is selected
  ↓
Relevant memory/documents are loaded
  ↓
Appropriate agent is activated
  ↓
Tool usage is guarded by hooks
  ↓
If cross-domain: handoff contract created and verified
  ↓
Session state and ledger updated
  ↓
Compaction / stop hooks preserve continuity
```

## 7.2 Human Role in the Interaction Model

This flow must be read through the human-in-the-loop design:
- the human decides when to move across stages
- the human invokes or approves workflow paths
- the human remains the authority behind strategic choices and risky actions
- the system structures and safeguards the flow rather than fully owning it

---

## 8. Major Operational Scenarios

## 8.1 Single-Agent Scenario

Used for:
- focused review
- bounded edits
- domain-specific tasks

### Characteristics
- one primary active agent
- limited memory load
- normal hook interception around tool use
- updates written to session state

## 8.2 Multi-Agent Orchestration Scenario

Used for:
- complex feature work
- cross-domain execution
- release coordination

### Characteristics
- human invokes orchestration deliberately
- `producer` acts as the primary coordination agent
- `product-manager` clarifies scope and acceptance intent
- `technical-director` defines architecture and technical constraints
- specialist agents execute their bounded slices
- handoff contracts govern cross-domain transfers

## 8.3 Hotfix Scenario

Used for:
- urgent bug fixes
- fast-path work with continued traceability

### Characteristics
- bypasses normal sprint pacing
- still constrained by approvals, risk, hook validations, and audit logging

## 8.4 Diagnose / Failure Escalation Scenario

Used for:
- repeated failures
- unknown bugs
- blocked execution paths

### Characteristics
- layered recovery before escalation
- global circuit breaker state via `.claude/memory/circuit-state.json`
- fallback agent routing at the orchestration layer
- failure and decision logging

## 8.5 Compaction / Crash Recovery Scenario

Used for:
- long-running sessions
- context overflow
- resumed work after interruptions

### Characteristics
- active state stored in files, not conversation
- pre-compaction preservation of work-in-progress context
- restart recovery driven by `active.md`

---

## 9. Governance Model

## 9.1 Governance Sources

Governance is currently distributed across:
- `CLAUDE.md`
- `settings.json`
- `coordination-rules.md`
- `context-management.md`
- skill documentation
- runtime hooks

## 9.2 Governance Concerns Covered

- approval boundaries
- stage gating
- permission modes
- domain boundaries
- escalation rules
- recovery strategy
- concurrency constraints
- circuit breaker logic
- decision tracing
- handoff verification

## 9.3 Architectural Observation

Governance is one of the strongest aspects of the project. However, it is also one of the most distributed aspects of the project, which makes anomaly detection and maintenance more difficult.

---

## 10. Memory and Context Architecture

## 10.1 Memory Philosophy

The project explicitly treats files as durable memory and conversation as ephemeral.

### Implications
- recovery depends on file-based checkpoints
- memory loading must be selective
- context should be actively managed and compacted
- specialist context should remain isolated

## 10.2 Context Routing

The system uses relevance-based loading rather than broad preloading.

### Routing Strategy
- always start from `MEMORY.md`
- load at most a small bounded set of Tier 2 files
- load only one specialist namespace for the active agent
- load consensus decisions for cross-agent work
- use archives or semantic memory only when appropriate

## 10.3 Architectural Value

This is one of the most mature parts of the system because it directly addresses context pollution, stale knowledge, and session continuity.

---

## 11. Handoff and Cross-Agent Coordination

## 11.1 Handoff Contracts

When work crosses domains or risk boundaries, the system generates structured handoff contracts.

### Contract Fields
- sender and receiver
- task identifier
- artifact reference
- artifact status
- acceptance criteria
- context snapshot reference
- risk tier
- timestamp and session

## 11.2 Architectural Purpose

Handoffs reduce:
- context loss
- assumption mismatch
- implicit transfer of incomplete artifacts

## 11.3 Cross-Agent Control Pattern

The system does not assume that agents can safely pass work informally. It formalizes inter-agent transfer with verifiable criteria.

---

## 12. Observability and Audit

## 12.1 Observability Components

The architecture includes lightweight runtime observability through:
- status line updates
- hook-triggered write and commit logs
- session logs
- decision ledger entries
- hook reports and visual reports

## 12.2 Decision Ledger

Important decisions are written to `production/traces/decision_ledger.jsonl`.

### Intended Use
- audit trail
- debugging historical behavior
- failure analysis
- tracing overrides and major handoffs

## 12.3 Architectural Value

This layer strengthens trust, explainability, and recoverability in a human-governed AI workflow.

---

## 13. Strengths of the Current Architecture

### 13.1 Strong System Thinking
The project is not a collection of prompts. It is a layered architecture with semantics, runtime, memory, rules, and auditability.

### 13.2 Human-Compatible Control Model
Because the human remains in control, the system is more realistic for enterprise and consulting environments.

### 13.3 Mature Context Management
The context and memory discipline is a major strength and appears intentionally designed rather than incidental.

### 13.4 Formalized Coordination
Handoff contracts, delegation rules, and fallback mechanisms indicate a strong operational mindset.

### 13.5 Recoverability and Traceability
The combination of state files, ledgers, and lifecycle hooks makes the architecture resilient to interruption and easier to inspect.

---

## 14. Architectural Anomalies / Optimization Targets

This section summarizes the major anomalies or structural tensions discovered during the review.

## 14.1 Distributed Orchestration Logic

Although the human is the true orchestrator, supporting orchestration logic is distributed across multiple files and subsystems:
- `CLAUDE.md`
- `settings.json`
- `coordination-rules.md`
- `context-management.md`
- skill docs
- hook scripts

### Impact
- harder to trace why a behavior occurred
- harder to debug stage transitions
- harder to detect overlap or contradiction

## 14.2 Missing Central Control Map

The architecture has workflow gates, skills, roles, and hooks, but does not yet expose a single canonical control map describing:
- task type → stage
- stage → skill
- skill → agent
- exit criteria per stage
- fallback route per failure class

### Impact
- behavior remains understandable only after deep manual inspection
- anomaly detection is more expensive than it should be

## 14.3 Retrieval Logic Is Disciplined but Still Distributed

Memory retrieval strategy is strong, but the logic is partly embedded in:
- `MEMORY.md`
- `context-management.md`
- specialist namespace rules
- active agent behavior

### Impact
- retrieval behavior is policy-driven but not yet transparent as one unified model

## 14.4 Hook Surface Complexity

The hook layer is powerful, but its breadth increases runtime complexity.

### Impact
- side effects become harder to reason about
- overlapping hook responsibilities may emerge over time
- anomaly investigation may require tracing multiple lifecycle events

## 14.5 Rule Precedence Is Not Yet Fully Explicit

There are multiple sources of constraint:
- critical rules
- coordination rules
- permission allow/deny lists
- hook behaviors
- skill precedence

### Impact
- conflict resolution between rule layers may be inferred rather than explicitly documented

---

## 15. Recommended Next-Step Artifacts

To improve anomaly detection and long-term maintainability, the next architectural artifacts should be:

### 15.1 Control-Plane Map
A single document showing:
- human decision points
- AI proposal points
- mandatory gates
- state update points
- fallback and escalation paths

### 15.2 Rule Precedence Matrix
A matrix documenting which rule source wins when constraints overlap.

### 15.3 Stage Transition State Machine
A formal state-machine view of:
- planning
- specification
- implementation
- review
- diagnose
- hotfix
- recovery

### 15.4 Hook Responsibility Matrix
A map of each hook to:
- event
- side effect
- data touched
- downstream dependencies

### 15.5 Memory Retrieval Map
A simple diagram showing how Tier 1, Tier 2, Tier 2.5, Tier 3, and semantic memory are selected.

---

## 16. Final Assessment

The `.claude` subsystem is the architectural core of this repository.

It already demonstrates the structure of a serious operating layer for AI-assisted software development:
- semantic constitution
- runtime dispatch
- specialist role system
- procedural skill layer
- event-driven safeguards
- durable memory architecture
- audit and recovery infrastructure

Its defining characteristic is not autonomy. Its defining characteristic is **human-governed, stateful, auditable software development augmentation**.

That makes the project both technically interesting and operationally realistic.

The main optimization opportunity is no longer “add more capability.” It is to make the already-existing control logic more legible, centralized, and diagnosable.

---

## 17. Short Definition

**Software Development Department (`.claude`) is a human-orchestrated operating layer for AI-assisted software development, combining workflow gates, role-based execution, runtime hooks, durable memory, and auditable state management.**
