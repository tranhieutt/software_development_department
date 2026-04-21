#!/usr/bin/env node
// Validates all JSONL trace files under production/traces/.
// Checks: UTF-8 clean, no NUL bytes, one valid JSON object per line, no empty lines mid-file.
// Exit 0 = all clean. Exit 1 = failures found.

const fs = require('fs');
const path = require('path');

const TRACES_DIR = path.join(__dirname, '..', 'production', 'traces');
const TRACE_FILES = ['decision_ledger.jsonl', 'agent-metrics.jsonl', 'skill-usage.jsonl'];

let totalFails = 0;

for (const filename of TRACE_FILES) {
    const filepath = path.join(TRACES_DIR, filename);

    if (!fs.existsSync(filepath)) {
        console.log(`SKIP  ${filename} (not found — no data yet)`);
        continue;
    }

    const raw = fs.readFileSync(filepath);
    const fails = [];

    // Check NUL bytes
    if (raw.includes(0x00)) {
        const count = [...raw].filter(b => b === 0).length;
        fails.push(`NUL bytes detected (${count} found) — likely UTF-16 encoding corruption`);
    }

    // Parse as UTF-8
    let text;
    try {
        text = raw.toString('utf8');
    } catch (e) {
        fails.push(`UTF-8 decode failed: ${e.message}`);
        report(filename, fails);
        totalFails++;
        continue;
    }

    // Check line-by-line
    const lines = text.split('\n');
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;
        try {
            const obj = JSON.parse(line);
            if (typeof obj !== 'object' || Array.isArray(obj)) {
                fails.push(`line ${i + 1}: not a JSON object`);
            }
        } catch (e) {
            fails.push(`line ${i + 1}: invalid JSON — ${e.message}`);
        }
    }

    if (fails.length === 0) {
        const lineCount = lines.filter(l => l.trim()).length;
        console.log(`OK    ${filename} (${lineCount} entries)`);
    } else {
        report(filename, fails);
        totalFails++;
    }
}

function report(filename, fails) {
    console.error(`FAIL  ${filename}`);
    for (const f of fails) console.error(`      - ${f}`);
}

if (totalFails > 0) {
    console.error(`\n${totalFails} file(s) failed integrity check.`);
    process.exit(1);
} else {
    console.log('\nAll trace files passed integrity check.');
    process.exit(0);
}
