$ErrorActionPreference = 'Stop'

$skillsDir = Join-Path (Get-Location) '.claude/skills'
$requiredFields = @('name', 'description', 'user-invocable', 'allowed-tools', 'effort')
$workflowFields = @('argument-hint')
$recommendedFields = @('type')
$optionalFields = @('agent', 'when_to_use', 'context')

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

        if ($skillFailed) {
            Write-Output "FAIL $skillName"
            Write-Output ("  Missing required: {0}" -f ($missingRequired -join ' '))
            $script:failed++
        }
        elseif ($missingOptional.Count -gt 0) {
            Write-Output ("WARN {0} - optional missing: {1}" -f $skillName, ($missingOptional -join ' '))
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
