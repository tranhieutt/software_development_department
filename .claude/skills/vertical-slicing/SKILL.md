---
name: vertical-slicing
description: "Guidelines and procedures for planning and implementing end-to-end functional slices for fullstack features."
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
effort: 3
argument-hint: "[feature, epic, or PRD name]"
---

# Skill: /vertical-slice

Use this skill when planning complex fullstack features to ensure delivery by user-value units rather than technical layers.

## The Vertical Slicing Workflow

### 1. Identify the Smallest Value Unit
- Decompose the PRD into slices that represent a functional path.
- Example: Instead of "Authentication System," start with "Login with Email and Password".

### 2. Define the Contract
- Before implementing, the `lead-programmer` or `backend-developer` must define the API contract.
- Document this in a Design Doc or temporary spec.

### 3. Plan the Slice Tasks
Organize each phase to contain:
- **Database/Data Model**: Schema changes required for this slice.
- **Backend Implementation**: Logic and API endpoints.
- **Frontend Integration**: UI components and API consumption.
- **E2E Verification**: Test verifying the whole path.

### 4. Implementation Rules
- Always prioritize the "Deepest" part of the slice first (Database) and move "Upwards" (UI).
- Do not move to the next slice until the current one is "Integration Complete".
- If a horizontal change is absolutely necessary (e.g., shared middleware), implement it as a prerequisite phase 0.

## Benefits for Agents
- **Context Management**: Focusing on a slice keeps the context window filled with relevant code for that specific path.
- **Early Feedback**: The user can verify functional pieces earlier.
- **Reduced Integration Risk**: Cross-layer issues are caught within the slice implementation.
