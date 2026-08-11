$ErrorActionPreference = 'Stop'

$migration = Get-Content 'supabase/migrations/20260811064000_phase8_grounded_ai.sql' -Raw
$test = Get-Content 'supabase/tests/database/phase8_grounded_ai.test.sql' -Raw
$plan = Get-Content 'docs/consulting-os/implementation/PHASE-8-GROUNDED-AI-PLAN.md' -Raw
foreach ($table in @('ai_generation_runs','ai_run_sources','ai_outputs','ai_output_citations')) {
  if ($migration -notmatch "create table consulting_os\.$table") { throw "Missing Phase 8 table: $table" }
  if ($migration -notmatch "alter table consulting_os\.$table enable row level security") { throw "Missing Phase 8 RLS: $table" }
}
foreach ($contract in @('permission_filter_applied_at','assert_ai_source_eligible','eligible_ai_source_fragments','SUGGESTED','CHALLENGING','claim_citations','ai_truth_eligible_records','INSUFFICIENT_EVIDENCE','reject_ai_suggestion','enforce_ai_authority_boundary','enforce_ai_attribution_boundary')) {
  if ($migration -notmatch [regex]::Escape($contract)) { throw "Missing Phase 8 integrity contract: $contract" }
}
foreach ($proof in @('Cross-tenant source is rejected before ranking','Private coaching evidence is rejected before ranking','AI cannot create an Insight','AI cannot make a Decision','Rejected and unreviewed AI suggestions never appear as truth')) {
  if ($test -notmatch [regex]::Escape($proof)) { throw "Missing Phase 8 adversarial proof: $proof" }
}
foreach ($criterion in @('AI origin','source set','permission filtering before ranking','supporting and contrary evidence','insufficient evidence','rejected suggestions')) {
  if ($plan -notmatch [regex]::Escape($criterion)) { throw "Missing Document 07 Phase 8 criterion: $criterion" }
}
foreach ($path in @('components/meridian-ai/grounded-assistance.tsx','lib/meridian-ai/workflow.ts','app/api/meridian-ai/route.ts','tests/e2e/phase8.spec.ts')) {
  if (-not (Test-Path $path)) { throw "Missing Phase 8 implementation evidence: $path" }
}
Write-Output 'Phase 8 static verification passed: permission-first retrieval, provenance, review, refusal, privacy, and portal contracts.'
