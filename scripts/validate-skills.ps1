$ErrorActionPreference = 'Stop'

$skillsDir = Join-Path (Get-Location) '.claude/skills'
$requiredFields = @('name', 'description', 'user-invocable', 'allowed-tools', 'effort')
$workflowFields = @('argument-hint')
$recommendedFields = @('type')
$optionalFields = @('agent', 'when_to_use', 'context')
$validTypes = @('workflow', 'reference', 'agent')
$minBodyLines = 30

$total = 0
$passed = 0
$failed = 0
$warnings = 0

function Get-Frontmatter {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $lines = Get-Content -LiteralPath $Path
    if ($lines.Length -lt 3) {
        return @()
    }

    if ($lines[0].Trim() -ne '---') {
        return @()
    }

    $endIndex = -1
    for ($i = 1; $i -lt $lines.Length; $i++) {
        if ($lines[$i].Trim() -eq '---') {
            $endIndex = $i
            break
        }
    }

    if ($endIndex -lt 1) {
        return @()
    }

    return $lines[1..($endIndex - 1)]
}

function Get-BodyLines {
    param([string]$Path)
    $lines = Get-Content -LiteralPath $Path
    $inFrontmatter = $false
    $endFrontmatter = -1
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i].Trim() -eq '---') {
            if ($inFrontmatter) { $endFrontmatter = $i; break }
            else { $inFrontmatter = $true }
        }
    }
    if ($endFrontmatter -lt 0) { return $lines }
    return $lines[($endFrontmatter + 1)..($lines.Length - 1)]
}

Write-Output '==========================================='
Write-Output '  SDD Skill Validator (PowerShell)'
Write-Output '==========================================='
Write-Output ''

if (-not (Test-Path -LiteralPath $skillsDir)) {
    throw "Skills dir not found: $skillsDir"
}

Get-ChildItem -LiteralPath $skillsDir -Directory |
    Sort-Object Name |
    ForEach-Object {
        $skillName = $_.Name
        if ($skillName -eq 'templates') {
            return
        }

        $skillFile = Join-Path $_.FullName 'SKILL.md'
        $script:total++

        if (-not (Test-Path -LiteralPath $skillFile)) {
            Write-Output "FAIL $skillName - SKILL.md khong ton tai"
            $script:failed++
            return
        }

        $frontmatter = @(Get-Frontmatter -Path $skillFile)
        $frontText = $frontmatter -join "`n"
        $missingRequired = New-Object System.Collections.Generic.List[string]
        $missingOptional = New-Object System.Collections.Generic.List[string]
        $skillFailed = $false

        $skillType = 'workflow'
        $typeMatch = [regex]::Match($frontText, '(?m)^type:\s*"?([^"\r\n]+)"?')
        if ($typeMatch.Success) {
            $skillType = $typeMatch.Groups[1].Value.Trim()
        }

        foreach ($field in $requiredFields) {
            if ($frontText -notmatch "(?m)^$([regex]::Escape($field)):") {
                $missingRequired.Add($field)
                $skillFailed = $true
            }
        }

        if ($skillType -eq 'workflow') {
            foreach ($field in $workflowFields) {
                if ($frontText -notmatch "(?m)^$([regex]::Escape($field)):") {
                    $missingRequired.Add($field)
                    $skillFailed = $true
                }
            }
        }

        foreach ($field in $recommendedFields) {
            if ($frontText -notmatch "(?m)^$([regex]::Escape($field)):") {
                $missingOptional.Add($field)
            }
        }

        # --- NEW CHECKS ---
        $extraWarnings = New-Object System.Collections.Generic.List[string]

        # Check 1: Type values valid
        if ($typeMatch.Success -and ($skillType -notin $validTypes)) {
            $extraWarnings.Add("invalid type '$skillType' (expected: $($validTypes -join ', '))")
        }

        # Check 2: Boilerplate detection
        $allContent = Get-Content -LiteralPath $skillFile -Raw
        if ($allContent -match 'Working on .+ tasks or workflows') {
            $extraWarnings.Add('generic boilerplate header detected')
        }

        # Check 3: Broken references - find /skill-name patterns outside code blocks
        # Some slash commands are command aliases for canonical skill directories.
        $slashCommandAliases = @{
            "plan" = "planning-and-task-breakdown"
            "spec" = "spec-driven-development"
            "tdd" = "test-driven-development"
        }
        $noCodeBlocks = [regex]::Replace($allContent, '```[\s\S]*?```', '')
        $noInlineCode = [regex]::Replace($noCodeBlocks, '`[^`]+`', '')
        $refMatches = [regex]::Matches($noInlineCode, '(?<=^|[\s(])/([a-z][a-z0-9-]+[a-z0-9])(?=[\s).,;:!?]|$)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
        foreach ($refMatch in $refMatches) {
            $refName = $refMatch.Groups[1].Value
            if ($slashCommandAliases.ContainsKey($refName)) {
                $aliasDir = Join-Path $skillsDir $slashCommandAliases[$refName]
                if (Test-Path -LiteralPath $aliasDir) {
                    continue
                }
            }
            $refDir = Join-Path $skillsDir $refName
            if ($refName -ne $skillName -and -not (Test-Path -LiteralPath $refDir)) {
                $extraWarnings.Add("broken reference: /$refName (directory not found)")
            }
        }

        # Check 4: Minimum content length
        $bodyLines = @(Get-BodyLines -Path $skillFile)
        $nonEmptyLines = ($bodyLines | Where-Object { $_.Trim() -ne '' }).Count
        if ($nonEmptyLines -lt $minBodyLines) {
            $extraWarnings.Add("thin content: $nonEmptyLines non-empty lines (min: $minBodyLines)")
        }

        # --- REPORT ---
        if ($skillFailed) {
            Write-Output "FAIL $skillName"
            Write-Output ("  Missing required: {0}" -f ($missingRequired -join ' '))
            $script:failed++
        }
        elseif ($missingOptional.Count -gt 0 -or $extraWarnings.Count -gt 0) {
            $allWarnings = @($missingOptional | ForEach-Object { "optional missing: $_" }) + @($extraWarnings)
            Write-Output ("WARN {0} - {1}" -f $skillName, ($allWarnings -join '; '))
            $script:passed++
            $script:warnings++
        }
        else {
            Write-Output "PASS $skillName"
            $script:passed++
        }
    }

Write-Output ''
Write-Output '==========================================='
Write-Output ("  Total: {0} | Pass: {1} | Fail: {2} | Warn: {3}" -f $total, $passed, $failed, $warnings)
Write-Output '==========================================='

if ($failed -ne 0) {
    exit 1
}
