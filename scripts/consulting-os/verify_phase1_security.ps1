[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..")).Path
$migrations = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot "supabase\migrations") -Filter "*_phase1_security_foundation.sql")
if ($migrations.Count -ne 1) {
    throw "Expected exactly one Phase 1 security migration; found $($migrations.Count)."
}
$migration = $migrations[0]
$testPath = Join-Path $repoRoot "supabase\tests\database\phase1_security_foundation.test.sql"
$configPath = Join-Path $repoRoot "supabase\config.toml"

if (-not $migration -or -not (Test-Path -LiteralPath $testPath) -or -not (Test-Path -LiteralPath $configPath)) {
    throw "Phase 1 migration, pgTAP suite, or Supabase config is missing."
}

$sql = Get-Content -LiteralPath $migration.FullName -Raw -Encoding utf8
$tests = Get-Content -LiteralPath $testPath -Raw -Encoding utf8
$config = Get-Content -LiteralPath $configPath -Raw -Encoding utf8

$requiredSchemas = @("consulting_os", "consulting_security", "consulting_private")
foreach ($schema in $requiredSchemas) {
    if ($sql -notmatch "create schema if not exists $schema") {
        throw "Missing required schema: $schema"
    }
}

$rlsTables = @(
    "people", "organizations", "organization_memberships", "consultant_assignments",
    "engagements", "engagement_memberships", "domain_objects", "visibility_grants",
    "entity_relationships", "file_objects", "audit_events"
)
foreach ($table in $rlsTables) {
    if ($sql -notmatch "alter table consulting_os\.$table enable row level security") {
        throw "RLS is not enabled for consulting_os.$table"
    }
}
if ($sql -notmatch "alter table consulting_private\.private_records enable row level security") {
    throw "RLS is not enabled for consulting_private.private_records"
}
if ($sql -notmatch "revoke all on all tables in schema consulting_private from public, anon, authenticated") {
    throw "Private-schema ordinary grants are not revoked."
}

$forbidden = @("auth\.role\(", "user_metadata", "raw_user_meta_data.*authorization", "NEXT_PUBLIC_.*service", "service_role.*browser")
foreach ($pattern in $forbidden) {
    if ($sql -match $pattern) {
        throw "Forbidden security pattern found: $pattern"
    }
}

foreach ($policy in @("consulting_files_select", "consulting_files_insert", "consulting_files_update", "consulting_files_delete")) {
    if ($sql -notmatch "create policy $policy on storage\.objects") {
        throw "Missing Storage policy: $policy"
    }
}

if ($sql -notmatch "foreign key \(source_id, organization_id\)" -or $sql -notmatch "foreign key \(target_id, organization_id\)") {
    throw "Relationship endpoints are not tenant-aware composite foreign keys."
}
if ($sql -notmatch "with \(security_invoker = true\)" -or $sql -notmatch "authorized_source_ids") {
    throw "Secure export/retrieval pre-filter foundation is missing."
}
if ($tests -notmatch "select plan\(32\)" -or $tests -notmatch "Cross-tenant relationship" -or $tests -notmatch "Membership removal stops access") {
    throw "The 32-test adversarial suite is incomplete."
}
if ($config -notmatch 'schemas = \["consulting_os", "graphql_public"\]' -or $config -match 'schemas = \["public"') {
    throw "Supabase Data API schema configuration is not Consulting-only."
}

$secretFiles = @(Get-ChildItem -LiteralPath $repoRoot -Recurse -Force -File | Where-Object {
    $_.Name -eq ".env" -or $_.Name -like ".env.*"
})
if ($secretFiles.Count -gt 0) {
    throw "Environment files must not be committed: $($secretFiles.FullName -join ', ')"
}

Write-Output "PASS: Phase 1 schemas, RLS declarations, private partition, and least-privilege markers are present."
Write-Output "PASS: same-tenant relationship constraints and secure pre-retrieval projection are present."
Write-Output "PASS: four Storage operations have explicit policies."
Write-Output "PASS: 32 adversarial pgTAP assertions and Consulting-only API configuration are present."
Write-Output "STATIC ONLY: database execution, pgTAP, lint, and advisors are still required before Phase 1 PASS."
