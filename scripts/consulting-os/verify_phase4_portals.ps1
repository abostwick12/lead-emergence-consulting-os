$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$failures = [System.Collections.Generic.List[string]]::new()

function Require-Text([string]$Path, [string]$Pattern, [string]$Description) {
  $fullPath = Join-Path $root $Path
  if (-not (Test-Path $fullPath)) { $failures.Add("Missing $Description at $Path"); return }
  $content = [System.IO.File]::ReadAllText($fullPath)
  if ($content -notmatch $Pattern) { $failures.Add("$Description contract missing from $Path") }
}

$required = @(
  'app/layout.tsx', 'app/login/page.tsx', 'app/consultant/page.tsx', 'app/client/page.tsx',
  'components/portal/portal-shell.tsx', 'components/portal/roadmap.tsx',
  'lib/portal/context.ts', 'lib/portal/repository.ts', 'lib/supabase/server.ts',
  'tests/e2e/portals.spec.ts', 'tests/e2e/mobile.spec.ts'
)
foreach ($path in $required) {
  if (-not (Test-Path (Join-Path $root $path))) { $failures.Add("Missing Phase 4 file: $path") }
}

Require-Text 'lib/portal/types.ts' "SEE REALITY[\s\S]*REFRAME REALITY[\s\S]*ALIGN WITH REALITY[\s\S]*BUILD CAPABILITY[\s\S]*PRODUCE VALUE[\s\S]*NEW REALITY[\s\S]*SEE AGAIN" 'canonical seven-stage roadmap'
Require-Text 'lib/portal/repository.ts' 'client_visible_validated_conclusions' 'client-safe validated conclusion read model'
Require-Text 'lib/portal/repository.ts' 'epistemic_record_states' 'consultant epistemic read model'
Require-Text 'lib/portal/context.ts' 'consultant_assignments' 'Consulting consultant authorization'
Require-Text 'lib/portal/context.ts' 'organization_memberships' 'Consulting client authorization'
Require-Text 'lib/portal/context.ts' 'getClaims' 'server-validated authentication claims'
Require-Text 'lib/portal/context.ts' "import 'server-only'" 'server-only authorization boundary'
Require-Text 'lib/portal/repository.ts' "import 'server-only'" 'server-only DTO boundary'
Require-Text 'lib/portal/navigation.ts' 'value\.includes' 'backslash redirect defense'
Require-Text 'lib/portal/navigation.ts' 'u0000' 'control-character header-injection defense'
Require-Text 'lib/supabase/config.ts' "E2E_MOCK_AUTH.*NODE_ENV.*production" 'non-production fixture-mode gate'
Require-Text 'components/portal/state-badge.tsx' 'AI SUGGESTION[\s\S]*INTERPRETATION[\s\S]*VALIDATED INSIGHT[\s\S]*DECISION' 'distinct epistemic state legend'
Require-Text 'components/portal/portal-shell.tsx' 'current-organization[\s\S]*current-engagement' 'persistent organization and engagement context'
Require-Text 'tests/e2e/portals.spec.ts' 'client cannot guess consultant-private record URL' 'client private-record URL attack test'
Require-Text 'tests/e2e/portals.spec.ts' 'role boundaries reject cross-portal URL guessing' 'cross-portal URL attack test'
Require-Text 'tests/e2e/mobile.spec.ts' 'Private coaching content is never organizational telemetry' 'mobile coaching privacy boundary'

$sourceFiles = Get-ChildItem -Path (Join-Path $root 'app'), (Join-Path $root 'components'), (Join-Path $root 'lib') -Recurse -File -Include *.ts,*.tsx
foreach ($sourceFile in $sourceFiles) {
  $content = [System.IO.File]::ReadAllText($sourceFile.FullName)
  if ($content -match 'service[_-]?role' -and $sourceFile.Name -ne 'config.ts') {
    $failures.Add("Service-role wording or credential use found in application source: $($sourceFile.FullName.Substring($root.Length + 1))")
  }
  if ($content -match 'user_metadata.*role|role.*user_metadata') {
    $failures.Add("Mutable user metadata is used for authorization: $($sourceFile.FullName.Substring($root.Length + 1))")
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Phase 4 portal static verification passed.'
Write-Host "Verified $($required.Count) required files, tenant-aware role resolution, client-safe read models, canonical roadmap, epistemic states, privacy attacks, and mobile boundaries."
