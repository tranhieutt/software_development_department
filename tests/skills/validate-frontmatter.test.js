const fs = require('fs');
const path = require('path');

const memoryDir = path.join(__dirname, '../../.claude/memory');
const specialistsDir = path.join(memoryDir, 'specialists');

function checkFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    const hasFrontmatter = content.startsWith('---') && content.includes('\n---');
    if (!hasFrontmatter) {
        console.error(`FAIL: ${filePath} missing YAML frontmatter`);
        return false;
    }
    return true;
}

const files = fs.readdirSync(memoryDir)
    .filter(f => f.endsWith('.md') && f !== 'MEMORY.md')
    .map(f => path.join(memoryDir, f))
    .concat(
        fs.readdirSync(specialistsDir)
            .filter(f => f.endsWith('.md'))
            .map(f => path.join(specialistsDir, f))
    );

let allPassed = true;
files.forEach(f => {
    if (!checkFile(f)) allPassed = false;
});

if (allPassed) {
    console.log(`PASS: All ${files.length} memory topic files have YAML frontmatter.`);
    process.exit(0);
} else {
    process.exit(1);
}
