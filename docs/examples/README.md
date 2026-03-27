# Example Sessions

This directory contains realistic, end-to-end session transcripts showing how the Software Development Department agent architecture works in practice. Each example demonstrates the **collaborative workflow** where agents ask questions, present options, and wait for user approval rather than autonomously generating content.

## Available Examples

### session-design-api-feature.md
**Agent:** `lead-programmer`
**Scenario:** Design the authentication API for a new web application.

- Developer provides a PRD
- Agent asks clarifying questions (JWT vs sessions, OAuth strategy)
- Agent presents full API contract with endpoints, schemas, error codes
- Agent awaits approval before writing to `docs/api/auth-service.md`
- Agent suggests next steps (db-review, security review, implementation)

## What These Examples Show

- How agents **ask questions** before generating content
- How agents **present options with tradeoffs** for the developer to choose
- How agents **request approval** before writing files
- How agents **suggest next steps** to keep the developer moving forward
- The **collaborative, not autonomous** nature of the department

## Contributing Examples

Good example sessions show:
1. A **realistic starting point** (what you ask the agent)
2. The agent **asking clarifying questions** before acting
3. The agent **presenting options** with tradeoffs, not just one answer
4. The developer **making decisions** that guide the output
5. The agent **drafting and seeking approval** before writing files
6. **Suggested next steps** that connect to other agents or skills
