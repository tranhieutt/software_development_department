#!/usr/bin/env node
// skill-usage-report.js — Skill usage analysis + cull candidates
// Reads production/traces/skill-usage.jsonl + .claude/skills/ directory.
//
// Usage:
//   node scripts/skill-usage-report.js              # compact summary
//   node scripts/skill-usage-report.js --full       # full report (table + cull list)
//   node scripts/skill-usage-report.js --json       # raw JSON
//   node scripts/skill-usage-report.js --cull-only  # cull candidates only
//   node scripts/skill-usage-report.js --days 7     # limit to last N days (default: all)

const fs   = require('fs');
const path = require('path');

const USAGE_FILE  = path.join(process.cwd(), 'production/traces/skill-usage.jsonl');
const SKILLS_DIR  = path.join(process.cwd(), '.claude/skills');
const CULL_FILE   = path.join(process.cwd(), 'production/traces/skill-cull-candidates.md');

const args     = process.argv.slice(2);
const FLAG_JSON      = args.includes('--json');
const FLAG_CULL_ONLY = args.includes('--cull-only');
const FLAG_FULL      = args.includes('--full');
const FLAG_COMPACT   = args.includes('--compact') || (!FLAG_JSON && !FLAG_FULL && !FLAG_CULL_ONLY);
const daysIdx        = args.indexOf('--days');
const DAYS_LIMIT     = daysIdx !== -1 ? parseInt(args[daysIdx + 1], 10) : null;

// ─── Load all skills from disk ────────────────────────────────────────────────
const allSkills = fs.readdirSync(SKILLS_DIR)
    .filter(f => fs.statSync(path.join(SKILLS_DIR, f)).isDirectory())
    .sort();

// ─── Load usage data ──────────────────────────────────────────────────────────
const usageMap = {}; // skill → { count, sessions: Set, lastSeen, firstSeen }

if (fs.existsSync(USAGE_FILE)) {
    const cutoff = DAYS_LIMIT
        ? new Date(Date.now() - DAYS_LIMIT * 86400 * 1000)
        : null;

    const lines = fs.readFileSync(USAGE_FILE, 'utf8').split('\n').filter(Boolean);
    for (const line of lines) {
        try {
            const e = JSON.parse(line);
            const ts = new Date(e.timestamp);
            if (cutoff && ts < cutoff) continue;

            const sk = e.skill;
            if (!sk) continue;
            if (!usageMap[sk]) {
                usageMap[sk] = { count: 0, sessions: new Set(), lastSeen: null, firstSeen: null };
            }
            usageMap[sk].count++;
            usageMap[sk].sessions.add(e.session_id || 'unknown');
            if (!usageMap[sk].lastSeen  || ts > new Date(usageMap[sk].lastSeen))  usageMap[sk].lastSeen  = e.timestamp;
            if (!usageMap[sk].firstSeen || ts < new Date(usageMap[sk].firstSeen)) usageMap[sk].firstSeen = e.timestamp;
        } catch (_) {}
    }
}

// ─── Classify each skill ──────────────────────────────────────────────────────
// Categories:
//   used       — invoked at least once
//   never-used — on disk, no invocation record
//
// Cull candidates (subset of never-used):
//   - No SKILL.md metadata file → likely template/placeholder
//   - Name overlaps with another skill by >70% token similarity → duplicate

function tokenSimilarity(a, b) {
    const ta = new Set(a.split('-'));
    const tb = new Set(b.split('-'));
    const inter = [...ta].filter(t => tb.has(t)).length;
    return inter / Math.max(ta.size, tb.size);
}

// Domain clusters — skills in the same cluster overlap in purpose
const DOMAIN_CLUSTERS = [
    ['backend-patterns', 'backend-architect', 'fastapi-pro', 'nestjs-expert', 'springboot-patterns', 'django-patterns', 'dotnet-backend-patterns'],
    ['frontend-patterns', 'frontend-design', 'frontend-ui-dark-ts', 'senior-frontend', 'angular-best-practices', 'nextjs-patterns'],
    ['code-review', 'code-review-checklist', 'db-review', 'design-review', 'mobile-review'],
    ['test-driven-development', 'spec-driven-development'],
    ['planning-and-task-breakdown', 'sprint-plan', 'milestone-review', 'estimate'],
    ['team-backend', 'team-frontend', 'team-mobile', 'team-ui', 'team-feature', 'team-release'],
    ['docker-patterns', 'kubernetes-architect', 'devops-deploy', 'gitlab-ci-patterns', 'deployment-engineer', 'deployment-procedures'],
    ['ml-engineer', 'mlops-engineer', 'rag-engineer', 'llm-app-patterns'],
    ['shadcn', 'radix-ui-design-system', 'tailwind-patterns', 'design-system'],
    ['postgres-patterns', 'sql-optimization-patterns', 'nosql-expert', 'drizzle-orm-expert', 'prisma-expert', 'database-architect'],
    ['security-audit', 'backend-security-coder', 'frontend-security-coder'],
    ['map-systems', 'map-workflow'],
    ['save-state', 'resume-from'],
    ['freeze', 'unfreeze'],
    ['fork-join', 'orchestrate'],
];

function clusterOf(sk) {
    return DOMAIN_CLUSTERS.find(c => c.includes(sk));
}

const used      = [];
const neverUsed = [];
const cullCandidates = [];

for (const sk of allSkills) {
    const u = usageMap[sk];
    if (u && u.count > 0) {
        used.push({ skill: sk, count: u.count, sessions: u.sessions.size, lastSeen: u.lastSeen, firstSeen: u.firstSeen });
    } else {
        neverUsed.push(sk);

        // Cull heuristic 1: high token name similarity to another skill
        for (const other of allSkills) {
            if (other === sk) continue;
            if (tokenSimilarity(sk, other) >= 0.7) {
                const otherUsed = usageMap[other] && usageMap[other].count > 0;
                cullCandidates.push({
                    skill: sk,
                    reason: `name overlaps with '${other}'${otherUsed ? ' (other is used)' : ''}`,
                });
                break;
            }
        }
        if (cullCandidates.some(c => c.skill === sk)) continue;

        // Cull heuristic 2: in a domain cluster with 4+ members, all never-used
        const cluster = clusterOf(sk);
        if (cluster && cluster.length >= 4) {
            const clusterUsed = cluster.filter(s => usageMap[s] && usageMap[s].count > 0);
            if (clusterUsed.length === 0) {
                cullCandidates.push({
                    skill: sk,
                    reason: `in '${cluster[0]}' cluster (${cluster.length} skills, none used)`,
                });
            }
        }
    }
}

used.sort((a, b) => b.count - a.count);

// ─── JSON output ──────────────────────────────────────────────────────────────
if (FLAG_JSON) {
    console.log(JSON.stringify({ used, neverUsed, cullCandidates }, null, 2));
    process.exit(0);
}

const NOW_ISO = new Date().toISOString().slice(0, 19).replace('T', ' ');
const PAD = (s, n) => String(s ?? '').slice(0, n).padEnd(n);

function writeCullFile() {
    const cullLines = [
        `# Skill Cull Candidates`,
        ``,
        `> Generated: ${NOW_ISO} UTC | Total skills: ${allSkills.length} | Cull candidates: ${cullCandidates.length}`,
        `> **Do NOT delete** without usage data covering >=7 days. This list is heuristic only.`,
        ``,
        `## Criteria`,
        `- Missing \`SKILL.md\` metadata file (likely placeholder/template)`,
        `- Name overlaps >=70% token similarity with another skill`,
        ``,
        `## Candidates`,
        ``,
        `| Skill | Reason | Decision |`,
        `|---|---|---|`,
        ...cullCandidates.map(c => `| \`${c.skill}\` | ${c.reason} | pending |`),
        ``,
        `## Used Skills (safe - do not cull)`,
        ``,
        ...used.map(s => `- \`${s.skill}\` - ${s.count} call(s), ${s.sessions} session(s)`),
    ];

    fs.mkdirSync(path.dirname(CULL_FILE), { recursive: true });
    fs.writeFileSync(CULL_FILE, cullLines.join('\n') + '\n');
}

if (FLAG_COMPACT) {
    const periodNote = DAYS_LIMIT ? `last ${DAYS_LIMIT} days` : 'all time';
    const topUsed = used.slice(0, 5);
    const topCull = cullCandidates.slice(0, 10);

    writeCullFile();

    console.log(`SDD Skill Usage: ${allSkills.length} total | ${used.length} used | ${neverUsed.length} never-used | ${cullCandidates.length} cull candidates (${periodNote})`);

    console.log('');
    console.log('Top Used:');
    if (topUsed.length === 0) {
        console.log('- none recorded');
    } else {
        for (const s of topUsed) {
            const last = s.lastSeen ? s.lastSeen.slice(0, 10) : 'unknown';
            console.log(`- ${s.skill}: ${s.count} call(s), ${s.sessions} session(s), last=${last}`);
        }
    }

    console.log('');
    console.log('Warnings:');
    if (topCull.length === 0) {
        console.log('- no cull candidates identified');
    } else {
        for (const c of topCull.slice(0, 5)) {
            console.log(`- ${c.skill}: ${c.reason}`);
        }
        if (topCull.length > 5) {
            console.log(`- ${topCull.length - 5} more candidate(s) in production/traces/skill-cull-candidates.md`);
        }
    }

    console.log('');
    console.log('Next:');
    if (cullCandidates.length > 0) {
        console.log('1. Review production/traces/skill-cull-candidates.md before deleting anything.');
        console.log('2. Require at least 7 days of usage data before culling.');
        console.log('3. Run: node scripts/skill-usage-report.js --full');
    } else {
        console.log('1. No cull action required.');
        console.log('2. Run --full only when auditing individual skill usage.');
    }
    process.exit(0);
}

// ─── Full report ──────────────────────────────────────────────────────────────
if (!FLAG_CULL_ONLY) {
    const periodNote = DAYS_LIMIT ? ` (last ${DAYS_LIMIT} days)` : ' (all time)';
    console.log(`\n╔═══════════════════════════════════════════════════════════════════════╗`);
    console.log(`║  SDD Skill Usage Report${periodNote.padEnd(47)}║`);
    console.log(`║  ${NOW_ISO} UTC${' '.repeat(41)}║`);
    console.log(`╠═══════════════════════════════════════════════════════════════════════╣`);
    console.log(`║  Total skills: ${String(allSkills.length).padEnd(4)} │ Used: ${String(used.length).padEnd(4)} │ Never used: ${String(neverUsed.length).padEnd(4)} │ Cull candidates: ${String(cullCandidates.length).padEnd(3)}║`);
    console.log(`╚═══════════════════════════════════════════════════════════════════════╝`);

    if (used.length > 0) {
        console.log(`\n── Top Used Skills ─────────────────────────────────────────────────────`);
        console.log(`  ${'Skill'.padEnd(30)} ${'Calls'.padStart(5)}  ${'Sessions'.padStart(8)}  Last seen`);
        console.log(`  ${'─'.repeat(30)} ${'─'.repeat(5)}  ${'─'.repeat(8)}  ${'─'.repeat(12)}`);
        for (const s of used) {
            const last = s.lastSeen ? s.lastSeen.slice(0, 10) : '—';
            console.log(`  ${PAD(s.skill, 30)} ${String(s.count).padStart(5)}  ${String(s.sessions).padStart(8)}  ${last}`);
        }
    } else {
        console.log(`\n  (no usage data yet — skills will appear here after /skill invocations)`);
    }

    console.log(`\n── Never Used (${neverUsed.length}) ──────────────────────────────────────────────────`);
    const cols = 3;
    for (let i = 0; i < neverUsed.length; i += cols) {
        const row = neverUsed.slice(i, i + cols).map(s => PAD(s, 28)).join('  ');
        console.log(`  ${row}`);
    }
}

// ─── Cull candidates ─────────────────────────────────────────────────────────
console.log(`\n── Cull Candidates (${cullCandidates.length}) — review before deleting ────────────────────`);
if (cullCandidates.length === 0) {
    console.log(`  (none identified)`);
} else {
    console.log(`  ${'Skill'.padEnd(30)}  Reason`);
    console.log(`  ${'─'.repeat(30)}  ${'─'.repeat(35)}`);
    for (const c of cullCandidates) {
        console.log(`  ${PAD(c.skill, 30)}  ${c.reason}`);
    }
}
console.log('');

// ─── Write cull candidates file ───────────────────────────────────────────────
const cullLines = [
    `# Skill Cull Candidates`,
    ``,
    `> Generated: ${NOW_ISO} UTC | Total skills: ${allSkills.length} | Cull candidates: ${cullCandidates.length}`,
    `> **Do NOT delete** without usage data covering ≥7 days. This list is heuristic only.`,
    ``,
    `## Criteria`,
    `- Missing \`SKILL.md\` metadata file (likely placeholder/template)`,
    `- Name overlaps ≥70% token similarity with another skill`,
    ``,
    `## Candidates`,
    ``,
    `| Skill | Reason | Decision |`,
    `|---|---|---|`,
    ...cullCandidates.map(c => `| \`${c.skill}\` | ${c.reason} | ⬜ pending |`),
    ``,
    `## Used Skills (safe — do not cull)`,
    ``,
    ...used.map(s => `- \`${s.skill}\` — ${s.count} call(s), ${s.sessions} session(s)`),
];

fs.mkdirSync(path.dirname(CULL_FILE), { recursive: true });
fs.writeFileSync(CULL_FILE, cullLines.join('\n') + '\n');
console.log(`  Cull candidates written to: production/traces/skill-cull-candidates.md\n`);
