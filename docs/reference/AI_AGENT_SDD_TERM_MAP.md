# AI Agent Terms to SDD Mapping

Date: 2026-04-24
Source prompt: compare the terms in `AI Agent.md` with the actual SDD project

## Summary

SDD aligns strongly with the operational side of modern agent systems: agents, state, memory, tools, orchestration, planning, evaluation, handoffs, and architecture.

Current assessment:

| Match level | Count |
| --- | ---: |
| Direct | 14 |
| Partial | 5 |
| Weak | 1 |

## Mapping Matrix

| AI Agent term | SDD equivalent | Match | Primary SDD artifacts | Notes |
| --- | --- | --- | --- | --- |
| Agent | Specialized SDD agent roles with bounded ownership | Direct | `.claude/agents/*.md`, `.claude/docs/agent-roster.md`, `docs/technical/ARCHITECTURE.md` | SDD is explicitly a multi-agent department, not a single assistant. |
| Environment | Claude runtime plus Codex adapter, permissions, hooks, and repo context | Direct | `CLAUDE.md`, `.claude/settings.json`, `.claude/hooks/*`, `AGENTS.md`, `docs/codex-compatibility.md` | Environment includes runtime policy, tool permissions, and adapter boundaries. |
| Perception | Structured repo reading, source inspection, diagnostics, and memory recall | Partial | `.claude/skills/using-sdd/SKILL.md`, `.claude/skills/diagnose/SKILL.md`, `.claude/docs/context-management.md` | SDD has the function, but not a named perception subsystem. |
| Action | Skill execution, hook execution, task execution, and stage transitions | Direct | `docs/technical/SDD_LIFECYCLE_MAP.md`, `docs/technical/CONTROL_PLANE_MAP.md`, `.claude/skills/*/SKILL.md` | Actions are governed through DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP. |
| State | Task state, session state, circuit state, and runtime state | Direct | `production/session-state/active.md`, `.tasks/NNN-*.md`, `.claude/memory/circuit-state.json`, `docs/technical/SOURCE_OF_TRUTH_REGISTRY.md` | State is formalized as first-class repo artifacts. |
| LLMs | Model-backed agents with role-specific model choices | Direct | `.claude/docs/agent-roster.md`, `.claude/agents/ai-programmer.md`, `.claude/docs/llm-coding-behavior.md` | SDD distinguishes agent role and model selection. |
| LRMs | Reasoning-heavy workflows and high-judgment roles | Partial | `technical-director`, `diagnose`, `review-spec`, `verification-before-completion` | SDD has reasoning-intensive layers, but no explicit LRM class. |
| Tools | Read, Grep, Bash, Task, TodoWrite and Codex-mapped tools | Direct | `AGENTS.md`, `.claude/skills/codex-sdd/SKILL.md`, `.claude/settings.json` | Tooling is explicit and governed by runtime policy. |
| Memory | Tiered durable memory with local and cloud recall | Direct | `.claude/memory/MEMORY.md`, `.claude/memory/*`, `.claude/docs/context-management.md` | One of the strongest implemented concepts in SDD. |
| Knowledge Base | Distributed documentation and memory knowledge layer | Direct | `docs/technical/*`, `docs/internal/adr/*`, `docs/reference/*`, `.claude/memory/*` | SDD uses a file-based knowledge base rather than one monolithic DB. |
| Orchestration | Multi-agent coordination with wave planning and dependency rules | Direct | `.claude/skills/orchestrate/SKILL.md`, `.claude/docs/agent-coordination-map.md` | Explicit orchestration exists as a dedicated workflow. |
| Planning | Plan gate, atomic tasks, verification contracts, execution mode selection | Direct | `.claude/skills/planning-and-task-breakdown/SKILL.md`, `.claude/skills/using-sdd/SKILL.md` | Planning is mandatory for multi-step work. |
| Evaluation | Verification, review, audit, and quality gates | Direct | `.claude/skills/verification-before-completion/SKILL.md`, `.claude/skills/code-review/SKILL.md`, `scripts/validate-skills.ps1`, `scripts/harness-audit.js` | Evaluation is enforced through fresh evidence, not confidence. |
| Architecture | System blueprint, control plane, ADRs, and source-of-truth ownership | Direct | `docs/technical/ARCHITECTURE.md`, `docs/technical/CONTROL_PLANE_MAP.md`, `docs/internal/adr/*` | Architecture is durable and explicitly governed. |
| CoT | Externalized reasoning through specs, plans, diagnosis reports, and review artifacts | Partial | `.claude/skills/spec-driven-development/SKILL.md`, `.claude/skills/planning-and-task-breakdown/SKILL.md`, `.claude/skills/diagnose/SKILL.md` | SDD operationalizes reasoning outputs, but does not expose CoT as a named primitive. |
| ReAct | Observe -> reason -> act -> verify loop | Partial | `.claude/skills/diagnose/SKILL.md`, `.claude/skills/test-driven-development/SKILL.md`, `.claude/skills/verification-before-completion/SKILL.md` | The behavior is present, but the framework name is not core to SDD terminology. |
| Multi-Agent System | Hierarchical MAS with defined delegation and escalation paths | Direct | `docs/technical/ARCHITECTURE.md`, `.claude/docs/agent-coordination-map.md`, `.claude/docs/agent-roster.md` | This is a direct match. |
| Swarm | Limited parallel workstreams, not self-organized swarm behavior | Weak | `.claude/skills/fork-join/SKILL.md`, `.claude/skills/orchestrate/SKILL.md` | SDD is coordinated and hierarchical, not swarm-native. |
| Handoffs | Lightweight 3-field cross-domain handoff plus optional durable artifact | Direct | `.claude/skills/handoff/SKILL.md`, `.tasks/handoffs/*`, `production/traces/decision_ledger.jsonl` | Strong direct implementation with acceptance criteria. |
| Agent Debate | Structured challenge and verification between roles | Partial | `investigator -> verifier -> solver`, code review, Rule 3 escalation | SDD supports adversarial validation, but not a generic debate engine. |

## Practical Interpretation

SDD is best understood as an agent operating system for software delivery, not as a research-oriented agent cognition framework.

It is strongest in:

- governance and source-of-truth control
- multi-agent coordination and handoffs
- memory and state management
- planning and verification discipline
- auditable execution

It is weaker or less explicit in:

- named cognitive primitives such as `Perception`, `CoT`, `ReAct`, and `LRM`
- emergent coordination models such as `Swarm`
- formal debate systems as a reusable standalone mechanism

## Key Evidence

- `docs/technical/ARCHITECTURE.md` states that SDD is a hierarchical multi-agent system and calls out durable memory, circuit breaker, decision ledger, and A2A handoff.
- `.claude/docs/context-management.md` defines the memory model, session state, subagent delegation, and Supermemory integration.
- `.claude/skills/orchestrate/SKILL.md` defines wave-based orchestration, dependency rules, and downstream handoff summaries.
- `.claude/skills/planning-and-task-breakdown/SKILL.md` defines planning as a formal pre-code gate.
- `.claude/skills/handoff/SKILL.md` defines the 3-field handoff schema.
- `docs/technical/SOURCE_OF_TRUTH_REGISTRY.md` formalizes ownership for agent definitions, task state, runtime state, memory, and adapter policy.

## Current Gaps Worth Tracking

1. If SDD wants stronger alignment with AI-agent terminology, it could add a short glossary doc formalizing how `Perception`, `Reasoning`, `Action`, and `Evaluation` map to existing SDD workflows.
2. If debate is meant to become a first-class capability, it would need a reusable workflow beyond the current `investigator -> verifier -> solver` path.
3. If swarm-style execution is ever desired, it would require a new coordination policy because the current system is intentionally hierarchical.
