---
name: skill-technical-document
type: workflow
description: |
  Generate a polished internal technical HTML document following the SDD visual
  design system. Use when asked to "táº¡o tài liá»‡u ká»¹ thuáº­t", "generate HTML
  reference", "visual report", "technical doc", "táº¡o report HTML", "làm tài
  liá»‡u ná»™i bá»™", or when asked to document a subsystem (hooks, memory, agents,
  ADRs, audit findings) in a browser-readable format with sidebar navigation.
argument-hint: "[document topic, subsystem, or report scope]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
effort: 3
when_to_use: "Use when asked to generate an internal technical HTML document, visual reference, subsystem report, or browser-readable documentation artifact."
---

# Goal

Generate a single, self-contained `.html` file that looks and feels like
`hooks_visual_report.html` — warm off-white palette, JetBrains Mono + Inter
fonts, fixed sidebar with section nav, and layered content sections —
without needing any external CSS framework or JS library.

# Instructions

## Step 1: Identify document type

Pick the layout template based on content:

| Document type             | Primary component | Secondary components     |
| ------------------------- | ----------------- | ------------------------ |
| Hook / agent reference    | Hook-table        | Deployment priority list |
| Architecture / flow       | Diagram-block     | Section tables           |
| Audit / compliance        | Matrix-table      | Callouts, checklists     |
| ADR / decision record     | Priority-list     | Callouts, diagram        |
| Memory / config reference | Hook-table        | Callouts                 |

## Step 2: Plan sections (max 7)

Map content → `§ 00`, `§ 01`, ... sections. Each section needs:
- A unique `id` for the sidebar anchor
- A `section-num` label
- A `section-desc` (1–2 sentences)
- One primary component (table, diagram, or list)

## Step 3: Assign nav dot colors

Nav dots communicate semantics, not decoration:
- `green` → start/lifecycle/session
- `red` → security/blocking/guard
- `blue` → enrichment/context/read-path
- `purple` → observability/logging/audit
- _(no class)_ → neutral (matrix, summary, deployment order)

## Step 4: Write content following these rules

**For table cells (`col-desc`):**
- Lead with `<strong>Bold summary sentence.</strong>` — one sharp phrase
- Follow with detail text
- Bullet points go inside `<ul class="behaviors">` — never plain `<ul>`
- Inline code uses `<code>` inside `.col-desc`

**For hook/agent names (`hn`):**
- Always monospace
- Never truncate — use full filename including extension

**For numbers in `doc-meta`:**
- Must be real, meaningful counts (files, hooks, layers, date)
- Don't invent stats

**For event badges:**
- SessionStart → `.ev-green`
- PreToolUse:Bash/Task (when it can `exit 2`) → `.ev-red` + add `<span class="blocks">blocks</span>`
- UserPromptSubmit, PreToolUse:Read/Write → `.ev-blue`
- PostToolUse, SubagentStart, PreCompact → `.ev-purple`
- Stop, sub-process, utility → `.ev-orange`
- Warnings/partial states → `.ev-amber`

**Diagram block (dark canvas):**
- Background: dark (`--text` = `#1A1614`)
- Highlighted items: `.hl` → `#F5A673`
- Dimmed items: `.dim` → `#6B6058`
- Always has `.diagram-caption` with `// description` text

## Step 5: Assemble HTML file

Structure:
```
<html>
  <head>  ← Google Fonts + <style> block from resources/css_template.md
  <body>
    <div class="shell">
      <nav class="sidebar">   ← brand + nav-links + sidebar-footer
      <main class="main">
        <header class="doc-header">  ← eyebrow + title + subtitle + meta-stats
        <section § 00>  ← diagram-block (flow map)
        <hr class="section-sep">
        <section § 01..N>   ← tables / matrices / priority lists
        <hr class="section-sep"> between each
        <div class="doc-footer">
    <script>  ← scroll-highlight JS (see resources/components.md)
```

## Step 6: Output

- Save to `docs/` as `{topic}_visual_report.html` or `{topic}_reference.html`
- Single file, no external dependencies
- Run the Quality Checklist from `resources/checklist.md` before finalizing

# Examples

See `examples/audit_summary_example.html` — a compact 3-section doc showing
header + diagram + matrix + priority-list in ~200 lines.

See `examples/agent_reference_example.html` — a full 5-section agent reference
with hook-tables and event badges.

# Constraints

- SKILL.md must use the exact CSS tokens from `resources/css_template.md` —
  never invent new color values
- Never use Tailwind, Bootstrap, or any external CSS framework
- Never use placeholder text ("Lorem ipsum") — all content must be real
- Keep `<style>` block complete but minified — put readable reference in
  `resources/css_template.md`
- Sidebar must always have a `sidebar-footer` with at least 2 metadata lines
- Section count: minimum 2, maximum 7 — more than 7 = split into 2 docs
- `doc-meta` stats must be real numbers sourced from the actual content
- Always include the scroll-highlight `<script>` at end of `<body>`

<!-- Generated by Skill Creator Ultra v1.0 -->
