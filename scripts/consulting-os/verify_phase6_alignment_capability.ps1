$ErrorActionPreference = 'Stop'

$migration = Get-Content 'supabase/migrations/20260810231500_phase6_alignment_capability.sql' -Raw
$mapping = Get-Content 'docs/consulting-os/implementation/DOMAIN-SCHEMA-MAPPING.md' -Raw
$plan = Get-Content 'docs/consulting-os/implementation/PHASE-6-ALIGNMENT-CAPABILITY-PLAN.md' -Raw

$requiredTables = @(
  'roles', 'role_assignments', 'design_principles', 'responsibilities', 'authorities', 'boundaries', 'interfaces',
  'workflows', 'workflow_versions', 'workflow_steps', 'reinvention_initiatives', 'organizational_systems', 'metric_definitions',
  'alignment_conflicts', 'capabilities', 'capability_requirements', 'capability_assessments', 'capability_gaps',
  'development_plans', 'development_activities', 'practices', 'resources', 'capability_maturity_assessments'
)

foreach ($table in $requiredTables) {
  if ($migration -notmatch "create table consulting_os\.$table") { throw "Missing Phase 6 table: $table" }
  if ($migration -notmatch "alter table consulting_os\.$table enable row level security") { throw "Missing RLS: $table" }
}

foreach ($relationship in @('CREATES','AUTHORIZES','REQUIRES','DEVELOPS','ENABLES','CONSTRAINS','OWNS')) {
  if ($migration -notmatch "'$relationship'") { throw "Missing relationship rule: $relationship" }
}

foreach ($contract in @('validate_role_architecture','validate_capability_requirement','validate_capability_assessment_evidence','validate_capability_gap','validate_development_plan','validate_maturity_evidence','validate_phase6_reference_visibility','security_invoker = true','my_capability_pathways')) {
  if ($migration -notmatch [regex]::Escape($contract)) { throw "Missing Phase 6 integrity contract: $contract" }
}

if ($mapping -notmatch '`workflows` \+ `workflow_versions` \+ `workflow_steps`') { throw 'Approved workflow mapping changed.' }
if ($plan -notmatch 'Purpose, Responsibilities, Authority, Boundaries, Interfaces, Support, Accountability, and Success Measures') { throw 'Role contract is incomplete in Phase 6 plan.' }
if (-not (Test-Path 'components/alignment/alignment-capability-center.tsx')) { throw 'Missing cohesive Phase 6 portal experience.' }
if (-not (Test-Path 'tests/e2e/phase6.spec.ts')) { throw 'Missing Phase 6 browser acceptance coverage.' }

Write-Output "Phase 6 static verification passed: $($requiredTables.Count) mapped tables, integrity, relationship, RLS, portal, and test contracts."
