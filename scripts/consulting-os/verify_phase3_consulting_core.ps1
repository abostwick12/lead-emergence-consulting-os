$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$migrationPath = Join-Path $repoRoot "supabase\migrations\20260810151138_phase3_consulting_core.sql"
$testPath = Join-Path $repoRoot "supabase\tests\database\phase3_consulting_core.test.sql"

if (-not (Test-Path -LiteralPath $migrationPath)) {
    throw "Missing Phase 3 Consulting Core migration."
}
if (-not (Test-Path -LiteralPath $testPath)) {
    throw "Missing Phase 3 Consulting Core pgTAP suite."
}

$migration = Get-Content -Raw -Encoding utf8 -LiteralPath $migrationPath
$tests = Get-Content -Raw -Encoding utf8 -LiteralPath $testPath

$typedTables = @(
    "risks",
    "strengths",
    "unrealized_potentials",
    "diagnoses",
    "interviews",
    "interview_responses",
    "assessment_instruments",
    "assessment_administrations",
    "assessment_responses",
    "artifacts",
    "identity_elements",
    "organizational_dna_versions",
    "future_state_narratives",
    "future_state_principles",
    "future_states",
    "organizational_blueprints"
)
foreach ($table in $typedTables) {
    if ($migration -notmatch "create table consulting_os\.$table\s*\(") {
        throw "Missing Phase 3 typed table: $table"
    }
    if ($migration -notmatch "alter table consulting_os\.$table enable row level security;") {
        throw "RLS is not enabled for Phase 3 table: $table"
    }
}

$supportingTables = @(
    "assessment_instrument_versions",
    "assessment_items",
    "artifact_sections",
    "artifact_members",
    "organizational_dna_elements",
    "blueprint_members"
)
foreach ($table in $supportingTables) {
    if ($migration -notmatch "create table consulting_os\.$table\s*\(") {
        throw "Missing Phase 3 supporting table: $table"
    }
    if ($migration -notmatch "alter table consulting_os\.$table enable row level security;") {
        throw "RLS is not enabled for Phase 3 supporting table: $table"
    }
}

$requiredContracts = @(
    "consulting_private.interview_responses",
    "consulting_private.assessment_responses",
    "validate_response_provenance",
    "protect_assessment_definition",
    "validation_claim_status",
    "artifact_section_rules",
    "validate_artifact_member",
    "visibility_can_contain",
    "validate_version_chain",
    "prevent_versioned_mutation",
    "assumption_register",
    "artifact_completion",
    "current_identity_elements",
    "current_organizational_dna",
    "current_future_state_narratives",
    "current_future_states",
    "current_organizational_blueprints",
    "client_visible_validated_conclusions",
    "assessment_response_provenance",
    "security_invoker = true"
)
foreach ($contract in $requiredContracts) {
    if ($migration -notmatch [regex]::Escape($contract)) {
        throw "Missing Phase 3 contract: $contract"
    }
}

$sixNarrativeFields = @(
    "what_was_true",
    "what_changed",
    "what_is_true_now",
    "what_that_means",
    "what_must_become_true_next",
    "what_could_become_possible"
)
foreach ($field in $sixNarrativeFields) {
    if ($migration -notmatch "$field text not null") {
        throw "Missing canonical Future-State Narrative field: $field"
    }
}

$assertionCount = [regex]::Matches(
    $tests,
    "(?im)^select\s+(results_eq|throws_ok|lives_ok|cmp_ok|ok)\s*\("
).Count
if ($tests -notmatch "select plan\(45\)" -or $assertionCount -ne 45) {
    throw "Expected exactly 45 Phase 3 pgTAP assertions; found $assertionCount."
}

$requiredTests = @(
    "Organizational Portrait is complete as a structured artifact",
    "Current-State Reality Map is complete as a structured artifact",
    "Interview response retains exact source-fragment provenance",
    "Assessment response remains attached to administered version 1",
    "Assumption Register counts evidence for",
    "Assumption Register counts evidence against",
    "Future-State Narrative preserves all six canonical fields",
    "Client-visible artifact cannot broaden consultant-private analysis",
    "Coaching-shared scope cannot broaden consultant-private analysis",
    "Client member cannot read consultant-private Diagnosis",
    "Other organization cannot read the Reality Map"
)
foreach ($test in $requiredTests) {
    if ($tests -notmatch [regex]::Escape($test)) {
        throw "Missing Phase 3 acceptance assertion: $test"
    }
}

Write-Output "PASS: Phase 3 Portrait, Reality Map, assessment, interview, Identity/DNA, Future State, and Blueprint contracts are present."
Write-Output "PASS: provenance, version immutability, RLS, physical privacy, and no-visibility-broadening constraints are present."
Write-Output "PASS: 45 Phase 3 pgTAP assertions cover the seven Canonical Document 07 exit requirements."
Write-Output "STATIC COMPLETE: disposable database execution and lint remain the Phase 3 evidence gate."
