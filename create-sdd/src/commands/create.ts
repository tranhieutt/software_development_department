import * as p from '@clack/prompts';
import chalk from 'chalk';

/** Called when binary is invoked as `npx create-sdd [dir]` */
export function createCommand(args: string[]): void {
  const dir = args[0] ?? '.';
  run(dir).catch((err) => {
    console.error(chalk.red('Error:'), err.message);
    process.exit(1);
  });
}

export async function run(targetDir: string): Promise<void> {
  p.intro(chalk.bgCyan(' create-sdd ') + ' Claude Code Software Development Department');

  p.outro(chalk.yellow('🚧 create command — coming in Phase 4'));
  process.exit(0);
}
