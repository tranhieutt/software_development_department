---
name: patch-notes
description: "Generates user-facing patch notes from git history and internal changelogs, translating technical changes into clear user communication. Use when preparing patch notes or when the user mentions patch notes or user-facing changelog."
argument-hint: "[version] [--style brief|detailed|full]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash
effort: 1
when_to_use: "Use when preparing user-facing patch notes for a release version, or when the user mentions patch notes, version notes, or user-facing changelog."
---

When this skill is invoked:

1. **Parse the arguments**:
   - `version`: the release version to generate notes for (e.g., `1.2.0`)
   - `--style`: output style — `brief` (bullet points), `detailed` (with context),
     `full` (with developer commentary). Default: `detailed`.

2. **Gather change data from multiple sources**:
   - Read the internal changelog at `production/releases/[version]/changelog.md` if it exists
   - Run `git log` between the previous release tag and current tag/HEAD
   - Read sprint retrospectives in `production/sprints/` for context
   - Read any balance change documents in `design/balance/`
   - Read bug fix records from QA if available

3. **Categorize all changes** into user-facing categories:
   - **New Content**: new features, maps, characters, items, modes
   - **Business Logic Changes**: balance adjustments, mechanic changes, progression changes
   - **Quality of Life**: UI improvements, convenience features, accessibility
   - **Bug Fixes**: grouped by system (combat, UI, networking, etc.)
   - **Performance**: optimization improvements users might notice
   - **Known Issues**: transparency about unresolved problems

4. **Translate developer language to user language**:
   - "Refactored damage calculation pipeline" → "Improved hit detection accuracy"
   - "Fixed null reference in inventory manager" → "Fixed a crash when opening inventory"
   - "Reduced GC allocations in combat loop" → "Improved combat performance"
   - Remove purely internal changes that don't affect users
   - Preserve specific numbers for balance changes (damage: 50 → 45)

5. **Generate the patch notes** using the appropriate style:

### Brief Style

```markdown
# Patch [Version] — [Title]

**New**
- [Feature 1]
- [Feature 2]

**Changes**
- [Balance/mechanic change with before → after values]

**Fixes**
- [Bug fix 1]
- [Bug fix 2]

**Known Issues**
- [Issue 1]
```

### Detailed Style

```markdown
# Patch [Version] — [Title]
*[Date]*

## Highlights
[1-2 sentence summary of the most exciting changes]

## New Content
### [Feature Name]
[2-3 sentences describing the feature and why users should be excited]

## Business Logic Changes
### Balance
| Change | Before | After | Reason |
| ---- | ---- | ---- | ---- |
| [Item/ability] | [old value] | [new value] | [brief rationale] |

### Mechanics
- **[Change]**: [explanation of what changed and why]

## Quality of Life
- [Improvement with context]

## Bug Fixes
### Combat
- Fixed [description of what users experienced]

### UI
- Fixed [description]

### Networking
- Fixed [description]

## Performance
- [Improvement users will notice]

## Known Issues
- [Issue and workaround if available]
```

### Full Style

Includes everything from Detailed, plus:

```markdown
## Developer Commentary
### [Topic]
> [Developer insight into a major change — why it was made, what was considered,
> what the team learned. Written in first-person team voice.]
```

6. **Review the output** for:
   - No internal jargon (replace technical terms with user-friendly language)
   - No references to internal systems, tickets, or sprint numbers
   - Balance changes include before/after values
   - Bug fixes describe the user experience, not the technical cause
   - Tone matches the product's voice (adjust formality based on product style)

7. **Save the patch notes** to `production/releases/[version]/patch-notes.md`,
   creating the directory if needed.

8. **Output to the user**: the complete patch notes, the file path, a count of
   changes by category, and any internal changes that were excluded (for review).

## Protocol

- **Question**: Reads version and `--style` argument; defaults to `detailed` if style is omitted
- **Options**: Style choice if unspecified — `brief` / `detailed` / `full`
- **Decision**: Skip — style drives output format
- **Draft**: Full patch notes shown in conversation before saving
- **Approval**: "May I write to `production/releases/[version]/patch-notes.md`?"

## Output

Deliver exactly:

- **Patch notes file** saved to `production/releases/[version]/patch-notes.md`
- **Change count by category** (Features: X, Fixes: Y, Balance: Z, etc.)
- **Excluded internal items** — list of changes omitted from user-facing notes
