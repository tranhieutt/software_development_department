---
name: using-sdd
type: workflow
description: "Routes every software-development request through the right SDD workflow before action. Use at session start, before clarifying questions, before edits, and whenever deciding which SDD skill should govern a task."
argument-hint: "[user-request-or-current-task]"
user-invocable: true
allowed-tools: Read, Glob, Grep
context: main
effort: 2
agent: technical-director
when_to_use: "Use at the start of every SDD session and before any non-trivial response, clarification, code edit, review, bug fix, plan, commit, or completion claim."
---

# Using SDD

`using-sdd` is the router and discipline layer for the Software Development
Department. It does not replace specialist skills. It decides which SDD workflow
must govern the current request before the agent acts.

For phase orientation, use `docs/technical/SDD_LIFECYCLE_MAP.md`
(`DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP`). For detailed runtime
stage rules, use `docs/technical/CONTROL_PLANE_MAP.md`.

## Core Rule

Before answering, asking clarifying questions, editing files, spawning agents, or
claiming completion, check whether an SDD skill applies.

If a skill applies, use it. Do not rely on memory of the skill. Read the current
skill and follow its gates.

## Skill Routing

| User intent or situation | Required SDD workflow |
| --- | --- |
| First session, unclear project state | `start` |
| Vague product idea, ideation, product direction | `brainstorm` |
| User wants structured requirements or says "ask me", "don't assume", "interview" | `deep-interview` |
| New feature, behavior change, architectural change | `spec-driven-development` |
| Existing spec needs readiness review before planning or implementation | `review-spec` |
| Approved spec conflicts with code, tests, review findings, user feedback, or platform reality | `spec-evolution` |
| Framework, library, external API, platform behavior, deprecation, migration, or "latest/official/best practice" correctness matters | `source-driven-development` |
| Epic, multi-step work, large prompt, many files | `planning-and-task-breakdown` |
| Implementation of one approved task | `test-driven-development` |
| Execution of approved multi-task sequential plan with review gates | `subagent-driven-development` |
| Bug, failing test, build failure, CI failure, performance regression, or unexpected behavior | `systematic-debugging` |
| Complex, intermittent, unfamiliar, or repeatedly failed bug investigation | `diagnose` |
| Simple obvious bug with clear cause | `test-driven-development` with a regression test |
| Coordinated multi-agent work across domains | `orchestrate` |
| Independent parallel workstreams | `fork-join` |
| UI/frontend architecture or component design | `frontend-design` or `ui-spec` |
| API contract or endpoint design | `api-design` |
| Architecture decision with durable consequences | `architecture-decision-records` |
| Code quality, PR review, merge readiness | `code-review` or `code-review-checklist` |
| Behavior-preserving cleanup, simplification, readability refactor, or complexity reduction after tests pass | `code-simplification` |
| Review comments, PR feedback, CHANGES_REQUIRED verdict, or reviewer questions need response | `receiving-code-review` |
| Phase transition or readiness review | `gate-check` |
| Release or launch preparation | `release-checklist` or `launch-checklist` |
| Completion claim, success claim, task done, fixed, passing, ready, clean, merge-ready | `verification-before-completion` |
| Commit requested | `commit` |
| Save reusable lesson or preference | `learner` or `annotate` |
| Context is too large or stale | `context-engineering` or `save-state` |

When multiple skills apply, use process skills before implementation skills:

1. Requirements and design: `brainstorm`, `deep-interview`,
   `spec-driven-development`, `review-spec`, `source-driven-development`,
   `spec-evolution`
2. Planning and coordination: `planning-and-task-breakdown`,
   `subagent-driven-development`, `orchestrate`, `fork-join`
3. Investigation and execution: `systematic-debugging`,
   `test-driven-development`, domain implementation skills
4. Review and release: `verification-before-completion`, `code-review`,
   `code-simplification`, `receiving-code-review`, `gate-check`,
   `release-checklist`

## Mandatory Gates

### Before Implementation

Implementation code means any production behavior change in files such as
`src/`, `app/`, `lib/`, `services/`, `components/`, migrations, infrastructure,
runtime config, hooks, build scripts, or generated assets that ship with the
product. Tests are only allowed before production code when they are part of a
TDD RED phase.

Do not write implementation code until one of these gate paths is satisfied:

| Gate path | Allowed when | Required before code |
| --- | --- | --- |
| Fast Gate | Small, explicit, low-risk edit; one obvious file; no behavior ambiguity | State the exact file, exact change, risk check, and verification command/check |
| Spec Gate | New feature, behavior change, UI flow, API change, data change, or unclear side effects | Use `spec-driven-development`; present spec and task sequence; get explicit user approval |
| Spec Review Gate | Existing spec is the source of truth for a plan, review, or implementation | Use `review-spec`; proceed only if verdict is `APPROVED` or the plan carries non-blocking notes |
| Spec Evolution Gate | Approved spec and implementation reality disagree | Use `spec-evolution`; get explicit approval for the selected evolution path before code or plan changes continue |
| Plan Gate | Multi-step work, multiple files, cross-domain changes, or an epic | Use `planning-and-task-breakdown`; produce atomic tasks; get explicit approval for Task 1 |
| Interview Gate | Vague goal, hidden assumptions, or user asks not to assume | Use `deep-interview` until requirements are clear enough for a spec |
| Override Gate | User explicitly says to skip planning | Restate the skipped gate, name the risk, and get acknowledgment before code |

If none of these paths is satisfied, stop. Ask for the missing approval or
clarification instead of editing files.

For any new feature or behavior change, default to:

`spec-driven-development` -> `planning-and-task-breakdown` -> `test-driven-development`

When the spec or implementation depends on framework, library, platform, or
external API behavior that may be version-sensitive or documented externally,
insert `source-driven-development` after the spec/review step and before
planning or code:

`spec-driven-development` -> `source-driven-development` -> `planning-and-task-breakdown`

For work from an existing spec, default to:

`review-spec` -> `planning-and-task-breakdown` -> `test-driven-development`

If implementation evidence contradicts the approved spec, pause and route to:

`spec-evolution` -> `review-spec` -> `planning-and-task-breakdown` or `test-driven-development`

For behavior-preserving cleanup after working implementation or review feedback,
use:

`test-driven-development` -> `code-simplification` -> `verification-before-completion`

For bug fixes and failing tests, default to:

`systematic-debugging` -> `test-driven-development` -> `verification-before-completion`

If `systematic-debugging` cannot establish root cause quickly, escalates to
`diagnose`.

### Pre-Code Checklist

Before the first production edit, verify and state the gate in one line:

```text
Pre-code gate: <Fast|Spec|Plan|Interview|Override> satisfied by <evidence>; next edit: <file>; verification: <command/check>.
```

Examples:

- `Pre-code gate: Fast satisfied by explicit user request; next edit:
  landing-page/index.html; verification: visual/manual HTML check.`
- `Pre-code gate: Spec satisfied by approved Task 1; next edit:
  src/auth/session.ts; verification: npm test -- session.`

If the next edit is a test in the RED phase, say that explicitly:

```text
Pre-code gate: Plan satisfied by approved Task 1; next edit is RED test <file>; verification: <failing test command>.
```

Do not use "I think", "probably", or "should" in the gate line. Either the gate
is satisfied or it is not.

### Before Multi-Agent Execution

Use `subagent-driven-development` when an approved implementation plan has
multiple mostly sequential tasks and each task should pass implementation,
spec-compliance review, and code-quality review before the next task begins.

Use `orchestrate` when work spans multiple domains and has dependencies.

Use `fork-join` only when work units are independent, touch disjoint files, and
can be merged safely.

Do not spawn agents just because a task is large. Spawn agents when the workflow
requires distinct ownership, parallelism, or review separation.

Execution mode selection for approved plans:

| Plan shape | Workflow |
| --- | --- |
| One small approved task | `test-driven-development` |
| Multiple sequential tasks needing review gates | `subagent-driven-development` |
| Multiple specialist domains with wave dependencies | `orchestrate` |
| Multiple independent disjoint workstreams | `fork-join` |

### Before Completion Claims

Use `verification-before-completion` before saying work is done, fixed, passing,
safe, ready, merged, or clean.

Do not make the claim unless you have fresh evidence from the relevant command
or file check in the current completion context.

If verification cannot be run, say exactly what was not verified and why.

### After Review Feedback

Use `receiving-code-review` after any review returns comments, questions, or a
`CHANGES_REQUIRED` verdict.

Do not fix review feedback until each finding is classified as fix, reject,
defer, needs clarification, or route to `spec-evolution`.

Do not mark a review thread resolved until the specific finding has fresh
verification evidence.

## Anti-Rationalizations

| Thought | Required correction |
| --- | --- |
| "This is simple; no skill needed." | Simple tasks still need routing. Check the table. |
| "I need to inspect files first." | Use the skill that governs how to inspect. |
| "The user did not type a slash command." | Natural language still triggers skills. |
| "I remember the workflow." | Read the current skill. Skills change. |
| "I can ask clarification first." | Check routing first; some skills define how to ask. |
| "I can write code and test after." | Use `test-driven-development`. |
| "The plan is obvious." | For multi-step work, write the plan and get approval. |
| "The agent/reviewer said it passed." | Use `verification-before-completion` and verify independently before claiming completion. |

## Minimal Response Pattern

When a routed skill applies, say one short line:

```text
I'm using `<skill-name>` to <purpose>.
```

Then follow that skill. Do not add ceremony.

For tiny explicit tasks where no separate workflow is needed, state the narrow
action and proceed:

```text
I'll update `<file>` to <specific change>, then verify with <command/check>.
```

## Stop Conditions

Stop and ask the user before proceeding when:

- The request can be interpreted in two materially different ways.
- The change affects architecture, data, security, billing, deployment, or
  release policy without an approved spec.
- Required verification needs a tool, credential, service, or network access the
  current environment cannot provide.
- The user explicitly overrides an SDD gate and the risk is not yet acknowledged.

## Output Discipline

Keep status updates short and factual. Prefer evidence over confidence.

At the end of work, report:

- What changed
- What was verified
- What was not verified, if anything
- The next useful step only when it follows directly from the task
