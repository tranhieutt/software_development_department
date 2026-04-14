/**
 * installer.ts — copies SDD template files into a target project directory.
 * Handles: file existence checks, conflict resolution, settings.json merge,
 * and MEMORY.md preservation.
 */
import { mkdirSync, readdirSync, statSync, existsSync, readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { render, type TemplateVars } from './engine.js';

const __dirname = fileURLToPath(new URL('.', import.meta.url));
const TEMPLATES_DIR = join(__dirname, '../../templates');

export type ConflictStrategy = 'skip' | 'overwrite' | 'merge';

export interface InstallOptions {
  targetDir: string;
  vars: TemplateVars;
  modules: string[];           // e.g. ['agents','skills','rules','hooks','memory']
  conflictStrategy: ConflictStrategy;
  dryRun?: boolean;
}

export interface InstallResult {
  copied: string[];
  skipped: string[];
  merged: string[];
}

/** Modules → template subdirectory mapping */
const MODULE_MAP: Record<string, string> = {
  agents:  '.claude/agents',
  skills:  '.claude/skills',
  rules:   '.claude/rules',
  hooks:   '.claude/hooks',
  docs:    '.claude/docs',
  memory:  '.claude/memory',
};

/** Files that must never be overwritten if they already contain user content */
const PRESERVE_IF_EXISTS = new Set([
  '.claude/memory/MEMORY.md',
  'CLAUDE.md',
]);

export async function install(opts: InstallOptions): Promise<InstallResult> {
  const result: InstallResult = { copied: [], skipped: [], merged: [] };
  const { targetDir, vars, modules, conflictStrategy, dryRun = false } = opts;

  // 1. Install CLAUDE.md from template
  await installTemplateFile(
    join(TEMPLATES_DIR, 'CLAUDE.md.template'),
    join(targetDir, 'CLAUDE.md'),
    vars, conflictStrategy, dryRun, result
  );

  // 2. Install selected modules
  for (const mod of modules) {
    const srcSubdir = MODULE_MAP[mod];
    if (!srcSubdir) continue;
    const srcDir = join(TEMPLATES_DIR, srcSubdir);
    const destDir = join(targetDir, srcSubdir);
    if (!existsSync(srcDir)) continue;
    copyDir(srcDir, destDir, srcSubdir, vars, conflictStrategy, dryRun, result);
  }

  // 3. Merge settings.json
  await mergeSettings(
    join(TEMPLATES_DIR, 'settings.json.template'),
    join(targetDir, '.claude', 'settings.json'),
    dryRun, result
  );

  // 4. Write .claude/sdd-version.json
  const versionFile = join(targetDir, '.claude', 'sdd-version.json');
  if (!dryRun) {
    mkdirSync(dirname(versionFile), { recursive: true });
    writeFileSync(versionFile, JSON.stringify({
      version: vars.SDD_VERSION,
      installedAt: new Date().toISOString(),
      modules,
    }, null, 2), 'utf-8');
  }
  result.copied.push('.claude/sdd-version.json');

  return result;
}

// ── Helpers ──────────────────────────────────────────────────────────────────

function copyDir(
  srcDir: string,
  destDir: string,
  relBase: string,
  vars: TemplateVars,
  strategy: ConflictStrategy,
  dryRun: boolean,
  result: InstallResult
): void {
  const entries = readdirSync(srcDir);
  for (const entry of entries) {
    const src = join(srcDir, entry);
    const dest = join(destDir, entry);
    const relPath = `${relBase}/${entry}`;
    if (statSync(src).isDirectory()) {
      copyDir(src, dest, relPath, vars, strategy, dryRun, result);
    } else {
      installTemplateFile(src, dest, vars, strategy, dryRun, result);
    }
  }
}

async function installTemplateFile(
  src: string,
  dest: string,
  vars: TemplateVars,
  strategy: ConflictStrategy,
  dryRun: boolean,
  result: InstallResult
): Promise<void> {
  const relDest = dest; // used in result arrays for readability

  if (existsSync(dest) && PRESERVE_IF_EXISTS.has(getRelative(dest))) {
    result.skipped.push(relDest);
    return;
  }

  if (existsSync(dest) && strategy === 'skip') {
    result.skipped.push(relDest);
    return;
  }

  const raw = readFileSync(src, 'utf-8');
  const rendered = render(raw, vars);

  if (!dryRun) {
    mkdirSync(dirname(dest), { recursive: true });
    writeFileSync(dest, rendered, 'utf-8');
  }
  result.copied.push(relDest);
}

/** Merge settings.json: append hooks arrays, preserve user permissions */
async function mergeSettings(
  templatePath: string,
  destPath: string,
  dryRun: boolean,
  result: InstallResult
): Promise<void> {
  const template = JSON.parse(readFileSync(templatePath, 'utf-8')) as Record<string, unknown>;

  if (!existsSync(destPath)) {
    if (!dryRun) {
      mkdirSync(dirname(destPath), { recursive: true });
      writeFileSync(destPath, JSON.stringify(template, null, 2), 'utf-8');
    }
    result.copied.push('.claude/settings.json');
    return;
  }

  // Existing settings — deep-merge hooks (append, deduplicate by command)
  const existing = JSON.parse(readFileSync(destPath, 'utf-8')) as Record<string, unknown>;
  const merged = deepMergeSettings(existing, template);
  if (!dryRun) {
    writeFileSync(destPath, JSON.stringify(merged, null, 2), 'utf-8');
  }
  result.merged.push('.claude/settings.json');
}

function deepMergeSettings(existing: Record<string, unknown>, incoming: Record<string, unknown>): Record<string, unknown> {
  const result = { ...existing };

  const existingHooks = (existing['hooks'] ?? {}) as Record<string, unknown[]>;
  const incomingHooks = (incoming['hooks'] ?? {}) as Record<string, unknown[]>;

  const mergedHooks: Record<string, unknown[]> = { ...existingHooks };
  for (const [event, entries] of Object.entries(incomingHooks)) {
    if (!mergedHooks[event]) {
      mergedHooks[event] = entries;
    } else {
      // Append entries not already present (deduplicate by JSON equality)
      const existing = new Set(mergedHooks[event].map((e) => JSON.stringify(e)));
      for (const entry of entries) {
        if (!existing.has(JSON.stringify(entry))) {
          mergedHooks[event].push(entry);
        }
      }
    }
  }
  result['hooks'] = mergedHooks;
  return result;
}

function getRelative(absPath: string): string {
  // Normalize to forward slashes and extract the .claude/... part
  const normalized = absPath.replace(/\\/g, '/');
  const idx = normalized.indexOf('/.claude/');
  if (idx >= 0) return normalized.slice(idx + 1);
  if (normalized.endsWith('/CLAUDE.md')) return 'CLAUDE.md';
  return normalized;
}

