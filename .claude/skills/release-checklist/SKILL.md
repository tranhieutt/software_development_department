---
name: release-checklist
type: workflow
description: "Generates a comprehensive pre-release validation checklist for software versions covering build verification, deployment readiness, and release risk. Use when preparing to release a product version or when the user mentions release checklist or pre-release validation."
argument-hint: "[surface: web|api|desktop|mobile|all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
effort: 3
when_to_use: "Use before releasing a software version to validate build completeness, deployment readiness, and launch risk across target surfaces."
---

When this skill is invoked:

> **Explicit invocation only**: This skill should only run when the user explicitly requests it with `/release-checklist`. Do not auto-invoke based on context matching.

1. **Read the argument** for the target surface (`web`, `api`, `desktop`,
   `mobile`, or `all`). If no surface is specified, default to `all`.

2. **Read `CLAUDE.md`** for project context, version information, and release
   surfaces.

3. **Read the current milestone** from `production/milestones/` to understand
   what features and behaviors should be included in this release.

4. **Scan the codebase** for outstanding issues:
   - Count `TODO` comments
   - Count `FIXME` comments
   - Count `HACK` comments
   - Note their locations and severity

5. **Check for test results** in any test output directories, CI logs, or
   release validation notes if available.

6. **Generate the release checklist**:

```markdown
## Release Checklist: [Version] -- [Surface]
Generated: [Date]

### Codebase Health
- TODO count: [N] ([list top 5 if many])
- FIXME count: [N] ([list all -- these are potential blockers])
- HACK count: [N] ([list all -- these need review])

### Build Verification
- [ ] Clean build succeeds for all target surfaces
- [ ] No release-blocking compiler or linter errors
- [ ] Build version number correctly set ([version])
- [ ] Release artifact is reproducible from tagged commit
- [ ] Configuration files and feature flags match release intent
- [ ] Schema migrations tested with rollback or recovery plan
- [ ] Packaging, signing, or publish steps validated where applicable

### Quality Gates
- [ ] Zero Sev1 (Critical) bugs
- [ ] Zero Sev2 (High/Major) bugs, or documented exceptions with owner approval
- [ ] All critical-path features tested and signed off by QA
- [ ] No regression from previous release
- [ ] Performance within budgets:
  - [ ] Response time or startup time within target
  - [ ] Memory usage within budget
  - [ ] Load time or background job latency within budget
  - [ ] No sustained error-rate increase during release candidate soak
- [ ] Monitoring and alerting verified for release-critical paths

### Product Complete
- [ ] All placeholder content replaced or removed
- [ ] All TODO/FIXME in user-facing flows resolved or documented
- [ ] All user-facing text proofread
- [ ] All text localization-ready (no hardcoded strings)
- [ ] Analytics / telemetry events verified
- [ ] Support and admin workflows tested
- [ ] Known limitations documented for support and customers
```

7. **Add surface-specific sections** based on the argument:

For `web`:
```markdown
### Surface Requirements: Web
- [ ] Core journeys tested on supported browsers
- [ ] Responsive layouts verified across target breakpoints
- [ ] Authentication, session expiry, and logout flows verified
- [ ] CDN, cache invalidation, and static asset delivery validated
- [ ] CSP, cookie consent, and security headers reviewed
- [ ] SEO metadata and robots/indexing settings reviewed if public-facing
```

For `api`:
```markdown
### Surface Requirements: API
- [ ] OpenAPI / schema docs updated
- [ ] Backward compatibility or versioning impact assessed
- [ ] Auth, rate limiting, and idempotency tested
- [ ] Webhooks, retries, and signature verification tested if applicable
- [ ] Consumer-facing breaking changes communicated
- [ ] Database migrations validated against representative data
```

For `desktop`:
```markdown
### Surface Requirements: Desktop
- [ ] Installer/package generated and verified
- [ ] Code signing and notarization complete if required
- [ ] Auto-update flow tested
- [ ] Clean install, upgrade, and uninstall scenarios verified
- [ ] File-system permissions and data directory behavior verified
- [ ] Crash recovery and relaunch behavior tested
```

For `mobile`:
```markdown
### Surface Requirements: Mobile
- [ ] App store guidelines compliance verified
- [ ] All required device permissions justified and documented
- [ ] Privacy policy linked and accurate
- [ ] Background, resume, and offline behavior verified
- [ ] Push notification and deep link flows tested if applicable
- [ ] In-app purchase / subscription flows tested if applicable
- [ ] Crash-free launch tested on supported OS/device matrix
```

8. **Add release distribution and launch sections**:

```markdown
### Distribution / Release Assets
- [ ] Changelog complete and proofread
- [ ] Release notes complete and audience-appropriate
- [ ] Customer support FAQ updated
- [ ] Public status page, docs, or announcement content prepared
- [ ] App store or download-page metadata current, if applicable
- [ ] Legal notices, privacy policy, and third-party attributions in place

### Launch Readiness
- [ ] Analytics / telemetry verified and receiving data
- [ ] Crash reporting configured and dashboard accessible
- [ ] Deployment window approved
- [ ] Rollback plan documented and tested
- [ ] On-call team schedule set for release window
- [ ] Support team briefed on known issues and escalation path
- [ ] Incident communication template prepared

### Go / No-Go: [READY / NOT READY]

**Rationale:**
[Summary of readiness assessment. List any blocking items that must be
resolved before release. If NOT READY, list the specific items that need
resolution and estimated time to address them.]

**Sign-offs Required:**
- [ ] QA Lead
- [ ] Engineering Lead
- [ ] Product Owner
- [ ] Release Manager
- [ ] Security / Compliance Owner (if applicable)
```

9. **Save the checklist** to
   `production/releases/release-checklist-[version].md`, creating the
   directory if it does not exist.

10. **Output a summary** to the user with: total checklist items, number of
    known blockers (FIXME/HACK counts, known bugs), and the file path.

## Protocol

- **Question**: Reads surface argument (`web` / `api` / `desktop` / `mobile` / `all`); defaults to `all`
- **Options**: Skip
- **Decision**: Skip - checklist is generated; Go/No-Go is advisory
- **Draft**: Summary shown before writing
- **Approval**: "May I write to `production/releases/release-checklist-[version].md`?"

## Output

Deliver exactly:

- **Checklist file** saved to `production/releases/release-checklist-[version].md`
- **Summary**: total items / blockers count (FIXME/HACK/known bugs) / sign-offs pending
- **Verdict**: `READY TO RELEASE` / `CONDITIONAL` / `BLOCKED - DO NOT RELEASE`
