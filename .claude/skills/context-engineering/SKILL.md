---
name: context-engineering
type: workflow
description: Strictly enforce context engineering principles to avoid context stuffing, optimize memory architecture, and manage the Research-Plan-Reset-Implement cycle.
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
context: fork
agent: technical-director
effort: 4
argument-hint: "[context source or workflow scope]"
when_to_use: "When prompts, logs, specs, or multi-step work exceed a clean working set and the agent needs to compress, externalize, or reset context before continuing"
---

# 1. Overview
Context engineering bridges the gap between static training data and dynamic reality. **Context Stuffing** (jamming volume without intent) degrades reasoning, increases noise, and leads to hallucinations. **Context Engineering** treats AI attention as a scarce resource and allocates it deliberately through structure, bounded contexts, and intelligent memory retrieval (RAG / MCP Supermemory). Without this skill, the AI suffers from "Context Hoarding Disorder," leading to goal drift, high latency, and poor execution quality.

# 2. When to Use
Activate this skill immediately upon detecting the following signs:
- **Sign 1:** User pastes a massive block of uncurated documents entirely into the context window (e.g., full PRDs, full codebases, thousands of lines of logs).
- **Sign 2:** The AI's outputs start to become vague, hedged, or inconsistent despite having "all the context", or when the context window is clearly overflowing.
- **Sign 3:** The user wants to start a multi-step complex workflow spanning many files and iterations.
- **Implicit Command:** User types `/context` or `/memory`.

# 3. Strict Process
*ULTIMATUM*: You are an Agent. You DO NOT have the right to ignore, truncate, or alter the order of these steps, even if you think "the model has a 1 million token context limit anyway."

1. **[Step 1 - Intent & Boundary Falsification]**: Identify exactly what decision the provided context supports. Apply the falsification test: "If I exclude [context element X], what specific failure will occur in [decision Y]?" If there is no concrete failure, the context must be rejected or removed from the active window.
2. **[Step 2 - Persist vs. Retrieve Classification]**: Separate the information. Core constraints and glossary definitions remain in active context. Episodic, project-specific, or historical data must be offloaded and retrieved only when queried. Use `mcp_supermemory_recall` for historical lookups instead of keeping them in the prompt.
3. **[Step 3 - The R-P-R-I Cycle Execution]**: 
   - **R**esearch: Gather necessary information.
   - **P**lan: Synthesize findings into a high-density `PLAN.md` or `SPEC.md`. 
   - **R**eset: Save crucial lessons to memory using `mcp_supermemory_memory` and explicitly ask the user to **clear the context window** (start a new chat) or summarize everything to drop the past context rot.
   - **I**mplement: Execute purely based on the dense plan.
4. **[Step 4 - Storage & Consolidation]**: Upon finishing a milestone, write the generalized knowledge or operational principles into `mcp_supermemory_memory`.

# 4. Anti-Rationalizations
These are lazy thoughts that Agents (like you) commonly fall prey to. If an idea in your head matches the Left Column, you MUST immediately obey the Right Column:

| Agent's Lazy Rationalization | Refutation & Mandatory Action |
| :--- | :--- |
| "I have a massive context window; I can just read all 50 files the user provided without complaining." | Volume != Quality. Context is an attention economy. You MUST explicitly tell the user that "Context Stuffing" dilutes attention. Limit the working context to only the files strictly needed for the immediate decision. |
| "I'll just try again and rewrite the code if it hallucinates." | Retries mask bad information architecture. Do not normalize retries. Stop and fix the context structure, break down the problem, or refine the retrieved memory BEFORE writing another line of code. |
| "I'll keep all the research logs and failed attempts in the chat history so I remember what I tried." | "Context Rot" kills reasoning. Once a plan is synthesized, the previous dead ends become pure noise. You MUST instruct the user to flush the context or start fresh with a clean `SPEC.md`. |

# 5. Verification Gates
You are NOT allowed to end your turn and respond "Context established" or proceed to implementation until the following checks pass:
- [ ] You have successfully filtered out unnecessary broad context and kept only the decision-critical context.
- [ ] You have explicitly called `mcp_supermemory_memory` to commit important established facts, or `mcp_supermemory_recall` to fetch past facts instead of asking the user to paste them.
- [ ] You have synthesized the current sprawling context into a dense artifact (e.g. `PLAN.md` or `SPEC.md`) and proposed a Context Reset.

# 6. Red Flags
Immediately STOP and request User intervention if:
- The user demands that you process more than 35k tokens of unstructured, mixed-domain text in a single prompt without allowing you to summarize and discard the noise.
- You detect that the current context window is bloated with >3 failed attempts of the same task. You must halt and enforce a **Reset**.
- Memory retrieval tools (like `mcp_supermemory`) fail repeatedly, meaning you are operating blind on historical context.
