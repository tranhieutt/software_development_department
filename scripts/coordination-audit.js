#!/usr/bin/env node
/**
 * coordination-audit.js
 *
 * Manual, non-blocking coordination drift audit for Tier 2 artifacts.
 *
 * This script is intentionally report-only. It does not modify runtime files,
 * does not gate CI, and should be run manually or on a lightweight schedule
 * only after Tier 2 artifacts have some real adoption.
 *
 * Current checks:
 * 1. Stable/implemented contracts must link a feature spec.
 * 2. Implemented contracts must reflect into docs/technical/API.md unless they
 *    explicitly say the API reference is not applicable.
 * 3. Medium/High risk formal handoff files must have a matching ledger entry.
 */

const fs = require('fs');
const path = require('path');

function runAudit(options = {}) {
    const root = options.root || path.resolve(__dirname, '..');
    const format = options.format || 'text';
    const contractsDir = path.join(root, 'design', 'contracts');
    const apiPath = path.join(root, 'docs', 'technical', 'API.md');
    const handoffsDir = path.join(root, '.tasks', 'handoffs');
    const ledgerPath = path.join(root, 'production', 'traces', 'decision_ledger.jsonl');

    const findings = [];
    const scanned = {
        contracts: 0,
        handoffs: 0
    };

    const apiContent = readTextIfExists(apiPath);
    const makeRel = filePath => path.relative(root, filePath).replace(/\\/g, '/');
    const ledgerEntries = readJsonlIfExists(ledgerPath, findings, makeRel);

    auditContracts();
    auditHandoffs();

    return emitResults();

    function auditContracts() {
        if (!fs.existsSync(contractsDir)) return;

        const files = fs.readdirSync(contractsDir)
            .filter(name => name.endsWith('.md'))
            .filter(name => !['README.md', 'contract-template.md'].includes(name));

        for (const filename of files) {
            const fullPath = path.join(contractsDir, filename);
            const content = fs.readFileSync(fullPath, 'utf8');
            scanned.contracts++;

            const status = matchField(content, '**Status:**');
            const featureSpec = matchSourceLink(content, 'Feature spec');
            const implementedApiRef = matchSourceLink(content, 'Implemented API reference');

            if (!status) {
                findings.push(finding('error', makeRel(fullPath), 'missing_status', 'Contract is missing `**Status:**`.'));
                continue;
            }

            const normalizedStatus = status.toLowerCase();
            const requiresSpec = normalizedStatus === 'stable' || normalizedStatus === 'implemented';

            if (requiresSpec && (!featureSpec || featureSpec === 'none')) {
                findings.push(finding(
                    'error',
                    makeRel(fullPath),
                    'stable_contract_missing_spec',
                    `Contract status is \`${normalizedStatus}\` but \`Feature spec\` is missing or \`none\`.`
                ));
            }

            if (normalizedStatus === 'implemented') {
                if (!implementedApiRef || implementedApiRef === 'not applicable') {
                    findings.push(finding(
                        'error',
                        makeRel(fullPath),
                        'implemented_contract_missing_api_ref',
                        'Implemented contract must point to `docs/technical/API.md` or another concrete API reference.'
                    ));
                    continue;
                }

                if (!apiContent) {
                    findings.push(finding(
                        'error',
                        makeRel(fullPath),
                        'api_reference_missing',
                        'Contract claims an implemented API reference, but `docs/technical/API.md` was not found.'
                    ));
                    continue;
                }

                const contractRefSignals = [
                    filename,
                    `design/contracts/${filename}`,
                    `design\\contracts\\${filename}`
                ];
                const reflected = contractRefSignals.some(signal => apiContent.includes(signal));

                if (!reflected) {
                    findings.push(finding(
                        'error',
                        makeRel(fullPath),
                        'implemented_contract_not_reflected_in_api',
                        `Contract status is \`implemented\` but API reference does not mention \`${filename}\`.`
                    ));
                }
            }
        }
    }

    function auditHandoffs() {
        if (!fs.existsSync(handoffsDir)) return;

        const files = fs.readdirSync(handoffsDir).filter(name => name.endsWith('.json'));
        for (const filename of files) {
            const fullPath = path.join(handoffsDir, filename);
            const raw = readTextIfExists(fullPath);
            if (!raw) continue;
            scanned.handoffs++;

            let handoff;
            try {
                handoff = JSON.parse(raw);
            } catch (error) {
                findings.push(finding('error', makeRel(fullPath), 'invalid_handoff_json', `Invalid JSON: ${error.message}`));
                continue;
            }

            const risk = String(handoff.risk_tier || '').toLowerCase();
            if (!['medium', 'high'].includes(risk)) continue;

            const matched = ledgerEntries.some(entry => {
                if (!entry || typeof entry !== 'object') return false;
                if (String(entry.request || '') !== `Handoff to ${handoff.to}`) return false;
                if (String(entry.agent_id || '') !== String(handoff.from || '')) return false;
                if (String(entry.task_id || '') !== String(handoff.task_id || '')) return false;
                return String(entry.risk_tier || '').toLowerCase() === risk;
            });

            if (!matched) {
                findings.push(finding(
                    'error',
                    makeRel(fullPath),
                    'handoff_missing_ledger_entry',
                    `Formal ${risk} handoff has no matching ledger entry for from=${handoff.from}, to=${handoff.to}, task=${handoff.task_id}.`
                ));
            }
        }
    }

    function emitResults() {
        const summary = {
            root,
            scanned,
            findings: findings.length
        };

        if (format === 'json') {
            console.log(JSON.stringify({ summary, findings }, null, 2));
        } else {
            console.log('Coordination Audit');
            console.log(`Root: ${root}`);
            console.log(`Contracts scanned: ${scanned.contracts}`);
            console.log(`Formal handoffs scanned: ${scanned.handoffs}`);

            if (findings.length === 0) {
                console.log('Result: PASS (no coordination drift findings in current audit scope)');
            } else {
                console.log(`Result: FAIL (${findings.length} finding${findings.length === 1 ? '' : 's'})`);
                for (const item of findings) {
                    console.log(`- [${item.severity}] ${item.code} :: ${item.path}`);
                    console.log(`  ${item.message}`);
                }
            }
        }

        return {
            ok: findings.length === 0,
            exitCode: findings.length > 0 ? 1 : 0,
            summary,
            findings
        };
    }
}

function matchField(content, label) {
    const escaped = escapeRegex(label);
    const regex = new RegExp(`${escaped}\\s*([^\\r\\n]+)`);
    const match = content.match(regex);
    return match ? match[1].trim() : null;
}

function matchSourceLink(content, label) {
    const escaped = escapeRegex(label);
    const regex = new RegExp(`-\\s*${escaped}:\\s*\`([^\\r\\n\`]+)\``, 'i');
    const match = content.match(regex);
    return match ? match[1].trim() : null;
}

function readTextIfExists(filePath) {
    if (!fs.existsSync(filePath)) return null;
    return fs.readFileSync(filePath, 'utf8');
}

function readJsonlIfExists(filePath, findingsList, makeRel) {
    if (!fs.existsSync(filePath)) return [];
    const lines = fs.readFileSync(filePath, 'utf8')
        .split(/\r?\n/)
        .map(line => line.trim())
        .filter(Boolean);

    const parsed = [];
    for (let i = 0; i < lines.length; i++) {
        try {
            parsed.push(JSON.parse(lines[i]));
        } catch (error) {
            findingsList.push(finding(
                'error',
                makeRel(filePath),
                'invalid_ledger_jsonl',
                `Ledger line ${i + 1} is invalid JSON: ${error.message}`
            ));
        }
    }
    return parsed;
}

function finding(severity, filePath, code, message) {
    return { severity, path: filePath, code, message };
}

function escapeRegex(text) {
    return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function printHelp() {
    console.log(`coordination-audit.js

Usage:
  node scripts/coordination-audit.js
  node scripts/coordination-audit.js --format json
  node scripts/coordination-audit.js --fixtures tests/fixtures/coordination-audit/malformed

Options:
  --fixtures <path>  Read from a fixture tree instead of the repo root
  --format <text|json>
  --help
`);
}

function parseCliArgs(args) {
    let root = path.resolve(__dirname, '..');
    let format = 'text';
    let help = false;

    for (let i = 0; i < args.length; i++) {
        const arg = args[i];
        if (arg === '--fixtures' && args[i + 1]) {
            root = path.resolve(args[++i]);
        } else if (arg === '--format' && args[i + 1]) {
            format = args[++i];
        } else if (arg === '--help' || arg === '-h') {
            help = true;
        }
    }

    return { root, format, help };
}

if (require.main === module) {
    const options = parseCliArgs(process.argv.slice(2));
    if (options.help) {
        printHelp();
        process.exit(0);
    }
    const result = runAudit(options);
    process.exit(result.exitCode);
}

module.exports = {
    runAudit,
    parseCliArgs
};
