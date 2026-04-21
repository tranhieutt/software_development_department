#!/bin/bash
# Claude Code PostToolUse hook: Extract decisions from agent tool output → Tier 2 memory
# Triggers on: Write, Edit, Bash (non-trivial outputs)
# Exit 0: always (fail-open per Rule 9)
#
# Input: { "tool_name": "...", "tool_input": {...}, "tool_response": {...} }

set -u
exec 2>/dev/null

INPUT=$(cat)

if ! command -v node >/dev/null 2>&1; then
    exit 0
fi

EXTRACT_INPUT="$INPUT" node - <<'NODE_SCRIPT'
const fs = require('fs');
const path = require('path');

const MEMORY_DIR = '.claude/memory';
const ERR_LOG = 'production/session-logs/memory-write-errors.log';

function logError(msg) {
    try {
        fs.mkdirSync(path.dirname(ERR_LOG), { recursive: true });
        fs.appendFileSync(ERR_LOG, `${new Date().toISOString()} extract-decisions: ${msg}\n`);
    } catch {}
}

// ─── Parse input ─────────────────────────────────────────────────────────────
let toolName = '', toolInput = {}, toolResponse = {};
try {
    const raw = process.env.EXTRACT_INPUT || '';
    const obj = JSON.parse(raw);
    toolName     = (obj.tool_name || '').toLowerCase();
    toolInput    = obj.tool_input || {};
    toolResponse = obj.tool_response || {};
} catch (e) { logError('parse: ' + e.message); process.exit(0); }

// Only process Write and Edit (file-level decisions with clear signal)
if (!['write', 'edit'].includes(toolName)) process.exit(0);

// ─── Extract content from file writes/edits ───────────────────────────────
const filePath = toolInput.file_path || toolInput.path || '';
const content  = toolInput.content || toolInput.new_string || '';

if (!content || content.length < 30) process.exit(0);

// Skip binary, generated, or log files
const skipPatterns = [
    /\.(png|jpg|gif|ico|woff|ttf|map|lock)$/i,
    /session-logs\//,
    /archive\//,
    /portal\.html$/,
    /decision_ledger\.jsonl$/,
    /agent-metrics\.jsonl$/
];
if (skipPatterns.some(p => p.test(filePath))) process.exit(0);

// ─── Decision markers in written content ─────────────────────────────────────
// Look for explicit decision markers Claude writes into files
const DECISION_PATTERNS = [
    // ADR-style decisions in docs
    { re: /##\s+Decision\s*\n+(.+?)(?:\n#|\n\n|$)/si,       file: 'project_tech_decisions.md', type: 'project'  },
    { re: /\*\*Decision:\*\*\s*(.+?)(?:\n|$)/i,              file: 'project_tech_decisions.md', type: 'project'  },
    // Rule downgrade / upgrade markers
    { re: />\s+\*\*Note[^:]*:\*\*\s*Downgraded\s+(.+?)(?:\n|$)/i, file: 'project_tech_decisions.md', type: 'project' },
    // Annotation-style gotchas written to source files
    { re: /\/\/\s+NOTE:\s+(.{20,200})/,                      file: 'annotations.md',            type: 'project'  },
    { re: /\/\/\s+GOTCHA:\s+(.{20,200})/,                    file: 'annotations.md',            type: 'project'  },
    { re: /\/\/\s+WORKAROUND:\s+(.{20,200})/,                file: 'annotations.md',            type: 'project'  },
    // Feedback markers in shell/config
    { re: /^#\s+FEEDBACK:\s+(.{20,200})/m,                   file: 'feedback_rules.md',         type: 'feedback' },
];

let match = null;
for (const p of DECISION_PATTERNS) {
    const r = content.match(p.re);
    if (r) {
        const body = (r[1] || '').trim().replace(/[*_`]/g, '').slice(0, 300);
        if (body.length >= 15) {
            match = { ...p, body };
            break;
        }
    }
}

if (!match) process.exit(0);

// ─── Write to target Tier 2 file ──────────────────────────────────────────────
const targetPath = path.join(MEMORY_DIR, match.file);
const today = new Date().toISOString().slice(0, 10);
const shortFile = path.basename(filePath);

try {
    if (!fs.existsSync(targetPath)) process.exit(0); // never create, only append

    const existing = fs.readFileSync(targetPath, 'utf8');
    if (existing.toLowerCase().includes(match.body.toLowerCase().slice(0, 40))) {
        process.exit(0); // dedup
    }

    const block = [
        '',
        `## ${today} — From ${shortFile}`,
        `**Source:** PostToolUse/${toolName} on \`${shortFile}\``,
        match.body,
        ''
    ].join('\n');

    fs.appendFileSync(targetPath, block);
} catch (e) {
    logError(`write-fail ${match.file}: ${e.message}`);
}

process.exit(0);
NODE_SCRIPT

exit 0
