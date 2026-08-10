$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')

$checks = @(
  @{ Path = 'supabase/migrations/20260810210000_phase5_meetings_coaching.sql'; Tokens = @('create table consulting_os.meetings', 'create table consulting_os.coaching_relationships', 'create table consulting_private.meeting_notes', 'create or replace function consulting_os.create_meeting', 'add_meeting_decision', 'validate_meeting_context', 'record_coaching_promotion', 'phase5_organizational_intelligence_sources') },
  @{ Path = 'lib/meetings/repository.ts'; Tokens = @('CREATE_MEETING', 'ADD_PRIVATE_NOTE', 'create_meeting', 'create_private_meeting_note') },
  @{ Path = 'components/meetings/meeting-center.tsx'; Tokens = @('meetingPhases', 'First-class decisions', 'Shared summary', 'Follow-up', 'Private partition', 'Commitments across sessions', 'NAMED PARTICIPANTS') },
  @{ Path = 'tests/e2e/portals.spec.ts'; Tokens = @('creates, advances, captures, commits', 'Delegate defined routine decisions', 'FOLLOW_UP', 'never sees consultant-private content') },
  @{ Path = 'docs/consulting-os/implementation/PHASE-5-MEETINGS-COACHING-PLAN.md'; Tokens = @('One shared interaction engine', 'physically stores coach-private notes') }
)

foreach ($check in $checks) {
  $path = Join-Path $root $check.Path
  if (-not (Test-Path -LiteralPath $path)) { throw "Missing Phase 5 file: $($check.Path)" }
  $content = Get-Content -LiteralPath $path -Raw -Encoding utf8
  foreach ($token in $check.Tokens) {
    if (-not $content.Contains($token)) { throw "Missing Phase 5 contract '$token' in $($check.Path)" }
  }
}

$activePaths = @('app', 'components', 'lib', 'supabase') | ForEach-Object { Join-Path $root $_ }
$ministryImport = & rg -n 'emergence-ministry-platform|\.\./.*ministry' @activePaths 2>$null
if ($LASTEXITCODE -eq 0 -and $ministryImport) { throw "Product-separation violation detected: $ministryImport" }

Write-Output 'Phase 5 Meetings + Coaching static contracts passed.'
