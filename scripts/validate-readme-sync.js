#!/usr/bin/env node
/**
 * Validate README inventory sync for the English and Vietnamese storefront docs.
 *
 * Source of truth is the filesystem, not hard-coded marketing copy:
 * - .claude/agents/*.md
 * - .claude/skills/<skill>/SKILL.md folders
 * - .claude/hooks files, counted recursively
 * - .claude/rules/*.md
 */

'use strict';

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const P = (...parts) => path.join(ROOT, ...parts);

function readText(rel) {
  return fs.readFileSync(P(rel), 'utf8');
}

function listDir(rel) {
  return fs.readdirSync(P(rel), { withFileTypes: true });
}

function countFilesRecursive(rel) {
  let count = 0;
  for (const entry of listDir(rel)) {
    const child = path.join(rel, entry.name);
    if (entry.isDirectory()) {
      count += countFilesRecursive(child);
    } else if (entry.isFile()) {
      count += 1;
    }
  }
  return count;
}

function listAgentNames() {
  return listDir('.claude/agents')
    .filter((entry) => entry.isFile() && entry.name.endsWith('.md'))
    .map((entry) => entry.name.replace(/\.md$/, ''))
    .sort();
}

function countSkillFolders() {
  return listDir('.claude/skills')
    .filter((entry) =>
      entry.isDirectory() &&
      !entry.name.startsWith('_') &&
      entry.name !== 'templates'
    )
    .length;
}

function countRuleFiles() {
  return listDir('.claude/rules')
    .filter((entry) => entry.isFile() && entry.name.endsWith('.md'))
    .length;
}

function formatInventory(inv) {
  return `${inv.agents} agents, ${inv.skills} skills, ${inv.hooks} hook files, ${inv.rules} rules`;
}

const agentNames = listAgentNames();
const agentSet = new Set(agentNames);
const inventory = {
  agents: agentNames.length,
  skills: countSkillFolders(),
  hooks: countFilesRecursive('.claude/hooks'),
  rules: countRuleFiles(),
};

const failures = [];

function fail(file, message) {
  failures.push(`${file}: ${message}`);
}

function requireIncludes(file, text, snippet, label) {
  if (!text.includes(snippet)) {
    fail(file, `missing ${label}: ${JSON.stringify(snippet)}`);
  }
}

function requireRegex(file, text, regex, label) {
  if (!regex.test(text)) {
    fail(file, `missing ${label}: ${regex}`);
  }
}

function rejectRegex(file, text, regex, label) {
  if (regex.test(text)) {
    fail(file, `stale ${label}: ${regex}`);
  }
}

function validateRoster(file, text) {
  const heading = text.indexOf('### Department Hierarchy');
  if (heading === -1) {
    fail(file, 'missing Department Hierarchy section');
    return;
  }

  const fenceStart = text.indexOf('```', heading);
  const fenceEnd = text.indexOf('```', fenceStart + 3);
  if (fenceStart === -1 || fenceEnd === -1) {
    fail(file, 'missing Department Hierarchy roster code block');
    return;
  }

  const block = text.slice(fenceStart + 3, fenceEnd);
  const roster = new Set(block.match(/\b[a-z][a-z0-9-]*\b/g) || []);
  const missing = agentNames.filter((name) => !roster.has(name));
  const unexpected = [...roster].filter((name) => !agentSet.has(name));

  if (missing.length) {
    fail(file, `roster missing agent(s): ${missing.join(', ')}`);
  }
  if (unexpected.length) {
    fail(file, `roster contains unknown agent(s): ${unexpected.join(', ')}`);
  }
}

function validateReadme(file, separator) {
  const text = readText(file);
  const tagline = `${inventory.agents} agents ${separator} ${inventory.skills} context-optimized skills`;

  requireIncludes(file, text, tagline, 'inventory tagline');
  requireIncludes(file, text, `badge/agents-${inventory.agents}-`, 'agents badge count');
  requireIncludes(file, text, `alt="${inventory.agents} Agents"`, 'agents badge alt');
  requireIncludes(file, text, `badge/skills-${inventory.skills}-`, 'skills badge count');
  requireIncludes(file, text, `alt="${inventory.skills} Skills"`, 'skills badge alt');
  requireIncludes(file, text, `badge/hooks-${inventory.hooks}-`, 'hooks badge count');
  requireRegex(file, text, new RegExp(`alt="${inventory.hooks} Hook(?: Files|s)"`), 'hooks badge alt');
  requireIncludes(file, text, `badge/rules-${inventory.rules}-`, 'rules badge count');
  requireIncludes(file, text, `alt="${inventory.rules} Rules"`, 'rules badge alt');

  requireRegex(file, text, new RegExp(`Structured Agent Definitions.*${inventory.agents} agents`), 'structured agent count');
  requireRegex(file, text, new RegExp(`Skill Routing.*${inventory.skills} skills`), 'skill routing count');
  requireRegex(file, text, new RegExp(String.raw`\`/\`[^\n]*${inventory.skills}`), 'slash-menu skill count');
  requireRegex(file, text, new RegExp(`\\b${inventory.skills} workflows\\b`), 'workflow count');

  requireIncludes(file, text, `| **Agents** | ${inventory.agents} |`, 'included agents count');
  requireIncludes(file, text, `| **Skills** | ${inventory.skills} |`, 'included skills count');
  requireIncludes(file, text, `| **Hooks** | ${inventory.hooks} |`, 'included hooks count');
  requireRegex(file, text, new RegExp(`agents/\\s+# ${inventory.agents} agent definitions`), 'tree agents count');
  requireRegex(file, text, new RegExp(`skills/\\s+# ${inventory.skills} skills`), 'tree skills count');
  requireRegex(file, text, new RegExp(`hooks/\\s+# ${inventory.hooks} hook scripts`), 'tree hooks count');

  rejectRegex(file, text, /\b31 agents\b|agents-31|31 Agents|31 agent definitions/i, '31-agent count');
  rejectRegex(file, text, /\b116 context-optimized skills\b|skills-116|116 Skills|\b117 skills\b|\b123 skills\b|\b123 workflows\b/i, 'skill count');
  rejectRegex(file, text, /hooks-20|20 Hooks|20 hooks|15 hook scripts/i, 'hook count');
  rejectRegex(file, text, /\bqa-tester\b/, 'ghost qa-tester reference');

  validateRoster(file, text);
}

validateReadme('README.md', '-');
validateReadme('README_vn.md', String.fromCharCode(0xb7));

if (failures.length) {
  console.error(`README sync check failed. Expected ${formatInventory(inventory)}.`);
  for (const item of failures) {
    console.error(`FAIL  ${item}`);
  }
  process.exit(1);
}

console.log(`README sync check passed (${formatInventory(inventory)}).`);
