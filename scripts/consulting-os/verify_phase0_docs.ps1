[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..")).Path
$docsRoot = Join-Path $repoRoot "docs\consulting-os"

function Get-CanonicalSha256([string]$Path) {
    if ([IO.Path]::GetExtension($Path) -eq ".md") {
        $content = [IO.File]::ReadAllText($Path).Replace("`r`n", "`n").Replace("`r", "`n")
        $bytes = [Text.UTF8Encoding]::new($false).GetBytes($content)
        $sha = [Security.Cryptography.SHA256]::Create()
        try {
            return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace("-", "")
        } finally {
            $sha.Dispose()
        }
    }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

$required = @(
    "README.md",
    "SOURCE-MANIFEST.md",
    "canonical\01-product-constitution.docx",
    "canonical\02-emergence-methodology.docx",
    "canonical\03-domain-model.docx",
    "canonical\03-domain-model-authoritative-continuation-2026-08-10.md",
    "canonical\04-meridian-epistemology.docx",
    "canonical\05-security-multitenancy.docx",
    "canonical\06-portal-ux.docx",
    "canonical\07-v1-scope-acceptance.docx",
    "constraints\build-goal.md",
    "constraints\product-separation-repository-architecture.md",
    "reference\full-build-plan.docx",
    "implementation\IMPLEMENTATION-PLAN.md",
    "implementation\PHASE-STATUS.md",
    "implementation\BLOCKERS.md",
    "implementation\ERD-PROPOSAL.md",
    "implementation\DOMAIN-SCHEMA-MAPPING.md",
    "implementation\LEGACY-CONFLICT-MAP.md",
    "implementation\MINISTRY-ONLY-DISTRIBUTION.md",
    "implementation\PHASE-0-CHECKPOINT.md",
    "implementation\PHASE-0-CHECKPOINT-RESPONSE-2026-08-10.md",
    "implementation\PHASE-0-ARCHITECTURE-APPROVAL-2026-08-10.md",
    "implementation\PHASE-0-COMPLETION-APPROVAL-2026-08-10.md",
    "implementation\PHASE-AUTHORIZATION-2026-08-10.md",
    "implementation\PHASE-0-ACCEPTANCE-AUDIT.md",
    "implementation\TARGET-TOPOLOGY-MIGRATION-PLAN.md",
    "adrs\ADR-0001-product-boundary-architecture.md",
    "adrs\ADR-0002-consulting-tenancy-schema-and-migrations.md",
    "adrs\ADR-0003-typed-domain-registry-and-versioning.md",
    "adrs\ADR-0004-auth-privacy-retrieval-and-entry.md"
)

$missingRequired = @($required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $docsRoot $_)) })
if ($missingRequired.Count -gt 0) {
    throw "Missing required Phase 0 files: $($missingRequired -join ', ')"
}

$manifestPath = Join-Path $docsRoot "SOURCE-MANIFEST.md"
$manifestRows = Get-Content -LiteralPath $manifestPath -Encoding utf8 | ForEach-Object {
    if ($_ -match '^\| `([^`]+)` \| [^|]+ \| `([a-f0-9]{64})` \|$') {
        [pscustomobject]@{ RelativePath = $Matches[1]; ExpectedHash = $Matches[2].ToUpperInvariant() }
    }
}
if (@($manifestRows).Count -ne 15) {
    throw "Expected 15 checksum rows in SOURCE-MANIFEST.md; found $(@($manifestRows).Count)."
}
foreach ($row in $manifestRows) {
    $path = Join-Path $docsRoot $row.RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Manifest source is missing: $($row.RelativePath)"
    }
    $actualHash = Get-CanonicalSha256 -Path $path
    if ($actualHash -ne $row.ExpectedHash) {
        throw "Checksum mismatch: $($row.RelativePath)"
    }
}

$domainPath = Join-Path $docsRoot "canonical\03-domain-model.md"
$domain = Get-Content -LiteralPath $domainPath -Encoding utf8
$appendixA = ($domain | Select-String -Pattern '^# Appendix A').LineNumber
$appendixB = ($domain | Select-String -Pattern '^# Appendix B').LineNumber
if (-not $appendixA -or -not $appendixB -or $appendixB -le $appendixA) {
    throw "Could not locate Document 03 Appendix A boundaries."
}
$canonicalEntities = @(
    $domain[$appendixA..($appendixB - 2)] |
        Where-Object { $_ -match '^- ' } |
        ForEach-Object { $_.Substring(2).Trim() }
)

$mappingPath = Join-Path $docsRoot "implementation\DOMAIN-SCHEMA-MAPPING.md"
$mappedEntities = @(
    Get-Content -LiteralPath $mappingPath -Encoding utf8 | ForEach-Object {
        if ($_ -match '^\| ([^|]+) \| `') { $Matches[1].Trim() }
    }
)
$missingEntities = @($canonicalEntities | Where-Object { $_ -notin $mappedEntities })
$extraEntities = @($mappedEntities | Where-Object { $_ -notin $canonicalEntities })
$duplicateEntities = @($mappedEntities | Group-Object | Where-Object Count -gt 1)
if ($missingEntities.Count -or $extraEntities.Count -or $duplicateEntities.Count) {
    throw "Entity mapping mismatch. Missing=$($missingEntities -join ', '); Extra=$($extraEntities -join ', '); Duplicate=$($duplicateEntities.Name -join ', ')"
}
if ($canonicalEntities.Count -ne 77 -or $mappedEntities.Count -ne 77) {
    throw "Expected 77 canonical and mapped entities; found $($canonicalEntities.Count) and $($mappedEntities.Count)."
}

$missingLinks = @()
Get-ChildItem -LiteralPath $docsRoot -Recurse -Filter "*.md" | ForEach-Object {
    $file = $_
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
    [regex]::Matches($content, '\[[^\]]+\]\(([^)]+)\)') | ForEach-Object {
        $target = $_.Groups[1].Value.Trim()
        if ($target -match '^(https?://|mailto:|#)' -or $target.Contains(' ')) { return }
        $pathPart = $target.Split('#')[0]
        if (-not $pathPart) { return }
        if (-not (Test-Path -LiteralPath (Join-Path $file.DirectoryName $pathPart))) {
            $missingLinks += "$($file.FullName): $target"
        }
    }
}
if ($missingLinks.Count -gt 0) {
    throw "Missing relative Markdown link targets: $($missingLinks -join '; ')"
}

$domainRaw = Get-Content -LiteralPath $domainPath -Raw -Encoding utf8
$continuationPath = Join-Path $docsRoot "canonical\03-domain-model-authoritative-continuation-2026-08-10.md"
$continuationRaw = Get-Content -LiteralPath $continuationPath -Raw -Encoding utf8
$tailIndex = $domainRaw.IndexOf("# 12. Domain G")
if ($tailIndex -lt 0) {
    throw "Restored Document 03 does not contain the authoritative Section 12 start."
}
$canonicalTail = $domainRaw.Substring($tailIndex).Replace("`r`n", "`n").Trim()
$authoritativeTail = $continuationRaw.Replace("`r`n", "`n").Trim()
if ($canonicalTail -cne $authoritativeTail) {
    throw "Restored Document 03 tail differs from the retained authoritative continuation."
}
foreach ($number in 12..30) {
    $count = @($domain | Select-String -Pattern "^# $number\.").Count
    if ($count -ne 1) {
        throw "Expected exactly one level-1 Document 03 Section $number; found $count."
    }
}
if (@($domain | Select-String -Pattern '^# End of Canonical Document 03$').Count -ne 1) {
    throw "Expected exactly one canonical Document 03 end marker."
}

if (-not (Test-Path -LiteralPath (Join-Path $repoRoot "scripts\consulting-os\restore_doc03_continuation.py"))) {
    throw "Missing deterministic Document 03 restoration script."
}

$rootReadme = Join-Path $repoRoot "README.md"
if (-not (Test-Path -LiteralPath $rootReadme)) {
    throw "Missing private Consulting repository README."
}
$rootReadmeContent = Get-Content -LiteralPath $rootReadme -Raw -Encoding utf8
if ($rootReadmeContent -notmatch 'private repository boundary' -or $rootReadmeContent -notmatch 'Phase 1: (authorized|in progress)') {
    throw "Private repository README does not record the approved boundary and current Phase 1 state."
}

$checkpoint = Get-Content -LiteralPath (Join-Path $docsRoot "implementation\PHASE-0-CHECKPOINT.md") -Raw -Encoding utf8
if ($checkpoint -notmatch 'Phase 0 complete: \*\*yes\*\*' -or $checkpoint -notmatch 'Phase 1 authorized: \*\*yes\*\*') {
    throw "Final Phase 0 completion and Phase 1 authorization are not recorded."
}

$adrStatuses = @(
    "adrs\ADR-0001-product-boundary-architecture.md",
    "adrs\ADR-0002-consulting-tenancy-schema-and-migrations.md",
    "adrs\ADR-0003-typed-domain-registry-and-versioning.md",
    "adrs\ADR-0004-auth-privacy-retrieval-and-entry.md"
)
foreach ($relativePath in $adrStatuses) {
    $adr = Get-Content -LiteralPath (Join-Path $docsRoot $relativePath) -Raw -Encoding utf8
    if ($adr -notmatch '\*\*Status:\*\* Accepted') {
        throw "ADR is not recorded as accepted: $relativePath"
    }
}

Write-Output "PASS: 15 source checksums match the manifest."
Write-Output "PASS: 77 canonical entities map exactly once, with no extras."
Write-Output "PASS: required Phase 0 artifacts exist and relative Markdown links resolve."
Write-Output "PASS: Document 03 Sections 12-30 occur exactly once and its canonical tail matches the authoritative continuation."
Write-Output "PASS: ADR-0001 through ADR-0004 are accepted and the private-repository boundary is recorded."
Write-Output "PASS: Phase 0 completion and Phase 1 authorization are recorded."
Write-Output "PHASE 1: authorization is recorded; current execution state is tracked separately."
