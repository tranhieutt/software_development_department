---
name: spec-driven-development
type: workflow
description: "Enforces the creation of a clear, actionable specification before any implementation code is written. Prevents hallucinations and architectural drift."
argument-hint: "[feature-description-or-issue]"
user-invocable: true
allowed-tools: Read, Glob, Grep, WebSearch
effort: 3
agent: lead-programmer
when_to_use: "When starting a new feature, doing major architectural refactoring, receiving a complex prompt, or when the user invokes /spec."
---

# Spec-Driven Development

## Purpose

This skill forces the agent to pause, analyze, and agree upon a specification before jumping into implementation code. Drafting a spec first prevents hallucinations, scopes down overly ambitious changes, and protects the codebase's existing architecture.

---

## Workflow (Strict Process)

**ABSOLUTE DIRECTIVE**: You are an Agent. You MUST NOT start writing implementation files (.ts, .js, .py, etc.) until you have completed this workflow.

### 1. Context Analysis
- Review relevant files using `Read`, `Glob`, or `Grep` to understand the system boundaries.
- Identify how the proposed feature fits into the current architecture.

### 2. Draft the Spec
- Provide the user with a concise summary (1-3 paragraphs) containing:
  - **Core Objective**
  - **Proposed Data/UI Flow**
  - **Files to Modify & Files to Create**

### 3. Task Breakdown
- Break the feature into granular, atomic checklist items:
  - `[ ] Task 1: ...`
  - `[ ] Task 2: ...`

### 4. Approval Gate
- End your response by asking the user for explicit approval: *"Do you approve of this specification and task sequence? Please permit me to begin Task 1 (TDD)."*

---

## Anti-Rationalizations

Be aware of lazy logic that an Agent typically uses to skip this step. If a thought on the left occurs, YOU MUST apply the rebuttal on the right:

| Excuse (Agent's Lazy Rationalization) | Rebuttal & Correct Action |
| :--- | :--- |
| "This is a tiny change, no need for a massive spec." | **REJECTED.** Even a 1-line change needs a quick confirmation. Reply with: *"I will modify X to do Y. Shall I proceed?"* |
| "The user is rushing and wants code immediately." | **REJECTED.** Hasty code causes bugs and frustrates users more. Write a "Fast-Spec" with just 3 bullet points outlining the action and side-effects. |
| "I understand the request perfectly. I'll just write all 3 files at once in this single turn." | **REJECTED.** High complexity requires phased execution. Write the spec, break it down, and execute sequentially focusing on one atomic task at a time. |

---

## Verification Gates

Do not conclude your first interaction turn unless you have fulfilled the following:
- [ ] Displayed the Spec structure and Task Checklist to the user.
- [ ] Explicitly checked for side-effect risks on the existing infrastructure.
- [ ] Requested strict explicit approval from the user to proceed.

---

## Edge Cases

- **[Massive Feature Request]**: If the feature requires touching >10 files, immediately raise a RED FLAG. Stop and request a scope reduction from the user before finalizing the spec.
- **[Architectural Violation]**: If the user's request violates underlying framework patterns (e.g., securely calling a database from a Next.js Client Component), stop and suggest a corrected architectural spec.

---

## Related Skills

- `test-driven-development` — Invoked immediately after the Spec is approved to implement Task 1 using the Red-Green-Refactor cycle.
- `planning-and-task-breakdown` — Used for ultra-large epics that need more project management rather than technical specs.
