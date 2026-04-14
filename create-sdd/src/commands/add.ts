import { Command } from 'commander';
import * as p from '@clack/prompts';
import chalk from 'chalk';

export const MODULES = ['skills', 'rules', 'hooks', 'memory', 'agents'] as const;
export type Module = (typeof MODULES)[number];

export function addCommand(): Command {
  return new Command('add')
    .description('Add or update a specific SDD module')
    .argument('<module>', `Module to add: ${MODULES.join(', ')}`)
    .action(async (module: string) => {
      p.intro(chalk.bgCyan(` sdd add ${module} `));
      p.outro(chalk.yellow('🚧 add command — coming in Phase 7'));
    });
}
