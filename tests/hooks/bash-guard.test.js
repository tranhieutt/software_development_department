/**
 * Smoke tests for .claude/hooks/bash-guard.sh (and bash-guard.ps1 on Windows)
 *
 * Exit codes:
 *   0 = allowed (safe command or soft warning)
 *   2 = blocked (hard deny)
 *
 * Test naming: [category]_[scenario]_[expected]
 */

const { execFileSync } = require('child_process');
const path = require('path');

const isWindows = process.platform === 'win32';
const hookPath = path.join(
    __dirname,
    isWindows ? '../../.claude/hooks/bash-guard.ps1' : '../../.claude/hooks/bash-guard.sh'
);
const hookRunner = isWindows
    ? {
        command: 'powershell.exe',
        args: ['-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', hookPath]
    }
    : {
        command: 'bash',
        args: [hookPath]
    };

function runHook(command, toolName = 'Bash') {
    const input = { tool_name: toolName, tool_input: { command } };
    try {
        const stdout = execFileSync(hookRunner.command, hookRunner.args, {
            input: JSON.stringify(input),
            encoding: 'utf8',
            stdio: ['pipe', 'pipe', 'pipe']
        });
        return { status: 0, stdout, stderr: '' };
    } catch (error) {
        return {
            status: error.status,
            stdout: error.stdout || '',
            stderr: error.stderr || error.message || ''
        };
    }
}

// ─── Test runner ──────────────────────────────────────────────────────────────

let passed = 0;
let failed = 0;

function test(name, fn) {
    try {
        fn();
        console.log(`  PASS: ${name}`);
        passed++;
    } catch (err) {
        console.error(`  FAIL: ${name}`);
        console.error(`        ${err.message}`);
        failed++;
    }
}

function assertStatus(result, expected, hint = '') {
    if (result.status !== expected) {
        throw new Error(
            `Expected exit ${expected}, got ${result.status}` +
            (hint ? ` | ${hint}` : '') +
            (result.stderr ? `\n        stderr: ${result.stderr.trim()}` : '')
        );
    }
}

function assertOutputContains(result, substring) {
    const all = result.stdout + result.stderr;
    if (!all.includes(substring)) {
        throw new Error(`Expected output to contain "${substring}"\n        got: ${all.trim()}`);
    }
}

// ─── PASS-THROUGH ─────────────────────────────────────────────────────────────

console.log('\n[pass-through]');

test('passthrough_safe_command_allowed', () => {
    assertStatus(runHook('ls -la'), 0);
});

test('passthrough_echo_allowed', () => {
    assertStatus(runHook('echo hello'), 0);
});

test('passthrough_non_bash_tool_skipped', () => {
    // Hook must exit 0 immediately for non-Bash tools
    assertStatus(runHook('rm -rf /', 'Read'), 0);
});

test('passthrough_git_status_allowed', () => {
    assertStatus(runHook('git status'), 0);
});

// ─── HARD BLOCKS — fork bomb ──────────────────────────────────────────────────

console.log('\n[block: fork bomb]');

test('block_fork_bomb_standard_blocked', () => {
    assertStatus(runHook(':(){ :|:& };:'), 2);
});

// ─── HARD BLOCKS — rm -rf variants ───────────────────────────────────────────

console.log('\n[block: rm -rf variants]');

test('block_rm_rf_root_slash_blocked', () => {
    assertStatus(runHook('rm -rf /'), 2);
});

test('block_rm_fr_root_slash_blocked', () => {
    assertStatus(runHook('rm -fr /'), 2);
});

test('block_rm_r_f_root_slash_blocked', () => {
    assertStatus(runHook('rm -r -f /'), 2);
});

test('block_rm_f_r_root_slash_blocked', () => {
    assertStatus(runHook('rm -f -r /'), 2);
});

test('block_rm_rf_wildcard_blocked', () => {
    assertStatus(runHook('rm -rf *'), 2);
});

test('block_rm_fr_wildcard_blocked', () => {
    assertStatus(runHook('rm -fr *'), 2);
});

// ─── HARD BLOCKS — .env overwrites ───────────────────────────────────────────

console.log('\n[block: .env overwrite]');

test('block_tee_env_blocked', () => {
    assertStatus(runHook('echo SECRET=V | tee .env'), 2);
});

test('block_tee_env_production_blocked', () => {
    assertStatus(runHook('cat secrets | tee .env.production'), 2);
});

test('block_redirect_to_env_blocked', () => {
    assertStatus(runHook('echo KEY=val > .env'), 2);
});

// ─── HARD BLOCKS — disk operations ───────────────────────────────────────────

console.log('\n[block: disk operations]');

test('block_mkfs_blocked', () => {
    assertStatus(runHook('mkfs.ext4 /dev/sdb'), 2);
});

test('block_direct_disk_write_blocked', () => {
    assertStatus(runHook('cat file > /dev/sda'), 2);
});

test('block_dd_dev_zero_blocked', () => {
    assertStatus(runHook('dd if=/dev/zero of=/dev/sda'), 2);
});

test('block_dd_dev_random_blocked', () => {
    assertStatus(runHook('dd if=/dev/random of=/dev/sda'), 2);
});

// ─── HARD BLOCKS — cron & package publish ────────────────────────────────────

console.log('\n[block: cron & publish]');

test('block_crontab_r_blocked', () => {
    assertStatus(runHook('crontab -r'), 2);
});

test('block_twine_upload_blocked', () => {
    assertStatus(runHook('twine upload dist/*'), 2);
});

// ─── SOFT WARNINGS — SQL ─────────────────────────────────────────────────────

console.log('\n[warn: SQL]');

test('warn_drop_table_exits_0', () => {
    assertStatus(runHook('DROP TABLE users'), 0);
});

test('warn_drop_table_prints_warning', () => {
    const result = runHook('DROP TABLE users');
    assertOutputContains(result, 'SQL DROP TABLE');
});

test('warn_delete_from_exits_0', () => {
    const result = runHook('DELETE FROM orders WHERE id=1');
    assertStatus(result, 0);
});

test('warn_delete_from_prints_warning', () => {
    const result = runHook('DELETE FROM orders WHERE id=1');
    assertOutputContains(result, 'SQL DELETE FROM');
});

test('warn_truncate_exits_0', () => {
    assertStatus(runHook('TRUNCATE TABLE logs'), 0);
});

test('warn_truncate_prints_warning', () => {
    const result = runHook('TRUNCATE TABLE logs');
    assertOutputContains(result, 'SQL TRUNCATE');
});

test('warn_drop_database_exits_0', () => {
    const result = runHook('DROP DATABASE mydb');
    assertStatus(result, 0);
});

test('warn_drop_database_prints_warning', () => {
    const result = runHook('DROP DATABASE mydb');
    assertOutputContains(result, 'SQL DROP DATABASE');
});

// ─── SOFT WARNINGS — git ─────────────────────────────────────────────────────

console.log('\n[warn: git]');

test('warn_git_reset_hard_exits_0', () => {
    assertStatus(runHook('git reset --hard'), 0);
});

test('warn_git_reset_hard_prints_warning', () => {
    const result = runHook('git reset --hard');
    assertOutputContains(result, 'git reset --hard');
});

test('warn_git_clean_f_exits_0', () => {
    assertStatus(runHook('git clean -f'), 0);
});

test('warn_git_clean_fd_exits_0', () => {
    assertStatus(runHook('git clean -fd'), 0);
});

// ─── SOFT WARNINGS — docker ───────────────────────────────────────────────────

console.log('\n[warn: docker]');

test('warn_docker_volume_rm_exits_0', () => {
    assertStatus(runHook('docker volume rm mydata'), 0);
});

test('warn_docker_volume_rm_prints_warning', () => {
    const result = runHook('docker volume rm mydata');
    assertOutputContains(result, 'docker volume rm');
});

// ─── SUMMARY ──────────────────────────────────────────────────────────────────

console.log(`\n${'─'.repeat(50)}`);
console.log(`Results: ${passed} passed, ${failed} failed`);

if (failed > 0) {
    process.exit(1);
}
console.log('All bash-guard tests passed!');
