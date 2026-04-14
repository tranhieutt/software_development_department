import { Command } from 'commander';
import * as p from '@clack/prompts';
import chalk from 'chalk';

export function upgradeCommand(): Command {
  return new Command('upgrade')
    .description('Upgrade SDD templates to the latest version')
    .option('--dry-run', 'Preview changes without writing files')
    .option('--module <name>', 'Upgrade only a specific module')
    .action(async () => {
      p.intro(chalk.bgCyan(' sdd upgrade '));
      p.outro(chalk.yellow('🚧 upgrade command — coming in Phase 6'));
    });
}
