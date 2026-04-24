---
name: source-driven-development
type: workflow
description: "Grounds framework, library, API, and platform-specific technical decisions in official documentation before implementation. Use when current docs, version-specific behavior, best practices, deprecations, or external API correctness matter."
argument-hint: "[framework-library-api-or-technical-decision]"
user-invocable: true
allowed-tools: Read, Glob, Grep, WebSearch
context: fork
effort: 3
agent: technical-director
when_to_use: "Use whenever a spec, plan, implementation, or review depends on framework/library/API behavior that may vary by version, deprecation status, official guidance, or platform constraints."
---

# Source-Driven Development

## Purpose

`source-driven-development` verifies technical correctness against authoritative
external sources. It prevents agents from implementing framework, library, API,
or platform patterns from stale memory.

This skill does **not** replace `spec-driven-development`. It verifies the
technical decisions inside a spec, plan, or implementation.

```text
spec-driven-development   = what we are building and why
source-driven-development = whether the technical pattern is correct today
```

## When to Use

Use this workflow when any decision depends on external technical truth:

- Framework or library APIs, especially version-specific behavior.
- Runtime or platform constraints.
- Officially recommended patterns for routing, forms, auth, data fetching,
  state management, migrations, deployment, or testing.
- Deprecation, migration, or compatibility questions.
- User asks for "latest", "official", "best practice", "correct", "current",
  "documented", or "standards-compliant" implementation.
- A spec proposes a technical pattern that may conflict with current docs.

Do not use this workflow for pure product intent, copy changes, simple local
logic, naming cleanup, or code whose correctness does not depend on an external
versioned source.

## Position in SDD

Use this as a verification layer:

```text
New feature:
spec-driven-development -> source-driven-development if technical docs matter
-> planning-and-task-breakdown -> test-driven-development

Existing spec:
review-spec -> source-driven-development if technical docs matter
-> planning-and-task-breakdown

Implementation/review conflict:
source-driven-development finds docs/spec mismatch -> spec-evolution
```

If official sources contradict the approved spec, do not silently change the
spec or implementation. Route through `spec-evolution` and ask the user to
approve the updated path.

## Source Hierarchy

Use the strongest available source for the specific decision:

| Priority | Source |
| --- | --- |
| 1 | Official framework, library, product, or API documentation |
| 2 | Official migration guides, release notes, changelogs, or RFCs |
| 3 | Official standards bodies or platform references such as MDN/web.dev |
| 4 | Runtime compatibility data from maintained compatibility references |

Do not use community posts, Stack Overflow, tutorials, AI summaries, or memory
as primary evidence when official sources are available.

## Workflow

### 1. Identify the Technical Decision

State the exact decision being verified:

```text
Decision to verify: <framework/library/API pattern>
Why it matters: <risk if wrong>
Affected spec/plan/code: <file/section/task if known>
```

If there is no concrete technical decision, return to `spec-driven-development`,
`review-spec`, or `planning-and-task-breakdown`.

### 2. Detect Stack and Version

Read the smallest relevant files to identify versions and runtime context:

- `package.json`, lockfiles, `vite.config.*`, `next.config.*`
- `pyproject.toml`, `requirements.txt`, framework settings
- `go.mod`, `Cargo.toml`, `composer.json`, `Gemfile`
- existing source files that show local conventions

If the version cannot be determined and version affects the answer, ask the user
or mark the decision as `UNVERIFIED`.

### 3. Fetch or Locate Authoritative Sources

Use official docs for the specific feature, not a broad homepage. Prefer deep
links to the page or section that supports the decision.

Capture:

- Source URL or local official doc path.
- Version or date if visible.
- The specific rule, API, constraint, or deprecation relevant to the decision.
- Any ambiguity or missing official guidance.

### 4. Compare Docs to the Spec, Plan, and Code

Classify the result:

- `CONFIRMED`: official sources support the proposed pattern.
- `ADJUST`: official sources support a different pattern; update proposal via
  `spec-evolution` if the spec was already approved.
- `CONFLICT`: official sources and existing codebase conventions disagree;
  present options and ask.
- `UNVERIFIED`: no authoritative source was found or version is unknown.

Do not overrule local architecture automatically. If current docs and existing
code disagree, surface the tradeoff:

```text
Option A: follow current official docs
Option B: match existing project convention
Option C: adapt via a compatibility wrapper
```

### 5. Record the Evidence

For any non-obvious decision, include the evidence in the spec, plan, review, or
final response:

```markdown
## Source Verification

**Decision:** [technical pattern]
**Stack/version:** [detected version or unknown]
**Sources:** [official URLs or local docs]
**Result:** CONFIRMED | ADJUST | CONFLICT | UNVERIFIED
**Impact:** [spec/plan/code consequence]
```

If the discovery reveals a durable caveat, use `annotate` to persist it.

## Anti-Rationalizations

| Thought | Required correction |
| --- | --- |
| "I know this API." | Memory is not evidence. Verify version-sensitive patterns. |
| "The docs will take too long." | A wrong framework pattern costs more than a targeted docs check. |
| "The spec already says what to use." | Specs can be technically stale; verify external truth when it matters. |
| "A popular blog says this is best practice." | Use official sources first. Blogs can inform, not authorize. |
| "The docs conflict with our code; I'll just pick one." | Present the conflict and route through `spec-evolution` if approved scope changes. |
| "I could not verify it, but it is probably fine." | Mark it `UNVERIFIED` and narrow the claim. |

## Stop Conditions

Stop and ask before proceeding when:

- Required docs are inaccessible and the decision is high risk.
- Framework version is unknown and changes the implementation pattern.
- Official guidance contradicts an approved spec.
- The documented pattern requires a dependency, migration, security exception,
  or architecture change not already approved.

## Integration

- `using-sdd` routes version-sensitive technical decisions here.
- `spec-driven-development` defines the product and technical intent; this skill
  validates external technical correctness.
- `review-spec` can call this when spec readiness depends on official docs.
- `planning-and-task-breakdown` should carry source verification notes into task
  acceptance criteria.
- `spec-evolution` handles approved spec changes caused by source findings.
---
