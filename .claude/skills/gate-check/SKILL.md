---
name: gate-check
type: workflow
description: "Validates a software product, service, or feature against readiness gates before advancing to the next delivery phase. Use when planning a phase transition or when the user mentions gate check, phase review, or readiness validation."
argument-hint: "[target-phase: systems-design | technical-setup | pre-production | production | polish | release]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write
effort: 3
when_to_use: "When validating software delivery readiness to advance to the next development phase"
---

# Phase Gate Validation

This skill validates whether the software project is ready to advance to the
next delivery phase. It checks for required artifacts, quality standards, and
operational blockers.

**Distinct from `/project-stage-detect`**: That skill is diagnostic ("where are
we?"). This skill is prescriptive ("are we ready to advance?" with a formal
verdict).

## Production Stages (7)

The project progresses through these stages:

1. **Concept** - Problem framing, product concept document
2. **Systems Design** - Requirements, workflows, architecture boundaries
3. **Technical Setup** - Stack selection, CI/CD, environments, architecture decisions
4. **Pre-Production** - Spikes, prototypes, acceptance criteria, delivery planning
5. **Production** - Feature development and integration work
6. **Polish** - Stabilization, QA hardening, performance, operational readiness
7. **Release** - Go-live prep, support readiness, rollback and communication planning

**When a gate passes**, write the new stage name to `production/stage.txt`
(single line, e.g. `Production`). This updates the status line immediately.

---

## 1. Parse Arguments

- **With argument**: `/gate-check production` - validate readiness for that specific phase
- **No argument**: Auto-detect current stage using the same heuristics as
  `/project-stage-detect`, then validate the NEXT phase transition

---

## 2. Phase Gate Definitions

### Gate: Concept -> Systems Design

**Required Artifacts:**
- [ ] `design/docs/product-concept.md` exists and has content
- [ ] Product pillars defined (in concept doc or `design/docs/product-pillars.md`)
- [ ] Success metrics or launch goals captured in the concept or PRD seed notes

**Quality Checks:**
- [ ] Product concept has been reviewed (`/design-review` verdict not MAJOR REVISION NEEDED)
- [ ] Primary user workflow or business outcome is described and understood
- [ ] Target audience and problem statement are identified

---

### Gate: Systems Design -> Technical Setup

**Required Artifacts:**
- [ ] Systems index exists at `design/docs/systems-index.md` with at least MVP systems enumerated
- [ ] At least 1 PRD in `design/docs/` (beyond product-concept.md and systems-index.md)

**Quality Checks:**
- [ ] PRD(s) pass design review (8 required sections present)
- [ ] System dependencies are mapped in the systems index
- [ ] MVP priority tier is defined
- [ ] Non-functional requirements are captured where relevant (performance, security, reliability, compliance)

---

### Gate: Technical Setup -> Pre-Production

**Required Artifacts:**
- [ ] Stack chosen (CLAUDE.md Technology Stack is not `[CHOOSE]`)
- [ ] Technical preferences configured (`.claude/docs/technical-preferences.md` populated)
- [ ] At least 1 Architecture Decision Record in `docs/architecture/`
- [ ] CI/CD workflow, build script, or release automation exists
- [ ] Environment strategy documented (dev/staging/prod, secrets handling, deployment path)

**Quality Checks:**
- [ ] Architecture decisions cover core domains, data flow, integrations, and deployment concerns
- [ ] Technical preferences have naming conventions and performance budgets set
- [ ] Operational ownership is clear for build, deploy, and rollback paths

---

### Gate: Pre-Production -> Production

**Required Artifacts:**
- [ ] At least 1 prototype, spike, or technical validation artifact exists with notes or a README
- [ ] First sprint plan exists in `production/sprints/`
- [ ] All MVP-tier PRDs from systems index are complete
- [ ] Initial delivery scope is defined for the first release or milestone

**Quality Checks:**
- [ ] Prototype or spike validates the riskiest technical assumption or critical user workflow
- [ ] Sprint plan references real work items from PRDs
- [ ] Acceptance criteria and release scope are defined
- [ ] Dependencies and sequencing risks are identified

---

### Gate: Production -> Polish

**Required Artifacts:**
- [ ] `src/` has active code organized into subsystems
- [ ] All core workflows from PRD are implemented (cross-reference `design/docs/` with `src/`)
- [ ] Main user journey works end-to-end in a dev or staging environment
- [ ] Test files exist in `tests/`
- [ ] Deployment or release scripts exist
- [ ] QA/UAT evidence exists (test summary, checklist, sign-off notes, or release candidate results)

**Quality Checks:**
- [ ] Tests are passing (run test suite via `Bash`)
- [ ] No critical/blocker bugs in any bug tracker or known issues
- [ ] Critical acceptance criteria are satisfied (compare to PRD acceptance criteria)
- [ ] Performance and reliability are within target budgets (check technical-preferences.md targets)
- [ ] Logs, metrics, and error reporting exist for critical paths

---

### Gate: Polish -> Release

**Required Artifacts:**
- [ ] All features from the milestone plan are implemented or explicitly deferred
- [ ] Environment variables, secrets, and feature flags are audited for release
- [ ] Localization strings are externalized (no hardcoded user-facing text in `src/`)
- [ ] QA test plan exists
- [ ] Release checklist completed (`/release-checklist` or `/launch-checklist` run)
- [ ] Deployment and rollback runbook exists
- [ ] Customer-facing release artifacts are prepared (release notes, support notes, status-page/internal comms as applicable)
- [ ] Changelog / patch notes drafted

**Quality Checks:**
- [ ] Full QA or UAT pass signed off by the owning team
- [ ] All automated checks and release validations are passing
- [ ] Performance, availability, and operational targets are met for the release surface
- [ ] No known critical or high-severity bugs; medium-severity items have documented accepted risk
- [ ] Accessibility basics covered for the release surface
- [ ] Localization verified for all target languages
- [ ] Legal, privacy, and security requirements are met (privacy policy, consent, licenses, terms as applicable)
- [ ] Production deployment, packaging, or publish flow completes cleanly
- [ ] Monitoring, alerting, and incident communication paths are ready

---

## 3. Run the Gate Check

For each item in the target gate:

### Artifact Checks
- Use `Glob` and `Read` to verify files exist and have meaningful content
- Don't just check existence - verify the file has real content (not just a template header)
- For code checks, verify directory structure and file counts

### Quality Checks
- For test checks: Run the test suite via `Bash` if a test runner is configured
- For design review checks: `Read` the PRD and check for the 8 required sections
- For performance checks: `Read` technical-preferences.md and compare against any
  profiling data in `tests/performance/` or recent `/perf-profile` output
- For localization checks: `Grep` for hardcoded strings in `src/`
- For release readiness checks: `Read` runbooks, release notes, deployment docs, and QA summaries if they exist

### Cross-Reference Checks
- Compare `design/docs/` documents against `src/` implementations
- Check that every system referenced in architecture docs has corresponding code
- Verify sprint plans reference real work items
- Verify deployment, environment, and rollback expectations are reflected in documentation or automation

---

## 4. Collaborative Assessment

For items that can't be automatically verified, **ask the user**:

- "I can't automatically verify business or QA sign-off. Has the release candidate been approved?"
- "No regression summary was found. Has QA or UAT completed a full pass?"
- "Performance or reliability evidence isn't available. Would you like to run `/perf-profile` or review recent monitoring data?"

**Never assume PASS for unverifiable items.** Mark them as MANUAL CHECK NEEDED.

---

## 5. Output the Verdict

```markdown
## Gate Check: [Current Phase] -> [Target Phase]

**Date**: [date]
**Checked by**: gate-check skill

### Required Artifacts: [X/Y present]
- [x] design/docs/product-concept.md - exists, 2.4KB
- [ ] docs/architecture/ - MISSING (no ADRs found)
- [x] production/sprints/ - exists, 1 sprint plan

### Quality Checks: [X/Y passing]
- [x] PRD has 8/8 required sections
- [ ] Tests - FAILED (3 failures in tests/unit/)
- [?] QA sign-off - MANUAL CHECK NEEDED

### Blockers
1. **No Architecture Decision Records** - Create an ADR before entering production.
2. **3 test failures** - Fix failing tests in tests/unit/ before advancing.

### Recommendations
- [Priority actions to resolve blockers]
- [Optional improvements that aren't blocking]

### Verdict: [PASS / CONCERNS / FAIL]
- **PASS**: All required artifacts present, all quality checks passing
- **CONCERNS**: Minor gaps exist but can be addressed during the next phase
- **FAIL**: Critical blockers must be resolved before advancing
```

---

## 6. Update Stage on PASS

When the verdict is **PASS** and the user confirms they want to advance:

1. Write the new stage name to `production/stage.txt` (single line, no trailing newline)
2. This immediately updates the status line for all future sessions

**Always ask before writing**: "Gate passed. May I update `production/stage.txt` to 'Production'?"

---

## Protocol

- **Question**: Asks about unverifiable quality checks (QA/UAT sign-off, monitoring evidence, manual validation)
- **Options**: Skip - gate is auto-detected or specified by argument
- **Decision**: User confirms whether to advance on PASS verdict
- **Draft**: Full gate check report shown in conversation before updating stage
- **Approval**: "May I update `production/stage.txt` to '[new-stage]'?" - only on PASS + user confirmation

## Output

Deliver exactly:

- **Gate being checked**: `[Current Phase] -> [Target Phase]`
- **Artifacts**: X/Y present (with list of missing items)
- **Quality checks**: X/Y passing (with list of failures and MANUAL CHECK NEEDED items)
- **Blockers**: numbered list, or "None"
- **Verdict**: `PASS` / `CONCERNS` / `FAIL`

---

## 7. Follow-Up Actions

Based on the verdict, suggest specific next steps:

- **No product concept?** -> `/brainstorm` to create one
- **No systems index?** -> `/map-systems` to decompose the concept into systems
- **Missing design docs?** -> `/reverse-document`
- **Missing ADRs?** -> `/architecture-decision-records`
- **Tests failing?** -> `/test-driven-development`
- **No QA or release evidence?** -> `/release-checklist` or `/launch-checklist`
- **Performance unknown?** -> `/perf-profile`
- **Security or compliance gaps?** -> `/security-audit`
- **Not localized?** -> `/localize`
- **Ready for release?** -> `/launch-checklist`

---

## Collaborative Protocol

This skill follows the collaborative design principle:

1. **Scan first**: Check all artifacts and quality gates
2. **Ask about unknowns**: Don't assume PASS for things you can't verify
3. **Present findings**: Show the full checklist with status
4. **User decides**: The verdict is a recommendation - the user makes the final call
5. **Get approval**: "May I write this gate check report to production/gate-checks/?"

**Never** block a user from advancing - the verdict is advisory. Document the
risks and let the user decide whether to proceed despite concerns.
