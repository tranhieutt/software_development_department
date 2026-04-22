#!/usr/bin/env node
// agent-health.js — Per-agent circuit breaker status report
// Reads .claude/memory/circuit-state.json (schema v2) and prints a table.
//
// Usage:
//   node scripts/agent-health.js           # compact summary
//   node scripts/agent-health.js --full    # full table
//   node scripts/agent-health.js --json    # raw JSON output
//   node scripts/agent-health.js --open    # show only OPEN/HALF_OPEN agents

const fs = require('fs');
const path = require('path');

const CIRCUIT_FILE = path.join(process.cwd(), '.claude/memory/circuit-state.json');
const LEDGER_FILE  = path.join(process.cwd(), 'production/traces/decision_ledger.jsonl');

const args = process.argv.slice(2);
const FLAG_JSON = args.includes('--json');
const FLAG_OPEN = args.includes('--open');
const FLAG_FULL = args.includes('--full');
const FLAG_COMPACT = args.includes('--compact') || (!FLAG_JSON && !FLAG_FULL);

// ─── Load circuit state ───────────────────────────────────────────────────────
if (!fs.existsSync(CIRCUIT_FILE)) {
    console.error('[agent-health] ERROR: circuit-state.json not found at', CIRCUIT_FILE);
    process.exit(1);
}

let circuit;
try {
    circuit = JSON.parse(fs.readFileSync(CIRCUIT_FILE, 'utf8'));
} catch (e) {
    console.error('[agent-health] ERROR: failed to parse circuit-state.json:', e.message);
    process.exit(1);
}

if (circuit._version !== 2 || !circuit.agents) {
    console.error('[agent-health] ERROR: unsupported schema version. Expected v2 with "agents" key.');
    process.exit(1);
}

// ─── Load last transition from ledger (optional) ──────────────────────────────
const lastTransition = {}; // agent → { ts, choice }
if (fs.existsSync(LEDGER_FILE)) {
    const lines = fs.readFileSync(LEDGER_FILE, 'utf8').split('\n').filter(Boolean);
    for (const line of lines) {
        try {
            const entry = JSON.parse(line);
            if (entry.task_id && entry.task_id.startsWith('circuit-transition-')) {
                lastTransition[entry.agent_id] = { ts: entry.ts, choice: entry.choice };
            }
        } catch (_) {}
    }
}

// ─── Format helpers ───────────────────────────────────────────────────────────
const STATE_ICON = { CLOSED: '✅', HALF_OPEN: '⚠️ ', OPEN: '🔴' };
const PAD = (s, n) => String(s ?? '').slice(0, n).padEnd(n);

function relativeTime(isoTs) {
    if (!isoTs || isoTs === 'null') return '—';
    const diff = Math.floor((Date.now() - new Date(isoTs).getTime()) / 1000);
    if (diff < 60)   return `${diff}s ago`;
    if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
    return `${Math.floor(diff / 3600)}h ago`;
}

// ─── Filter ───────────────────────────────────────────────────────────────────
const agents = Object.entries(circuit.agents)
    .filter(([, v]) => !FLAG_OPEN || v.state !== 'CLOSED')
    .sort(([, a], [, b]) => {
        const order = { OPEN: 0, HALF_OPEN: 1, CLOSED: 2 };
        return (order[a.state] ?? 3) - (order[b.state] ?? 3);
    });

const allAgents = Object.entries(circuit.agents);
const allOpen = allAgents.filter(([, v]) => v.state === 'OPEN');
const allHalfOpen = allAgents.filter(([, v]) => v.state === 'HALF_OPEN');
const allClosed = allAgents.filter(([, v]) => v.state === 'CLOSED');

// ─── JSON output ──────────────────────────────────────────────────────────────
if (FLAG_JSON) {
    const out = agents.map(([name, v]) => ({
        agent: name,
        state: v.state,
        fail_count: v.fail_count,
        fallback: v.fallback,
        open_reason: v.open_reason,
        last_fail: v.last_fail_ts,
        last_success: v.last_success_ts,
        last_transition: lastTransition[name] ?? null,
    }));
    console.log(JSON.stringify(out, null, 2));
    process.exit(0);
}

if (FLAG_COMPACT) {
    const visibleOpen = agents.filter(([, v]) => v.state === 'OPEN');
    const visibleHalfOpen = agents.filter(([, v]) => v.state === 'HALF_OPEN');
    const problemAgents = [...visibleOpen, ...visibleHalfOpen].slice(0, 5);

    console.log(`SDD Agent Health: ${allAgents.length} tracked | CLOSED ${allClosed.length} | HALF_OPEN ${allHalfOpen.length} | OPEN ${allOpen.length}`);

    if (problemAgents.length > 0) {
        console.log('');
        console.log('Critical:');
        for (const [name, v] of problemAgents.slice(0, 3)) {
            const fallback = v.fallback || 'none';
            const reason = v.open_reason ? ` - ${v.open_reason}` : '';
            console.log(`- ${name}: ${v.state}, fail_count=${v.fail_count ?? 0}, fallback=${fallback}${reason}`);
        }
        if (problemAgents.length > 3) {
            console.log(`- ${problemAgents.length - 3} more non-closed agent(s).`);
        }
    } else {
        console.log('');
        console.log('Critical: none');
    }

    const staleFailures = agents
        .filter(([, v]) => v.state === 'CLOSED' && (v.fail_count ?? 0) > 0)
        .slice(0, 5);
    if (staleFailures.length > 0) {
        console.log('');
        console.log('Warnings:');
        for (const [name, v] of staleFailures) {
            console.log(`- ${name}: CLOSED with fail_count=${v.fail_count ?? 0}; last_fail=${relativeTime(v.last_fail_ts)}`);
        }
    }

    console.log('');
    console.log('Next:');
    if (allOpen.length > 0) {
        console.log('1. Route OPEN agent tasks to their fallback agents.');
        console.log('2. Inspect circuit transition history before resetting any agent.');
        console.log('3. Run: node scripts/agent-health.js --full');
    } else if (allHalfOpen.length > 0) {
        console.log('1. Keep HALF_OPEN agents on low-risk validation tasks.');
        console.log('2. Watch the next transition in production/traces/decision_ledger.jsonl.');
        console.log('3. Run: node scripts/agent-health.js --full');
    } else {
        console.log('1. No circuit action required.');
        console.log('2. Run --full only when investigating a specific agent.');
    }
    process.exit(0);
}

// ─── Table output ─────────────────────────────────────────────────────────────
const NOW_ISO = new Date().toISOString();
console.log(`\n╔═══════════════════════════════════════════════════════════════════════╗`);
console.log(`║  SDD Agent Health — Circuit Breaker Status                           ║`);
console.log(`║  ${NOW_ISO.slice(0, 19).replace('T', ' ')} UTC${' '.repeat(41)}║`);
console.log(`╠══════════════════════╤════════════╤══════╤══════════════╤════════════╣`);
console.log(`║ Agent                │ State      │ Fail │ Last Fail    │ Fallback   ║`);
console.log(`╠══════════════════════╪════════════╪══════╪══════════════╪════════════╣`);

if (agents.length === 0) {
    console.log(`║  (no agents match filter)                                            ║`);
} else {
    for (const [name, v] of agents) {
        const icon  = STATE_ICON[v.state] ?? '❓';
        const state = `${icon} ${v.state}`;
        const fails = String(v.fail_count ?? 0);
        const lastFail = relativeTime(v.last_fail_ts);
        const ABBREV = { 'fullstack-developer': 'fullstack', 'backend-developer': 'backend', 'frontend-developer': 'frontend' };
        const fallback = v.fallback ? (ABBREV[v.fallback] ?? v.fallback) : '—';
        console.log(
            `║ ${PAD(name, 20)} │ ${PAD(state, 10)} │ ${PAD(fails, 4)} │ ${PAD(lastFail, 12)} │ ${PAD(fallback, 10)} ║`
        );

        // Show open_reason indented if not CLOSED
        if (v.state !== 'CLOSED' && v.open_reason) {
            console.log(`║   ↳ Reason: ${PAD(v.open_reason, 57)} ║`);
        }

        // Show last ledger transition if exists
        const lt = lastTransition[name];
        if (lt) {
            const when = relativeTime(lt.ts);
            const label = `${lt.choice} (${when})`;
            console.log(`║   ↳ Last transition: ${PAD(label, 48)} ║`);
        }
    }
}

console.log(`╚══════════════════════╧════════════╧══════╧══════════════╧════════════╝`);

// Summary line
const openCount     = agents.filter(([, v]) => v.state === 'OPEN').length;
const halfOpenCount = agents.filter(([, v]) => v.state === 'HALF_OPEN').length;
const closedCount   = agents.filter(([, v]) => v.state === 'CLOSED').length;

console.log(`\n  Agents tracked: ${Object.keys(circuit.agents).length}  |  ✅ CLOSED: ${closedCount}  |  ⚠️  HALF_OPEN: ${halfOpenCount}  |  🔴 OPEN: ${openCount}\n`);

if (openCount > 0) {
    console.log(`  ⚠️  Action required: ${openCount} agent(s) are OPEN. Route tasks to their fallback agents.\n`);
}
