$ErrorActionPreference = 'Stop'

$migration = Get-Content 'supabase/migrations/20260811131500_phase9_signals_see_again.sql' -Raw
$test = Get-Content 'supabase/tests/database/phase9_signals_see_again.test.sql' -Raw
$plan = Get-Content 'docs/consulting-os/implementation/PHASE-9-SIGNALS-SEE-AGAIN-PLAN.md' -Raw
foreach ($table in @('signals','descriptive_trends','assumption_review_schedules','emerging_questions')) {
  if ($migration -notmatch "create table consulting_os\.$table") { throw "Missing Phase 9 table: $table" }
  if ($migration -notmatch "alter table consulting_os\.$table enable row level security") { throw "Missing Phase 9 RLS: $table" }
}
foreach ($contract in @('current_signal_set','current_assumptions_due','REENTERS_AS','reenter_signal_as_observation','visibility_scope','compatible indicator identity','Private coaching','descriptive')) {
  if ($migration -notmatch [regex]::Escape($contract)) { throw "Missing Phase 9 integrity contract: $contract" }
}
foreach ($proof in @('Private coaching evidence cannot become organizational telemetry','Incompatible indicator identities cannot become a trend','Re-entry preserves the typed relationship','Signal Evidence cannot cross the organization boundary','Completed assumption review leaves the due queue')) {
  if ($test -notmatch [regex]::Escape($proof)) { throw "Missing Phase 9 adversarial proof: $proof" }
}
foreach ($criterion in @('descriptive','compatible','Private coaching','Assumptions due','REENTERS_AS','autonomous drift detection')) {
  if ($plan -notmatch [regex]::Escape($criterion)) { throw "Missing Document 07 Phase 9 criterion: $criterion" }
}
foreach ($path in @('components/signals/descriptive-signals-center.tsx','lib/signals/workflow.ts','app/api/signals/route.ts','tests/e2e/phase9.spec.ts')) {
  if (-not (Test-Path $path)) { throw "Missing Phase 9 implementation evidence: $path" }
}
Write-Output 'Phase 9 static verification passed: descriptive Signals, compatible trends, privacy, assumption review, baseline, and explicit re-entry contracts.'
