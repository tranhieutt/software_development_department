---
name: reverse-document
description: "Generates missing design or architecture documentation by working backwards from existing code or prototypes. Use when documentation is missing for existing code or when the user mentions documenting existing implementation or reverse engineering docs."
argument-hint: "<type> <path> (e.g., 'design src/api/auth' or 'architecture src/core')"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
effort: 3
when_to_use: "Use when documentation is missing for existing code, a feature was built without a design doc, or the user needs to formalize an existing implementation into design or architecture documentation."
---

# Reverse Documentation

This skill analyzes existing implementation (code, prototypes, systems) and generates
appropriate design or architecture documentation. Use this when:

- You built a feature without writing a design doc first
- You inherited a codebase without documentation
- You prototyped a mechanic and need to formalize it
- You need to document "why" behind existing code

---

## Workflow

### 1. Parse Arguments

**Format**: `/reverse-document <type> <path>`

**Type options**:
- `design` → Generate a product design document (PRD section)
- `architecture` → Generate an Architecture Decision Record (ADR)
- `concept` → Generate a concept document from prototype

**Path**: Directory or file to analyze
- `src/api/auth/` → All combat-related code
- `src/core/event-system.cpp` → Specific file
- `prototypes/stealth-mech/` → Prototype directory

**Examples**:
```bash
/reverse-document design src/api/payment
/reverse-document architecture src/core/entity-component
/reverse-document concept prototypes/vehicle-combat
```

### 2. Analyze Implementation

**Read and understand the code/prototype**:

**For design docs (PRD):**
- Identify mechanics, rules, formulas
- Extract business logic values (damage, cooldowns, ranges)
- Find state machines, ability systems, progression
- Detect edge cases handled in code
- Map dependencies (what systems interact?)

**For architecture docs (ADR):**
- Identify patterns (ECS, singleton, observer, etc.)
- Understand technical decisions (threading, serialization, etc.)
- Map dependencies and coupling
- Assess performance characteristics
- Find constraints and trade-offs

**For concept docs (prototype analysis):**
- Identify core mechanic
- Extract emergent business patterns
- Note what worked vs what didn't
- Find technical feasibility insights
- Document user fantasy / feel

### 3. Ask Clarifying Questions (Collaborative Protocol)

**DO NOT** just describe the code. **ASK** about intent:

**Design questions**:
- "I see a stamina system that depletes during combat. Was this for:
  - Pacing (prevent spam)?
  - Resource management (strategic depth)?
  - Or something else?"
- "The stagger mechanic seems central. Is this a core pillar, or supporting feature?"
- "Damage scales exponentially with level. Intentional power fantasy, or needs rebalancing?"

**Architecture questions**:
- "You're using a service locator pattern. Was this chosen for:
  - Testability (mock dependencies)?
  - Decoupling (reduce hard references)?
  - Or inherited from existing code?"
- "I see manual memory management instead of smart pointers. Performance requirement, or legacy?"

**Concept questions**:
- "The prototype emphasizes stealth over combat. Is that the intended pillar?"
- "Users seem to exploit the grappling hook for speed. Feature or bug?"

### 4. Present Findings

Before drafting, show what you discovered:

```text
I've analyzed src/api/auth/. Here's what I found:

MECHANICS IMPLEMENTED:
- 3-hit combo system with timing windows
- Guard-break mechanic (heavy attack vs blocking enemy)
- Stamina system (depletes on attack/dodge, regens when idle)
- Stagger system (builds up, triggers vulnerable state)

FORMULAS DISCOVERED:
- Damage = Base * (1 + StrengthScaling * Level)
- Stagger buildup = AttackStaggerValue / (Enemy.Poise * 0.5)
- Stamina cost = BaseStaminaCost * (1 - EfficiencyBonus)

UNCLEAR INTENT AREAS:
1. Stamina system — pacing or resource management?
2. Stagger — core pillar or supporting feature?
3. Damage scaling — power fantasy or needs tuning?

Before I draft the design doc, could you clarify these points?
```

Wait for user to clarify intent before drafting.

### 5. Draft Document Using Template

Based on type, use appropriate template:

| Type | Template | Output Path |
|------|----------|-------------|
| `design` | `templates/design-doc-from-implementation.md` | `design/docs/[system-name].md` |
| `architecture` | `templates/architecture-doc-from-code.md` | `docs/architecture/[decision-name].md` |
| `concept` | `templates/concept-doc-from-prototype.md` | `prototypes/[name]/CONCEPT.md` or `design/concepts/[name].md` |

**Draft structure**:
- Capture **what exists** (mechanics, patterns, implementation)
- Document **why it exists** (intent clarified with user)
- Identify **what's missing** (edge cases not handled, gaps in design)
- Flag **follow-up work** (balance tuning, missing features)

### 6. Show Draft and Request Approval

**Collaborative protocol**:

```text
I've drafted the combat system design doc based on your code and clarifications.

[Show key sections: Overview, Mechanics, Formulas, Design Intent]

ADDITIONS I MADE:
- Documented stamina as "pacing mechanic" per your clarification
- Added edge cases not in code (what if stamina hits 0 mid-combo?)
- Flagged balance concern: exponential damage scaling at high levels

SECTIONS MARKED AS INCOMPLETE:
- "Enemy AI interaction with stagger" (not fully implemented yet)
- "Weapon variety and scaling" (only sword implemented so far)

May I write this to design/docs/combat-system.md?
```

Wait for approval. User may request changes before writing.

### 7. Write Document with Metadata

When approved, write the file with special markers:

```markdown
---
status: reverse-documented
date: 2026-02-13
verified-by: [User name]
---

# Combat System Design

> **Note**: This document was reverse-engineered from the existing implementation.
> It captures current behavior and clarified design intent. Some sections may be
> incomplete where implementation is partial or intent was unclear.

[Rest of document...]
```

### 8. Flag Follow-Up Work

After writing, suggest next steps:

```text
✅ Written to design/docs/combat-system.md

FOLLOW-UP RECOMMENDED:
1. Run /balance-check on combat formulas (exponential scaling concern)
2. Create ADR for stamina system architecture decision
3. Implement missing edge cases:
   - Stamina depletion mid-combo behavior
   - Stagger state during dodge
4. Extend design doc when weapon variety is implemented

Would you like me to tackle any of these now?
```

---

## Template Selection Logic

| If analyzing... | Use template... | Because... |
|----------------|-----------------|------------|
| `src/api/*` | design-doc-from-implementation.md | Business mechanics → PRD |
| `src/core/*`, `src/ai/*` | architecture-doc-from-code.md | Core systems → ADR |
| `prototypes/*` | concept-doc-from-prototype.md | Experiments → concept doc |
| `src/networking/*` | architecture-doc-from-code.md | Technical systems → ADR |
| `src/ui/*` | design-doc-from-implementation.md | UI/UX → design spec |

---

## Example Session: Reverse-Document Combat Code

```text
User: /reverse-document design src/api/auth

Agent: I'll analyze your combat implementation to create a design doc.
       [Reads code, discovers mechanics, formulas]

Agent: I've analyzed src/api/auth/. Here's what I found:
       [Shows mechanics, formulas, unclear areas]

       Before drafting, could you clarify:
       1. Stamina system intent?
       2. Is stagger a core pillar?
       3. Damage scaling — intentional or needs tuning?

User: 1. Stamina is for pacing, prevent button mashing
      2. Stagger is core — I want deliberate combat
      3. Yeah, exponential is too much, should be linear

Agent: Perfect, that clarifies the vision. Let me draft the design doc.
       [Shows draft with clarified intent]

       May I write this to design/docs/combat-system.md?

User: Yes, write it.

Agent: ✅ Written to design/docs/combat-system.md
       ✅ Marked as [REVERSE-DOCUMENTED]
       ✅ Flagged damage scaling for rebalancing

       Next steps:
       - Update damage formula to linear scaling
       - Run /balance-check to validate progression curve
       - Document stagger as core pillar in product-pillars.md
```

---

## Collaborative Protocol

This skill follows the collaborative design principle:

1. **Analyze First**: Read code, understand implementation
2. **Question Intent**: Ask about "why", not just "what"
3. **Present Findings**: Show discoveries, highlight unclear areas
4. **User Clarifies**: Separate intent from accidents
5. **Draft Document**: Create doc based on reality + intent
6. **Show Draft**: Display key sections, explain additions
7. **Get Approval**: "May I write to [filepath]?"
8. **Flag Follow-Up**: Suggest related work, don't auto-execute

**Never assume intent. Always ask before documenting "why".**

## Protocol

- **Question**: Analyzes code, then asks about design intent — never assumes "why" from "what"
- **Options**: Type drives template — `design` → PRD, `architecture` → ADR, `concept` → concept doc
- **Decision**: User clarifies intent for all unclear areas before the draft is written
- **Draft**: Draft shown with additions and uncertainty flags before saving
- **Approval**: "May I write to `design/docs/[system].md`?" (or architecture/concept path)

## Output

Deliver exactly:

- **Document type** — `design`, `architecture`, or `concept` (based on argument)
- **Generated document** saved to `design/specs/[name].md` or `docs/technical/[name].md`
- **Uncertainty flags** — sections where intent was inferred rather than confirmed (user must verify)
- **Follow-up suggestions** — related docs that are also missing
