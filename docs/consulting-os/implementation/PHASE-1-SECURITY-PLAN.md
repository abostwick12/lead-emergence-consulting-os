# Phase 1 — Security Foundation

**Status:** PASS — evidence gate satisfied 2026-08-10

**Branch/worktree:** `codex/consulting-os-phase1` / `.worktrees/consulting-os-phase1`

**Production application:** Not authorized and not performed.

## Implemented foundation

- Consulting-owned `consulting_os`, `consulting_security`, and `consulting_private` schemas.
- Auth identity mapping, organizations, memberships, consultant assignments, engagements, and engagement membership.
- Current database-backed authorization with no default organization and no `user_metadata` role decisions.
- Canonical role and visibility vocabularies.
- Direct tenant attribution and composite same-tenant foreign keys.
- RLS for every Phase 1 application/private table, with separate command policies and `USING`/`WITH CHECK` on updates.
- Physically partitioned private records with no ordinary authenticated grants.
- Security-invoker authorized-record projection and source-ID pre-filter for later exports, search, and AI.
- Tenant-aware file metadata plus private Storage bucket policies for read, upload, upsert, and delete.
- Append-only security audit events and narrowly scoped service-role audit function.
- Minimal domain-object/relationship security metadata required to prove same-tenant relationship integrity; Phase 2 still owns epistemic/domain behavior.

## Acceptance mapping

| Canonical requirement | Automated evidence |
|---|---|
| Known Org B UUID does not grant Org A read | pgTAP known-ID SELECT test |
| Org A cannot INSERT or move records into Org B | pgTAP INSERT and UPDATE attacks |
| Cross-tenant and type-mismatched relationships fail | Composite FK and endpoint trigger tests |
| Consultant requires active assignment | Assigned Org A and unassigned Org B tests |
| Client admin/leader cannot override privacy | Consultant-private, individual-private, and coaching-shared tests |
| Membership removal stops access | Current-state revocation test |
| Files obey tenant/visibility | File metadata and guessed Storage path tests |
| Search/export/AI filter before retrieval | Security-invoker view and `authorized_source_ids` tests |
| Private records are physically restricted | Direct private-schema denial test |
| Audit history is protected | Trigger coverage and append-only mutation test |
| Privileged work fails without tenant context | Service-role negative and audited-positive tests |
| Anonymous access fails | Schema-access denial test |

The suite contains 32 adversarial assertions in `supabase/tests/database/phase1_security_foundation.test.sql` and rolls all synthetic fixtures back.

## Completion evidence

| Evidence | Result |
|---|---|
| Clean migration in a disposable Supabase stack | PASS — GitHub Actions run `31384043484` applied the migration from an empty isolated state. |
| Adversarial database suite | PASS — all 32 pgTAP assertions passed. |
| Database lint | PASS — `supabase db lint` completed with no schema error. |
| Static RLS/grant/storage contract audit | PASS — every Phase 1 tenant/private table has RLS, explicit grants, and command-specific policies; all four private-bucket policy operations are present. |
| Canonical security mapping | PASS — every Document 07 Phase 1 criterion and the applicable Document 05 foundation gate is mapped in `PHASE-1-COMPLETION-REVIEW.md`. |
| Ministry separability recheck | PASS — no Consulting identifier or dependency exists in active Ministry application, migration, package, or CI paths; no Ministry dependency exists in Consulting runtime, migration, package, or CI paths. |
| Repeatability | PASS — pull-request run `31384046716` independently repeated the complete database job. |
| Hosted-environment safety | PASS — neither existing hosted Supabase project was linked, migrated, seeded, or modified. |

Hosted-project Security and Performance Advisor reports were not run because Phase 1 intentionally used a disposable local Supabase stack in CI and no Consulting hosted project exists. The equivalent pre-hosted checks are schema lint, explicit grant/RLS inspection, and adversarial execution. Advisor review remains a deployment-environment gate before any real client data, not a reason to target an unrelated hosted project.

`LECO-008` is resolved. The Phase 1 evidence gate is satisfied; production migration and real client data remain unauthorized.
