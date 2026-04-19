# Rule & Skill Precedence — 5-Layer Hierarchy

> **Applies from:** SDD v1.32.1 (2026-04-17) — rewritten to English and expanded to a full 5-layer precedence matrix in v1.38.0 (2026-04-19).
> **Problem it solves:** SDD enforces constraints at five separate layers (critical rules, coordination rules, permission lists, hook behaviors, skills). When two layers appear to give contradictory guidance, the agent must know which one wins. This document is the single source of truth for that resolution order.

---

## 1. The 5-Layer Precedence Ladder

The ladder is read top-down. A higher layer always overrides a lower one. A lower layer may add refinements but may not contradict anything above it.

| Tier | Layer | Where it lives | What it governs | Can override? |
|---|---|---|---|---|
| **L1** | **Critical Rules** | `CLAUDE.md` §🚨 CRITICAL RULES | Session-wide behavioral gates that must hold on every turn (no autopilot, confirm before proactive writes, no commits without permission, annotation protocol, risk-tier assessment). | **None.** L1 is absolute. |
| **L2** | **Coordination Rules** | `.claude/docs/coordination-rules.md` (Rules 1–16) | Multi-agent orchestration: delegation, concurrency, recovery layering, circuit breaker, decision ledger, A2A handoff contracts. | Only another L2 rule (via explicit supersession note) or an ADR. |
| **L3** | **Permission Lists** | `.claude/settings.json` (`permissions`, `hooks`, `allow`, `deny`) | What tools/commands are runnable in what mode; which hooks fire at which events. | L1 and L2 only. A skill cannot grant itself tool access the settings forbid. |
| **L4** | **Hook Behaviors** | `.claude/hooks/*.sh`, registered in `settings.json` | Runtime side effects: context injection, state bootstrap, ledger append, circuit-state transitions, memory persistence. Hook `exit 2` is enforcement, not advice. | L1, L2, L3. Hooks implement coordination rules; they never invent them. |
| **L5** | **Skill Precedence** | `.claude/skills/*/SKILL.md` + this document §3 | Domain expertise content invoked within a workflow gate. Includes command ↔ skill aliasing and scope-overlap resolution between similar skills. | L1, L2, L3, L4. A skill cannot bypass a blocking hook or a critical rule. |

### Resolution protocol when layers disagree

1. Identify the layer of each competing instruction.
2. The higher layer wins. Period.
3. If two instructions at the **same layer** appear to conflict, escalate:
   - L1 conflict → halt and ask the user (L1 conflicts usually indicate a CLAUDE.md bug).
   - L2 conflict → check for a governing ADR in `docs/internal/adr/`; if none, escalate per Rule 3 (shared parent / cto / technical-director).
   - L3 conflict → `settings.json` is ordered; the later rule in the file wins (JSON merge semantics). If intent is ambiguous, ask the user.
   - L4 conflict → hooks at the same event run in registration order; if two hooks touch the same state file, they must use the orchestrator pattern (see §4).
   - L5 conflict → follow the skill-boundary rules in §3.

---

## 2. Command ↔ Skill Aliasing (inside Layer 5)

**Golden rule:** **Commands CONTAIN skills — they do not replace them.**

Workflow commands are **gates** that mark which stage of a task is active. Skills are **domain expertise** that supply the content used within that stage. A command triggers its backing skill; the agent does not fire both separately.

### Vocabulary

| Dimension | **Workflow Commands** | **Skills** |
|---|---|---|
| **Role** | Workflow **gate** — marks a task stage | Domain **expertise** — supplies knowledge |
| **Answers the question** | "Which stage of the task are we in?" | "What knowledge do I need for this step?" |
| **Examples** | `/plan`, `/spec`, `/tdd`, `/diagnose` | `backend-patterns`, `shadcn`, `postgres-patterns` |
| **Scope** | Task-level (the entire task) | Content-level (a single step within a task) |
| **Invocation** | User types it, or the agent triggers it from context | Agent auto-invokes when trigger terms match |
| **Occurrences per task** | 1–2 (one gate per stage) | Many (each step may use a different skill) |

### Flow

```
Task arrives
  ↓
1. Workflow Command (if any) → determines STAGE
     ↓
2. Within the stage, skills are invoked → supply CONTENT
     ↓
3. Skills return guidance → Command advances to the next stage gate
```

### Worked example

**Task:** "Add a POST /users endpoint with input validation."

```
/plan                           ← Command: this is the planning stage
  ↓ agent emits an atomic task list
/spec                           ← Command: next stage is spec
  ↓ invoke skill api-design             ← Skill: API domain knowledge
  ↓ invoke skill backend-patterns       ← Skill: Express/Node domain knowledge
  ↓ emit approved blueprint
/tdd                            ← Command: next stage is TDD
  ↓ invoke skill test-driven-development ← Skill: TDD protocol
  ↓ invoke skill backend-patterns       ← Skill: implementation patterns
  ↓ RED → GREEN
```

**Wrong pattern:**
```
/plan AND /planning-and-task-breakdown invoked simultaneously   ← DUPLICATE
```

**Correct pattern:**
```
/plan → agent knows to trigger skill `planning-and-task-breakdown` (skill is the implementation of the command)
```

### When a command and a skill share a name

Case: `/plan` in `CLAUDE.md` ↔ skill `planning-and-task-breakdown`.

- The **command is an alias** that triggers the backing skill.
- If both are referenced in the same turn, **the command wins** (user intent is clearer); the skill is invoked inside the command flow.

| Command in CLAUDE.md | Backing skill | Relationship |
|---|---|---|
| `/plan` | `planning-and-task-breakdown` | Command ⊃ Skill |
| `/spec` | `spec-driven-development` | Command ⊃ Skill |
| `/tdd` | `test-driven-development` | Command ⊃ Skill |
| `/context`, `/memory` | `context-engineering` | Command ⊃ Skill |
| `/diagnose` | `diagnose` | Command ⊃ Skill |
| `/vertical-slice` | `vertical-slicing` | Command ⊃ Skill |
| `/ui-spec` | `ui-spec` | Command ⊃ Skill |

---

## 3. Skill Boundary Rules — Avoiding Content Overlap

When two skills have overlapping scope, their `description` fields must exclude each other explicitly.

| Skill | Correct scope | Out of scope |
|---|---|---|
| `frontend-patterns` | Generic React/Vue, hooks, TanStack Query | Next.js App Router |
| `senior-frontend` | Next.js 13+ App Router, Server Components | Generic React/Vue |
| `backend-patterns` | Node.js Express/Fastify production patterns | FastAPI (→ `fastapi-pro`) |
| `backend-architect` | System architecture (multi-service) | Single-service patterns |

**Checklist for every new skill:**
- [ ] Does the description include "NOT" or "Use X instead" language that excludes overlapping scope?
- [ ] Does the skill name carry a clear domain prefix (`nextjs-*`, `postgres-*`, etc.)?
- [ ] Has the repo been grepped for an existing skill that covers the same ground?
- [ ] Does the trigger pattern (`paths:`) overlap with another skill?

---

## 4. Cross-Layer Interactions to Remember

These are the situations where the layers genuinely touch each other and the precedence ladder is load-bearing.

### 4.1 Hooks must implement coordination rules, not invent them

Example: Rule 14 (Circuit Breaker) is defined at **L2**. Its mechanism is specified in **ADR-004** and **ADR-005**. The hooks `circuit-guard.sh`, `decision-ledger-writer.sh`, and `circuit-updater.sh` at **L4** are *implementations* of that L2+ADR contract. If the hook ever disagrees with the ADR, the ADR wins and the hook is a bug.

### 4.2 Settings can revoke tool access a skill expects

If `.claude/settings.json` (L3) denies a tool via `permissions.deny`, no skill (L5) that references that tool can run — the skill must fail cleanly rather than attempt to work around the deny list.

### 4.3 Critical rules block hook-driven writes

Example: the "confirm before proactive writes" rule at L1 applies even when a hook at L4 (e.g., `persist-memory.sh`) would otherwise auto-write. The hook must respect the user's explicit scope.

### 4.4 Multiple hooks on the same state file need an orchestrator

When two hooks at L4 both write to the same artifact (e.g., `decision_ledger.jsonl` is appended to by `log-commit.sh` and `decision-ledger-writer.sh`), the two hooks must either:
- Run through a shared helper (single append path, canonical schema), or
- Declare explicit ordering in `settings.json` so the second reads-then-rewrites the first's entry.

The current audit (2026-04-19) has this overlap flagged as P1; the target fix is a shared `ledger-append` helper.

### 4.5 Memory precedence

Memory tiers (T1 `MEMORY.md` → T4 Supermemory) are a separate orthogonal dimension: they govern *what is loaded into context*, not *which instruction wins*. When a memory recall conflicts with the live repo state, the **live repo wins** (per `auto memory` § "Before recommending from memory" in the system prompt).

---

## 5. Audit & Telemetry (future work)

- Hook `log-agent.sh` should log skill invocations to `production/session-logs/skill-usage.jsonl`.
- Run `node scripts/harness-audit.js skills --unused 30d` periodically to flag skills not invoked in the last 30 days.
- Based on telemetry: merge or delete unused skills.
- Extend `/trace-history` to join ledger entries with skill invocations to show *which skill drove which decision*.

---

## 6. History

| Date | Change |
|---|---|
| 2026-04-17 | Created doc; removed `nodejs-backend-patterns` (duplicate of `backend-patterns`); clarified boundary between `frontend-patterns` ↔ `senior-frontend`. |
| 2026-04-19 | Rewrote in English; expanded from command↔skill only to the full 5-layer precedence matrix (critical rules → coordination rules → permission lists → hook behaviors → skill precedence) per audit §14.5. |
