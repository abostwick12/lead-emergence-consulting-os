$ErrorActionPreference = 'Stop'

$phaseStatus = Get-Content 'docs/consulting-os/implementation/PHASE-STATUS.md' -Raw -Encoding utf8
$finalAudit = Get-Content 'docs/consulting-os/implementation/FINAL-V1-ACCEPTANCE-AUDIT.md' -Raw -Encoding utf8
$phase9Review = Get-Content 'docs/consulting-os/implementation/PHASE-9-COMPLETION-REVIEW.md' -Raw -Encoding utf8
$implementationPlan = Get-Content 'docs/consulting-os/implementation/IMPLEMENTATION-PLAN.md' -Raw -Encoding utf8
$designQa = Get-Content 'design-qa.md' -Raw -Encoding utf8
$eslintConfig = Get-Content 'eslint.config.mjs' -Raw -Encoding utf8
$vitestConfig = Get-Content 'vitest.config.mts' -Raw -Encoding utf8

foreach ($phase in 0..9) {
  if ($phaseStatus -notmatch "\| $phase .*\| \*\*PASS\*\*") {
    throw "Phase $phase is not recorded as PASS."
  }
}

foreach ($contract in @(
  '**Result:** V1 ACCEPTANCE PASS',
  '24fcb2579e50f8166239d62357fa610babda4adf',
  '29 tests',
  'Ministry-only source scan',
  'V1 Goal is complete at the implementation/evidence boundary'
)) {
  if ($finalAudit -notmatch [regex]::Escape($contract)) {
    throw "Final V1 audit is missing: $contract"
  }
}

if ($phaseStatus -notmatch 'broader V1 Goal are complete' -or $phase9Review -notmatch 'completing the broader V1 Goal') {
  throw 'Phase status and Phase 9 completion review do not record final V1 completion.'
}
if ($implementationPlan -notmatch 'non-production environment and pilot-readiness decision') {
  throw 'Implementation plan does not preserve the post-V1 environment decision boundary.'
}
if ($designQa -notmatch 'final result: passed') {
  throw 'Unified-entry design QA has not passed.'
}
if ($eslintConfig -notmatch [regex]::Escape('.worktrees/**')) {
  throw 'ESLint does not exclude historical worktrees.'
}
if ($vitestConfig -notmatch [regex]::Escape('configDefaults.exclude') -or $vitestConfig -notmatch [regex]::Escape('**/.worktrees/**')) {
  throw 'Vitest does not preserve default exclusions plus the historical-worktree boundary.'
}

Write-Output 'Final V1 static verification passed: Phases 0-9, unified-entry approval, product separation, current-main test boundaries, and post-V1 governance are recorded.'
