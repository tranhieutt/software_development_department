---
name: start
description: "Guides first-time onboarding by asking where the user is in their project journey, then routing them to the right workflow. Use at the beginning of a new session without context, or when the user runs /start for the first time."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion
effort: 3
when_to_use: "Use at the very beginning of a new project or first session to route the user to the appropriate workflow based on their current project stage."
---

# Guided Onboarding

This skill is the entry point for new users. It does NOT assume you have a
project idea, a framework preference, or any prior architecture. It asks first,
then routes you to the right software engineering workflow.

---

## Workflow

### 1. Detect Project State (Silent)

Before asking anything, silently gather context so you can tailor your guidance.
Do NOT show these results unprompted — they inform your recommendations, not
the conversation opener.

Check:
- **Tech Stack configured?** Read `README.md` or `.claude/docs/technical-preferences.md` to see if frameworks are defined.
- **Architecture doc exists?** Check for `design/architecture/` or `docs/architecture.md`.
- **Source code exists?** Glob for source files in `src/` (`*.ts`, `*.js`, `*.py`, `*.go`, `*.java`, `*.rs`, `*.cpp`).
- **Prototypes exist?** Check for subdirectories in `prototypes/`.
- **Production artifacts?** Check for files in `production/` or `.github/workflows/`.

Store these findings internally. You will use them to validate the user's
self-assessment and to tailor follow-up recommendations.

---

### 2. Ask Where the User Is

This is the first thing the user sees. Present these 4 options clearly:

> **Welcome to the Software Development Department!**
>
> Before I suggest anything, I'd like to understand where you're starting from.
> Where are you at with your software project right now?
>
> **A) No idea yet** — I don't have a project concept at all. I want to explore
> and figure out what to build.
>
> **B) Vague idea** — I have a rough problem to solve or a general app idea
> (e.g., "a SaaS for HR" or "an internal dashboard") but nothing concrete.
>
> **C) Clear concept** — I know the core idea — target users, basic features,
> maybe a pitch sentence — but haven't formalized the architecture yet.
>
> **D) Existing work** — I already have design docs, prototypes, code, or
> significant planning done. I want to organize, refactor, or continue the work.

Wait for the user's answer. Do not proceed until they respond.

---

### 3. Route Based on Answer

#### If A: No idea yet

The user needs creative exploration and problem definition before anything else. Tech stack choice comes later.

1. Acknowledge that starting from zero is completely fine
2. Briefly explain what `/brainstorm` does (guided ideation using software engineering frameworks — user needs, core value proposition)
3. Recommend running `/brainstorm open` as the next step
4. Show the recommended path:
   - `/brainstorm` — discover your product concept
   - `/architecture-decision` — decide on the tech stack
   - `/design-system` — decompose the concept into systems
   - `/prototype` — test the core functionality
   - `/sprint-plan` — plan the first sprint

#### If B: Vague idea

The user has a seed but needs help growing it into a product concept.

1. Ask them to share their vague idea — even a few words is enough
2. Validate the idea as a starting point (don't judge or redirect)
3. Recommend running `/brainstorm [their hint]` to develop it
4. Show the recommended path:
   - `/brainstorm [hint]` — develop the idea into a full concept
   - `/architecture-decision` — specify the technical stack
   - `/design-system` — break down the architecture
   - `/prototype` — build a minimum viable prototype
   - `/sprint-plan` — plan the development sprint

#### If C: Clear concept

The user knows what they want to make but hasn't documented the architecture.

1. Ask 2-3 follow-up questions to understand their concept:
   - What's the main user flow and core feature? (one sentence)
   - Do they have a tech stack preference, or need help choosing?
   - What's the rough scope? (MVP, internal tool, enterprise app)
2. Based on their answers, offer two paths:
   - **Formalize first**: Run `/brainstorm` to structure the concept into a proper PRD (Product Requirements Document).
   - **Jump to architecture**: If they're confident in their concept, go straight to `/architecture-decision`.
3. Show the recommended path (adapted to their choice):
   - `/brainstorm` or `/architecture-decision` (their pick)
   - `/tech-debt` (if reviewing legacy ideas) or `/design-system`
   - `/team-feature` — allocate tasks to specialized AI agents
   - `/sprint-plan` — plan the first sprint

#### If D: Existing work

The user has artifacts already. Figure out what exists and what's missing.

1. Share what you found in Step 1 (now it's relevant):
   - "I can see you have [X source files / Y design docs / Z prototypes]..."
   - "Your tech stack is [configured as X / not yet clearly defined]..."
2. Recommend running `/project-stage-detect` for a full analysis
3. If the architecture isn't clear, note that `/architecture-decision` should come first
4. Show the recommended path:
   - `/project-stage-detect` — full gap analysis
   - `/code-review` — analyze existing codebase quality
   - `/team-feature` / `/team-backend` / `/team-frontend` — assign specialized agents to specific tasks
   - `/sprint-plan` — organize the remaining work

---

### 4. Confirm Before Proceeding

After presenting the recommended path, ask the user which step they'd like
to take first. Never auto-run the next skill.

> "Would you like to start with [recommended first step], or would you prefer
> to do something else first?"

---

### 5. Hand Off

When the user chooses their next step, let them invoke the skill themselves
or offer to run it for them. Either way, the `/start` skill's job is done
once the user has a clear next action.

---

## Edge Cases

- **User picks D but project is empty**: Gently redirect — "It looks like the
  project is a fresh template with no artifacts yet. Would Path A or B be a
  better fit?"
- **User picks A but project has code**: Mention what you found — "I noticed
  there's already code in `src/`. Did you mean to pick D (existing work)? Or
  would you like to start fresh with a new concept?"
- **User is returning (stack configured, concept exists)**: Skip onboarding
  entirely — "It looks like you're already set up! Your stack is [X] and you
  have a design document at `design/`. Want to pick up where
  you left off? Try `/sprint-plan` or just tell me what you'd like to work on."
- **User doesn't fit any option**: Let them describe their situation in their
  own words and adapt. The 4 options are starting points, not a prison.

---

## Collaborative Protocol

This skill follows the collaborative design principle:

1. **Ask first** — never assume the user's state or intent
2. **Present options** — give clear paths, not mandates
3. **User decides** — they pick the direction
4. **No auto-execution** — recommend the next skill, don't run it without asking
5. **Adapt** — if the user's situation doesn't fit a template, listen and adjust
