# Workflow Graph Schema

> **Owner:** `@producer`
> **Used by:** `/map-workflow` skill
> **Purpose:** Define and communicate multi-agent execution plans in a
> structured, verifiable format before any implementation begins.

---

## Schema Definition

A workflow graph is a YAML-like block with these fields:

```yaml
workflow:
  id: "<short-id>"           # e.g. "auth-feature", "sprint-03-wave-1"
  pattern: "<pattern-name>"  # Sequential | Parallel | Hierarchical | Iterative
  task: "<human description of what this workflow delivers>"
  nodes:
    - id: "<node-id>"
      agent: "<agent-name>"
      task: "<what this agent does>"
      depends_on: []           # list of node ids that must complete first
      on_fail: "<node-id|escalate|stop>"   # what to do if this node fails
      on_pass: "<node-id|done>"            # what to do if this node passes
  entry: "<first node-id>"
  exit: "<final node-id or 'done'>"
```

---

## Pattern A — Sequential Pipeline

Every node runs one after the other. Failure at any node stops the pipeline.

```yaml
workflow:
  id: "sequential-example"
  pattern: Sequential
  task: "Build and ship a backend feature end-to-end"
  nodes:
    - id: design
      agent: technical-director
      task: "Approve API contract"
      depends_on: []
      on_pass: backend
      on_fail: stop
    - id: backend
      agent: backend-developer
      task: "Implement API endpoint"
      depends_on: [design]
      on_pass: qa
      on_fail: stop
    - id: qa
      agent: qa-engineer
      task: "Run integration tests"
      depends_on: [backend]
      on_pass: done
      on_fail: stop
  entry: design
  exit: done
```

---

## Pattern B — Parallel Fan-out

An orchestrator dispatches multiple agents simultaneously, then merges results.

```yaml
workflow:
  id: "parallel-example"
  pattern: Parallel
  task: "Implement frontend and backend slices simultaneously"
  nodes:
    - id: orchestrate
      agent: producer
      task: "Dispatch backend and frontend work"
      depends_on: []
      on_pass: [backend, frontend]
      on_fail: stop
    - id: backend
      agent: backend-developer
      task: "Implement API"
      depends_on: [orchestrate]
      on_pass: merge
      on_fail: escalate
    - id: frontend
      agent: frontend-developer
      task: "Implement UI components"
      depends_on: [orchestrate]
      on_pass: merge
      on_fail: escalate
    - id: merge
      agent: lead-programmer
      task: "Integration review — both slices complete"
      depends_on: [backend, frontend]
      on_pass: qa
      on_fail: stop
    - id: qa
      agent: qa-engineer
      task: "End-to-end test"
      depends_on: [merge]
      on_pass: done
      on_fail: stop
  entry: orchestrate
  exit: done
```

---

## Pattern C — Hierarchical Delegation

A supervisor agent breaks the task and delegates to specialists.

```yaml
workflow:
  id: "hierarchical-example"
  pattern: Hierarchical
  task: "Full feature delivery with lead oversight"
  nodes:
    - id: plan
      agent: lead-programmer
      task: "Break feature into sub-tasks and assign"
      depends_on: []
      on_pass: [backend, frontend, qa-setup]
      on_fail: stop
    - id: backend
      agent: backend-developer
      task: "Implement assigned backend sub-task"
      depends_on: [plan]
      on_pass: review
      on_fail: escalate
    - id: frontend
      agent: frontend-developer
      task: "Implement assigned frontend sub-task"
      depends_on: [plan]
      on_pass: review
      on_fail: escalate
    - id: qa-setup
      agent: qa-engineer
      task: "Prepare test plan in parallel"
      depends_on: [plan]
      on_pass: review
      on_fail: stop
    - id: review
      agent: lead-programmer
      task: "Code review and integration sign-off"
      depends_on: [backend, frontend, qa-setup]
      on_pass: done
      on_fail: stop
  entry: plan
  exit: done
```

---

## Pattern D — Iterative Loop

A test agent drives a retry loop until quality gates pass or max retries exceeded.

```yaml
workflow:
  id: "iterative-example"
  pattern: Iterative
  task: "Implement feature with TDD loop until tests pass"
  max_iterations: 3
  nodes:
    - id: implement
      agent: backend-developer
      task: "Write or fix implementation"
      depends_on: []
      on_pass: test
      on_fail: stop
    - id: test
      agent: qa-engineer
      task: "Run test suite"
      depends_on: [implement]
      on_pass: done
      on_fail: implement      # loops back — subject to max_iterations
  entry: implement
  exit: done
```

**Loop safety:** `max_iterations` caps how many times the loop can cycle.
If exceeded, the workflow stops and surfaces a blocker to the user.

---

## Composing a Custom Workflow

Use `/map-workflow` to generate a graph interactively:

```
/map-workflow --pattern Sequential --agents "technical-director,backend-developer,qa-engineer" --task "Auth API"
/map-workflow --pattern Parallel   --agents "backend-developer,frontend-developer" --task "Login UI + API"
/map-workflow --pattern Iterative  --agents "backend-developer,qa-engineer" --task "Payment module" --max-iter 3
```

The skill outputs the filled YAML schema above, ready to share with the team
or paste into a `.tasks/` file.
