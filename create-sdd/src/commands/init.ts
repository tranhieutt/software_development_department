import { Command } from 'commander';
import * as p from '@clack/prompts';
import chalk from 'chalk';

export function initCommand(): Command {
  return new Command('init')
    .description('Add SDD to an existing project')
    .option('--stack <preset>', 'Use a preset stack (ts-nextjs, py-fastapi, go-gin, ...)')
    .option('--minimal', 'Install only CLAUDE.md and core rules')
    .action(async () => {
      p.intro(chalk.bgCyan(' sdd init '));
      p.outro(chalk.yellow('🚧 init command — coming in Phase 5'));
    });
}
