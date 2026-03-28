---
name: mobile-review
description: "Performs a mobile-specific code review on a React Native, Flutter, or native iOS/Android file. Checks platform standards compliance, performance anti-patterns, security, accessibility, and offline behavior. Distinct from code-review: this skill applies mobile-first criteria."
argument-hint: "[path-to-mobile-file-or-directory]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
---

When this skill is invoked:

1. **Read the target file(s)** in full.

2. **Read the CLAUDE.md** to identify the mobile tech stack (React Native / Flutter / Swift / Kotlin).

3. **Determine platform scope**: iOS-only, Android-only, or cross-platform.

4. **Evaluate Performance (MFRI Check)**:
   - [ ] No `ScrollView` wrapping long or dynamic lists — use `FlatList` / `FlashList` (RN) or `ListView.builder` (Flutter)
   - [ ] `renderItem` is wrapped in `useCallback` / item widget is `const` or `StatelessWidget`
   - [ ] Stable `keyExtractor` — no array index as key
   - [ ] Animations use native driver (`useNativeDriver: true`) or GPU-composited properties
   - [ ] No `console.log` / debug print in production code paths
   - [ ] Images use lazy loading and caching (FastImage / cached_network_image)
   - [ ] Cold start: no heavy sync work on app launch

5. **Evaluate Platform Standards**:
   - [ ] Follows Apple HIG on iOS: navigation styles, back behavior, SF Symbols
   - [ ] Follows Material Design 3 on Android: navigation rail, dynamic color, M3 components
   - [ ] Touch targets ≥ 44pt (iOS) / 48dp (Android)
   - [ ] No hover assumptions — all interactions are touch/gesture-first
   - [ ] Platform-specific gestures respected (edge swipe on iOS, system back on Android)
   - [ ] Typography uses platform font scale (Dynamic Type / Font Scale)

6. **Evaluate Security (OWASP MASVS)**:
   - [ ] No tokens or secrets stored in `AsyncStorage` / `SharedPreferences` — use `SecureStore` / Keychain / EncryptedSharedPreferences
   - [ ] No sensitive data in logs
   - [ ] SSL/certificate pinning configured for sensitive endpoints
   - [ ] No hardcoded API keys, URLs, or credentials

7. **Evaluate Offline & Network Handling**:
   - [ ] Network errors are caught and shown to user — no silent failures
   - [ ] Loading, error, empty, and offline states all handled
   - [ ] Retry mechanism present for failed requests
   - [ ] Local data persisted for offline-first features (SQLite / Realm / Hive / MMKV)

8. **Evaluate Accessibility**:
   - [ ] All interactive elements have `accessibilityLabel` / `contentDescription` / `semanticsLabel`
   - [ ] VoiceOver / TalkBack can navigate the screen logically
   - [ ] No functionality gated behind gestures only — button fallback exists
   - [ ] Focus management correct after navigation or modal open/close

9. **Output the review** in this format:

```
## Mobile Code Review: [File/Feature Name]
Platform: [iOS / Android / Cross-platform]
Framework: [React Native / Flutter / SwiftUI / Compose]

### Performance: [X/7 passing]
[List failures with line references and fix suggestion]

### Platform Standards: [X/6 passing]
[List non-compliant items]

### Security (MASVS): [X/4 passing]
[List security issues with severity: CRITICAL / HIGH / MEDIUM]

### Offline & Network: [X/4 passing]
[List missing states or error handling gaps]

### Accessibility: [X/4 passing]
[List missing labels or navigation issues]

### Positive Observations
[What is done well — always include this section]

### Required Changes (block release)
[Must-fix items]

### Suggestions (non-blocking)
[Nice-to-have improvements]

### Verdict: [APPROVED / APPROVED WITH SUGGESTIONS / CHANGES REQUIRED]
```
