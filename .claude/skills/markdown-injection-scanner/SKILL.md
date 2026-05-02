---
name: markdown-injection-scanner
type: workflow
description: "Scans Markdown (.md) files for malicious code injection including XSS, prompt injection, script injection, obfuscated payloads, and supply chain attack vectors. Use when auditing .md files for security threats or when the user mentions scanning markdown for malicious content."
context: fork
agent: security-engineer
when_to_use: "When scanning .md files for injection attacks, prompt injection, embedded malware, or when auditing documentation files for security threats"
allowed-tools: Read, Glob, Grep, Bash
argument-hint: "[target directory path]"
user-invocable: true
effort: 3
---

# Markdown Injection Scanner

Scans all `.md` files in a target directory for 18 categories of malicious code injection.
Uses regex pattern matching across the entire file corpus with parallel subagent execution for speed.

## Usage

```
/markdown-injection-scanner [target-directory]
```

If no directory is specified, ask the user to provide one.

---

## Phase 1: Discovery — Map the File Corpus

1. **Count all .md files** in target directory (recursive).

2. **Sample 2-3 files** to understand the file structure and content type (design docs, documentation, config, etc.).

3. **Report file count and content type** before proceeding.

---

## Phase 2: Parallel Injection Scanning

Execute scans in **3 parallel batches** using subagents for speed. Each subagent uses `search_files` with the target directory path and `*.md` file pattern.

### Batch 1 — Script and Code Injection (5 patterns)

| # | Category | Regex Pattern | Threat |
|---|----------|---------------|--------|
| 1 | Script tags | `<script[^>]*>` | Embedded JavaScript execution |
| 2 | HTML Event Handlers | `(onclick\|onerror\|onload\|onmouseover\|onfocus\|onblur\|onresize\|onsubmit\|onchange\|oninput\|onkeydown\|onkeyup\|onkeypress\|ontouchstart\|onmouseenter\|onmouseleave)\s*=` | Inline JS via HTML attributes |
| 3 | JS/VBScript Protocol | `(javascript:\|vbscript:)` | Malicious link protocols |
| 4 | Dynamic Code Execution | `(eval\s*\(\|Function\s*\(\|setTimeout\s*\(\|setInterval\s*\()` | Code execution via eval/setTimeout |
| 5 | DOM Manipulation | `(document\.(cookie\|domain\|write)\|window\.(location\|open)\|XMLHttpRequest\|fetch\s*\()` | DOM-based attacks |

### Batch 2 — Obfuscation and Encoding (6 patterns)

| # | Category | Regex Pattern | Threat |
|---|----------|---------------|--------|
| 6 | Base64 Payloads | `(base64\|atob\|btoa\|b64decode\|b64encode)[\s(]` | Encoded malicious content |
| 7 | Data URI Injection | `data:\s*(text/html\|application/javascript\|text/javascript)` | Inline HTML/JS via data URIs |
| 8 | SVG Injection | `<svg[^>]*>` | SVG-based XSS vectors |
| 9 | Hex/Unicode Encoding | `(\\x[0-9a-fA-F]{2}\|\\u[0-9a-fA-F]{4}\|&#x[0-9a-fA-F]+;)` | Obfuscated character encoding |
| 10 | Hidden Text — display:none | `<(span\|div\|p)[^>]*style\s*=\s*['"][^'"]*display\s*:\s*none` | Hidden content tricks |
| 11 | Hidden Text — font-size:0 | `font-size\s*:\s*0` | Invisible text |

### Batch 3 — Injection Vectors (7 patterns)

| # | Category | Regex Pattern | Threat |
|---|----------|---------------|--------|
| 12 | HTML Tag Injection | `<(iframe\|embed\|object\|link\|meta\|form\|input\|textarea\|button)[\s>]` | Injected HTML elements |
| 13 | Suspicious Markdown Links | `\[.*?\]\(data:` then `\[.*?\]\(javascript:` then `\[.*?\]\(vbscript:` | Malicious link targets |
| 14 | Prompt Injection (NL) | `(?i)(ignore\s+(all\s+)?previous\s+instructions\|you\s+are\s+now\|forget\s+(all\s+)?previous\|system\s*:\s*you\s+are\|disregard\s+(all\s+)?prior\|override\s+(all\s+)?instructions\|new\s+instructions?:\|IMPORTANT:.*ignore\|do\s+not\s+follow)` | AI/LLM prompt hijacking |
| 15 | Prompt Injection (Token) | `(?i)(\[INST\]\|\[\/INST\]\|<\|im_start\|>\|<\|im_end\|>\|<\|system\|>\|<\|user\|>\|<\|assistant\|>\|Human:\|Assistant:\|###\s*System\s*Prompt\|BEGIN\s+HIDDEN\|END\s+HIDDEN)` | LLM token format injection |
| 16 | Shell Command Injection | `(curl\s+\|wget\s+\|bash\s+-c\|sh\s+-c\|powershell\|cmd\.exe\|/bin/sh\|/bin/bash\|rm\s+-rf\|chmod\s+777\|sudo\s+)` | Shell command execution |
| 17 | Executable File Links | `(https?://[^\s)>\]]*\.(exe\|bat\|cmd\|ps1\|sh\|msi\|dll\|vbs\|wsf\|hta\|scr))` | Links to malicious executables |
| 18 | Malware Keywords | `(?i)(steganograph\|obfusc\|malware\|payload\|exploit\|backdoor\|trojan\|keylog\|ransom\|phish)` | Direct malware references |

### Subagent Prompt Templates

Use 3 subagents via `use_subagents`, each with prompts corresponding to their batch patterns above. Replace `[TARGET_DIR]` with the actual target directory.

**Subagent 1 — Script and Code Injection:**
```
Search for script and code injection patterns in .md files in "[TARGET_DIR]". Use search_files with these regex patterns on *.md files, one at a time:
1. `<script[^>]*>`
2. `(onclick|onerror|onload|onmouseover|onfocus|onblur|onresize|onsubmit|onchange|oninput|onkeydown|onkeyup|onkeypress|ontouchstart|onmouseenter|onmouseleave)\s*=`
3. `(javascript:|vbscript:)`
4. `(eval\s*\(|Function\s*\(|setTimeout\s*\(|setInterval\s*\()`
5. `(document\.(cookie|domain|write)|window\.(location|open)|XMLHttpRequest|fetch\s*\()`
Report all findings per pattern.
```

**Subagent 2 — Obfuscation and Encoding:**
```
Search for obfuscation and encoding patterns in .md files in "[TARGET_DIR]". Use search_files with these regex patterns on *.md files, one at a time:
1. `(base64|atob|btoa|b64decode|b64encode)[\s(]`
2. `data:\s*(text/html|application/javascript|text/javascript)`
3. `<svg[^>]*>`
4. `(\\x[0-9a-fA-F]{2}|\\u[0-9a-fA-F]{4}|&#x[0-9a-fA-F]+;)`
5. `<(span|div|p)[^>]*style\s*=\s*['"][^'"]*display\s*:\s*none`
6. `font-size\s*:\s*0`
Report all findings per pattern.
```

**Subagent 3 — Injection Vectors:**
```
Search for injection vectors in .md files in "[TARGET_DIR]". Use search_files with these regex patterns on *.md files, one at a time:
1. `<(iframe|embed|object|link|meta|form|input|textarea|button)[\s>]`
2. `\[.*?\]\(data:` then `\[.*?\]\(javascript:` then `\[.*?\]\(vbscript:`
3. `(?i)(ignore\s+(all\s+)?previous\s+instructions|you\s+are\s+now|forget\s+(all\s+)?previous|system\s*:\s*you\s+are|disregard\s+(all\s+)?prior|override\s+(all\s+)?instructions|new\s+instructions?:|IMPORTANT:.*ignore|do\s+not\s+follow)`
4. `(?i)(\[INST\]|\[\/INST\]|<\|im_start\|>|<\|im_end\|>|<\|system\|>|<\|user\|>|<\|assistant\|>|Human:|Assistant:|###\s*System\s*Prompt|BEGIN\s+HIDDEN|END\s+HIDDEN)`
5. `(curl\s+|wget\s+|bash\s+-c|sh\s+-c|powershell|cmd\.exe|/bin/sh|/bin/bash|rm\s+-rf|chmod\s+777|sudo\s+)`
6. `(https?://[^\s)>\]]*\.(exe|bat|cmd|ps1|sh|msi|dll|vbs|wsf|hta|scr))`
7. `(?i)(steganograph|obfusc|malware|payload|exploit|backdoor|trojan|keylog|ransom|phish)`
Report all findings per pattern.
```

---

## Phase 3: Sample Review

If **any** patterns matched in Phase 2, read the flagged files to:
1. Confirm the match is a true positive (not just a URL or benign text)
2. Assess severity of the injection
3. Identify the exact location and content

If **zero** patterns matched, skip to Phase 4.

---

## Phase 4: Report Findings

### Output Format

```markdown
# Markdown Injection Scan Report — [TARGET_DIR]

## Summary
- **Files scanned:** [count]
- **Patterns checked:** 18
- **Threats found:** [count]
- **Verdict:** CLEAN | LOW RISK | MEDIUM RISK | HIGH RISK

## Results Matrix

| # | Category | Pattern | Matches | Severity |
|---|----------|---------|---------|----------|
| 1 | Script tags | <script> | 0 | — |
| ... | ... | ... | ... | ... |

## Detailed Findings (if any)

| Severity | Category | File:Line | Content | Remediation |
|----------|----------|-----------|---------|-------------|
| P0/P1/P2/P3 | ... | ... | ... | ... |

## Sample File Review
- Files reviewed: [list]
- Structure: [description]
- Suspicious content: [none / details]
```

### Severity Guide
- **P0 Critical**: Active script tags, eval(), javascript: protocol in links, command injection
- **P1 High**: Prompt injection, SVG injection, data URI injection, HTML event handlers
- **P2 Medium**: Base64 payloads, suspicious URLs, obfuscated content
- **P3 Low/Info**: Malware keywords in text, hidden HTML elements

---

## Phase 5: Save Report

Ask user permission before saving:
> "May I write the report to `docs/security/markdown-injection-scan-{YYYY-MM-DD}.md`?"

---

## Protocol

- **Question**: Reads target directory from argument
- **Options**: Skip — proceed directly if directory is provided
- **Decision**: Run all 18 patterns via 3 parallel subagents
- **Draft**: Results matrix shown in conversation before saving
- **Approval**: Ask before writing report file

## Related Skills

- `security-audit` — comprehensive OWASP/infrastructure security audit for codebases
- `code-review` — code-level review with security considerations
- `guard` — freeze check before deploying security fixes
