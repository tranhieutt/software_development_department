# Upgrading Claude Code Software Development Department

This template is designed to be forked and customized for your project. Upgrading means pulling improvements from the upstream template into your customized fork.

## Strategy: Cherry-Pick What You Need

Because you've customized agents, rules, and templates for your project, a blind merge will overwrite your changes. The recommended approach is to **cherry-pick specific files** you want to update rather than doing a full merge.

## Setup: Add the Upstream Remote

```bash
# Navigate to your project
cd /path/to/your-project

# Add the template as a remote (one-time setup)
git remote add template https://github.com/Donchitos/Claude-Code-Software-Department.git
git fetch template
```

## Upgrading Safe Files

These files are unlikely to conflict with your customizations and can be upgraded directly:

### Always Safe to Upgrade
- `.claude/hooks/` — hook scripts (check your settings.json still matches)
- `.claude/docs/coding-standards.md` — if you haven't customized it
- `.claude/docs/context-management.md`
- `.claude/docs/review-workflow.md`

```bash
# Example: upgrade a specific hook
git checkout template/main -- .claude/hooks/validate-commit.sh
```

### Review Before Upgrading
- `.claude/agents/*.md` — may have template improvements but check for conflicts with custom personas
- `.claude/skills/*/skill.md` — check if new options were added
- `.claude/rules/*.md` — check if new standards were added

### Never Blindly Upgrade
- `CLAUDE.md` — you've configured your stack here
- `.claude/docs/technical-preferences.md` — your project-specific conventions
- `production/` — your sprint and milestone data
- `docs/` — your project documentation

## Checking What Changed

```bash
# See what changed in the template since your last sync
git fetch template
git log --oneline HEAD..template/main -- .claude/

# Compare a specific file
git diff HEAD template/main -- .claude/agents/lead-programmer.md
```

## After Upgrading

1. Run a grep to verify nothing unexpected was changed:
   ```bash
   grep -ri "game\|godot\|unity\|unreal" .claude/ --include="*.md"
   # Should return no results
   ```

2. Test that hooks still work:
   ```bash
   bash .claude/hooks/session-start.sh
   ```

3. Verify agent count is still correct:
   ```bash
   ls .claude/agents/*.md | wc -l
   ```
