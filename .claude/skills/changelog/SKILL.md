---
name: changelog
type: workflow
description: "Generates a structured changelog from git history following Keep a Changelog format and conventional commits. Use when creating a CHANGELOG.md, preparing release notes, or when the user mentions changelog or release history."
argument-hint: "[version|sprint-number]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
context: |
  !git log --oneline -30 2>/dev/null
  !git tag --list --sort=-v:refname 2>/dev/null | head -5
effort: 1
when_to_use: "When generating a changelog from git commits for a version or sprint release"
---

When this skill is invoked:

1. **Read the argument** for the target version or sprint number. If a version
   is given, use the corresponding git tag. If a sprint number is given, use
   the sprint date range.

1b. **Check git availability** — Verify the repository is initialized:
   - Run `git rev-parse --is-inside-work-tree` to confirm git is available
   - If not a git repo, inform the user and abort gracefully

2. **Read the git log** since the last tag or release:
   ```
   git log --oneline [last-tag]..HEAD
   ```
   If no tags exist, read the full log or a reasonable recent range (last 100
   commits).

3. **Read sprint reports** from `production/sprints/` for the relevant period
   to understand planned work and context behind changes.

4. **Read completed design documents** from `design/docs/` for any new features
   that were implemented during this period.

5. **Categorize every change** into one of these categories:
   - **New Features**: Entirely new business systems, modes, or content
   - **Improvements**: Enhancements to existing features, UX improvements,
     performance gains
   - **Bug Fixes**: Corrections to broken behavior
   - **Balance Changes**: Tuning of business logic values, difficulty, economy
   - **Known Issues**: Issues the team is aware of but have not yet resolved

6. **Generate the INTERNAL changelog** (full technical detail):

```markdown
# Internal Changelog: [Version]
Date: [Date]
Sprint(s): [Sprint numbers covered]
Commits: [Count] ([first-hash]..[last-hash])

## New Features
- [Feature Name] -- [Technical description, affected systems]
  - Commits: [hash1], [hash2]
  - Owner: [who implemented it]
  - Design doc: [link if applicable]

## Improvements
- [Improvement] -- [What changed technically and why]
  - Commits: [hashes]
  - Owner: [who]

## Bug Fixes
- [BUG-ID] [Description of bug and root cause]
  - Fix: [What was changed]
  - Commits: [hashes]
  - Owner: [who]

## Balance Changes
- [What was tuned] -- [Old value -> New value] -- [Design intent]
  - Owner: [who]

## Technical Debt / Refactoring
- [What was cleaned up and why]
  - Commits: [hashes]

## Known Issues
- [Issue description] -- [Severity] -- [ETA for fix if known]

## Metrics
- Total commits: [N]
- Files changed: [N]
- Lines added: [N]
- Lines removed: [N]
```

7. **Generate the USER-FACING changelog** (friendly, non-technical):

```markdown
# What is New in [Version]

## New Features
- **[Feature Name]**: [User-friendly description of what they can now do
  and why it is exciting. Focus on the experience, not the implementation.]

## Improvements
- **[What improved]**: [How this makes the product better for the user.
  Be specific but avoid jargon.]

## Bug Fixes
- Fixed an issue where [describe what the user experienced, not what was
  wrong in the code]
- Fixed [user-visible symptom]

## Balance Changes
- [What changed in user-understandable terms and the design intent.
  Example: "Healing potions now restore 50 HP (up from 30) -- we felt
  users needed more recovery options in late-product encounters."]

## Known Issues
- We are aware of [issue description in user terms] and are working on a
  fix. [Workaround if one exists.]

---
Thank you for playing! Your feedback helps us make the product better.
Report issues at [link].
```

8. **Output both changelogs** to the user. The internal changelog is the
   primary working document. The user-facing changelog is ready for
   community posting after review.

### Guidelines

- Never expose internal code references, file paths, or developer names in
  the user-facing changelog
- Group related changes together rather than listing individual commits
- If a commit message is unclear, check the associated files and sprint data
  for context
- Balance changes should always include the design reasoning, not just the
  numbers
- Known issues should be honest -- users appreciate transparency
- If the git history is messy (merge commits, reverts, fixup commits), clean
  up the narrative rather than listing every commit literally

## Protocol

- **Question**: Reads version or sprint number from argument; verifies git repo availability before starting
- **Options**: Skip — both internal and user-facing versions always generated
- **Decision**: Skip
- **Draft**: Both changelogs shown in conversation before saving
- **Approval**: "May I write to `production/releases/[version]/changelog.md`?"

## Output

Deliver exactly:

- **Internal changelog** — developer-facing, grouped by category (Features, Fixes, Performance, etc.)
- **User-facing changelog** — user-friendly language, no internal references
- **Both saved** to `production/releases/[version]/changelog.md` and `changelog-user.md`
- **Excluded items count** — internal-only changes omitted from user version
