/**
 * stack.ts — interactive prompts for technology stack selection.
 * Returns a partial TemplateVars with stack fields populated.
 */
import * as p from '@clack/prompts';
import { PRESETS, UNCONFIGURED, type TemplateVars } from '../template/engine.js';

export interface StackAnswers {
  language: string;
  frontendFramework: string;
  backendFramework: string;
  database: string;
  deployment: string;
  cicd: string;
}

/** Ask the user to pick a preset OR configure manually */
export async function promptStack(presetKey?: string): Promise<Partial<TemplateVars>> {
  // Shortcut: preset passed via --stack flag
  if (presetKey) {
    const preset = PRESETS[presetKey];
    if (!preset) {
      p.log.warn(`Unknown preset "${presetKey}". Available: ${Object.keys(PRESETS).join(', ')}`);
    } else {
      p.log.success(`Using preset: ${presetKey}`);
      return preset;
    }
  }

  // Ask: use a preset or configure manually?
  const mode = await p.select({
    message: 'How do you want to configure the technology stack?',
    options: [
      { value: 'preset',  label: 'Use a preset  (quick start)' },
      { value: 'manual',  label: 'Configure manually' },
      { value: 'skip',    label: 'Skip for now  (fill in CLAUDE.md later)' },
    ],
  });

  if (p.isCancel(mode)) { p.cancel('Cancelled.'); process.exit(0); }
  if (mode === 'skip') return {};

  if (mode === 'preset') {
    const chosen = await p.select({
      message: 'Choose a preset stack:',
      options: Object.entries(PRESETS).map(([key, vals]) => ({
        value: key,
        label: `${key.padEnd(14)} — ${vals.LANGUAGE} / ${vals.BACKEND_FRAMEWORK ?? vals.FRONTEND_FRAMEWORK}`,
      })),
    });
    if (p.isCancel(chosen)) { p.cancel('Cancelled.'); process.exit(0); }
    return PRESETS[chosen as string] ?? {};
  }

  // Manual configuration
  const language = await p.text({
    message: 'Primary language?',
    placeholder: 'TypeScript',
    defaultValue: UNCONFIGURED,
  });
  if (p.isCancel(language)) { p.cancel('Cancelled.'); process.exit(0); }

  const frontendFramework = await p.text({
    message: 'Frontend framework?  (leave blank if none)',
    placeholder: 'React / Next.js / Vue / none',
    defaultValue: 'none',
  });
  if (p.isCancel(frontendFramework)) { p.cancel('Cancelled.'); process.exit(0); }

  const backendFramework = await p.text({
    message: 'Backend framework?  (leave blank if none)',
    placeholder: 'Express / FastAPI / NestJS / none',
    defaultValue: 'none',
  });
  if (p.isCancel(backendFramework)) { p.cancel('Cancelled.'); process.exit(0); }

  const database = await p.text({
    message: 'Database?  (leave blank if none)',
    placeholder: 'PostgreSQL / MongoDB / SQLite / none',
    defaultValue: 'none',
  });
  if (p.isCancel(database)) { p.cancel('Cancelled.'); process.exit(0); }

  const deployment = await p.text({
    message: 'Deployment target?',
    placeholder: 'Docker / Vercel / Railway / AWS',
    defaultValue: UNCONFIGURED,
  });
  if (p.isCancel(deployment)) { p.cancel('Cancelled.'); process.exit(0); }

  const cicd = await p.text({
    message: 'CI/CD platform?',
    placeholder: 'GitHub Actions / GitLab CI / none',
    defaultValue: UNCONFIGURED,
  });
  if (p.isCancel(cicd)) { p.cancel('Cancelled.'); process.exit(0); }

  return {
    LANGUAGE:           String(language),
    FRONTEND_FRAMEWORK: String(frontendFramework),
    BACKEND_FRAMEWORK:  String(backendFramework),
    DATABASE:           String(database),
    DEPLOYMENT:         String(deployment),
    CICD:               String(cicd),
  };
}
