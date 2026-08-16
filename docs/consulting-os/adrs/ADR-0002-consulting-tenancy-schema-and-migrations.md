# ADR-0002: Consulting tenancy, schema, and migration ownership

- **Status:** Accepted — approved 2026-08-10; hosted topology amended 2026-08-15
- **Date:** 2026-08-09; private-repository path incorporated 2026-08-10
- **Depends on:** ADR-0001

## Context

Document 05 makes Organization the hard tenant boundary and requires database-enforced isolation. The existing Ministry schema has a single `profiles.ministry_id`, Ministry roles, and a `current_ministry_id()` fallback to a default Ministry. That behavior is not safe for consultants assigned to multiple client organizations.

## Decision

Create Consulting-owned Postgres schemas and migrations:

- `consulting_os`: tenant-owned product data, typed domain tables, auditable product functions.
- `consulting_security`: non-exposed authorization helpers and narrowly scoped privileged functions.
- `consulting_private`: physically partitioned private coaching/consultant content with no ordinary Data API grants.

Migrations live only in this private Consulting repository at `supabase/migrations/`. They are additive, idempotent where practical, environment-verified before application, and never applied as part of the public Ministry repository migration workflow.

## Hosted Supabase topology amendment — 2026-08-15

Ministry and Consulting use one hosted Supabase project because a completed Consulting engagement is expected to lead into an authorized Ministry setup. This is shared infrastructure, not a shared product data model:

- Ministry continues to own its existing `public` tables and Ministry migrations.
- Consulting owns `consulting_os`, `consulting_security`, `consulting_private`, the `consulting-private` storage bucket, and Consulting migrations.
- Personal remains on a separate Supabase project and is not part of the Ministry/Consulting tenant graph.
- Supabase Auth identity may be shared by Ministry and Consulting, but authorization remains product-local. An Auth user receives no Consulting access without a Consulting assignment or membership and no Ministry access merely because Consulting access exists.
- Each client church or organization is represented by a row in `consulting_os.organizations`; scaling to additional clients does not create additional Supabase projects.
- Ministry and Consulting remain separate repositories, Vercel projects, deployments, domains, and application authorization surfaces.

The hosted project's API and Auth settings are a deliberately managed union of both products' needs. The Consulting `supabase/config.toml` remains a local-development configuration and must not be pushed wholesale to the shared hosted project. In particular:

- `public` remains available to the Ministry application under its existing grants and RLS policies.
- `consulting_os` may be exposed only with its explicit grants and RLS policies.
- `consulting_security` and `consulting_private` remain unexposed.
- Auth redirect allowlists include only approved Ministry and Consulting origins.
- Consulting migrations do not alter Ministry-owned tables, functions, policies, or grants without a future shared-interface ADR.

## Identity and membership core

| Table | Purpose |
|---|---|
| `consulting_os.people` | Consulting profile linked to an authentication subject; no global organizational title/role. |
| `consulting_os.organizations` | Client organization and tenant boundary. |
| `consulting_os.organization_memberships` | Person membership plus Consulting platform role and active state. |
| `consulting_os.consultant_assignments` | Explicit consultant-to-organization authorization. |
| `consulting_os.engagements` | Bounded consulting initiative within exactly one organization. |
| `consulting_os.engagement_memberships` | Participation in one engagement, always through same-organization membership. |
| `consulting_os.visibility_grants` | Team, named-user, coaching, or leadership ACL rows where a simple scope is insufficient. |

A signed-in identity has no Consulting access until an active assignment or membership exists. There is no default Consulting organization.

## Tenant attribution and referential integrity

- Every organization-owned record carries `organization_id` directly.
- Tenant-owned primary targets expose `unique (id, organization_id)`.
- Child tables use composite foreign keys `(parent_id, organization_id)` to prevent cross-tenant links.
- `domain_objects` and `entity_relationships` use the same composite pattern for both endpoints.
- `engagement_id` narrows context but never replaces `organization_id`.
- Organization IDs are resolved from current membership/assignment; browser-supplied IDs are identifiers to authorize, never authorization themselves.

## RLS posture

- Enable RLS on every exposed Consulting table before granting `authenticated` access.
- Write and test SELECT, INSERT, UPDATE, and DELETE independently.
- UPDATE uses both `USING` and `WITH CHECK`; UPDATE also has a compatible SELECT policy.
- Missing, stale, ambiguous, or inactive membership fails closed.
- Sensitive visibility is evaluated after tenant/action eligibility and before row return.
- Relationship writes verify both endpoints and the relationship row share one organization.
- Views exposed to the API use `security_invoker = true`; otherwise they remain in an unexposed schema with grants revoked.
- `SECURITY DEFINER` is exceptional, placed outside exposed schemas, has a fixed empty search path, checks `auth.uid()` internally, and has default PUBLIC execute revoked.

These choices follow current Supabase guidance for [Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security) and [Storage access control](https://supabase.com/docs/guides/storage/security/access-control).

## Platform roles and visibility

Platform roles use Document 05 vocabulary: `PLATFORM_ADMIN`, `CONSULTANT`, `CLIENT_ADMIN`, `CLIENT_LEADER`, and `CLIENT_MEMBER`. Organizational Role remains a domain object and never grants software access by itself.

Visibility uses: `CONSULTANT_PRIVATE`, `INDIVIDUAL_PRIVATE`, `COACHING_SHARED`, `TEAM_SHARED`, `LEADERSHIP_RESTRICTED`, `ENGAGEMENT_SHARED`, `ORGANIZATION_SHARED`, and `PLATFORM_RESTRICTED`.

`ALLOW = current product identity AND active tenant assignment/membership AND action permission AND visibility permission AND record-specific rule`.

## Service-role boundary

- User-facing reads/writes use the user's JWT and RLS whenever possible.
- Service role is not a repository default and never reaches client code.
- Every privileged operation has a named owner, explicit tenant input validated against trusted job context, minimum source set, audit event, and negative authorization tests.
- Background jobs operate on precomputed authorized record IDs or a server-established tenant scope; they do not trust request payload organization IDs.

## Storage

- Consulting files use product-owned private buckets and a Consulting metadata table containing organization, source record, visibility, owner, and retention class.
- Object paths begin with organization ID for operability but paths are never authorization.
- `storage.objects` policies join or validate product-owned metadata and current authorization.
- Extracted text, previews, transcripts, source fragments, and embeddings inherit the source's tenant and sensitivity.
- Upload, read/list, replace/upsert, and delete are tested separately; upsert requires INSERT, SELECT, and UPDATE authorization.

## Migration and extraction strategy

1. Phase 1 creates only tenancy, membership, assignments, visibility, audit, and storage foundations.
2. Later phases add product-owned typed tables; no Consulting migration changes Ministry tables unless an explicit shared-interface ADR is approved.
3. Each migration has a rollback/forward-repair note and synthetic two-tenant fixtures.
4. A migration manifest identifies Consulting files for independent application and later repository/database extraction.
5. No migration is applied to production in this goal without explicit target approval.

## Consequences

- Consulting security can fail closed without changing Ministry behavior.
- Composite keys add schema verbosity but make tenant invariants database-verifiable.
- Sharing one Supabase project remains possible while schemas, migration ownership, and future extraction stay explicit.
- The accepted hosted topology now uses that shared-project option while preserving schema and deployment isolation.
- Separate Consulting storage and private schemas reduce accidental Data API exposure.
- A project-wide privileged key has a larger blast radius in a shared project. Consulting therefore keeps privileged operations server-only, narrowly inventoried, tenant-validated, and auditable; user-facing data access continues through user JWTs and RLS.

## Rejected alternatives

- Reusing `public.ministries` and `current_ministry_id()`.
- Storing tenant context only on parent records.
- Relying on middleware/API filters without RLS.
- Treating the service role as the normal repository client.
- Putting all Consulting tables in `public` with a name prefix.

## Acceptance evidence required in Phase 1

- Two organizations with overlapping names and IDs known to adversarial users.
- Negative SELECT/INSERT/UPDATE/DELETE tests, including moving a row across organizations.
- Same-tenant relationship enforcement.
- Consultant assignment and revocation tests.
- Every visibility scope, private coaching access, storage access, export, search, and AI pre-filter tests.
- Service-role operations fail without verified tenant context and emit audit events when permitted.
