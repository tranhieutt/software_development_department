---
name: team-mobile
description: "Orchestrates the mobile team of ux-designer, mobile-developer, qa-tester, accessibility-specialist, and release-manager to design, implement, and ship a mobile feature from concept to app store release. Use when a mobile feature needs full-team delivery."
argument-hint: "[mobile feature or screen description]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
effort: 3
when_to_use: "Use when a mobile feature needs full-team delivery from UX design through native implementation, accessibility audit, device QA, and app store release."
---

When this skill is invoked, orchestrate the mobile team through a structured delivery pipeline.

**Decision Points:** At each phase, use `AskUserQuestion` to get user approval before proceeding.

## Team Composition

- **ux-designer** — Mobile UX flows, wireframes, platform-specific interaction design
- **mobile-developer** — Cross-platform or native implementation
- **accessibility-specialist** — Mobile accessibility audit (VoiceOver / TalkBack)
- **qa-tester** — Device and platform testing
- **release-manager** — Build signing, store submission, staged rollout

## Pipeline

### Phase 1: Platform Strategy

Before any design or code, resolve:

- **Platform**: iOS-only / Android-only / both (React Native, Flutter, or native)?
- **Offline requirement**: Must the feature work without network?
- **Minimum OS version**: iOS 16+ / Android API 28+?
- **Device targets**: Phone only, tablet, or both?

Use `AskUserQuestion` to confirm these with the user. Do not proceed without answers.

Output: Platform decision brief saved to `design/docs/mobile-[feature]-platform.md`

### Phase 2: UX Design (Mobile-First)

Delegate to **ux-designer** with mobile-specific constraints:

- Design user flow with platform-native navigation (tab bar / stack / drawer)
- Create wireframes for **all states**: default, loading, error, empty, offline, success
- Apply platform defaults:
  - iOS: bottom tab bar, edge-swipe back, SF Symbols, bottom sheets
  - Android: Navigation rail, system back, Material Icons, M3 components
- Minimum touch targets: 44pt (iOS) / 48dp (Android)
- Primary actions in thumb zone
- Output: Mobile UX spec + wireframes for user approval

### Phase 3: Implementation

Delegate to **mobile-developer**:

- Confirm tech stack matches CLAUDE.md
- Implement feature following approved UX spec
- Apply performance rules:
  - Use `FlatList` / `FlashList` (RN) or `ListView.builder` (Flutter) — never `ScrollView` for lists
  - `renderItem` in `useCallback` / `const` widgets
  - Native driver animations only
- Apply security rules:
  - No secrets in `AsyncStorage` — use `SecureStore` / Keychain
  - No sensitive data in logs
- Handle all states: loading, error, empty, offline, retry
- Write unit tests for business logic
- Write integration tests (Detox / Maestro / Patrol) for critical flows
- Output: Implemented feature + test results

### Phase 4: Mobile Accessibility Audit

Delegate to **accessibility-specialist** with mobile focus:

- VoiceOver (iOS): navigate screen with screen reader on
- TalkBack (Android): verify `contentDescription` on all interactive elements
- Check focus order after navigation transitions and modal open/close
- Verify no gesture-only interactions — button fallback exists
- Verify Dynamic Type / Font Scale does not break layout
- Output: Accessibility report — PASS / FAIL per item

### Phase 5: QA & Device Testing

Delegate to **qa-tester**:

- Test on real devices (not just simulator/emulator):
  - iOS: iPhone SE (small), iPhone 15 (standard), iPad if tablet-targeted
  - Android: Low-end device (API 28, 2GB RAM), mid-range (API 31), flagship
- Test all network conditions: fast WiFi, slow 3G, offline
- Test OS versions at min and max supported
- Run regression on existing mobile flows
- Output: QA report with pass/fail per device + issue list

### Phase 6: Release Preparation

Delegate to **release-manager**:

- Update version number and build number (semver)
- Run `mobile-review` skill on final code — must be APPROVED
- Verify code signing and provisioning profiles (iOS) / keystore (Android)
- Build release binary: `eas build --platform all` or `fastlane`
- Prepare store metadata: release notes, updated screenshots if needed
- Submit to TestFlight (iOS) and Internal App Sharing (Android) for beta
- **User approves** → submit to App Store / Google Play
- Output: Store submission confirmation + rollout plan

## Output

Summary report covering:
- Platform decision made
- UX spec status and key design decisions
- Implementation: features built, tests written
- Accessibility: PASS / FAIL summary
- QA: devices tested, critical issues found/resolved
- Release: build number, store submission status
- Any outstanding blockers or follow-up tasks
