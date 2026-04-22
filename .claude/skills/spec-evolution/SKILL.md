---
name: spec-evolution
type: workflow
description: "Resolves mismatches between an approved spec and implementation reality by proposing controlled spec changes before code or plan changes continue."
argument-hint: "[spec-path-and-mismatch]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
context: fork
effort: 4
agent: technical-director
when_to_use: "Use when code, tests, architecture, user feedback, or review findings contradict an approved spec; when a spec needs to evolve after implementation evidence; or when spec/code drift is suspected."
---

# Spec Evolution

## Purpose

`spec-evolution` keeps specs alive as the source of truth. When implementation
reality teaches that an approved spec is incomplete, wrong, obsolete, or
conflicting, this workflow resolves the mismatch deliberately before more code is
written.

This is not a shortcut around `spec-driven-development`. It is the controlled
path for changing a spec after evidence shows the current spec no longer matches
the project.

## Core Rule

```text
Do not silently change code to fit reality or silently change the spec to fit code.
Resolve the mismatch explicitly, then continue.
```

If the mismatch affects behavior, architecture, data, security, release policy,
or user-visible workflow, user approval is required before implementation
continues.

## When To Use

Use this workflow when:

- Tests or implementation reveal the approved spec is impossible or unsafe.
- Code review finds behavior that is useful but not specified.
- Existing code contradicts a new spec.
- A user asks to change requirements after a spec or plan was approved.
- A dependency, API, data model, or platform constraint invalidates the spec.
- A bug fix discovers the desired behavior differs from documented behavior.

Do not use it for:

- Initial spec creation. Use `spec-driven-development`.
- Pure typo fixes in a spec with no behavior meaning.
- Implementation bugs where the spec is clear and correct. Use
  `test-driven-development` or `diagnose`.

## Workflow

### 1. Freeze Execution

Stop implementation, planning, review approval, or release progression until the
mismatch is classified.

State:

```text
Spec evolution gate: execution paused because <spec> and <evidence> disagree.
```

### 2. Gather Evidence

Read the minimum required context:

- The approved spec or source-of-truth section
- The code, test, review finding, user request, or runtime evidence that
  contradicts it
- Any ADR, PRD, API contract, or README section that constrains the decision

Do not infer drift from memory. Cite the concrete file, section, test, command,
or review finding.

### 3. Classify the Mismatch

Use one primary classification:

| Type | Meaning | Default action |
| --- | --- | --- |
| Spec Gap | Required behavior was never specified | Amend spec before planning/code |
| Spec Error | Spec requirement is wrong, unsafe, or impossible | Propose correction and rationale |
| Code Drift | Code differs from correct spec | Keep spec, fix code with TDD |
| Reality Change | External constraint changed after approval | Update spec and plan |
| Scope Change | User wants a new behavior | Treat as new spec delta |
| Architecture Drift | Implementation violates architecture or ADR | Escalate to ADR or technical-director |

If more than one type applies, list secondary types but choose the one that
controls the next action.

### 4. Propose Evolution Options

Present options, not a hidden decision:

- **Option A: Keep spec, change code** when the spec is still correct.
- **Option B: Amend spec, then re-plan/re-test** when the spec is incomplete or
  wrong.
- **Option C: Split into follow-up spec** when the new behavior is valuable but
  outside current scope.
- **Option D: Escalate to ADR** when the change affects durable architecture,
  data model, security, deployment, or cross-team contracts.

For each option, include impact on:

- Files/spec sections
- Tests and verification
- Existing implementation or plan
- Risk and rollback

### 5. Request Approval For Material Evolution

Ask for explicit approval before changing any spec or continuing implementation
when the evolution changes behavior, architecture, data, security, release
policy, or acceptance criteria.

Approval must name the selected option. If approval is absent, stop.

### 6. Handoff After Decision

After approval:

- If the spec changes, update the spec through the appropriate edit workflow and
  route to `review-spec`.
- If code must change to match the current spec, route to
  `test-driven-development` with a regression or compliance test.
- If the plan must change, route to `planning-and-task-breakdown`.
- If architecture changes, route to `architecture-decision-records` before code.
- Before claiming resolution, use `verification-before-completion`.

## Output Format

```markdown
## Spec Evolution: [Topic]

**Spec Source:** [path/section]
**Evidence Source:** [code/test/review/user request/runtime evidence]
**Mismatch Type:** Spec Gap | Spec Error | Code Drift | Reality Change | Scope Change | Architecture Drift

### Mismatch
[One precise paragraph explaining the disagreement.]

### Options
1. **Keep spec, change code:** [impact, verification, risk]
2. **Amend spec, re-plan/re-test:** [impact, verification, risk]
3. **Split follow-up:** [impact, verification, risk]
4. **Escalate to ADR:** [when applicable, or "Not needed"]

### Recommendation
[Selected option and why.]

### Approval Needed
[Exact approval sentence needed before edits/implementation continue.]
```

## Anti-Rationalizations

| Thought | Required correction |
| --- | --- |
| "I'll just update the code; the spec was probably stale." | Prove and classify the mismatch first. |
| "I'll update the spec after the fix." | Spec changes before implementation continuation, not after. |
| "This is just a small requirement change." | Small behavior changes still alter acceptance criteria. |
| "Review can approve this as an improvement." | Unspecified improvements are scope changes. |
| "The implementation is better than the spec." | Maybe. Present options and get approval. |

## Integration

- `review-spec` routes here when it finds spec/code drift.
- `code-review` should route here when code implements behavior outside the
  approved spec.
- `test-driven-development` should route here when a RED test exposes an
  incorrect or incomplete spec.
- `planning-and-task-breakdown` should route here when a plan cannot be derived
  from the current spec without inventing requirements.
- `architecture-decision-records` is required when evolution changes durable
  architecture or cross-system contracts.
