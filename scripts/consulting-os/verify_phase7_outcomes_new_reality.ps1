$ErrorActionPreference = 'Stop'

$migration = Get-Content 'supabase/migrations/20260811015635_phase7_outcomes_new_reality.sql' -Raw
$mapping = Get-Content 'docs/consulting-os/implementation/DOMAIN-SCHEMA-MAPPING.md' -Raw
$plan = Get-Content 'docs/consulting-os/implementation/PHASE-7-OUTCOMES-NEW-REALITY-PLAN.md' -Raw

$requiredTables = @(
  'strategic_priorities','goals','value_hypotheses','indicators','measurements','outcomes','value_evaluations',
  'learnings','outcome_decisions','emergent_organization_profiles','emergent_profile_members',
  'emergent_reality_differences','organizational_stories','organizational_story_links',
  'baseline_snapshots','baseline_snapshot_members'
)
foreach ($table in $requiredTables) {
  if ($migration -notmatch "create table consulting_os\.$table") { throw "Missing Phase 7 table: $table" }
  if ($migration -notmatch "alter table consulting_os\.$table enable row level security") { throw "Missing RLS: $table" }
}

foreach ($contract in @(
  'value_dimension','outcome_disposition','validate_phase7_value_cycle','validate_phase7_causal_relationship',
  'create_baseline_snapshot','visibility_can_contain','security_invoker = true','client_progress','current_baselines',
  'evidence_summary','alternative_explanations','validated_by','validated_at'
)) { if ($migration -notmatch [regex]::Escape($contract)) { throw "Missing Phase 7 integrity contract: $contract" } }

foreach ($relationship in @('MEASURED_BY','MEASURES','EVALUATES','CONTRIBUTED_TO','CAUSES','BECOMES_BASELINE_FOR')) {
  if ($migration -notmatch "'$relationship'") { throw "Missing Phase 7 relationship rule: $relationship" }
}

if ($migration -notmatch "'baseline_snapshots','baseline_snapshot_members'" -or $migration -notmatch "grant select on consulting_os\.%I to authenticated") { throw 'Baseline tables must not allow direct authenticated writes.' }
if ($mapping -notmatch 'distinct from intended Future State') { throw 'Future State and Emergent Reality mapping boundary changed.' }
if ($plan -notmatch 'Harvest & Soil') { throw 'Harvest and Soil are missing from the Phase 7 plan.' }
foreach ($path in @('components/outcomes/outcomes-new-reality-center.tsx','lib/outcomes/workflow.ts','app/api/outcomes/route.ts','tests/e2e/phase7.spec.ts','supabase/tests/database/phase7_outcomes_new_reality.test.sql')) {
  if (-not (Test-Path $path)) { throw "Missing Phase 7 implementation evidence: $path" }
}

Write-Output "Phase 7 static verification passed: $($requiredTables.Count) typed tables, causality, immutable baseline, secure views, portal, and test contracts."
