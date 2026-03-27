---
name: brainstorm
description: "Guided product concept ideation — from zero idea to a structured product concept document. Uses professional product thinking frameworks, user psychology, and structured creative exploration."
argument-hint: "[product type or problem hint, or 'open' for fully open brainstorm]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, WebSearch, AskUserQuestion
---

When this skill is invoked:

1. **Parse the argument** for an optional product type or problem hint (e.g., `productivity app`,
   `API service`, `developer tool`, `marketplace`). If `open` or no argument, start from scratch.

2. **Check for existing concept work**:
   - Read `design/docs/product-concept.md` if it exists (resume, don't restart)
   - Read `design/docs/product-pillars.md` if it exists (build on established pillars)

3. **Run through ideation phases** interactively, asking the user questions at
   each phase. Do NOT generate everything silently — the goal is **collaborative
   exploration** where the AI acts as a product thinking facilitator, not a
   replacement for the human's vision.

   **Use `AskUserQuestion`** at key decision points throughout brainstorming:
   - Constrained taste questions (product type, target users, scope)
   - Concept selection ("Which 2-3 concepts resonate?") after presenting options
   - Direction choices ("Develop further, explore more, or start sprint planning?")
   - Pillar ranking after concepts are refined

   Write full analysis in conversation text first, then use `AskUserQuestion`
   to capture the decision with concise labels.

   Professional product brainstorming principles to follow:
   - Withhold judgment — no idea is bad during exploration
   - Encourage unusual ideas — outside-the-box thinking sparks better products
   - Build on each other — "yes, and..." responses, not "but..."
   - Use constraints as creative fuel — limitations often produce the best ideas
   - Time-box each phase — keep momentum, don't over-deliberate early

---

### Phase 1: Creative Discovery

Start by understanding the person and their context, not the product. Ask these questions
conversationally (not as a checklist):

**Problem anchors**:
- What's a frustrating problem you personally experience that no existing tool solves well?
- Is there a workflow, process, or task you've always wished was easier or more automated?

**Experience profile**:
- What 3 products (apps, tools, APIs, services) do you use most? What keeps you coming back?
- Are there product categories you love or actively avoid? Why?
- Do you prefer products that save time, reduce complexity, enable creativity, or connect people?

**Practical constraints** (shape the sandbox before brainstorming):
- Solo developer or team? What skills and resources are available?
- Timeline: weeks (MVP), months (v1), or years (full product)?
- Any platform constraints? (Web only? Mobile? API-first? Desktop?)
- First product or experienced builder?
- Revenue model in mind? (SaaS, open source, freemium, one-time purchase?)

**Synthesize** the answers into a **Product Brief** — a 3-5 sentence
summary of the person's goals, experience context, and constraints.
Read the brief back and confirm it captures their intent.

---

### Phase 2: Concept Generation

Using the product brief as a foundation, generate **3 distinct concepts**
that each take a different creative direction. Use these ideation techniques:

**Technique 1: Verb-First Design**
Start with the core user verb (build, track, automate, connect, analyze, manage,
discover, share, deploy) and build the product outward from there. The verb IS the product.

**Technique 2: Problem-Inversion Method**
Take an existing frustration in a market and invert it. "What if [pain point] just...
didn't exist?" Then design backward from that ideal state. Find the simplest product
that bridges the current reality to that ideal.

**Technique 3: Intersection Design**
Combine two unexpected domains: [Audience A] + [Workflow B]. The intersection creates
the unique hook. (e.g., "developers + financial compliance", "designers + data pipelines",
"small teams + enterprise security")

For each concept, present:
- **Working Title**
- **Elevator Pitch** (1-2 sentences — must pass the "10-second test")
- **Core User Action** (the single most frequent thing a user does)
- **Core Value Promise** (the outcome users pay/sign-up for)
- **Unique Angle** (passes the "AND ALSO" test: "Like X, AND ALSO Y")
- **Target User** (who specifically? Not "developers" — "backend engineers at 50-person startups")
- **Estimated Scope** (small / medium / large)
- **Why It Could Work** (1 sentence on market/timing fit)
- **Biggest Risk** (1 sentence on the hardest unanswered question)

Present all three. Ask the user to pick one, combine elements, or request
new concepts. Never pressure toward a choice — let them sit with it.

---

### Phase 3: Core User Flow Design

For the chosen concept, use structured questioning to build the core user flow.
The core flow is the beating heart of the product — if it isn't valuable in
isolation, no amount of features or polish will save the product.

**First-Use Flow** (the critical first 5 minutes):
- What's the first action a new user takes?
- When do they first experience value? (The "aha moment")
- What friction exists between sign-up and first value? How to minimize it?

**Core Usage Loop** (the repeating cycle):
- What does a typical usage session look like from start to finish?
- What triggers the user to open/use the product? (External trigger? Internal habit?)
- What output or result makes the session feel successful?

**Retention Hook** (why they come back):
- What makes users return daily / weekly?
- What accumulates over time that makes the product more valuable? (Data? History? Network?)
- What does the product feel like after 30 days vs. day 1?

**Growth Loop** (how it spreads):
- Does using the product naturally lead to sharing or inviting others?
- What's the viral or referral mechanic (if any)?

**User Motivation Analysis** (based on Self-Determination Theory):
- **Autonomy**: How much meaningful control does the user have over outcomes?
- **Competence**: How does the user feel more capable or skilled over time?
- **Relatedness**: How does the user feel connected (to team, community, or their work)?

---

### Phase 4: Pillars and Boundaries

Product pillars are used by top companies (Notion, Linear, Stripe, Figma) to align
teams around a single product vision. Even for solo builders, pillars prevent
scope creep and keep decision-making fast and consistent.

Collaboratively define **3-5 pillars**:
- Each pillar has a **name** and **one-sentence definition**
- Each pillar has a **design test**: "If we're choosing between feature X and Y,
  this pillar says we build __"
- Pillars should create productive tension — if all pillars agree on everything,
  they're not doing enough work

Then define **3+ anti-pillars** (what this product is NOT):
- Anti-pillars prevent the most common form of scope creep: "wouldn't it be cool if..."
  features that dilute the core value
- Frame as: "We will NOT build [thing] because it would compromise [pillar]"

---

### Phase 5: User Segment Validation

Using Jobs-to-be-Done and user motivation frameworks, validate who this product is for:

- **Primary user segment**: Who will LOVE this product? Be specific — role, company size,
  workflow context, pain level
- **Secondary appeal**: Who else might find value in it?
- **Who is this NOT for**: Being clear about who won't benefit is as important as knowing
  who will — it prevents building for everyone and delighting no one
- **Market validation**: Are there successful products serving adjacent user needs?
  What can we learn from their growth path?
- **Willingness to pay**: Is this a "must have" or "nice to have" for the target user?

---

### Phase 6: Scope and Feasibility

Ground the concept in reality:

- **Tech stack recommendation** — Language, Framework, Database, Cloud provider — with
  reasoning based on the concept's requirements, team expertise, and scalability needs
- **Build vs. Buy decisions** — auth (Clerk/Supabase/custom?), payments (Stripe?),
  search (Algolia?), email (SendGrid?), analytics (PostHog?)
- **MVP definition** — the absolute minimum feature set that validates:
  "Does this solve the user's pain better than what they use today?"
- **Infrastructure scope** — monolith vs. microservices, serverless vs. dedicated,
  multi-tenant vs. per-customer
- **Biggest risks** — technical risks, design risks, market risks, regulatory risks
- **Scope tiers**:
  - **MVP** (weeks): Validates core hypothesis with minimum code
  - **v1** (months): Shippable, complete product for early adopters
  - **Full vision** (beyond): What it becomes if successful

---

4. **Generate the product concept document** using the template at
   `.claude/docs/templates/product-concept.md`. Fill in ALL sections from the
   brainstorm conversation, including the user motivation analysis, value proposition,
   and flow design sections.

5. **Save to** `design/docs/product-concept.md`, creating directories as needed.

6. **Suggest next steps** (in this order — this is the professional product
   pre-production pipeline):

   - "Run `/design-review design/docs/product-concept.md` to validate completeness"
   - "Refine concept and pillars with the `product-manager` agent"
   - "Discuss technical approach with `cto` and `technical-director`"
   - "Decompose the concept into systems and APIs with `/map-systems`"
   - "Design the core API with `/api-design`"
   - "Prototype the core flow with `/prototype [core-feature]`"
   - "Validate the prototype with `ux-researcher` before full build"
   - "Plan the first sprint with `/sprint-plan new`"

7. **Output a summary** with:
   - Chosen concept elevator pitch
   - Product pillars (names only)
   - Primary target user
   - Tech stack recommendation
   - MVP definition (1 sentence)
   - Biggest risk
   - File path of saved concept doc
