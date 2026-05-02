---
paths:
  - "tests/**"
---

# Test Standards

- Test naming: `test_[system]_[scenario]_[expected_result]` pattern
- Every test must have a clear arrange/act/assert structure
- Unit tests must not depend on external state (filesystem, network, database)
- Integration tests must clean up after themselves
- Performance tests must specify acceptable thresholds and fail if exceeded
- Test data must be defined in the test or in dedicated fixtures, never shared mutable state
- Mock external dependencies — tests should be fast and deterministic
- Every bug fix must have a regression test that would have caught the original bug

## Examples

**Correct** (proper naming + Arrange/Act/Assert):

```javascript
// Using Node.js test runner (node:test) or any framework (Jest, Vitest, Mocha)
describe("HealthSystem", () => {
  test("takeDamage_reducesCurrentHealth", () => {
    // Arrange
    const health = new HealthSystem({ maxHealth: 100 });
    health.currentHealth = 100;

    // Act
    health.takeDamage(25);

    // Assert
    expect(health.currentHealth).toBe(75);
  });
});
```

**Incorrect**:

```javascript
// VIOLATION: no descriptive name
test("test1", () => {
  const health = new HealthSystem({ maxHealth: 100 });
  // VIOLATION: no arrange step, no clear assert
  health.takeDamage(25);
  // VIOLATION: imprecise assertion — does not check exact expected value
  expect(health.currentHealth).toBeLessThan(100);
});
```

## Coverage Mapping with GitNexus

When writing tests for a changed symbol, use GitNexus to find gaps:

```
mcp__gitnexus__impact(target: "symbolName", direction: "upstream")
```

This returns all callers of the symbol. Write new tests to cover d=1 callers
(direct callers) first -- these are the ones that will break silently if the
symbol's contract changes.
