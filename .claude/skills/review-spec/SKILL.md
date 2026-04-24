---
name: review-spec
type: workflow
description: "Reviews a product, technical, API, UI, or implementation spec for completeness, testability, architectural fit, and readiness before planning or implementation."
argument-hint: "[path-to-spec-or-spec-summary]"
user-invocable: true
allowed-tools: Read, Glob, Grep
context: fork
effort: 3
agent: technical-director
when_to_use: "Use before turning a spec into a plan, when validating an externally supplied spec, when code review finds spec ambiguity, or when the user asks whether a spec is ready."
---

# Review Spec

## Purpose

`review-spec` validates whether a specification is strong enough to become the
source of truth for planning, TDD, implementation, and verification. It is a
read-only quality gate. It does not write code and it does not approve execution
by itself.

Use this workflow to prevent weak specs from becoming precise-looking plans with
hidden ambiguity.

## Core Rule

```text
No implementation plan from an unreviewed or materially ambiguous spec.
```

If the spec cannot be tested, reviewed against code, or handed to another agent
without guessing, return `CHANGES REQUIRED`.

## Workflow

### 1. Identify the Source of Truth

- Locate the spec file, issue, PRD section, conversation summary, or design doc.
- Read only the surrounding context needed to understand the feature boundary.
- If no spec exists, stop and route to `spec-driven-development`.
- If the current code appears to contradict the spec, stop and route to
  `spec-evolution` instead of silently reviewing only one side.

### 2. Classify the Spec

Classify the spec as one or more:

- Product behavior
- Technical architecture
- API/data contract
- UI/UX flow
- Test/verification contract
- Release or migration plan

Use the classification to decide which checks matter most. For example, an API
spec must define request/response contracts and error behavior; a UI spec must
define states, accessibility requirements, and responsive behavior.

### 3. Review Against the Readiness Checklist

Evaluate the spec using these criteria:

| Area | Required standard |
| --- | --- |
| Objective | One clear outcome, user/system value, and non-goals |
| Scope | Explicit in-scope and out-of-scope boundaries |
| Behavior | Observable acceptance criteria, including failure states |
| Contracts | API, data, events, files, or UI state contracts are concrete |
| Architecture | Fits existing patterns or names required ADR/escalation |
| Dependencies | Upstream/downstream dependencies and ordering are known |
| Verification | Commands, tests, build, lint, manual, or visual checks are named |
| Rollback | Risk and rollback/disable path are stated for risky changes |
| Handoff | Another agent can plan from it without inventing requirements |

### 4. Detect Ambiguity and Drift

Flag these as blocking unless explicitly out of scope:

- Acceptance criteria are subjective or not observable.
- Terms such as "fast", "robust", "simple", "appropriate", or "secure" are
  used without measurable meaning.
- Data shape, API contract, permissions, errors, loading states, or empty states
  are implied but not defined.
- The spec references files or systems that do not exist.
- The spec conflicts with README, PRD, ADRs, code conventions, or existing user
  flows.
- Implementation has already diverged from the spec.

If drift is found, do not resolve it inside this workflow. Recommend
`spec-evolution` and name the exact mismatch.

### 5. Produce a Verdict

Use this exact verdict scale:

- `APPROVED`: Ready for `planning-and-task-breakdown` or `test-driven-development`.
- `APPROVED WITH NOTES`: Minor non-blocking gaps remain; execution can proceed
  if the notes are carried into the plan.
- `CHANGES REQUIRED`: The spec is not ready; revise before planning or code.
- `ROUTE TO SPEC-EVOLUTION`: The spec/code reality mismatch must be resolved
  before planning, implementation, or review can continue.

## Output Format

```markdown
## Spec Review: [Spec Name]

**Source:** [file/path or request summary]
**Spec Type:** [product / technical / API / UI / verification / release]
**Readiness Score:** [X/9]

### Blocking Issues
- [Issue with exact section/file reference, or "None"]

### Non-Blocking Notes
- [Note, or "None"]

### Missing Acceptance Criteria
- [Specific missing criterion, or "None"]

### Verification Fit
[Whether the spec can be verified, with named commands/checks if present.]

### Drift Check
[No drift found / suspected drift / confirmed drift with exact mismatch.]

### Verdict
`APPROVED` | `APPROVED WITH NOTES` | `CHANGES REQUIRED` | `ROUTE TO SPEC-EVOLUTION`
```

## Anti-Rationalizations

| Thought | Required correction |
| --- | --- |
| "The spec is good enough; planning will clarify it." | Planning should decompose decisions, not invent requirements. |
| "The code will reveal the details." | Details discovered in code must be reflected through `spec-evolution`. |
| "This is only a small spec." | Small specs still need observable acceptance criteria. |
| "The user knows what they mean." | The agent executing the plan needs explicit, reviewable language. |
| "I can approve with obvious assumptions." | List assumptions as blockers or notes. Do not hide them. |

## Integration

- Use after `spec-driven-development` when a spec needs a quality gate before
  planning.
- Use before `planning-and-task-breakdown` when the plan source is an existing
  spec.
- Use during `code-review` when implementation quality depends on ambiguous or
  missing spec requirements.
- Route to `spec-evolution` when implementation reality and the spec disagree.
