## Summary

Brief description of what this PR does.

## Type of Change

- [ ] New agent
- [ ] New skill
- [ ] New hook or rule
- [ ] Bug fix
- [ ] Documentation improvement
- [ ] Other:

## Changes

-
-
-

## P1 Evidence (Required)

- Spec ID:
- Stage/Tier:
- Test result:
- Lint result:
- Build result:
- Risk:
- Rollback/Fallback:
- Given:
- When:
- Then:

## Checklist

- [ ] I've tested this in a Claude Code session
- [ ] New agents include the Collaboration Protocol section
- [ ] New skills use the subdirectory format (`.claude/skills/<name>/SKILL.md`)
- [ ] Reference docs are updated (agent-roster, skills-reference, hooks-reference, rules-reference)
- [ ] Hooks use `grep -E` (POSIX) and fail gracefully without jq/python
- [ ] No hardcoded paths or platform-specific assumptions

## Coordination Policy Changes

Complete only when this PR changes coordination rules, weakens/removes a
protocol, or changes high-risk retry behavior.

- [ ] Queried `/trace-history --outcome blocked --last 20`
- [ ] Queried `/trace-history --outcome fail --last 20`
- [ ] Cited relevant prior blocked/failed decisions, or stated none were found
