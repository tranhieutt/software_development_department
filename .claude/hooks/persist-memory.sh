#!/bin/bash
# Claude Code UserPromptSubmit hook: Persist Tier 2 memory from explicit markers
# Implements .claude/docs/memory-write-schema.md — deterministic, no LLM.
#
# Input:  { "session_id": "...", "prompt": "...", "cwd": "..." }
# Exit 0: always (fail-open per Rule 9 — never blocks user)
#
# Delegates pattern matching + file append to Node (UTF-8 + regex safety).

set -u
_HOOK_ERR_LOG="production/session-logs/hook-errors.log"
mkdir -p "$(dirname "$_HOOK_ERR_LOG")" 2>/dev/null
exec 2>>"$_HOOK_ERR_LOG"  # redirect stderr to log file instead of /dev/null

INPUT=$(cat)

# ─── Require node (hook is no-op without it) ─────────────────────────────────
if ! command -v node >/dev/null 2>&1; then
    exit 0
fi

# Pass payload via env to avoid arg-escaping issues
PERSIST_INPUT="$INPUT" node - <<'NODE_SCRIPT'
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const MEMORY_DIR = '.claude/memory';
const ERR_LOG = 'production/session-logs/memory-write-errors.log';
const LEDGER_HELPER = 'scripts/ledger-append.sh';

function logError(msg) {
    try {
        fs.mkdirSync(path.dirname(ERR_LOG), { recursive: true });
        fs.appendFileSync(ERR_LOG, `${new Date().toISOString()} ${msg}\n`);
    } catch {}
}

let prompt = '';
try {
    const raw = process.env.PERSIST_INPUT || '';
    const obj = JSON.parse(raw);
    prompt = (obj.prompt || '').trim();
} catch (e) { logError('parse-input: ' + e.message); process.exit(0); }

if (!prompt || prompt.length < 15) process.exit(0);

// ─── Marker table (per memory-write-schema.md) ──────────────────────────────
// Each marker: regex (case-insensitive, anchored appropriately), target file, type.
// First match wins.
const MARKERS = [
    // Explicit label markers (strongest signal)
    { re: /\bfeedback:\s*(.+)/i,              file: 'feedback_rules.md',          type: 'feedback' },
    { re: /\bdecision:\s*(.+)/i,              file: 'project_tech_decisions.md',  type: 'project'  },
    { re: /\bref:\s*(.+)/i,                   file: 'reference_links.md',         type: 'reference'},
    { re: /\bsee also:\s*(.+)/i,              file: 'reference_links.md',         type: 'reference'},
    { re: /\bquyết định:\s*(.+)/i,            file: 'project_tech_decisions.md',  type: 'project'  },

    // Imperative English (sentence-start feel — allow leading word boundary)
    { re: /(?:^|[.!?\n]\s*)(don'?t\s+.+?)(?:[.!?\n]|$)/i,      file: 'feedback_rules.md', type: 'feedback' },
    { re: /(?:^|[.!?\n]\s*)(stop doing\s+.+?)(?:[.!?\n]|$)/i,  file: 'feedback_rules.md', type: 'feedback' },
    { re: /(?:^|[.!?\n]\s*)(never\s+.+?)(?:[.!?\n]|$)/i,       file: 'feedback_rules.md', type: 'feedback' },
    { re: /(?:^|[.!?\n]\s*)(from now on[,\s]+.+?)(?:[.!?\n]|$)/i, file: 'feedback_rules.md', type: 'feedback' },

    // Vietnamese feedback
    { re: /(?:^|[.!?\n]\s*)(từ giờ[,\s]+.+?)(?:[.!?\n]|$)/i,   file: 'feedback_rules.md', type: 'feedback' },
    { re: /(?:^|[.!?\n]\s*)(đừng\s+.+?)(?:[.!?\n]|$)/i,        file: 'feedback_rules.md', type: 'feedback' },

    // Project/tech decisions
    { re: /\bwe (?:chose|adopted|decided)\s+(.+?)(?:[.!?\n]|$)/i, file: 'project_tech_decisions.md', type: 'project' },
    { re: /\bchọn dùng\s+(.+?)(?:[.!?\n]|$)/i,                    file: 'project_tech_decisions.md', type: 'project' },

    // User profile
    { re: /\bi (?:prefer|use|am a)\s+(.+?)(?:[.!?\n]|$)/i, file: 'user_role.md', type: 'user' },
    { re: /\btôi (?:là|dùng|thích)\s+(.+?)(?:[.!?\n]|$)/i, file: 'user_role.md', type: 'user' },
];

// ─── Find first match ────────────────────────────────────────────────────────
let match = null;
for (const m of MARKERS) {
    const r = prompt.match(m.re);
    if (r) {
        // Prefer capture group if present, else full match
        const body = (r[1] || r[0]).trim().replace(/[.!?]+$/, '').trim();
        if (body.length >= 10 && body.length <= 400) {
            match = { ...m, body, trigger: r[0].trim().slice(0, 80) };
            break;
        }
    }
}

if (!match) process.exit(0);

// ─── Target file path & dedup check ──────────────────────────────────────────
const targetPath = path.join(MEMORY_DIR, match.file);

try {
    if (!fs.existsSync(targetPath)) {
        // Create with minimal frontmatter if missing
        const fm = [
            '---',
            `name: ${match.file.replace('.md','')}`,
            `description: Auto-populated by persist-memory.sh hook`,
            `type: ${match.type}`,
            '---',
            ''
        ].join('\n');
        fs.writeFileSync(targetPath, fm, 'utf8');
    }

    const existing = fs.readFileSync(targetPath, 'utf8');
    // Dedup: case-insensitive exact substring check
    if (existing.toLowerCase().includes(match.body.toLowerCase())) {
        process.exit(0);
    }

    // ─── Build append block ──────────────────────────────────────────────────
    const today = new Date().toISOString().slice(0, 10);
    const autoTitle = match.body.replace(/[.,;:!?]/g, '').slice(0, 60).trim();
    const block = [
        '',
        `## ${today} — ${autoTitle}`,
        `**Trigger:** "${match.trigger}"`,
        `**Source:** user-prompt`,
        match.body,
        ''
    ].join('\n');

    fs.appendFileSync(targetPath, block);

    // ─── Size warning (300 lines) ────────────────────────────────────────────
    const lineCount = fs.readFileSync(targetPath, 'utf8').split('\n').length;
    const warnMarker = '<!-- size-warning: file is >300 lines';
    if (lineCount > 300 && !existing.includes(warnMarker)) {
        fs.appendFileSync(targetPath, `\n${warnMarker}, consider /dream to consolidate -->\n`);
    }

    // ─── Ledger tie-in for High-signal entries ───────────────────────────────
    const highSignalRe = /\b(security|migrate|break|prod|critical)\b/i;
    const isHigh = (match.type === 'feedback' || match.type === 'project') && highSignalRe.test(match.body);

    if (isHigh && fs.existsSync(LEDGER_HELPER)) {
        const sha = crypto.createHash('sha1').update(match.body).digest('hex').slice(0, 8);
        const { spawnSync } = require('child_process');
        spawnSync('bash', [
            LEDGER_HELPER,
            '--agent',     'persist-memory',
            '--task-id',   `mem-${sha}`,
            '--request',   `Auto-persist ${match.type} insight`,
            '--reasoning', 'High-signal marker matched per memory-write-schema',
            '--choice',    match.body.slice(0, 60),
            '--outcome',   'pass',
            '--risk',      'High'
        ], { stdio: 'ignore' });
    }
} catch (e) {
    logError(`write-fail: ${match && match.file}: ${e.message}`);
}

process.exit(0);
NODE_SCRIPT

exit 0
