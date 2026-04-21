$ErrorActionPreference = 'Stop'

$inputJson = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($inputJson)) {
    exit 0
}

try {
    $payload = $inputJson | ConvertFrom-Json
} catch {
    exit 0
}

$filePath = $payload.tool_input.file_path
if ([string]::IsNullOrWhiteSpace($filePath)) {
    exit 0
}

$normalized = $filePath -replace '\\', '/'

if ($normalized -match '(\.mdx?$)|(^docs/)|(/docs/)|(^\.claude/skills/)') {
    exit 0
}

if ($normalized -match '(?i)(^|/)(tests?|__tests__|specs?)/|(\.test|\.spec)\.(js|jsx|ts|tsx|py|go|rs|java|cs)$') {
    exit 0
}

$implementationPattern = '(?i)(^|/)(src|app|lib|services|components|pages|packages|scripts|infra|infrastructure|migrations|landing-page|\.claude/hooks)/|(\.js|\.jsx|\.ts|\.tsx|\.py|\.go|\.rs|\.java|\.cs|\.php|\.rb|\.sh|\.ps1|\.sql|\.html|\.css|\.scss|\.json|\.ya?ml)$'

if ($normalized -match $implementationPattern) {
    [Console]::Error.WriteLine("SDD Pre-Code Gate: before editing '$normalized', state the satisfied gate from .claude/skills/using-sdd/SKILL.md and the verification command/check.")
}

exit 0

