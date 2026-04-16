---
name: investigator-memory
description: "Specialist memory for investigator: known failure signatures, root cause patterns, investigation heuristics, and past incident summaries."
type: project
namespace: specialists/investigator
---

# Investigator — Specialist Memory

> Loaded ONLY when `@investigator` is active on the current task.
> Updated by `@technical-director` during consensus merges.

## Known Failure Signatures

_Fill during sessions — e.g. "ECONNRESET on startup → missing env var, not network issue"_

## Root Cause Patterns

_Fill during sessions — e.g. "Race condition: always check event loop blocking first"_

## Investigation Heuristics

_Fill during sessions — e.g. "Read git blame before reading the file — context is everything"_

## Past Incidents (Summary)

_Fill during sessions — e.g. "2026-04-10: auth 500 caused by missing RS256 public key in prod"_
