const path = require('path');
const { runAudit } = require('../../scripts/coordination-audit.js');
const malformedFixture = path.join(__dirname, '../fixtures/coordination-audit/malformed');

let passed = 0;
let failed = 0;

function test(name, fn) {
    try {
        fn();
        console.log(`PASS: ${name}`);
        passed++;
    } catch (error) {
        console.error(`FAIL: ${name}`);
        console.error(`      ${error.message}`);
        failed++;
    }
}

test('repo_audit_passes_current_scope', () => {
    const result = runAudit({
        root: path.join(__dirname, '../..'),
        format: 'text'
    });
    if (result.exitCode !== 0) {
        throw new Error(`Expected exit 0, got ${result.exitCode}`);
    }
    if (!result.ok) {
        throw new Error(`Expected ok=true, got findings: ${JSON.stringify(result.findings, null, 2)}`);
    }
});

test('malformed_fixture_fails_and_reports_findings', () => {
    const result = runAudit({
        root: malformedFixture,
        format: 'text'
    });
    if (result.exitCode !== 1) {
        throw new Error(`Expected exit 1, got ${result.exitCode}`);
    }
    const codes = result.findings.map(item => item.code);
    if (!codes.includes('stable_contract_missing_spec')) {
        throw new Error(`Expected stable contract finding, got: ${codes.join(', ')}`);
    }
    if (!codes.includes('handoff_missing_ledger_entry')) {
        throw new Error(`Expected handoff ledger finding, got: ${codes.join(', ')}`);
    }
});

console.log(`\nResults: ${passed} passed, ${failed} failed`);
if (failed > 0) {
    process.exit(1);
}
