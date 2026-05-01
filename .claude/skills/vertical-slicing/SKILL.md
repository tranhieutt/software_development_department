---
name: vertical-slicing
type: workflow
description: "Guidelines and procedures for planning and implementing end-to-end functional slices for fullstack features."
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
effort: 3
argument-hint: "[feature, epic, or PRD name]"
when_to_use: "Use when planning a fullstack feature that should be delivered as end-to-end user-value slices instead of separate backend and frontend layers."
---

# Skill: /vertical-slicing

Use this skill when planning complex fullstack features to ensure delivery by user-value units rather than technical layers.

Vertical slices should not merely cross layers. They should also protect depth:
keep complexity concentrated behind small interfaces instead of smearing logic
across DB, API, and UI callers.

## The Vertical Slicing Workflow

### 1. Identify the Smallest Value Unit
- Decompose the PRD into slices that represent a functional path.
- Example: Instead of "Authentication System," start with "Login with Email and Password".

Good slice shape:

- Narrow enough to demo or verify independently
- Complete enough to exercise the real seam end-to-end
- Small enough that one RED -> GREEN loop can prove meaningful progress
- Not a horizontal placeholder like "backend groundwork" unless that groundwork
  is a real prerequisite with its own verification

### 2. Define the Contract
- Before implementing, the `lead-programmer` or `backend-developer` must define the API contract.
- Document this in a Design Doc or temporary spec.

Prefer contracts that create deep modules: small interfaces with meaningful
behavior hidden behind them. If a contract mostly forwards data or mirrors
caller complexity, it is probably too shallow.

### 3. Plan the Slice Tasks
Organize each phase to contain:
- **Database/Data Model**: Schema changes required for this slice.
- **Backend Implementation**: Logic and API endpoints.
- **Frontend Integration**: UI components and API consumption.
- **E2E Verification**: Test verifying the whole path.

For each slice, also record:

- **Blocked by**: exact prerequisite slice(s) or `None`
- **Acceptance criteria**: observable end-to-end outcomes
- **Verification**: exact command/check for the slice
- **Interface risk**: where a shallow seam or pass-through wrapper could appear

### 4. Implementation Rules
- Do not confuse "deepest" with "lowest layer". Start where the slice creates
  the strongest behavior seam, then drive outward through the stack.
- Do not move to the next slice until the current one is "Integration Complete".
- If a horizontal change is absolutely necessary (e.g., shared middleware), implement it as a prerequisite phase 0.
- Apply the deletion test to new wrappers and adapters. If deleting the new
  abstraction would mostly simplify the code instead of reintroducing complexity
  across callers, the seam is too shallow.

## Benefits for Agents
- **Context Management**: Focusing on a slice keeps the context window filled with relevant code for that specific path.
- **Early Feedback**: The user can verify functional pieces earlier.
- **Reduced Integration Risk**: Cross-layer issues are caught within the slice implementation.
- **Better Architecture**: Tracer-bullet slices expose where interfaces are deep
  enough to keep leverage and where they are only moving complexity around.
