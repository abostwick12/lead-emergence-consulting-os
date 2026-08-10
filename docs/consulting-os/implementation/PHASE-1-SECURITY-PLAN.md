# Phase 1 — Security Foundation

**Status:** IN PROGRESS

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

## Remaining evidence before PASS

1. Execute migration from a clean isolated PostgreSQL/Supabase state.
2. Run all 32 pgTAP assertions.
3. Run database lint plus Supabase security and performance advisors.
4. Confirm all exposed Phase 1 tables have RLS and only intended grants.
5. Record migration/test/advisor output here and in `PHASE-STATUS.md`.
6. Rerun the Ministry-only distribution check and confirm the Ministry repository remains independent.

Private-repository CI supplies the first isolated execution environment without touching either existing hosted Supabase project. `LECO-008` remains open until that job passes. Phase 1 must not be marked PASS until database execution evidence exists.
