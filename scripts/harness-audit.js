#!/usr/bin/env node
/**
 * scripts/harness-audit.js — v2 (12-pattern Ibryam alignment)
 *
 * Deterministic harness auditor for SDD (Software Development Department).
 * Audits the repo against the 12 Agentic Harness Patterns from Claude Code.
 *
 * Rubric: 12 Agentic Harness Patterns from Claude Code
 * Source: Bilgin Ibryam, "12 Agentic Harness Patterns from Claude Code"
 *         https://generativeprogrammer.com/p/12-agentic-harness-patterns-from
 *
 * NOTE: The 12-pattern framework is a respected third-party interpretation,
 * not an official Anthropic publication. Official Anthropic harness guidance
 * that informs pattern understanding (but is NOT directly scored here):
 *   - https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
 *   - https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
 *   - https://code.claude.com/docs/en/how-claude-code-works
 *
 * Rubric version: 2026-04-16-ibryam
 * Zero runtime dependencies (Node stdlib only).
 *
 * Usage:
 *   node scripts/harness-audit.js [scope] [--compact|--full|--format compact|text|json]
 *
 * Scopes:
 *   repo        (default) All 12 patterns, max 120
 *   memory      Patterns 1-5 (Memory & Context), max 50
 *   workflow    Patterns 6-8 (Workflow & Orchestration), max 30
 *   tools       Patterns 9-11 (Tools & Permissions), max 30
 *   automation  Pattern 12 (Automation), max 10
 *   hooks       Patterns with hook evidence (4,5,10,12), max 40 [legacy]
 *   skills      Patterns tied to skill design (2,11), max 20 [legacy]
 *   agents      Pattern 7 (Context-Isolated Subagents), max 10 [legacy]
 *   commands    Pattern 11 (Single-Purpose Tool Design), max 10 [legacy]
 *
 * Contract:
 *   - Same commit → identical output (deterministic).
 *   - Read-only: never modifies repo.
 *   - Each check is pass/fail; pattern score = round(10 * passed/total).
 */

'use strict';

const fs = require('fs');
const path = require('path');

const RUBRIC_VERSION = '2026-04-16-ibryam';
const RUBRIC_SOURCE = 'https://generativeprogrammer.com/p/12-agentic-harness-patterns-from';

// ─── Repo root detection ──────────────────────────────────────────────────
function findRepoRoot(start) {
  let dir = start;
  for (let i = 0; i < 8; i++) {
    if (fs.existsSync(path.join(dir, '.claude')) || fs.existsSync(path.join(dir, 'CLAUDE.md'))) {
      return dir;
    }
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return start;
}
const ROOT = findRepoRoot(process.cwd());
const P = (...parts) => path.join(ROOT, ...parts);

// ─── FS / text helpers ────────────────────────────────────────────────────
function exists(rel) { try { return fs.existsSync(P(rel)); } catch { return false; } }
function isDir(rel)  { try { return fs.statSync(P(rel)).isDirectory(); } catch { return false; } }
function isFile(rel) { try { return fs.statSync(P(rel)).isFile(); } catch { return false; } }
function stripBom(text) {
  return text.charCodeAt(0) === 0xFEFF ? text.slice(1) : text;
}
function readText(rel) {
  try {
    return stripBom(fs.readFileSync(P(rel), 'utf8'));
  } catch {
    return '';
  }
}
function readJSON(rel) { try { return JSON.parse(fs.readFileSync(P(rel), 'utf8')); } catch { return null; } }
function listDir(rel) { try { return fs.readdirSync(P(rel)); } catch { return []; } }
function listDirRecursive(rel, out = []) {
  if (!isDir(rel)) return out;
  for (const entry of listDir(rel)) {
    const full = path.join(rel, entry);
    if (isDir(full)) listDirRecursive(full, out);
    else out.push(full);
  }
  return out;
}
function fileSize(rel) { try { return fs.statSync(P(rel)).size; } catch { return 0; } }
function countLines(rel) {
  const txt = readText(rel);
  return txt ? txt.split('\n').length : 0;
}
function grepFile(rel, regex) {
  const txt = readText(rel);
  return regex.test(txt);
}
function readFrontmatter(rel) {
  const txt = readText(rel);
  if (!txt.startsWith('---')) return {};
  const end = txt.indexOf('\n---', 3);
  if (end === -1) return {};
  const block = txt.slice(3, end);
  const out = {};
  for (const line of block.split('\n')) {
    const m = line.match(/^([A-Za-z0-9_\-]+)\s*:\s*(.*?)\r?$/);
    if (m) out[m[1]] = m[2].trim().replace(/^["']|["']$/g, '');
  }
  return out;
}

// ─── Skill / agent enumeration ────────────────────────────────────────────
function enumerateSkills() {
  const dir = '.claude/skills';
  if (!isDir(dir)) return { folders: [], skillFiles: [], strayMd: [] };
  const entries = listDir(dir);
  const folders = [];
  const strayMd = [];
  const skillFiles = [];
  for (const e of entries) {
    if (e.startsWith('_') || e === 'templates') continue;
    const full = path.join(dir, e);
    if (isDir(full)) {
      folders.push(e);
      const sf = path.join(full, 'SKILL.md');
      if (isFile(sf)) skillFiles.push(sf);
    } else if (e.endsWith('.md')) {
      strayMd.push(e);
    }
  }
  return { folders, skillFiles, strayMd };
}
function enumerateAgents() {
  return listDir('.claude/agents').filter((f) => f.endsWith('.md'));
}

// ─── Check framework ──────────────────────────────────────────────────────
function check(id, passed, meta = {}) {
  return { id, passed: !!passed, ...meta };
}
function scorePattern(checks) {
  const total = checks.length;
  const passed = checks.filter((c) => c.passed).length;
  const score = total === 0 ? 0 : Math.round((10 * passed) / total);
  return { score, passed, total };
}

// ═══════════════════════════════════════════════════════════════════════════
// 12 PATTERN CHECK FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

// Pattern 1: Persistent Instruction File
function pat_PersistentInstructionFile() {
  const claude = readText('CLAUDE.md');
  return [
    check('pif.claude_md_exists', exists('CLAUDE.md'), { path: 'CLAUDE.md' }),
    check('pif.critical_rules', /CRITICAL RULES/i.test(claude), { path: 'CLAUDE.md' }),
    check('pif.memory_imported', /@\.claude\/memory\/MEMORY\.md/.test(claude),
          { hint: 'import MEMORY.md via @-syntax', path: 'CLAUDE.md' }),
    check('pif.tech_stack_section', /Technology Stack|Tech Stack/i.test(claude),
          { path: 'CLAUDE.md' }),
    check('pif.coordination_ref', /coordination-rules|Coordination Rules/i.test(claude),
          { path: 'CLAUDE.md' }),
  ];
}

// Pattern 2: Scoped Context Assembly
function pat_ScopedContextAssembly() {
  const rulesDir = '.claude/rules';
  const ruleFiles = listDir(rulesDir).filter((f) => f.endsWith('.md'));
  const withScope = ruleFiles.filter((f) => /Applies to:/i.test(readText(path.join(rulesDir, f))));
  return [
    check('sca.rules_dir_count', ruleFiles.length >= 3,
          { actual: ruleFiles.length, expected: '>=3', path: '.claude/rules/' }),
    check('sca.rules_have_scope', withScope.length >= 3,
          { actual: withScope.length, expected: '>=3 rules with "Applies to:"',
            path: '.claude/rules/' }),
    check('sca.rule_api', exists('.claude/rules/api-code.md'),
          { path: '.claude/rules/api-code.md' }),
    check('sca.rule_frontend', exists('.claude/rules/frontend-code.md'),
          { path: '.claude/rules/frontend-code.md' }),
    check('sca.rule_database', exists('.claude/rules/database-code.md'),
          { path: '.claude/rules/database-code.md' }),
  ];
}

// Pattern 3: Tiered Memory
function pat_TieredMemory() {
  const memLines = countLines('.claude/memory/MEMORY.md');
  const memText = readText('.claude/memory/MEMORY.md');
  const topicFiles = listDir('.claude/memory')
    .filter((f) => f.endsWith('.md') && f !== 'MEMORY.md');
  return [
    check('tm.memory_index', memLines > 0 && memLines <= 200,
          { actual: `${memLines} lines`, expected: '1..200',
            path: '.claude/memory/MEMORY.md' }),
    check('tm.multi_tier_docs', /Tier 1/i.test(memText) && /Tier 2/i.test(memText),
          { hint: 'MEMORY.md names multiple tiers',
            path: '.claude/memory/MEMORY.md' }),
    check('tm.archive_dir', isDir('.claude/memory/archive'),
          { path: '.claude/memory/archive/' }),
    check('tm.tier2_files', topicFiles.length >= 3,
          { actual: topicFiles.length, expected: '>=3 topic files',
            path: '.claude/memory/' }),
    check('tm.specialists_namespace',
          isDir('.claude/memory/specialists') || /Tier 2\.5|specialists\//i.test(memText),
          { hint: 'specialists/ folder or namespace doc',
            path: '.claude/memory/specialists/' }),
  ];
}

// Pattern 4: Dream Consolidation
function pat_DreamConsolidation() {
  const settings = readJSON('.claude/settings.json') || {};
  const allHooks = JSON.stringify(settings.hooks || {});
  const ctxMgmt = readText('.claude/docs/context-management.md');
  const memIdx = readText('.claude/memory/MEMORY.md');
  return [
    check('dc.dream_skill', exists('.claude/skills/dream/SKILL.md'),
          { path: '.claude/skills/dream/SKILL.md' }),
    check('dc.auto_dream_hook', exists('.claude/hooks/auto-dream.sh'),
          { path: '.claude/hooks/auto-dream.sh' }),
    check('dc.dreams_archive', isDir('.claude/memory/archive/dreams'),
          { path: '.claude/memory/archive/dreams/' }),
    check('dc.hook_wired', /auto-dream|dream\.sh/.test(allHooks)
                       || /auto-dream/.test(readText('.claude/hooks/auto-dream.sh')),
          { hint: 'auto-dream.sh referenced or self-executing',
            path: '.claude/settings.json' }),
    check('dc.consolidation_doc',
          /consolidat|\/dream/i.test(ctxMgmt) || /auto-consolidat/i.test(memIdx),
          { hint: 'consolidation/dream process documented',
            path: '.claude/docs/context-management.md' }),
  ];
}

// Pattern 5: Progressive Context Compaction
function pat_ProgressiveContextCompaction() {
  const settings = readJSON('.claude/settings.json') || {};
  const preCompact = JSON.stringify(settings?.hooks?.PreCompact || []);
  const ctxMgmt = readText('.claude/docs/context-management.md');
  return [
    check('pcc.compact_documented', /\/compact|Proactive Compaction/i.test(ctxMgmt),
          { path: '.claude/docs/context-management.md' }),
    check('pcc.pre_compact_hook', exists('.claude/hooks/pre-compact.sh'),
          { path: '.claude/hooks/pre-compact.sh' }),
    check('pcc.event_registered', /pre-compact/.test(preCompact),
          { path: '.claude/settings.json (hooks.PreCompact)' }),
    check('pcc.strategy_doc', /Compaction Instructions|compact proactively/i.test(ctxMgmt),
          { path: '.claude/docs/context-management.md' }),
    check('pcc.session_state',
          isDir('production/session-state') || /active\.md/i.test(ctxMgmt),
          { hint: 'session-state dir or active.md doc',
            path: 'production/session-state/' }),
  ];
}

// Pattern 6: Explore-Plan-Act Loop
function pat_ExplorePlanActLoop() {
  const claude = readText('CLAUDE.md');
  const coord = readText('.claude/docs/coordination-rules.md');
  return [
    check('epa.plan_skill',
          exists('.claude/skills/planning-and-task-breakdown/SKILL.md')
       || exists('.claude/skills/plan/SKILL.md'),
          { path: '.claude/skills/planning-and-task-breakdown/' }),
    check('epa.spec_skill',
          exists('.claude/skills/spec-driven-development/SKILL.md'),
          { path: '.claude/skills/spec-driven-development/' }),
    check('epa.plan_mode_doc', /plan\b.*mode|`plan`/i.test(coord) || /\/plan\b/.test(claude),
          { hint: 'plan mode / plan workflow documented',
            path: '.claude/docs/coordination-rules.md' }),
    check('epa.approval_before_impl',
          /NO AUTOPILOT|Question.*Options.*Decision|approval/i.test(claude),
          { hint: 'CLAUDE.md requires approval before implementation',
            path: 'CLAUDE.md' }),
    check('epa.permission_modes',
          /acceptEdits|bypassPermissions|Permission Mode/i.test(coord),
          { hint: 'permission modes (plan/default/acceptEdits) documented',
            path: '.claude/docs/coordination-rules.md' }),
  ];
}

// Pattern 7: Context-Isolated Subagents
function pat_ContextIsolatedSubagents() {
  const agents = enumerateAgents();
  const withFrontmatter = agents.filter((a) => {
    const fm = readFrontmatter(path.join('.claude/agents', a));
    return fm.name || fm.description;
  });
  const withTools = agents.filter((a) =>
    /^tools\s*:/m.test(readText(path.join('.claude/agents', a))));
  const coord = readText('.claude/docs/coordination-rules.md');
  return [
    check('cis.agents_dir_populated', agents.length >= 10,
          { actual: agents.length, expected: '>=10', path: '.claude/agents/' }),
    check('cis.agents_frontmatter',
          agents.length > 0 && withFrontmatter.length / agents.length >= 0.8,
          { actual: `${withFrontmatter.length}/${agents.length}`, expected: '>=80%',
            path: '.claude/agents/' }),
    check('cis.concurrency_rule', /Concurrency Classification|Concurrent-safe/i.test(coord),
          { path: '.claude/docs/coordination-rules.md' }),
    check('cis.tool_restrictions',
          agents.length > 0 && withTools.length / agents.length >= 0.3,
          { actual: `${withTools.length}/${agents.length} have tools:`, expected: '>=30%',
            path: '.claude/agents/' }),
    check('cis.isolation_doc',
          /context window|isolated context|subagent/i.test(
            readText('.claude/docs/context-management.md')),
          { path: '.claude/docs/context-management.md' }),
  ];
}

// Pattern 8: Fork-Join Parallelism
function pat_ForkJoinParallelism() {
  const coord = readText('.claude/docs/coordination-rules.md');
  return [
    check('fjp.fork_join_hook',
          exists('.claude/hooks/fork-join.sh')
       || exists('.claude/skills/fork-join/SKILL.md'),
          { path: '.claude/hooks/fork-join.sh | .claude/skills/fork-join/' }),
    check('fjp.worktree_rule', /worktree/i.test(coord),
          { path: '.claude/docs/coordination-rules.md' }),
    check('fjp.fork_join_command',
          /user-invocable\s*:\s*true/i.test(readText('.claude/skills/fork-join/SKILL.md')),
          { path: '.claude/skills/fork-join/SKILL.md' }),
    check('fjp.git_worktree_doc', /git worktree|isolation.*worktree/i.test(coord),
          { path: '.claude/docs/coordination-rules.md' }),
    check('fjp.concurrent_safe',
          /Concurrent-safe|State-modifying|classify/i.test(coord),
          { hint: 'agents classified by side-effect profile',
            path: '.claude/docs/coordination-rules.md' }),
  ];
}

// Pattern 9: Progressive Tool Expansion
function pat_ProgressiveToolExpansion() {
  const settings = readJSON('.claude/settings.json') || {};
  const allow = settings?.permissions?.allow || [];
  const { skillFiles } = enumerateSkills();
  const skillsWithAllowedTools = skillFiles.filter((sf) =>
    /^allowed-tools\s*:/m.test(readText(sf)));
  const agents = enumerateAgents();
  const agentsWithTools = agents.filter((a) =>
    /^tools\s*:/m.test(readText(path.join('.claude/agents', a))));
  return [
    check('pte.allow_list_explicit',
          allow.length > 0 && !allow.some((a) => a === '*' || a === 'Bash(*)'),
          { actual: `${allow.length} entries`, expected: 'no unrestricted * wildcard',
            path: '.claude/settings.json' }),
    check('pte.skills_allowed_tools',
          skillFiles.length > 0 && skillsWithAllowedTools.length / skillFiles.length >= 0.5,
          { actual: `${skillsWithAllowedTools.length}/${skillFiles.length}`,
            expected: '>=50% skills with allowed-tools:',
            path: '.claude/skills/*/SKILL.md' }),
    check('pte.default_set_bounded', allow.length >= 5 && allow.length <= 50,
          { actual: allow.length, expected: '5..50',
            path: '.claude/settings.json' }),
    check('pte.agents_tool_restrictions',
          agents.length > 0 && agentsWithTools.length / agents.length >= 0.3,
          { actual: `${agentsWithTools.length}/${agents.length}`, expected: '>=30%',
            path: '.claude/agents/' }),
    check('pte.on_demand_doc',
          /least privilege|allowed-tools|Tool Access/i.test(
            readText('.claude/docs/context-management.md')
          + readText('.claude/docs/coordination-rules.md')),
          { hint: 'least-privilege / on-demand tool doc',
            path: '.claude/docs/' }),
  ];
}

// Pattern 10: Command Risk Classification
function pat_CommandRiskClassification() {
  const settings = readJSON('.claude/settings.json') || {};
  const deny = settings?.permissions?.deny || [];
  const preTool = JSON.stringify(settings?.hooks?.PreToolUse || []);
  const claude = readText('CLAUDE.md');
  const coord = readText('.claude/docs/coordination-rules.md');
  return [
    check('crc.bash_guard', exists('.claude/hooks/bash-guard.sh'),
          { path: '.claude/hooks/bash-guard.sh' }),
    check('crc.deny_list_dangerous', deny.length >= 5,
          { actual: `${deny.length} deny patterns`, expected: '>=5',
            path: '.claude/settings.json' }),
    check('crc.pre_tool_bash_hook', /"matcher":\s*"Bash"/.test(preTool),
          { path: '.claude/settings.json (hooks.PreToolUse)' }),
    check('crc.risk_tiers_doc',
          /Low.*Medium.*High|Risk Tier/i.test(claude + coord),
          { hint: 'risk tier classification documented',
            path: 'CLAUDE.md | coordination-rules.md' }),
    check('crc.safety_tiers', /SAFETY TIERS/i.test(claude),
          { path: 'CLAUDE.md' }),
  ];
}

// Pattern 11: Single-Purpose Tool Design
function pat_SinglePurposeToolDesign() {
  const { folders, skillFiles, strayMd } = enumerateSkills();
  const total = folders.length + strayMd.length;
  const folderRatio = total > 0 ? folders.length / total : 0;
  const withDescription = skillFiles.filter((sf) => /^description\s*:/m.test(readText(sf))).length;
  const withWhenOrHint = skillFiles.filter((sf) =>
    /^(when_to_use|argument-hint)\s*:/m.test(readText(sf))).length;
  return [
    check('sptd.skills_are_folders', folderRatio >= 0.95,
          { actual: `${folders.length}/${total} folders (${Math.round(folderRatio * 100)}%)`,
            expected: '>=95% (no stray .md)',
            path: '.claude/skills/' }),
    check('sptd.skills_have_description',
          skillFiles.length > 0 && withDescription / skillFiles.length >= 0.8,
          { actual: `${withDescription}/${skillFiles.length}`, expected: '>=80%',
            path: '.claude/skills/*/SKILL.md' }),
    check('sptd.skills_when_to_use',
          skillFiles.length > 0 && withWhenOrHint / skillFiles.length >= 0.3,
          { actual: `${withWhenOrHint}/${skillFiles.length}`,
            expected: '>=30% with when_to_use/argument-hint',
            path: '.claude/skills/*/SKILL.md' }),
    check('sptd.validator_exists', exists('scripts/validate-skills.sh'),
          { path: 'scripts/validate-skills.sh' }),
    check('sptd.skill_count_granular', skillFiles.length >= 50,
          { actual: skillFiles.length, expected: '>=50 (granular single-purpose)',
            path: '.claude/skills/' }),
  ];
}

// Pattern 12: Deterministic Lifecycle Hooks
function pat_DeterministicLifecycleHooks() {
  const settings = readJSON('.claude/settings.json') || {};
  const hookEvents = settings.hooks ? Object.keys(settings.hooks) : [];

  // Collect all referenced hook script paths
  const hookScripts = [];
  const hookJson = JSON.stringify(settings.hooks || {});
  const scriptMatches = hookJson.match(/\.claude\/hooks\/[a-z0-9_\-]+\.sh/g) || [];
  for (const m of scriptMatches) if (!hookScripts.includes(m)) hookScripts.push(m);
  const hookScriptsExist = hookScripts.length > 0 &&
    hookScripts.every((s) => exists(s));

  const hasPre = !!settings?.hooks?.PreToolUse;
  const hasPost = !!settings?.hooks?.PostToolUse;
  const logsWired =
    isDir('production/session-logs') || isDir('production/traces')
 || /log-writes|agent-metrics/.test(hookJson);

  return [
    check('dlh.hooks_configured', hookEvents.length >= 3,
          { actual: `${hookEvents.length} events`, expected: '>=3',
            path: '.claude/settings.json' }),
    check('dlh.events_coverage', hookEvents.length >= 5,
          { actual: hookEvents, expected: '>=5 events',
            path: '.claude/settings.json' }),
    check('dlh.hook_scripts_exist', hookScriptsExist,
          { actual: `${hookScripts.length} referenced`,
            expected: 'all referenced .sh exist',
            path: '.claude/hooks/' }),
    check('dlh.hook_outputs_logged', logsWired,
          { hint: 'session-logs or traces dir or log-* hook wired',
            path: 'production/session-logs/ | production/traces/' }),
    check('dlh.pre_and_post_both', hasPre && hasPost,
          { path: '.claude/settings.json' }),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// PATTERN REGISTRY
// ═══════════════════════════════════════════════════════════════════════════

const PATTERNS = [
  // Memory & Context (5)
  { key: 'pif',  num: 1,  label: 'Persistent Instruction File',
    category: 'Memory & Context', fn: pat_PersistentInstructionFile },
  { key: 'sca',  num: 2,  label: 'Scoped Context Assembly',
    category: 'Memory & Context', fn: pat_ScopedContextAssembly },
  { key: 'tm',   num: 3,  label: 'Tiered Memory',
    category: 'Memory & Context', fn: pat_TieredMemory },
  { key: 'dc',   num: 4,  label: 'Dream Consolidation',
    category: 'Memory & Context', fn: pat_DreamConsolidation },
  { key: 'pcc',  num: 5,  label: 'Progressive Context Compaction',
    category: 'Memory & Context', fn: pat_ProgressiveContextCompaction },
  // Workflow & Orchestration (3)
  { key: 'epa',  num: 6,  label: 'Explore-Plan-Act Loop',
    category: 'Workflow & Orchestration', fn: pat_ExplorePlanActLoop },
  { key: 'cis',  num: 7,  label: 'Context-Isolated Subagents',
    category: 'Workflow & Orchestration', fn: pat_ContextIsolatedSubagents },
  { key: 'fjp',  num: 8,  label: 'Fork-Join Parallelism',
    category: 'Workflow & Orchestration', fn: pat_ForkJoinParallelism },
  // Tools & Permissions (3)
  { key: 'pte',  num: 9,  label: 'Progressive Tool Expansion',
    category: 'Tools & Permissions', fn: pat_ProgressiveToolExpansion },
  { key: 'crc',  num: 10, label: 'Command Risk Classification',
    category: 'Tools & Permissions', fn: pat_CommandRiskClassification },
  { key: 'sptd', num: 11, label: 'Single-Purpose Tool Design',
    category: 'Tools & Permissions', fn: pat_SinglePurposeToolDesign },
  // Automation (1)
  { key: 'dlh',  num: 12, label: 'Deterministic Lifecycle Hooks',
    category: 'Automation', fn: pat_DeterministicLifecycleHooks },
];

const SCOPES = {
  repo:       PATTERNS.map((p) => p.key),
  memory:     ['pif', 'sca', 'tm', 'dc', 'pcc'],
  workflow:   ['epa', 'cis', 'fjp'],
  tools:      ['pte', 'crc', 'sptd'],
  automation: ['dlh'],
  // Legacy scopes (preserved for backward compat)
  hooks:    ['dc', 'pcc', 'crc', 'dlh'],
  skills:   ['sca', 'sptd'],
  agents:   ['cis'],
  commands: ['sptd'],
};

// ═══════════════════════════════════════════════════════════════════════════
// TOP ACTIONS & SUGGESTED SKILLS
// ═══════════════════════════════════════════════════════════════════════════

const PATTERN_PRIORITY = {
  crc: 12, pte: 11,             // Tools & Permissions — security-critical
  dlh: 10, tm: 9, pcc: 8,       // Determinism + memory hygiene
  cis: 7,  epa: 6,              // Workflow discipline
  pif: 5,  sca: 4,  dc: 3,      // Documentation & consolidation
  sptd: 2, fjp: 1,              // Parallelism & granularity
};

const CHECK_HINTS = {
  'pif.claude_md_exists':       'Create CLAUDE.md at repo root',
  'pif.critical_rules':         'Add a CRITICAL RULES section to CLAUDE.md',
  'pif.memory_imported':        'Import MEMORY.md via `@.claude/memory/MEMORY.md` in CLAUDE.md',
  'pif.tech_stack_section':     'Add a Technology Stack section to CLAUDE.md',
  'pif.coordination_ref':       'Reference coordination-rules from CLAUDE.md',
  'sca.rules_dir_count':        'Add at least 3 path-scoped rule files under .claude/rules/',
  'sca.rules_have_scope':       'Add `Applies to:` headers to rule files',
  'sca.rule_api':               'Create .claude/rules/api-code.md',
  'sca.rule_frontend':          'Create .claude/rules/frontend-code.md',
  'sca.rule_database':          'Create .claude/rules/database-code.md',
  'tm.memory_index':            'Trim .claude/memory/MEMORY.md to <=200 lines',
  'tm.multi_tier_docs':         'Document Tier 1/2/3 structure in MEMORY.md',
  'tm.archive_dir':             'Create .claude/memory/archive/ for Tier 3 storage',
  'tm.tier2_files':             'Add >=3 Tier-2 topic files under .claude/memory/',
  'tm.specialists_namespace':   'Create .claude/memory/specialists/ or document Tier 2.5',
  'dc.dream_skill':             'Create /dream skill at .claude/skills/dream/SKILL.md',
  'dc.auto_dream_hook':         'Create .claude/hooks/auto-dream.sh',
  'dc.dreams_archive':          'Create .claude/memory/archive/dreams/',
  'dc.hook_wired':              'Wire auto-dream.sh into settings.json or cron',
  'dc.consolidation_doc':       'Document consolidation process in context-management.md',
  'pcc.compact_documented':     'Document /compact usage in context-management.md',
  'pcc.pre_compact_hook':       'Create .claude/hooks/pre-compact.sh',
  'pcc.event_registered':       'Register PreCompact hook in settings.json',
  'pcc.strategy_doc':           'Add "Compaction Instructions" section to context-management.md',
  'pcc.session_state':          'Create production/session-state/ with active.md',
  'epa.plan_skill':             'Create /plan or /planning-and-task-breakdown skill',
  'epa.spec_skill':             'Create /spec-driven-development skill',
  'epa.plan_mode_doc':          'Document plan mode in coordination-rules.md',
  'epa.approval_before_impl':   'Add NO AUTOPILOT rule requiring approval to CLAUDE.md',
  'epa.permission_modes':       'Document plan/default/acceptEdits/bypass modes',
  'cis.agents_dir_populated':   'Add at least 10 agent definitions to .claude/agents/',
  'cis.agents_frontmatter':     'Add YAML frontmatter to >=80% of agents',
  'cis.concurrency_rule':       'Add Subagent Concurrency Classification rule',
  'cis.tool_restrictions':      'Add tools: restrictions to agent definitions',
  'cis.isolation_doc':          'Document subagent context isolation',
  'fjp.fork_join_hook':         'Create fork-join.sh hook or fork-join skill',
  'fjp.worktree_rule':          'Document git worktree isolation rule',
  'fjp.fork_join_command':      'Mark fork-join skill as user-invocable',
  'fjp.git_worktree_doc':       'Document git worktree workflow in coordination-rules.md',
  'fjp.concurrent_safe':        'Classify agents as Concurrent-safe vs State-modifying',
  'pte.allow_list_explicit':    'Remove wildcard `*` from permissions.allow',
  'pte.skills_allowed_tools':   'Add `allowed-tools:` frontmatter to >=50% of skills',
  'pte.default_set_bounded':    'Keep allow-list between 5..50 entries (bounded)',
  'pte.agents_tool_restrictions': 'Add `tools:` field to agent definitions',
  'pte.on_demand_doc':          'Document least-privilege / on-demand tool activation',
  'crc.bash_guard':             'Create .claude/hooks/bash-guard.sh',
  'crc.deny_list_dangerous':    'Expand deny-list to >=5 risky patterns',
  'crc.pre_tool_bash_hook':     'Register PreToolUse hook with matcher:"Bash"',
  'crc.risk_tiers_doc':         'Document Low/Medium/High risk tiers',
  'crc.safety_tiers':           'Add SAFETY TIERS section to CLAUDE.md',
  'sptd.skills_are_folders':    'Convert stray .md files under .claude/skills/ to folder/SKILL.md',
  'sptd.skills_have_description': 'Add description: frontmatter to >=80% skills',
  'sptd.skills_when_to_use':    'Add when_to_use or argument-hint to >=30% skills',
  'sptd.validator_exists':      'Create scripts/validate-skills.sh',
  'sptd.skill_count_granular':  'Reach >=50 valid skill folders',
  'dlh.hooks_configured':       'Configure >=3 hook events in settings.json',
  'dlh.events_coverage':        'Cover >=5 hook events (SessionStart, PreToolUse, etc.)',
  'dlh.hook_scripts_exist':     'Ensure every referenced .sh file exists under .claude/hooks/',
  'dlh.hook_outputs_logged':    'Wire logging under production/session-logs/ or traces/',
  'dlh.pre_and_post_both':      'Register both PreToolUse and PostToolUse events',
};

function topActions(allFailed) {
  const sorted = [...allFailed].sort((a, b) =>
    (PATTERN_PRIORITY[b.patKey] || 0) - (PATTERN_PRIORITY[a.patKey] || 0));
  return sorted.slice(0, 3).map((f) => ({
    pattern: f.patLabel,
    pattern_num: f.patNum,
    action: CHECK_HINTS[f.id] || `Fix check: ${f.id}`,
    path: f.path || '',
  }));
}

function suggestSkills(failedByPattern) {
  const map = {
    pif:  ['/sync-template'],
    sca:  ['/architecture-decision'],
    tm:   ['/dream', '/prune'],
    dc:   ['/dream'],
    pcc:  ['/context-engineering', '/save-state'],
    epa:  ['/plan', '/spec-driven-development'],
    cis:  ['/orchestrate', '/team-feature'],
    fjp:  ['/fork-join'],
    pte:  ['/architecture-decision'],
    crc:  ['/security-audit', '/security-scan'],
    sptd: ['/harness-audit', '/skill-stocktake'],
    dlh:  ['/annotate', '/trace-history'],
  };
  const result = [];
  const seen = new Set();
  const sorted = Object.keys(failedByPattern).sort(
    (a, b) => failedByPattern[b].length - failedByPattern[a].length);
  for (const k of sorted) {
    for (const s of (map[k] || [])) {
      if (!seen.has(s)) { seen.add(s); result.push(s); }
      if (result.length >= 5) return result;
    }
  }
  return result;
}

// ═══════════════════════════════════════════════════════════════════════════
// RUNNER
// ═══════════════════════════════════════════════════════════════════════════

function runAudit(scope) {
  const keysInScope = SCOPES[scope];
  if (!keysInScope) throw new Error(`Unknown scope: ${scope}`);

  const active = PATTERNS.filter((p) => keysInScope.includes(p.key));
  const patternResults = [];
  const failed = [];

  for (const p of active) {
    const checks = p.fn();
    const { score, passed, total } = scorePattern(checks);
    patternResults.push({
      key: p.key, num: p.num, label: p.label, category: p.category,
      score, max: 10, passed, total, checks,
    });
    for (const c of checks) {
      if (!c.passed) failed.push({
        patKey: p.key, patLabel: p.label, patNum: p.num, category: p.category,
        id: c.id, path: c.path || '',
        actual: c.actual, expected: c.expected, hint: c.hint,
      });
    }
  }

  const overall = patternResults.reduce((s, r) => s + r.score, 0);
  const max = patternResults.length * 10;
  const failedByPattern = failed.reduce((acc, f) => {
    (acc[f.patKey] = acc[f.patKey] || []).push(f); return acc;
  }, {});

  return {
    rubric_version: RUBRIC_VERSION,
    rubric_source: RUBRIC_SOURCE,
    scope,
    overall_score: overall,
    max_score: max,
    readiness: buildReadinessDiagnostics(failed),
    patterns: patternResults,
    failed_checks: failed,
    top_actions: topActions(failed),
    suggested_skills: suggestSkills(failedByPattern),
  };
}

// ═══════════════════════════════════════════════════════════════════════════
// READINESS DIAGNOSTICS
// ═══════════════════════════════════════════════════════════════════════════

function issue(severity, id, message, meta = {}) {
  return { severity, id, message, ...meta };
}

function maxReadinessLevel(issues) {
  if (issues.some((i) => i.severity === 'blocked')) return 'blocked';
  if (issues.some((i) => i.severity === 'warning')) return 'warning';
  return 'ready';
}

function parseJsonFile(rel) {
  if (!exists(rel)) {
    return { ok: false, missing: true, value: null, error: `Missing ${rel}` };
  }
  try {
    return { ok: true, missing: false, value: JSON.parse(fs.readFileSync(P(rel), 'utf8')), error: '' };
  } catch (e) {
    return { ok: false, missing: false, value: null, error: e.message || String(e) };
  }
}

function extractHookScriptRefs(command) {
  const refs = [];
  const regex = /(?:^|\s)(\.claude[\\/]+hooks[\\/]+[A-Za-z0-9._-]+(?:\.(?:sh|ps1|js))?)/g;
  let match;
  while ((match = regex.exec(command)) !== null) {
    refs.push(match[1].replace(/\\/g, '/'));
  }
  return refs;
}

function diagnoseHooks(settingsParse) {
  const items = [];
  if (!settingsParse.ok) {
    items.push(issue(
      'blocked',
      settingsParse.missing ? 'hooks.settings_missing' : 'hooks.settings_invalid_json',
      settingsParse.error,
      { path: '.claude/settings.json' },
    ));
    return items;
  }

  const hooks = settingsParse.value.hooks || {};
  if (!hooks || typeof hooks !== 'object' || Array.isArray(hooks)) {
    items.push(issue('blocked', 'hooks.schema_invalid', 'settings.hooks must be an object', {
      path: '.claude/settings.json',
    }));
    return items;
  }

  for (const [eventName, groups] of Object.entries(hooks)) {
    if (!Array.isArray(groups)) {
      items.push(issue('blocked', 'hooks.event_not_array', `${eventName} hooks must be an array`, {
        event: eventName,
        path: '.claude/settings.json',
      }));
      continue;
    }
    groups.forEach((group, groupIndex) => {
      const hookDefs = group && Array.isArray(group.hooks) ? group.hooks : null;
      if (!hookDefs) {
        items.push(issue('blocked', 'hooks.group_missing_hooks', `${eventName}[${groupIndex}] is missing hooks[]`, {
          event: eventName,
          group_index: groupIndex,
          path: '.claude/settings.json',
        }));
        return;
      }
      hookDefs.forEach((hook, hookIndex) => {
        const base = {
          event: eventName,
          group_index: groupIndex,
          hook_index: hookIndex,
          path: '.claude/settings.json',
        };
        if (!hook || hook.type !== 'command') {
          items.push(issue('blocked', 'hooks.unsupported_type', `${eventName}[${groupIndex}].hooks[${hookIndex}] must be a command hook`, base));
          return;
        }
        if (typeof hook.command !== 'string' || !hook.command.trim()) {
          items.push(issue('blocked', 'hooks.missing_command', `${eventName}[${groupIndex}].hooks[${hookIndex}] is missing command`, base));
          return;
        }
        if (hook.timeout !== undefined && (!Number.isFinite(hook.timeout) || hook.timeout < 1 || hook.timeout > 600)) {
          items.push(issue('warning', 'hooks.timeout_suspicious', `${eventName}[${groupIndex}].hooks[${hookIndex}] has suspicious timeout`, {
            ...base,
            timeout: hook.timeout,
          }));
        }
        const refs = extractHookScriptRefs(hook.command);
        refs.forEach((ref) => {
          if (!isFile(ref)) {
            items.push(issue('blocked', 'hooks.script_missing', `Referenced hook script is missing: ${ref}`, {
              ...base,
              hook_file: ref,
            }));
          }
        });
      });
    });
  }
  return items;
}

function diagnoseSkillsAndAgents() {
  const items = [];
  const skillRequired = ['name', 'description', 'user-invocable', 'allowed-tools', 'effort'];
  const skillRecommended = ['type', 'when_to_use'];

  for (const rel of enumerateSkills().skillFiles) {
    const fm = readFrontmatter(rel);
    if (!Object.keys(fm).length) {
      items.push(issue('warning', 'skill.frontmatter_missing', 'Skill missing YAML frontmatter', { path: rel }));
      continue;
    }
    const type = fm.type || 'workflow';
    const missing = skillRequired.filter((field) => fm[field] === undefined || fm[field] === '');
    if (type === 'workflow' && (fm['argument-hint'] === undefined || fm['argument-hint'] === '')) {
      missing.push('argument-hint');
    }
    if (missing.length) {
      items.push(issue('warning', 'skill.required_schema_missing', `Skill missing required schema fields: ${missing.join(', ')}`, {
        path: rel,
        missing_fields: missing,
      }));
    }
    const missingRecommended = skillRecommended.filter((field) => fm[field] === undefined || fm[field] === '');
    if (missingRecommended.length) {
      items.push(issue('warning', 'skill.recommended_schema_missing', `Skill missing recommended fields: ${missingRecommended.join(', ')}`, {
        path: rel,
        missing_fields: missingRecommended,
      }));
    }
  }

  const agentRequired = ['name', 'description', 'tools'];
  const agentRecommended = ['model', 'maxTurns', 'skills'];
  for (const agentFile of enumerateAgents()) {
    const rel = path.join('.claude/agents', agentFile);
    const fm = readFrontmatter(rel);
    if (!Object.keys(fm).length) {
      items.push(issue('blocked', 'agent.frontmatter_missing', 'Agent missing YAML frontmatter', { path: rel }));
      continue;
    }
    const missing = agentRequired.filter((field) => fm[field] === undefined || fm[field] === '');
    if (missing.length) {
      items.push(issue('blocked', 'agent.required_schema_missing', `Agent missing required schema fields: ${missing.join(', ')}`, {
        path: rel,
        missing_fields: missing,
      }));
    }
    const missingRecommended = agentRecommended.filter((field) => fm[field] === undefined || fm[field] === '');
    if (missingRecommended.length) {
      items.push(issue('warning', 'agent.recommended_schema_missing', `Agent missing recommended fields: ${missingRecommended.join(', ')}`, {
        path: rel,
        missing_fields: missingRecommended,
      }));
    }
  }
  return items;
}

function diagnoseMcp() {
  const items = [];
  if (!exists('.mcp.json')) return items;
  const parsed = parseJsonFile('.mcp.json');
  if (!parsed.ok) {
    items.push(issue('blocked', 'mcp.invalid_json', parsed.error, { path: '.mcp.json' }));
    return items;
  }
  const servers = parsed.value.mcpServers;
  if (!servers || typeof servers !== 'object' || Array.isArray(servers)) {
    items.push(issue('blocked', 'mcp.schema_invalid', '.mcp.json must contain an mcpServers object', {
      path: '.mcp.json',
    }));
    return items;
  }
  for (const [name, cfg] of Object.entries(servers)) {
    const meta = { server: name, path: '.mcp.json' };
    if (!cfg || typeof cfg !== 'object' || Array.isArray(cfg)) {
      items.push(issue('blocked', 'mcp.server_invalid', `MCP server ${name} must be an object`, meta));
      continue;
    }
    const type = cfg.type || (cfg.url ? 'http' : 'stdio');
    if (type === 'stdio') {
      if (typeof cfg.command !== 'string' || !cfg.command.trim()) {
        items.push(issue('warning', 'mcp.stdio_missing_command', `MCP server ${name} uses stdio but has no command`, meta));
      }
      if (cfg.args !== undefined && !Array.isArray(cfg.args)) {
        items.push(issue('blocked', 'mcp.args_not_array', `MCP server ${name} args must be an array`, meta));
      }
    } else if (type === 'http' || type === 'ws') {
      if (typeof cfg.url !== 'string' || !/^(https?|wss?):\/\//.test(cfg.url)) {
        items.push(issue('blocked', 'mcp.url_invalid', `MCP server ${name} has invalid ${type} url`, meta));
      }
    } else {
      items.push(issue('blocked', 'mcp.type_unknown', `MCP server ${name} has unknown type: ${type}`, meta));
    }
  }
  return items;
}

function diagnosePermissions(settingsParse) {
  const items = [];
  if (!settingsParse.ok) return items;
  const permissions = settingsParse.value.permissions || {};
  const allow = Array.isArray(permissions.allow) ? permissions.allow : [];
  const deny = Array.isArray(permissions.deny) ? permissions.deny : [];
  if (!Array.isArray(permissions.allow)) {
    items.push(issue('blocked', 'permissions.allow_not_array', 'permissions.allow must be an array', {
      path: '.claude/settings.json',
    }));
  }
  if (!Array.isArray(permissions.deny)) {
    items.push(issue('blocked', 'permissions.deny_not_array', 'permissions.deny must be an array', {
      path: '.claude/settings.json',
    }));
  }

  const dangerousAllowChecks = [
    { id: 'permissions.allow_all_bash', pattern: /^Bash\(\*\)$/, message: 'Bash(*) allows arbitrary shell commands' },
    { id: 'permissions.allow_all_tools', pattern: /^\*$/, message: '* allows every tool' },
    { id: 'permissions.allow_force_push', pattern: /^Bash\(git push .*--force.*\)$/, message: 'force push is allowed' },
    { id: 'permissions.allow_git_reset_hard', pattern: /^Bash\(git reset --hard.*\)$/, message: 'git reset --hard is allowed' },
    { id: 'permissions.allow_rm_rf', pattern: /^Bash\(rm -rf.*\)$/, message: 'rm -rf is allowed' },
    { id: 'permissions.allow_env_read', pattern: /^Read\(\*\*\/\.env.*\)$/, message: '.env reads are allowed' },
  ];
  allow.forEach((entry) => {
    dangerousAllowChecks.forEach((check) => {
      if (typeof entry === 'string' && check.pattern.test(entry)) {
        items.push(issue(check.id.includes('allow_all') ? 'blocked' : 'warning', check.id, check.message, {
          path: '.claude/settings.json',
          permission: entry,
        }));
      }
    });
  });

  const sensitiveDenyPatterns = [
    '.ssh',
    '.aws',
    '.config/gcloud',
    '.azure',
    '.gnupg',
    '.docker/config.json',
    '.kube/config',
  ];
  sensitiveDenyPatterns.forEach((needle) => {
    if (!deny.some((entry) => typeof entry === 'string' && entry.includes(needle))) {
      items.push(issue('warning', 'permissions.sensitive_path_not_denied', `Sensitive credential path is not denied: ${needle}`, {
        path: '.claude/settings.json',
        sensitive_path: needle,
      }));
    }
  });
  return items;
}

function buildReadinessDiagnostics(patternFailures) {
  const settingsParse = parseJsonFile('.claude/settings.json');
  const hooks = diagnoseHooks(settingsParse);
  const schema = diagnoseSkillsAndAgents();
  const mcp = diagnoseMcp();
  const permissions = diagnosePermissions(settingsParse);
  const patternIssues = patternFailures.map((f) => issue(
    ['pte', 'crc', 'dlh', 'pcc'].includes(f.patKey) ? 'warning' : 'warning',
    `pattern.${f.id}`,
    `Pattern check failed: ${f.id}`,
    { pattern: f.patLabel, path: f.path || '' },
  ));

  const all = [...hooks, ...schema, ...mcp, ...permissions, ...patternIssues];
  return {
    level: maxReadinessLevel(all),
    summary: {
      blocked: all.filter((i) => i.severity === 'blocked').length,
      warning: all.filter((i) => i.severity === 'warning').length,
      ready_checks: all.length === 0 ? 1 : 0,
    },
    hooks: {
      level: maxReadinessLevel(hooks),
      issue_count: hooks.length,
      issues: hooks,
    },
    schema: {
      level: maxReadinessLevel(schema),
      issue_count: schema.length,
      issues: schema,
    },
    mcp: {
      level: maxReadinessLevel(mcp),
      issue_count: mcp.length,
      issues: mcp,
    },
    permissions: {
      level: maxReadinessLevel(permissions),
      issue_count: permissions.length,
      issues: permissions,
    },
    pattern_failures: {
      level: maxReadinessLevel(patternIssues),
      issue_count: patternIssues.length,
      issues: patternIssues,
    },
  };
}

// ═══════════════════════════════════════════════════════════════════════════
// FORMATTERS
// ═══════════════════════════════════════════════════════════════════════════

function icon(score) { return score >= 9 ? '✓' : score >= 6 ? '⚠' : '✗'; }

function formatText(result) {
  const lines = [];
  lines.push(`Harness Audit (${result.scope}): ${result.overall_score}/${result.max_score} · rubric ${result.rubric_version}`);
  lines.push(`Source: ${result.rubric_source}`);
  lines.push(`Readiness: ${result.readiness.level} (${result.readiness.summary.blocked} blocked, ${result.readiness.summary.warning} warning)`);
  lines.push('');

  // Group by category
  const byCat = {};
  for (const p of result.patterns) {
    (byCat[p.category] = byCat[p.category] || []).push(p);
  }
  lines.push('Pattern Scores:');
  for (const cat of Object.keys(byCat)) {
    lines.push(`  [${cat}]`);
    for (const p of byCat[cat]) {
      const num = `#${p.num}`.padStart(3);
      lines.push(`    ${icon(p.score)} ${num} ${p.label.padEnd(34)} ${String(p.score).padStart(2)}/10  (${p.passed}/${p.total})`);
    }
  }

  if (result.failed_checks.length) {
    lines.push('');
    lines.push(`Failed Checks (${result.failed_checks.length}):`);
    for (const f of result.failed_checks.slice(0, 25)) {
      const actual = f.actual !== undefined ? `  [actual: ${JSON.stringify(f.actual)}]` : '';
      lines.push(`  [#${f.patNum} ${f.patLabel}] ${f.id}${actual}`);
      if (f.path) lines.push(`    → ${f.path}`);
    }
    if (result.failed_checks.length > 25) {
      lines.push(`  ... and ${result.failed_checks.length - 25} more`);
    }
  }

  const readinessIssues = [
    ...result.readiness.hooks.issues,
    ...result.readiness.schema.issues,
    ...result.readiness.mcp.issues,
    ...result.readiness.permissions.issues,
  ];
  if (readinessIssues.length) {
    lines.push('');
    lines.push(`Readiness Issues (${readinessIssues.length}):`);
    for (const item of readinessIssues) {
      const where = item.path ? ` (${item.path})` : '';
      lines.push(`  [${item.severity}] ${item.id}: ${item.message}${where}`);
    }
  }

  if (result.top_actions.length) {
    lines.push('');
    lines.push('Top 3 Actions:');
    result.top_actions.forEach((a, i) => {
      lines.push(`${i + 1}) [#${a.pattern_num} ${a.pattern}] ${a.action}`);
      if (a.path) lines.push(`   (${a.path})`);
    });
  }

  if (result.suggested_skills.length) {
    lines.push('');
    lines.push('Suggested ECC Skills:');
    lines.push('  ' + result.suggested_skills.join('  '));
  }

  return lines.join('\n');
}

function formatCompact(result) {
  const lines = [];
  const failed = result.failed_checks;
  const critical = failed
    .filter((f) => ['pte', 'crc', 'dlh', 'pcc'].includes(f.patKey))
    .slice(0, 3);
  const warnings = failed
    .filter((f) => !critical.includes(f))
    .slice(0, 5);

  lines.push(`SDD Harness Audit: ${result.overall_score}/${result.max_score} (${result.scope})`);
  lines.push(`Readiness: ${result.readiness.level} (${result.readiness.summary.blocked} blocked, ${result.readiness.summary.warning} warning)`);
  lines.push('');

  lines.push('Critical:');
  const blockedReadiness = [
    ...result.readiness.hooks.issues,
    ...result.readiness.schema.issues,
    ...result.readiness.mcp.issues,
    ...result.readiness.permissions.issues,
  ].filter((i) => i.severity === 'blocked');
  if (critical.length === 0 && blockedReadiness.length === 0) {
    lines.push('- none');
  } else {
    for (const item of blockedReadiness.slice(0, 5)) {
      const path = item.path ? ` (${item.path})` : '';
      lines.push(`- ${item.id}: ${item.message}${path}`);
    }
    for (const f of critical) {
      const path = f.path ? ` (${f.path})` : '';
      lines.push(`- ${f.id}: ${CHECK_HINTS[f.id] || 'Fix failed check'}${path}`);
    }
  }

  lines.push('');
  lines.push('Warnings:');
  const readinessWarnings = [
    ...result.readiness.hooks.issues,
    ...result.readiness.schema.issues,
    ...result.readiness.mcp.issues,
    ...result.readiness.permissions.issues,
  ].filter((i) => i.severity === 'warning');
  if (warnings.length === 0 && readinessWarnings.length === 0) {
    lines.push('- none');
  } else {
    for (const item of readinessWarnings.slice(0, 7)) {
      const path = item.path ? ` (${item.path})` : '';
      lines.push(`- ${item.id}: ${item.message}${path}`);
    }
    for (const f of warnings) {
      const path = f.path ? ` (${f.path})` : '';
      lines.push(`- ${f.id}: ${CHECK_HINTS[f.id] || 'Fix failed check'}${path}`);
    }
    const hiddenFailed = failed.length - critical.length - warnings.length;
    const hiddenReadiness = result.readiness.summary.warning - Math.min(readinessWarnings.length, 7);
    if (hiddenFailed + hiddenReadiness > 0) {
      lines.push(`- ${hiddenFailed + hiddenReadiness} more issue(s); run --full or --format json for details.`);
    }
  }

  lines.push('');
  lines.push('Next:');
  if (result.top_actions.length === 0) {
    if (result.readiness.level === 'ready') {
      lines.push('1. No harness action required.');
      lines.push('2. Run --full only when auditing pattern-level evidence.');
    } else {
      lines.push('1. Run: node scripts/harness-audit.js --format json');
      lines.push('2. Fix blocked items first, then warnings by category.');
    }
  } else {
    result.top_actions.slice(0, 3).forEach((a, i) => {
      const path = a.path ? ` (${a.path})` : '';
      lines.push(`${i + 1}. ${a.action}${path}`);
    });
    lines.push(`${Math.min(result.top_actions.length, 3) + 1}. Run: node scripts/harness-audit.js ${result.scope} --full`);
  }

  return lines.join('\n');
}

// ═══════════════════════════════════════════════════════════════════════════
// CLI
// ═══════════════════════════════════════════════════════════════════════════

function parseArgs(argv) {
  const args = argv.slice(2);
  let scope = 'repo';
  let format = 'compact';
  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === '--format') { format = args[++i] || 'text'; continue; }
    if (a === '--compact') { format = 'compact'; continue; }
    if (a === '--full') { format = 'text'; continue; }
    if (a === '--help' || a === '-h') return { help: true };
    if (a === '--patterns') return { patterns: true };
    if (!a.startsWith('-')) { scope = a; continue; }
  }
  return { scope, format };
}

function printHelp() {
  console.log(
`harness-audit.js — SDD deterministic harness auditor
Rubric: ${RUBRIC_VERSION}
Source: ${RUBRIC_SOURCE}

Usage:
  node scripts/harness-audit.js [scope] [--compact|--full|--format compact|text|json]
  node scripts/harness-audit.js --patterns    # list all 12 patterns

Scopes:
  repo        (default) All 12 patterns, max 120
  memory      Patterns 1-5 (Memory & Context), max 50
  workflow    Patterns 6-8 (Workflow & Orchestration), max 30
  tools       Patterns 9-11 (Tools & Permissions), max 30
  automation  Pattern 12 (Deterministic Lifecycle Hooks), max 10

  Legacy shortcuts:
  hooks       Patterns 4, 5, 10, 12, max 40
  skills      Patterns 2, 11, max 20
  agents      Pattern 7, max 10
  commands    Pattern 11, max 10

Options:
  --compact                Compact decision-grade output (default)
  --full                   Full text report
  --format compact|text|json
  --patterns               List the 12 patterns and exit
  -h, --help               Show this help`);
}

function printPatterns() {
  console.log(`The 12 Agentic Harness Patterns (Ibryam, ${RUBRIC_SOURCE}):\n`);
  let lastCat = '';
  for (const p of PATTERNS) {
    if (p.category !== lastCat) {
      console.log(`[${p.category}]`);
      lastCat = p.category;
    }
    console.log(`  #${String(p.num).padStart(2)}  ${p.label}  (key: ${p.key})`);
  }
}

function main() {
  const parsed = parseArgs(process.argv);
  if (parsed.help) { printHelp(); return; }
  if (parsed.patterns) { printPatterns(); return; }
  if (!SCOPES[parsed.scope]) {
    console.error(`Error: unknown scope "${parsed.scope}". Valid: ${Object.keys(SCOPES).join(', ')}`);
    process.exit(2);
  }
  const result = runAudit(parsed.scope);
  if (parsed.format === 'json') {
    console.log(JSON.stringify(result, null, 2));
  } else if (parsed.format === 'compact') {
    console.log(formatCompact(result));
  } else {
    console.log(formatText(result));
  }
}

if (require.main === module) {
  try { main(); }
  catch (e) {
    console.error('Internal error:', e && e.stack || e);
    process.exit(1);
  }
}

module.exports = { runAudit, PATTERNS, RUBRIC_VERSION, RUBRIC_SOURCE };
