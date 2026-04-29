#!/usr/bin/env node
/*
 * P1 quality gates:
 * 1) PR evidence gate (for pull_request events)
 * 2) Stage transition gate for design/specs/*.md changes
 */

const fs = require('fs');
const cp = require('child_process');

function run(cmd) {
  return cp.execSync(cmd, { encoding: 'utf8' }).trim();
}

function fail(msg) {
  console.error(`P1_GATE_FAIL: ${msg}`);
  process.exit(2);
}

function readEvent() {
  const p = process.env.GITHUB_EVENT_PATH;
  if (!p || !fs.existsSync(p)) return null;
  try {
    return JSON.parse(fs.readFileSync(p, 'utf8'));
  } catch {
    return null;
  }
}

function gatePrEvidence() {
  const evt = readEvent();
  if (!evt || !evt.pull_request) return;

  const body = (evt.pull_request.body || '').toLowerCase();
  const required = [
    /spec[_ -]?id\s*:/,
    /(test|lint|build)\s*(result|output|evidence)?\s*:/,
    /risk\s*:/,
    /(rollback|fallback)\s*:/,
    /(given|when|then)/
  ];

  const missing = required.filter((re) => !re.test(body));
  if (missing.length > 0) {
    fail('PR evidence is incomplete. Required sections: Spec ID, Test/Lint/Build evidence, Risk, Rollback/Fallback, Given/When/Then.');
  }
}

function parseFrontmatter(text) {
  const lines = text.split(/\r?\n/);
  if (lines[0] !== '---') return null;
  const end = lines.indexOf('---', 1);
  if (end < 0) return null;
  const map = {};
  for (const line of lines.slice(1, end)) {
    const m = line.match(/^\s*([a-zA-Z_]+)\s*:\s*(.+)\s*$/);
    if (m) map[m[1].toLowerCase()] = m[2];
  }
  return map;
}

function stageRank(stage) {
  const order = ['discovery', 'planning', 'implementation', 'verification', 'release'];
  return order.indexOf((stage || '').toLowerCase());
}

function gateStageTransition() {
  let changed = '';
  try {
    changed = run('git diff --name-only HEAD~1 HEAD');
  } catch {
    return;
  }
  const files = changed.split(/\r?\n/).filter((f) => /^design\/specs\/.*\.md$/.test(f));
  for (const f of files) {
    if (!fs.existsSync(f)) continue;
    const content = fs.readFileSync(f, 'utf8');
    const fm = parseFrontmatter(content);
    if (!fm) fail(`${f} missing YAML frontmatter.`);
    for (const k of ['stage', 'tier', 'spec_id']) {
      if (!fm[k]) fail(`${f} frontmatter missing ${k}.`);
    }
    const s = stageRank(fm.stage);
    if (s < 0) fail(`${f} has invalid stage '${fm.stage}'.`);

    // Stage checklist automation (minimal enforceable set)
    if (s >= stageRank('implementation') && !/##\s+proposed flow/i.test(content)) {
      fail(`${f} at implementation+ must include '## Proposed Flow'.`);
    }
    if (s >= stageRank('verification')) {
      if (!/##\s+verification/i.test(content)) fail(`${f} at verification+ must include '## Verification'.`);
      if (!/given/i.test(content) || !/when/i.test(content) || !/then/i.test(content)) {
        fail(`${f} at verification+ must include Given/When/Then acceptance.`);
      }
    }
    if (s >= stageRank('release') && !/rollback|fallback/i.test(content)) {
      fail(`${f} at release must document rollback/fallback.`);
    }
  }
}

gatePrEvidence();
gateStageTransition();
console.log('P1 quality gates: pass');