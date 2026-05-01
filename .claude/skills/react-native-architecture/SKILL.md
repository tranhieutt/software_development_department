---
name: react-native-architecture
type: reference
description: "Provides React Native architecture patterns for navigation, state management, native module integration, offline sync, and Expo workflows. Use when working with React Native files or when the user mentions React Native, Expo, or mobile app."
paths: ["**/*.tsx", "**/*.jsx", "**/app.json", "**/metro.config.*", "**/expo.config.*"]
when_to_use: "When developing React Native or Expo mobile apps, implementing native modules, navigation, or cross-platform patterns"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
effort: 4
---

# React Native Architecture

Production-ready patterns for React Native with Expo: navigation, state management, native modules, offline-first, and performance.

## Navigation Patterns

### Expo Router (file-based routing)
\`\`\`typescript
// app/(tabs)/_layout.tsx - Tab layout
import { Tabs } from 'expo-router';
export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="index" options={{ title: 'Home' }} />
      <Tabs.Screen name="profile" options={{ title: 'Profile' }} />
    </Tabs>
  );
}
\`\`\`

### React Navigation (programmatic)
\`\`\`typescript
import { createNativeStackNavigator } from '@react-navigation/native-stack';
const Stack = createNativeStackNavigator<RootStackParamList>();
\`\`\`

Pattern: Use Expo Router for new projects, React Navigation for complex deep linking.

## State Management

| Pattern | Use When | Library |
|---------|----------|---------|
| Zustand | Simple global state | zustand |
| TanStack Query | Server state | @tanstack/react-query |
| Redux Toolkit | Complex state logic | @reduxjs/toolkit |
| Jotai | Atomic state | jotai |

\`\`\`typescript
// Zustand store example
import { create } from 'zustand';
const useAuthStore = create((set) => ({
  user: null,
  login: (user) => set({ user }),
  logout: () => set({ user: null }),
}));
\`\`\`

## Native Modules

### Expo Modules (recommended)
\`\`\`typescript
// modules/my-module/index.ts
import { requireNativeModule } from 'expo-modules-core';
export default requireNativeModule('MyModule');
\`\`\`

### Turbo Modules (bare RN)
Use when Expo module is insufficient. Requires native Swift/Kotlin code.

## Offline-First Architecture

Pattern: Queue mutations, sync on reconnect.
\`\`\`
User action → Local state (optimistic) → Queue mutation → Sync to server
\`\`\`

Tools: WatermelonDB, Realm, or SQLite with Drizzle ORM.

## Performance Checklist

- Use `React.memo` for expensive list items
- Virtualize lists with `FlashList` (not FlatList)
- Lazy load screens with `React.lazy` + Suspense
- Use `useMemo`/`useCallback` for expensive computations
- Profile with Flipper or React DevTools
- Hermes engine enabled (default in Expo)

## Build & Deploy

\`\`\`bash
# Expo build
eas build --platform ios
eas build --platform android

# OTA update
eas update --branch production
\`\`\`

## Related Skills

- `flutter-expert` — for Flutter cross-platform alternative
- `mobile-developer` — broader mobile development patterns
- `ios-developer` — iOS-specific native patterns
