---
name: project-stage-detect
description: "Analyzes existing project artifacts to detect development stage, identify documentation gaps, and recommend next steps. Use when starting a new session on an existing project, or when the user mentions project analysis, stage detection, or gap analysis."
argument-hint: "[optional: role filter like 'programmer' or 'designer']"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
effort: 3
when_to_use: "Use when starting a session on an existing project, onboarding to a codebase, or checking what documentation gaps exist before a milestone."
---

# Project Stage Detection

This skill scans your project to determine its current development stage, completeness
of artifacts, and gaps that need attention. It's especially useful when:

- Starting with an existing project
- Onboarding to a codebase
- Checking what's missing before a milestone
- Understanding "where are we?"

---

## Workflow

### 1. Scan Key Directories

Analyze project structure and content:

**Design Documentation** (`design/`):

- Count PRD files in `design/docs/*.md`
- Check for product-concept.md, product-pillars.md, systems-index.md
- If systems-index.md exists, count total systems vs. designed systems
- Analyze completeness (Overview, Detailed Design, Edge Cases, etc.)
- Count narrative docs in `design/narrative/`
- Count level designs in `design/specs/`

**Source Code** (`src/`):

- Count source files (language-agnostic)
- Identify major systems (directories with 5+ files)
- Check for core/, business/, ai/, networking/, ui/ directories
- Estimate lines of code (rough scale)

**Production Artifacts** (`production/`):

- Check for active sprint plans
- Look for milestone definitions
- Find roadmap documents

**Prototypes** (`prototypes/`):

- Count prototype directories
- Check for READMEs (documented vs undocumented)
- Assess if prototypes are archived or active

**Architecture Docs** (`docs/architecture/`):

- Count ADRs (Architecture Decision Records)
- Check for overview/index documents

**Tests** (`tests/`):

- Count test files
- Estimate test coverage (rough heuristic)

### 2. Classify Project Stage

Based on scanned artifacts, determine stage. Check `production/stage.txt` first —
if it exists, use its value (explicit override from `/gate-check`). Otherwise,
auto-detect using these heuristics (check from most-advanced backward):

| Stage | Indicators |
| ----- | ---------- |
| **Concept** | No product concept doc, brainstorming phase |
| **Systems Design** | Product concept exists, systems index missing or incomplete |
| **Technical Setup** | Systems index exists, engine not configured |
| **Pre-Production** | Engine configured, `src/` has <10 source files |
| **Production** | `src/` has 10+ source files, active development |
| **Polish** | Explicit only (set by `/gate-check` Production → Polish gate) |
| **Release** | Explicit only (set by `/gate-check` Polish → Release gate) |

### 3. Collaborative Gap Identification

**DO NOT** just list missing files. Instead, **ask clarifying questions**:

- "I see combat code (`src/api/auth/`) but no `design/docs/combat-system.md`. Was this prototyped first, or should we reverse-document?"
- "You have 15 ADRs but no architecture overview. Should I create one to help new contributors?"
- "No sprint plans in `production/`. Are you tracking work elsewhere (Jira, Trello, etc.)?"
- "I found a product concept but no systems index. Have you decomposed the concept into individual systems yet, or should we run `/map-systems`?"
- "Prototypes directory has 3 projects with no READMEs. Were these experiments, or do they need documentation?"

### 4. Generate Stage Report

Use template: `.claude/docs/templates/project-stage-report.md`

**Report structure**:

```markdown
# Project Stage Analysis

**Date**: [date]
**Stage**: [Concept/Systems Design/Technical Setup/Pre-Production/Production/Polish/Release]

## Completeness Overview
- Design: [X%] ([N] docs, [gaps])
- Code: [X%] ([N] files, [systems])
- Architecture: [X%] ([N] ADRs, [gaps])
- Production: [X%] ([status])
- Tests: [X%] ([coverage estimate])

## Gaps Identified
1. [Gap description + clarifying question]
2. [Gap description + clarifying question]

## Recommended Next Steps
[Priority-ordered list based on stage and role]
```

### 5. Role-Filtered Recommendations (Optional)

If user provided a role argument (e.g., `/project-stage-detect programmer`):

**Programmer**:

- Focus on architecture docs, test coverage, missing ADRs
- Code-to-docs gaps

**Designer**:

- Focus on PRD completeness, missing design sections
- Prototype documentation

**Producer**:

- Focus on sprint plans, milestone tracking, roadmap
- Cross-team coordination docs

**General** (no role):

- Holistic view of all gaps
- Highest-priority items across domains

### 6. Request Approval Before Writing

**Collaborative protocol**:

```text
I've analyzed your project. Here's what I found:

[Show summary]

Gaps identified:
1. [Gap 1 + question]
2. [Gap 2 + question]

Recommended next steps:
- [Priority 1]
- [Priority 2]
- [Priority 3]

May I write the full stage analysis to production/project-stage-report.md?
```

Wait for user approval before creating the file.

---

## Example Usage

```bash
# General project analysis
/project-stage-detect

# Programmer-focused analysis
/project-stage-detect programmer

# Designer-focused analysis
/project-stage-detect designer
```

---

## Follow-Up Actions

After generating the report, suggest relevant next steps:

- **Concept exists but no systems index?** → `/map-systems` to decompose into systems
- **Missing design docs?** → `/reverse-document design src/[system]`
- **Missing architecture docs?** → `/architecture-decision` or `/reverse-document architecture`
- **Prototypes need documentation?** → `/reverse-document concept prototypes/[name]`
- **No sprint plan?** → `/sprint-plan`
- **Approaching milestone?** → `/milestone-review`

---

## Collaborative Protocol

This skill follows the collaborative design principle:

1. **Question First**: Ask about gaps, don't assume
2. **Present Options**: "Should I create X, or is it tracked elsewhere?"
3. **User Decides**: Wait for direction
4. **Show Draft**: Display report summary
5. **Get Approval**: "May I write to production/project-stage-report.md?"

**Never** silently write files. **Always** show findings and ask before creating artifacts.

## Protocol

- **Question**: Asks clarifying questions about gaps (never just lists missing files)
- **Options**: Skip — role filter from argument narrows recommendations
- **Decision**: Skip
- **Draft**: Stage analysis summary shown before saving
- **Approval**: "May I write to `production/project-stage-report.md`?"

## Output

Deliver exactly:

- **Detected stage** — one of: Concept / Systems Design / Technical Setup / Pre-Production / Production / Polish / Release
- **Evidence** — artifacts found that support this stage detection
- **Gaps** — missing artifacts for current and next stage
- **Recommended next skill** — single highest-value action to take right now (e.g., `/map-systems`, `/sprint-plan`)
