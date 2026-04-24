---
name: launch-checklist
type: workflow
description: "Generates a comprehensive software launch checklist covering technical readiness, customer communications, support, and go-live steps. Use when preparing for a product launch or when the user mentions launch checklist or go-live readiness."
argument-hint: "[launch-date or 'dry-run']"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
effort: 3
when_to_use: "When preparing for a software product or feature launch and needing to validate all departments are ready"
---

When this skill is invoked:

> **Explicit invocation only**: This skill should only run when the user explicitly requests it with `/launch-checklist`. Do not auto-invoke based on context matching.

1. **Read the argument** for the launch date or `dry-run` mode. Dry-run mode
   generates the checklist without creating sign-off entries.

2. **Gather project context**:
   - Read `CLAUDE.md` for tech stack, release surfaces, and team structure
   - Read the latest milestone in `production/milestones/`
   - Read any existing release checklist in `production/releases/`
   - Read any launch, support, or communications notes in `docs/launch/`,
     `docs/runbooks/`, or `production/releases/` if they exist

3. **Scan codebase health**:
   - Count `TODO`, `FIXME`, `HACK` comments and their locations
   - Check for any `console.log`, `print()`, or debug output left in production code
   - Check for placeholder assets or copy (search for `placeholder`, `temp_`, `WIP_`)
   - Check for hardcoded test/dev values (localhost, test credentials, debug flags)

4. **Generate the launch checklist**:

```markdown
# Launch Checklist: [Product Title]
Target Launch: [Date or DRY RUN]
Generated: [Date]

---

## 1. Code Readiness

### Build Health
- [ ] Clean build or release artifact generated for all target surfaces
- [ ] Zero release-blocking compiler or linter errors
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] End-to-end or smoke tests passing for critical user journeys
- [ ] Schema migrations tested with rollback or recovery plan
- [ ] Release version correctly set and tagged in source control
- [ ] Performance and reliability benchmarks within agreed targets

### Code Quality
- [ ] TODO count: [N] (zero required for launch, or documented exceptions)
- [ ] FIXME count: [N] (zero required)
- [ ] HACK count: [N] (each must have documented justification)
- [ ] No unintended debug output in production code
- [ ] No hardcoded dev/test values
- [ ] All feature flags reviewed for launch defaults
- [ ] Error handling covers all critical paths
- [ ] Crash reporting and structured logging integrated and verified
- [ ] Dependency vulnerabilities triaged and accepted risk documented

### Security and Privacy
- [ ] No exposed API keys or credentials in source or build artifacts
- [ ] Authentication, authorization, and input validation verified on public endpoints
- [ ] Network communication secured (TLS, signed webhooks, secret rotation as applicable)
- [ ] Abuse protection, rate limiting, or bot controls enabled where required
- [ ] Privacy policy and data handling compliance verified
- [ ] Backup and restore path validated for stateful systems

---

## 2. Product Readiness

### Functional Scope
- [ ] All launch-scope features implemented or explicitly deferred
- [ ] Critical user journeys tested end-to-end
- [ ] Admin, support, and internal operational workflows verified
- [ ] Billing, notifications, integrations, and webhooks tested if applicable
- [ ] Data import/export, retention, or deletion flows verified if applicable
- [ ] Release notes and known issues drafted

### UX, Content, and Localization
- [ ] All placeholder copy and visuals replaced
- [ ] All user-facing text proofread
- [ ] No hardcoded strings (all externalized for localization)
- [ ] All supported languages translated and verified
- [ ] Text fits UI in all supported languages
- [ ] Help content, onboarding, and empty states reviewed
- [ ] Customer-facing documentation links are current

---

## 3. Quality Assurance

### Testing
- [ ] Full regression test suite passed
- [ ] Zero Sev1 (Critical) bugs open
- [ ] Zero Sev2 (High/Major) bugs open, or documented exceptions with owner approval
- [ ] Smoke test passed in staging or release candidate environment
- [ ] User acceptance or stakeholder sign-off captured
- [ ] Edge cases tested (no network, expired session, low storage, rate limits, retries)
- [ ] Backup/restore or disaster recovery drill completed if applicable

### Accessibility and Compliance
- [ ] Accessibility basics covered for target surfaces
- [ ] Consent, privacy, and legal notices reviewed
- [ ] Audit logging or regulated workflow checks verified if required
- [ ] App store or platform policy requirements met, if applicable

### Performance and Reliability
- [ ] Response time or startup time within budget
- [ ] Memory and CPU usage within budget
- [ ] Queue lag, background jobs, and async workflows within targets
- [ ] No sustained error-rate spikes during release candidate soak window
- [ ] Capacity and scaling assumptions reviewed for launch traffic

---

## 4. Distribution and Customer-Facing Assets

### Release Assets
- [ ] Changelog complete and proofread
- [ ] Release notes complete and customer-appropriate
- [ ] Version numbers aligned across app, API, docs, and packaging
- [ ] Download links, package names, or deployment targets finalized

### Launch Communications
- [ ] Status page messaging prepared
- [ ] Customer announcement drafted
- [ ] In-app banner, modal, or changelog entry prepared if needed
- [ ] Support macros / FAQ updated
- [ ] Sales, customer success, and internal stakeholders briefed

### Public Metadata
- [ ] Marketing site or product page copy updated
- [ ] Screenshots or release visuals current
- [ ] Pricing, packaging, and plan entitlements verified
- [ ] App store listing metadata current, if applicable

---

## 5. Infrastructure

### Production Readiness
- [ ] Production infrastructure provisioned and sized for launch
- [ ] Database backups configured and restore tested
- [ ] CDN, cache invalidation, and asset delivery configured where applicable
- [ ] Feature flag rollout strategy documented
- [ ] Secrets and access reviews completed
- [ ] Deployment and rollback runbooks current

### Analytics and Monitoring
- [ ] Analytics pipeline verified and receiving expected events
- [ ] Crash reporting active and dashboard accessible
- [ ] Monitoring dashboards live for core technical and business metrics
- [ ] Alerts configured for critical thresholds
- [ ] Incident escalation path and owners documented

---

## 6. Support and Operations

### Team Readiness
- [ ] On-call schedule set for first 72 hours post-launch
- [ ] Incident response playbook reviewed by the team
- [ ] Hotfix pipeline tested
- [ ] Communication plan for launch issues documented
- [ ] Support team briefed on known issues and escalation path

### Launch Day Plan
- [ ] Go-live sequence documented step by step
- [ ] Rollback decision criteria documented
- [ ] War room or launch channel established
- [ ] Launch monitoring dashboard bookmarked by all leads
- [ ] Checkpoint times defined for launch-day review

---

## Go / No-Go Decision

**Overall Status**: [READY / NOT READY / CONDITIONAL]

### Blocking Items
[List any items that must be resolved before launch]

### Conditional Items
[List items that have documented workarounds or accepted risk]

### Sign-Offs Required
- [ ] Product Owner - Scope and customer readiness
- [ ] Engineering Lead - Technical health and stability
- [ ] QA Lead - Quality and test coverage
- [ ] Release Manager - Deployment and rollback readiness
- [ ] Security / Compliance Owner - Security and data handling
- [ ] Support Lead - Support and incident readiness
```

5. **Save the checklist** to
   `production/releases/launch-checklist-[date].md`, creating directories as needed.

6. **Output a summary** to the user: total items, blocking items count,
   conditional items count, departments with incomplete sections, and the file path.

## Protocol

- **Question**: Reads launch date or `dry-run` argument; gathers context from CLAUDE.md and milestone files
- **Options**: Skip
- **Decision**: Skip - checklist is generated; Go/No-Go is advisory
- **Draft**: Summary statistics shown before saving
- **Approval**: "May I write to `production/releases/launch-checklist-[date].md`?"

## Output

Deliver exactly:

- **Checklist file** saved to `production/releases/launch-checklist-[date].md`
- **Summary**: total items / blocking count / conditional count / incomplete departments
- **Verdict**: `GO` / `CONDITIONAL GO` / `NO-GO` with blocking items listed
