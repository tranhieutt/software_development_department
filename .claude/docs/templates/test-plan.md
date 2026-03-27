# Test Plan: [Feature/System Name]

## Overview

- **Feature**: [Name]
- **Design Doc**: [Link to design document]
- **Implementation**: [Link to code or PR]
- **Author**: [QA owner]
- **Date**: [Date]
- **Priority**: [Critical / High / Medium / Low]

## Scope

### In Scope

- [What is being tested]

### Out of Scope

- [What is explicitly NOT being tested and why]

### Dependencies

- [Other systems that must be working for these tests to be valid]

## Test Environment

- **Build**: [Minimum build version]
- **Platform**: [Target platforms]
- **Preconditions**: [Required game state, save files, etc.]

## Test Cases

### Functional Tests -- Happy Path

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|----------------|--------|
| TC-001 | [Description] | 1. [Step] 2. [Step] | [Expected] | [ ] |
| TC-002 | [Description] | 1. [Step] 2. [Step] | [Expected] | [ ] |

### Functional Tests -- Edge Cases

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|----------------|--------|
| TC-010 | [Boundary value] | 1. [Step] | [Expected] | [ ] |
| TC-011 | [Zero/null input] | 1. [Step] | [Expected] | [ ] |
| TC-012 | [Maximum values] | 1. [Step] | [Expected] | [ ] |

### Negative Tests

| ID | Test Case | Steps | Expected Result | Status |
|----|-----------|-------|----------------|--------|
| TC-020 | [Invalid input] | 1. [Step] | [Graceful handling] | [ ] |
| TC-021 | [Interrupted action] | 1. [Step] | [No corruption] | [ ] |

### Integration Tests

| ID | Test Case | Systems Involved | Steps | Expected Result | Status |
|----|-----------|-----------------|-------|----------------|--------|
| TC-030 | [Cross-system interaction] | [System A, System B] | 1. [Step] | [Expected] | [ ] |

### Performance Tests

| ID | Test Case | Metric | Budget | Steps | Status |
|----|-----------|--------|--------|-------|--------|
| TC-040 | [Load time] | Seconds | [X]s | 1. [Step] | [ ] |
| TC-041 | [Frame rate] | FPS | [X] | 1. [Step] | [ ] |
| TC-042 | [Memory usage] | MB | [X]MB | 1. [Step] | [ ] |

### Regression Tests

| ID | Related Bug | Test Case | Steps | Expected Result | Status |
|----|------------|-----------|-------|----------------|--------|
| TC-050 | BUG-[XXXX] | [Verify fix holds] | 1. [Step] | [Expected] | [ ] |

## Test Results Summary

| Category | Total | Passed | Failed | Blocked | Skipped |
|----------|-------|--------|--------|---------|---------|
| Happy Path | | | | | |
| Edge Cases | | | | | |
| Negative | | | | | |
| Integration | | | | | |
| Performance | | | | | |
| Regression | | | | | |
| **Total** | | | | | |

## Bugs Found

| Bug ID | Severity | Test Case | Description | Status |
|--------|----------|-----------|-------------|--------|

## Sign-Off

- **QA Tester**: [Name] -- [Date]
- **QA Lead**: [Name] -- [Date]
- **Feature Owner**: [Name] -- [Date]
