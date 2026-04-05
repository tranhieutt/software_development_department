# Release Checklist: [Version] -- [Platform]

**Release Date**: [Target Date]
**Release Manager**: [Name]
**Status**: [ ] GO / [ ] NO-GO

---

## Build Verification

- [ ] Clean build succeeds on all target platforms
- [ ] No compiler warnings (zero-warning policy)
- [ ] Build version number set correctly: `[version]`
- [ ] Build is reproducible from tagged commit: `[commit hash]`
- [ ] Build size within budget: [actual] / [budget]
- [ ] All assets included and loading correctly
- [ ] No debug/development features enabled in release build

---

## Quality Gates

### Critical Bugs
- [ ] Zero S1 (Critical) bugs open
- [ ] Zero S2 (Major) bugs -- or documented exceptions below:

| Bug ID | Description | Exception Rationale | Approved By |
| ---- | ---- | ---- | ---- |
| | | | |

### Test Coverage
- [ ] All critical path features tested and signed off
- [ ] Full regression suite passed: [pass rate]%
- [ ] Extended soak test passed (4+ hours continuous usage)
- [ ] Edge case testing complete

### Performance
- [ ] API response time (p95) met: [actual] / [target] ms
- [ ] Memory usage within budget: [actual] / [budget] MB
- [ ] Load times within budget: [actual] / [target] seconds
- [ ] No memory leaks over extended usage (soak test)
- [ ] No response time degradation under normal usage load

---

## Content Complete

- [ ] All placeholder assets replaced with final versions
- [ ] All user-facing text proofread
- [ ] All text localization-ready (no hardcoded strings)
- [ ] Localization complete for: [list locales]
- [ ] Audio mix finalized and approved
- [ ] Credits complete and accurate
- [ ] Legal notices and third-party attributions complete

---

## Platform: PC

- [ ] Minimum and recommended specs documented
- [ ] Keyboard+mouse controls fully functional
- [ ] Resolution scaling tested: 1080p, 1440p, 4K, ultrawide
- [ ] Windowed, borderless, fullscreen modes working
- [ ] Graphics settings save and load correctly
- [ ] Store SDK integrated and tested: [Steam/Epic/GOG]
- [ ] Core analytics events firing correctly
- [ ] Data sync and persistence verified

## Platform: Mobile (if applicable)

- [ ] iOS build passes App Store review guidelines
- [ ] Android build passes Play Store review guidelines
- [ ] Push notifications functional on both platforms
- [ ] Offline mode degrades gracefully
- [ ] App size within platform limits
- [ ] Deep links navigate correctly

---

## Store and Distribution

- [ ] Store page metadata complete and proofread
- [ ] Screenshots current and meet platform requirements
- [ ] Age ratings / content classifications obtained (if applicable)
- [ ] Legal: EULA, Privacy Policy, Terms of Service
- [ ] Pricing configured for all regions

---

## Launch Readiness

- [ ] Analytics/telemetry verified and receiving data
- [ ] Crash reporting configured: [service name]
- [ ] Day-one patch prepared (if needed)
- [ ] On-call team schedule set for first 72 hours
- [ ] Community announcements drafted
- [ ] Press kit and launch announcement ready
- [ ] Support team briefed on known issues
- [ ] Rollback plan documented and tested

---

## Sign-offs

| Role | Name | Status | Date |
| ---- | ---- | ---- | ---- |
| QA Lead | | [ ] Approved | |
| Technical Director | | [ ] Approved | |
| Producer | | [ ] Approved | |
| Creative Director | | [ ] Approved | |

---

## Final Decision

**GO / NO-GO**: ____________

**Rationale**: [Summary of readiness. If NO-GO, list specific blocking items and estimated time to resolve.]

**Notes**: [Any additional context, known risks accepted, or conditions on the release.]
