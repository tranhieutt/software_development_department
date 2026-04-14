/**
 * modules.ts — checkbox prompt for selecting which SDD modules to install.
 */
import * as p from '@clack/prompts';
import { MODULES, type Module } from '../commands/add.js';

export interface ModuleOption {
  value: Module;
  label: string;
  hint: string;
}

const MODULE_OPTIONS: ModuleOption[] = [
  { value: 'agents',  label: 'Agents',  hint: '27 specialist agent definitions (backend, frontend, QA, ...)' },
  { value: 'skills',  label: 'Skills',  hint: '115 slash-command skills (/plan, /tdd, /spec, ...)' },
  { value: 'rules',   label: 'Rules',   hint: '13 domain coding rules (api, db, frontend, secrets, ...)' },
  { value: 'hooks',   label: 'Hooks',   hint: '11 lifecycle hooks (session-start, bash-guard, validate-commit, ...)' },
  { value: 'memory',  label: 'Memory',  hint: 'MEMORY.md tiered memory system' },
];

/** Full install — all modules */
export const ALL_MODULES: Module[] = MODULES as unknown as Module[];

/** Minimal install — only the essentials */
export const MINIMAL_MODULES: Module[] = ['rules', 'hooks', 'memory'];

/**
 * Prompt the user to pick which modules to install.
 * Returns an array of selected Module names.
 */
export async function promptModules(minimal = false): Promise<Module[]> {
  if (minimal) {
    p.log.info(`Minimal install: ${MINIMAL_MODULES.join(', ')}`);
    return MINIMAL_MODULES;
  }

  const installAll = await p.confirm({
    message: 'Install all SDD modules? (agents + skills + rules + hooks + memory)',
    initialValue: true,
  });
  if (p.isCancel(installAll)) { p.cancel('Cancelled.'); process.exit(0); }

  if (installAll) return ALL_MODULES;

  // Selective checkbox
  const selected = await p.multiselect({
    message: 'Select modules to install:',
    options: MODULE_OPTIONS,
    required: true,
  });
  if (p.isCancel(selected)) { p.cancel('Cancelled.'); process.exit(0); }

  return selected as unknown as Module[];
}
