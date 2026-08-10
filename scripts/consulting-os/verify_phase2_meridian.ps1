$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$migrationPath = Join-Path $repoRoot "supabase\migrations\20260810124622_phase2_meridian_core.sql"
$testPath = Join-Path $repoRoot "supabase\tests\database\phase2_meridian_core.test.sql"

if (-not (Test-Path -LiteralPath $migrationPath)) {
    throw "Missing Phase 2 Meridian Core migration."
}
if (-not (Test-Path -LiteralPath $testPath)) {
    throw "Missing Phase 2 Meridian Core pgTAP suite."
}

$migration = Get-Content -Raw -Encoding utf8 -LiteralPath $migrationPath
$tests = Get-Content -Raw -Encoding utf8 -LiteralPath $testPath

$requiredTables = @(
    "evidence_sources",
    "evidence_fragments",
    "evidence_items",
    "observations",
    "patterns",
    "assumptions",
    "hypotheses",
    "interpretations",
    "insights",
    "decisions",
    "decision_alternatives",
    "record_reviews",
    "claim_citations"
)
foreach ($table in $requiredTables) {
    if ($migration -notmatch "create table consulting_os\.$table\s*\(") {
        throw "Missing typed Meridian table: $table"
    }
    if ($migration -notmatch "alter table consulting_os\.$table enable row level security;") {
        throw "RLS is not enabled for Meridian table: $table"
    }
}

$requiredContracts = @(
    "domain_objects_typed_identity_key",
    "relationship_type_rules",
    "protect_domain_object_identity",
    "validate_typed_record",
    "prevent_append_only_mutation",
    "protect_assumption_version",
    "validate_relationship_endpoints",
    "security_invoker = true",
    "latest_record_reviews",
    "operative_epistemic_records",
    "validated_insights",
    "current_assumptions",
    "assumptions_at",
    "supersede_assumption",
    "AI-originated inferential records must begin SUGGESTED",
    "only a currently validated Insight may inform a Decision"
)
foreach ($contract in $requiredContracts) {
    if ($migration -notmatch [regex]::Escape($contract)) {
        throw "Missing Phase 2 contract: $contract"
    }
}

if ($migration -notmatch "content_sha256 text not null") {
    throw "Evidence fragments do not retain a content hash."
}
if ($migration -notmatch "references consulting_os\.evidence_fragments") {
    throw "Claim-level citation does not resolve to source fragments."
}
if ($migration -notmatch "unique \(organization_id, logical_id, version_number\)") {
    throw "Assumption version identity is not constrained."
}
if ($migration -notmatch "review_action <> 'VALIDATED'") {
    throw "Human validation detail requirements are missing."
}
if ($migration -notmatch "revoke update, delete on consulting_os\.entity_relationships from authenticated") {
    throw "Canonical relationships are not append-oriented."
}

$assertionCount = [regex]::Matches(
    $tests,
    "(?im)^select\s+(results_eq|throws_ok|lives_ok|cmp_ok|ok)\s*\("
).Count
if ($tests -notmatch "select plan\(27\)" -or $assertionCount -ne 27) {
    throw "Expected exactly 27 Phase 2 pgTAP assertions; found $assertionCount."
}

$requiredTests = @(
    "Complete Evidence-to-Decision reasoning relationships persist",
    "Competing interpretations coexist without overwrite",
    "Rejected AI interpretation is excluded from operative retrieval",
    "Unvalidated Insight cannot inform a Decision",
    "Historical query returns the version operative in 2022",
    "RLS excludes a high-similarity cross-tenant source before retrieval",
    "Assumption supersession creates an explicit historical relationship"
)
foreach ($test in $requiredTests) {
    if ($tests -notmatch [regex]::Escape($test)) {
        throw "Missing Phase 2 acceptance assertion: $test"
    }
}

Write-Output "PASS: Phase 2 typed evidence, reasoning, review, decision, and versioning contracts are present."
Write-Output "PASS: Meridian views use security-invoker semantics and preserve rejected/superseded history."
Write-Output "PASS: exact fragment citations, relationship rules, and 27 pgTAP assertions are present."
Write-Output "STATIC COMPLETE: disposable database execution and lint remain the Phase 2 evidence gate."
