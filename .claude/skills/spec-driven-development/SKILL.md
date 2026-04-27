---
name: spec-driven-development
type: workflow
description: "Enforces the creation of a clear, actionable specification before any implementation code is written. Prevents hallucinations and architectural drift."
argument-hint: "[feature-description-or-issue]"
user-invocable: true
allowed-tools: Read, Glob, Grep, WebSearch
context: fork
effort: 3
agent: lead-programmer
when_to_use: "When starting a new feature, doing major architectural refactoring, receiving a complex prompt, or when the user invokes /spec."
---

# Spec-Driven Development

## Purpose

This skill forces the agent to pause, analyze, and agree upon a specification before jumping into implementation code. Drafting a spec first prevents hallucinations, scopes down overly ambitious changes, and protects the codebase's existing architecture.

---

## Workflow (Strict Process)

**ABSOLUTE DIRECTIVE**: You are an Agent. You MUST NOT start writing implementation files (.ts, .js, .py, etc.) until you have completed this workflow and the user has explicitly approved the spec or the documented Fast Gate/Override Gate from `using-sdd`.

### 1. Context Analysis
- Review relevant files using `Read`, `Glob`, or `Grep` to understand the system boundaries.
- Identify how the proposed feature fits into the current architecture.
- Detect existing commands, test locations, project structure, and local conventions from repository files instead of inventing them.

### 2. Assumption Surfacing
- Before drafting spec content, explicitly list assumptions that affect scope, architecture, data, security, or verification.
- If an assumption materially changes the implementation path, ask a concise clarification question and stop until the answer is available.
- Do not silently fill in ambiguous requirements. Convert uncertainty into either an assumption, an open question, or a non-goal.

Example:

```text
Assumptions:
1. This change targets the existing web UI, not a new API.
2. Authentication behavior remains unchanged.
3. Verification can use npm test plus a manual browser check.
Correct these before I proceed if any are wrong.
```

### 3. Draft the Spec
- Provide the user with a concise summary (1-3 paragraphs) containing:
  - **Core Objective**: what is being built, why, and who it serves
  - **Assumptions & Open Questions**: what is inferred, what still needs an answer, and what is out of scope
  - **Proposed Data/UI Flow**: how data, state, and user interaction move through the system
  - **Success Criteria**: specific, testable conditions that define "done"
  - **Boundaries**: Always do, Ask first, and Never do constraints for this change
  - **Files to Modify & Files to Create**: expected file scope and ownership boundaries
  - **Verification Method**: exact test, build, lint, visual check, or manual check that will prove the change
  - **Pre-Code Gate**: why this requires Spec Gate, Fast Gate, or Override Gate
- Reframe vague instructions as measurable success criteria before asking for approval.

Example:

```text
Request: "Make the dashboard faster."
Success criteria:
- Dashboard initial load is measured before and after the change.
- The identified slow path improves by a named threshold or documented reason.
- Existing dashboard tests still pass.
```

#### Spec Artifact Template

For large, architecture-impacting, or multi-session work, propose a persistent
spec file before implementation. Do not write it without user approval.

```markdown
# Spec: [Feature or Change Name]

## Objective
[What is being built, why, and who it serves.]

## Assumptions
- [Assumption that affects scope or architecture.]

## Success Criteria
- [Specific, testable condition.]

## Project Context
- Commands: [full commands with flags]
- Structure: [relevant directories and ownership boundaries]
- Style: [existing conventions or examples to follow]

## Proposed Flow
[Data, UI, API, state, or operational flow.]

## Boundaries
- Always: [...]
- Ask first: [...]
- Never: [...]

## Files
- Modify: [...]
- Create: [...]

## Verification
- [Exact command or manual check.]

## Open Questions
- [Question that must be answered before implementation, or "None."]
```

### 4. Task Breakdown
- Break the feature into granular, atomic checklist items ordered by dependency:

```markdown
- [ ] Task 1: [Description]
  - Acceptance: [What must be true when done]
  - Verify: [Exact test, build, lint, or manual check]
  - Files: [Expected files or bounded file area]
```

- Each task should be small enough for one focused implementation pass.
- If a task requires touching more than about five files, split it unless the files are tightly coupled and the coupling is explained.
- Mark parallelizable tasks explicitly only when they touch disjoint file areas and have clear integration boundaries.

### 5. Approval Gate
- End your response by asking the user for explicit approval: *"Do you approve of this specification and task sequence? Please permit me to begin Task 1 (TDD)."*
- If the user does not approve, stop. Do not begin TDD, do not edit tests, and do not edit production code.
- If the user approves, the next response before any edit must state:

```text
Pre-code gate: Spec satisfied by user approval; next edit: <file>; verification: <command/check>.
```

---

## Anti-Rationalizations

Be aware of lazy logic that an Agent typically uses to skip this step. If a thought on the left occurs, YOU MUST apply the rebuttal on the right:

| Excuse (Agent's Lazy Rationalization) | Rebuttal & Correct Action |
| :--- | :--- |
| "This is a tiny change, no need for a massive spec." | **REJECTED.** Use Fast Gate instead: state the exact file, exact change, risk check, and verification command/check before editing. |
| "The user is rushing and wants code immediately." | **REJECTED.** Hasty code causes bugs and frustrates users more. Write a "Fast-Spec" with just 3 bullet points outlining the action and side-effects. |
| "I understand the request perfectly. I'll just write all 3 files at once in this single turn." | **REJECTED.** High complexity requires phased execution. Write the spec, break it down, and execute sequentially focusing on one atomic task at a time. |
| "I'll write the RED test now; that isn't production code." | **REJECTED unless approved.** RED tests are part of execution. Do not write them until the Spec Gate or Plan Gate is approved. |
| "The user said 'continue', so approval is implied." | **REJECTED.** Approval must clearly authorize implementation of the shown spec/task sequence. Ask if unclear. |
| "The spec changed while I was coding, but the new path is obvious." | **REJECTED.** Route through `spec-evolution` before changing the approved scope or architecture. |

---

## Verification Gates

Do not conclude your first interaction turn unless you have fulfilled the following:
- [ ] Displayed the Spec structure and Task Checklist to the user.
- [ ] Surfaced assumptions, open questions, and non-goals.
- [ ] Reframed vague requirements as specific, testable success criteria.
- [ ] Included the Pre-Code Gate and Verification Method.
- [ ] Included task-level Acceptance, Verify, and Files fields when tasks are listed.
- [ ] Explicitly checked for side-effect risks on the existing infrastructure.
- [ ] Requested strict explicit approval from the user to proceed.
- [ ] Made no test or production edits before approval.

---

## Edge Cases

- **[Massive Feature Request]**: If the feature requires touching >10 files, immediately raise a RED FLAG. Stop and request a scope reduction from the user before finalizing the spec.
- **[Architectural Violation]**: If the user's request violates underlying framework patterns (e.g., securely calling a database from a Next.js Client Component), stop and suggest a corrected architectural spec.
- **[Spec Drift]**: If implementation evidence, platform reality, or user feedback contradicts an approved spec, pause and route through `spec-evolution` before continuing.
- **[Persistent Spec Needed]**: If work is likely to span multiple sessions or reviewers, propose saving the spec in the repository. Ask before writing and do not commit without explicit user approval.

---

## Related Skills

- `source-driven-development` - Used when the spec depends on official framework, library, API, or platform behavior.
- `planning-and-task-breakdown` - Used for ultra-large epics that need more project management than a compact technical spec.
- `test-driven-development` - Invoked immediately after the Spec is approved to implement Task 1 using the Red-Green-Refactor cycle.
- `spec-evolution` - Used when an approved spec conflicts with implementation reality, tests, review findings, user feedback, or platform constraints.
