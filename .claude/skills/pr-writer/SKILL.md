---
name: pr-writer
type: workflow
description: "Creates and formats pull request titles, descriptions, and linked issue references following conventional commit standards. Use when creating or updating a pull request or when the user mentions PR description, pull request, or opening a PR."
context: fork
agent: lead-programmer
when_to_use: "When creating or updating pull requests -- generates PR title, description, and issue references following conventional commit format"
allowed-tools: Read, Glob, Grep, Write, Bash
argument-hint: "[PR title or empty for auto-generate from commits]"
user-invocable: true
effort: 2
---

# PR Writer

Create pull requests following conventional engineering practices.

**Requires**: GitHub CLI (`gh`) authenticated and available.

## Prerequisites

Before creating a PR, ensure all changes are committed. If there are uncommitted changes, run the `commit` skill first to commit them properly.

```bash
# Check for uncommitted changes
git status --porcelain
```

If the output shows any uncommitted changes (modified, added, or untracked files that should be included), invoke the `commit` skill before proceeding.

## Process

### Step 1: Verify Branch State

```bash
# Detect the default branch — note the output for use in subsequent commands
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

```bash
# Check current branch and status (substitute the detected branch name above for BASE)
git status
git log BASE..HEAD --oneline
```

Ensure:
- All changes are committed
- Branch is up to date with remote
- Changes are rebased on the base branch if needed

### Step 2: Analyze Changes

Review what will be included in the PR:

```bash
# See all commits that will be in the PR (substitute detected branch name for BASE)
git log BASE..HEAD

# See the full diff
git diff BASE...HEAD
```

Understand the scope and purpose of all changes before writing the description.

### Step 3: Write the PR Description

Use this structure for PR descriptions (ignoring any repository PR templates):

```markdown
<brief description of what the PR does>

<why these changes are being made - the motivation>

<alternative approaches considered, if any>

<any additional context reviewers need>
```

**Do NOT include:**
- "Test plan" sections
- Checkbox lists of testing steps
- Redundant summaries of the diff

**Do include:**
- Clear explanation of what and why
- Links to relevant issues or tickets
- Context that isn't obvious from the code
- Notes on specific areas that need careful review

### Step 4: Create the PR

```bash
gh pr create --draft --title "<type>(<scope>): <description>" --body "$(cat <<'EOF'
<description body here>
EOF
)"
```

**Title format** follows commit conventions:
- `feat(scope): Add new feature`
- `fix(scope): Fix the bug`
- `ref: Refactor something`

## PR Description Examples

### Feature PR

```markdown
Add Slack thread replies for alert notifications

When an alert is updated or resolved, we now post a reply to the original
Slack thread instead of creating a new message. This keeps related
notifications grouped and reduces channel noise.

Previously considered posting edits to the original message, but threading
better preserves the timeline of events and works when the original message
is older than Slack's edit window.

Refs #1234
```

### Bug Fix PR

```markdown
Handle null response in user API endpoint

The user endpoint could return null for soft-deleted accounts, causing
dashboard crashes when accessing user properties. This adds a null check
and returns a proper 404 response.

Found while investigating #5678.

Fixes #5678
```

### Refactor PR

```markdown
Extract validation logic to shared module

Moves duplicate validation code from the alerts, issues, and projects
endpoints into a shared validator class. No behavior change.

This prepares for adding new validation rules in #9999 without
duplicating logic across endpoints.
```

## Issue References

Reference issues in the PR body:

| Syntax | Effect |
|--------|--------|
| `Fixes #1234` | Closes GitHub issue on merge |
| `Fixes #1234` | Closes GitHub issue |
| `Refs GH-1234` | Links without closing |
| `Refs LINEAR-ABC-123` | Links Linear issue |

## Guidelines

- **One PR per feature/fix** - Don't bundle unrelated changes
- **Keep PRs reviewable** - Smaller PRs get faster, better reviews
- **Explain the why** - Code shows what; description explains why
- **Mark WIP early** - Use draft PRs for early feedback

## Editing Existing PRs

If you need to update a PR after creation, use `gh api` instead of `gh pr edit`:

```bash
# Update PR description
gh api -X PATCH repos/{owner}/{repo}/pulls/PR_NUMBER -f body="$(cat <<'EOF'
Updated description here
EOF
)"

# Update PR title
gh api -X PATCH repos/{owner}/{repo}/pulls/PR_NUMBER -f title='new: Title here'

# Update both
gh api -X PATCH repos/{owner}/{repo}/pulls/PR_NUMBER \
  -f title='new: Title' \
  -f body='New description'
```

Note: `gh pr edit` is currently broken due to GitHub's Projects (classic) deprecation.

## Protocol

- **Question**: Verifies no uncommitted changes before starting; runs `commit` skill first if found
- **Options**: Skip
- **Decision**: Skip
- **Draft**: PR title and body shown in conversation before creating
- **Approval**: "May I run `gh pr create` with this title and description?"

## Output

Deliver exactly:

- **PR title** — conventional commit format (`type(scope): description`, max 72 chars)
- **PR body** — Summary, Test plan, and breaking changes sections
- **`gh pr create` command** — ready to copy-paste or execute directly

## References

- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub CLI PR docs](https://cli.github.com/manual/gh_pr_create)

## When to Use

- Use when ALWAYS use this skill when creating or updating pull requests — never create or edit a PR directly without it. Follows conventional commit format for PR titles, descriptions, and issue references. Trigger on any create PR, open PR, submit PR, make PR,...
