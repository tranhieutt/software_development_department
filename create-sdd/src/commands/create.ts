import * as p from '@clack/prompts';
import chalk from 'chalk';
import { resolve, basename } from 'path';
import { existsSync, mkdirSync } from 'fs';
import { promptStack } from '../prompts/stack.js';
import { promptModules, ALL_MODULES, MINIMAL_MODULES } from '../prompts/modules.js';
import { buildVars } from '../template/engine.js';
import { install } from '../template/installer.js';
import { readPackageVersion } from '../utils/version.js';

export interface CreateOptions {
  stack?: string;
  minimal?: boolean;
}

/** Called when binary is invoked as `npx create-sdd [dir]` */
export function createCommand(args: string[]): void {
  const dir = args.find((a) => !a.startsWith('-')) ?? '.';
  const opts: CreateOptions = {
    stack:   args.includes('--stack')   ? args[args.indexOf('--stack') + 1]   : undefined,
    minimal: args.includes('--minimal'),
  };
  run(dir, opts).catch((err) => {
    console.error(chalk.red('Error:'), err.message);
    process.exit(1);
  });
}

export async function run(targetDir: string, opts: CreateOptions = {}): Promise<void> {
  const absTarget = resolve(targetDir);
  const projectName = basename(absTarget);

  p.intro(chalk.bgCyan(' create-sdd ') + '  Claude Code Software Development Department');

  // 1. Confirm target directory
  if (existsSync(absTarget) && targetDir !== '.') {
    const overwrite = await p.confirm({
      message: `Directory "${projectName}" already exists. Continue anyway?`,
      initialValue: false,
    });
    if (p.isCancel(overwrite) || !overwrite) { p.cancel('Aborted.'); process.exit(0); }
  }
  mkdirSync(absTarget, { recursive: true });

  // 2. Stack selection
  const stackVars = await promptStack(opts.stack);

  // 3. Module selection
  const modules = await promptModules(opts.minimal);

  // 4. Build template vars
  const sddVersion = readPackageVersion();
  const vars = buildVars({ ...stackVars, PROJECT_NAME: projectName }, projectName, sddVersion);

  // 5. Install
  const spinner = p.spinner();
  spinner.start('Installing SDD...');
  const result = await install({
    targetDir: absTarget,
    vars,
    modules,
    conflictStrategy: 'overwrite',
  });
  spinner.stop(`Installed ${result.copied.length} files`);

  if (result.skipped.length > 0) {
    p.log.warn(`Skipped ${result.skipped.length} existing files (preserved user content)`);
  }

  // 6. Next steps
  p.outro(
    chalk.green('✓ SDD installed!') +
    `\n\n  Next steps:\n` +
    (targetDir !== '.' ? `    ${chalk.cyan(`cd ${projectName}`)}\n` : '') +
    `    ${chalk.cyan('code .')}\n` +
    `    Open Claude Code and run ${chalk.cyan('/start')} to configure your stack\n`
  );
}
