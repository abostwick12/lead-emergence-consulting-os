# Canonical Entry identity in Consulting

Status on 2026-08-21: **implemented and locally accepted; not ready for production cutover**. This is the Consulting-side identity-linking, authorization, coexistence, migration, rollback, and operating contract. It does not authorize a production database, provider, deployment, DNS, traffic, or real-user change.

## Non-negotiable authority boundary

```text
Entry canonical identity + ACTIVE CONSULTING eligibility
                    │ OAuth/OIDC proof only
                    ▼
Consulting canonical identity link
                    │ local resolution only
                    ▼
Consulting person → roles/memberships/assignments
                    │ organization + engagement + context
                    ▼
Consulting RLS and record visibility
```

Entry decides whether a canonical account may attempt to enter Consulting. Consulting alone decides whether that identity is a consultant, client, member of an organization, assigned to an engagement, allowed into a tenant, or allowed to read a record. The OAuth callback creates no membership, role, assignment, engagement, or visibility.

Email is never an identity-link key. The durable key is the exact custom-provider subject, which must equal Entry's canonical UUID. A linked person without local authorization receives a safe no-workspace state.

## One-login user journey

- Normal `/login` immediately redirects to `/auth/entry`; Consulting no longer presents a second normal credential page.
- `/auth/entry` starts the configured custom-provider flow and returns only to `/auth/callback/sign-in`.
- If the user already has an Entry session, they continue without another password. Entry still checks its exact OAuth client and current `ACTIVE` entitlement.
- The callback exchanges the code, verifies the provider identity, atomically persists the identity proof, and then sends the user to Consulting context resolution.
- A denied, expired, malformed, mismatched, or conflicting flow fails closed, clears a newly created sign-in session when needed, and shows only an allow-listed error with a retry action.
- `/login?legacy=1` is the explicit password rollback route. It remains available during coexistence but is not part of the normal journey.

An error page may offer the explicit legacy route; that is a recovery option, not a second standard login page.

## Callback mode binding

Sign-in and existing-account linking are different ceremonies:

| Mode | Start | Fixed callback | Required prior state |
| --- | --- | --- | --- |
| New/repeat Entry sign-in | `/auth/entry` | `/auth/callback/sign-in` | No Consulting session required. |
| Link existing Consulting account | `/auth/entry/link` | `/auth/callback/link-existing` | Active consultant/client Consulting session and explicit settings action. |

Each start sets a distinct `HttpOnly`, `SameSite=Lax`, production-`Secure`, exact-path cookie with a ten-minute lifetime. The callback consumes and deletes it. Missing, crossed, expired, or unknown mode state signs out the unsafe local session and fails closed. Callback URLs are exact allow-list entries; open continuations are not accepted.

## Verified identity and durable link

`ENTRY_OIDC_PROVIDER` must match the exact configured custom provider, such as the development value `custom:lead-emergence-entry-dev`. The callback requires exactly one matching Auth identity and validates:

- provider identity `sub` is a UUID;
- provider identity `id` equals that `sub`;
- `sub` equals the canonical Entry UUID stored as `provider_subject` and `canonical_user_id`;
- the provider-local Auth identity UUID is stored separately as `provider_identity_id`;
- uniqueness holds for Consulting Auth user, provider/subject, and provider identity.

`consulting_os.link_entry_oidc_identity(...)` is service-role only and atomic. It either verifies the existing mapping, creates a new person/link for a new OIDC account, or rejects a conflict. It writes `ENTRY_IDENTITY_LINK_CREATED` for a new link and `ENTRY_SSO_IDENTITY_VERIFIED` for repeat proof. Its audit reason explicitly states that no Consulting authorization was created.

A `REVOKED` canonical link cannot be revived by login. A canonical identity already belonging to another Consulting person is rejected. An existing local Consulting person cannot be silently merged during ordinary sign-in.

## Existing-account linking

An existing account is linked only when all of these are true:

1. the user first authenticates to that Consulting account through the explicit legacy route;
2. Consulting resolves an active local consultant or client session;
3. the user chooses the Entry connection action in Consulting settings/context;
4. `/auth/entry/link` uses Supabase manual identity linking with its distinct callback mode;
5. Entry returns a verified provider subject;
6. the service-only RPC confirms the pending canonical link belongs to the same Consulting person;
7. the action is audited.

Matching email addresses alone never initiate or approve the link. Duplicate/conflicting users must be reviewed individually before production and resolved through an approved, audited migration procedure—not by editing link rows ad hoc.

## Consulting authorization after identity proof

Every request continues through Consulting's existing local session, portal-context, tenant, and RLS checks.

- Active matching membership/assignment: authorize only that local role and scope.
- No local membership: safe no-workspace response.
- Removed membership/assignment: access disappears under the local policy.
- Wrong organization or engagement: 404 or empty set according to the endpoint contract.
- Consultant-private data: clients receive empty/denied results even when a server-side control proves the row exists.
- Revoked canonical link: future identity persistence fails.

Entry eligibility is evaluated when OAuth authorization occurs; it is not a Consulting per-request claim. For immediate containment of an already-issued Consulting session, revoke the Consulting Auth session and the applicable local link/membership in addition to changing Entry eligibility.

## Migration contract

The additive migration is `20260821171434_entry_oidc_identity_linking.sql`. It depends on `consulting_os.canonical_identity_links` from `20260819110000_consulting_prospect_321.sql` and adds:

- `auth_user_id`, `provider_identifier`, `provider_subject`, and `provider_identity_id`;
- unique and consistency constraints;
- proof-completeness checks for `LINKED` rows;
- the service-only atomic linking RPC and audit writes.

Apply the prerequisite migration first if it is not present in the target schema, regardless of what a drifted migration-history table claims. Never edit an already-applied migration to backfill these changes. Before application, back up the database and run duplicate/conflict queries for Auth user, canonical UUID, provider subject, provider identity, email, and person ownership. Resolve every result with a named operator and audit record.

The migration is forward-compatible with coexistence: its nullable proof columns permit pre-existing pending links, while the `LINKED` completeness rule applies to verified links. Rollback should disable the new application path/provider and retain the additive columns/data; do not destructively drop identity evidence during an incident.

## Configuration

Required SSO values:

- ordinary Consulting Supabase URL, publishable key, secret key, and `APP_ORIGIN`;
- `ENTRY_OIDC_PROVIDER` with an exact environment-specific custom-provider identifier;
- exact Supabase Auth redirects for `/auth/callback/sign-in` and `/auth/callback/link-existing`;
- custom-provider issuer/client/scopes configured in Supabase Auth;
- Auth sign-up enabled for first-time OIDC users and manual identity linking enabled for the explicit existing-account ceremony.

Development, preview, and production use separate provider/client credentials. Store secrets only in the deployment secret manager; never in browser variables, repository files, screenshots, PRs, or logs. Rotate before production and after any suspected exposure. The legacy handoff variables (`ENTRY_ISSUER`, `ENTRY_JWKS_URL`, `ENTRY_HANDOFF_REDEEM_URL`, `ENTRY_HANDOFF_REDEEM_SECRET`) remain server-only and are not part of the canonical OAuth flow.

## Logout, recovery, and grant revocation

- Consulting `POST /auth/sign-out` clears the Consulting session and returns to `/login`, which can immediately authorize through a surviving Entry session.
- Entry logout is separate. A global sign-out experience must explicitly end both sessions rather than assuming one cookie controls both origins.
- Entry owns ordinary password recovery. Consulting's normal login should direct users into Entry rather than duplicate that workflow.
- Revoking an OAuth grant forces a new consent ceremony. Revoking the Entry entitlement blocks the next authorization, including remembered grants. Neither action substitutes for revoking an active Consulting session or local permission during incident response.

## Coexistence and rollback

Keep both fallback mechanisms available until an approved post-cutover retirement:

1. `/login?legacy=1` for explicit Consulting password login;
2. the earlier signed POST handoff at `/auth/handoff`, with Entry JWKS and one-time nonce redemption.

The POST handoff is rollback-only: do not expand its claims or consumers. Monitor usage, rehearse returning normal `/login` to the known-good legacy experience, and record rollback authority before cutover. A code rollback should disable the OAuth start/provider while retaining links and audit evidence. A database rollback should use forward repair or the approved restore plan, never destructive column/table drops in production.

After stable OAuth burn-in, zero observed transitional use, successful rollback rehearsal, and explicit approval, retire the POST handoff first; revoke its signing/redemption credentials afterward. Retiring legacy password access is a later, separately approved change.

## Verification evidence

On 2026-08-21, isolated development verification passed:

- clean Consulting database rebuild, schema check, and 358 pgTAP assertions;
- 160 unit tests, lint, typecheck, production build, and dependency audit with zero vulnerabilities;
- real Entry OAuth authorization with one password across two Consulting arrivals, one durable identity link, zero auto-created memberships/assignments, expected audit events, and zero browser errors;
- `ACTIVE`, `SUSPENDED`, `REVOKED`, absent, and revoked-with-remembered-grant outcomes with no unauthorized callback session/link mutation;
- explicit existing-account linking with stable person/organization/engagement ownership;
- active membership, no membership, removed membership, wrong tenant, and consultant-private visibility controls;
- Consulting logout while Entry remained authenticated, followed by passwordless reauthorization;
- Entry password recovery through a real isolated mailbox, callback exchange, password change, recovery-session sign-out, and old-password rejection.

The hosted Entry and Consulting Vercel previews use dummy backend origins by design. They prove build/deploy behavior, headers, CSP, public pages, redirects, and fail-closed configuration. They do not prove hosted cross-product OAuth with a real isolated Consulting backend.

## Operational monitoring

Track OAuth starts, callback successes/failures, safe error categories, new-link/reverification audit events, duplicate-link conflicts, no-workspace outcomes, legacy-login usage, and provider/issuer changes. Alert on callback-mode mismatches, unexpected provider identifiers or subjects, conflict spikes, tenant-denial anomalies, or legacy usage after the burn-in window.

Never log passwords, cookies, authorization codes, access/refresh tokens, recovery links, provider client secrets, or entire identity payloads. Use correlation IDs that can join Entry authorization with Consulting callback/audit evidence without exposing credentials.

Incident containment order:

1. stop new OAuth starts or disable the affected provider/client;
2. preserve the explicit legacy route if it remains safe;
3. revoke affected Consulting sessions and local authorization;
4. suspend/revoke Entry eligibility when cross-product entry must stop;
5. rotate credentials and grants;
6. investigate audit evidence and duplicate/conflict state;
7. forward-repair or restore under the approved database plan;
8. rerun the entire hosted matrix before re-enabling.

## Production cutover checklist — currently blocked

Do not cut over until:

- the target schema actually contains `20260819110000_consulting_prospect_321.sql` and `20260821171434_entry_oidc_identity_linking.sql`; current read-only inspection found the prerequisite canonical-link schema absent despite migration-history drift;
- the target custom provider uses the approved environment-specific Entry client, scopes, issuer, exact callbacks, and rotated credentials; current read-only inspection found provider configuration drift;
- Entry has its public site URL, exact redirects, OAuth client, leaked-password protection or approved compensating control, and production-shaped deployment;
- the full matrix passes on isolated hosted backends with synthetic identities and no production/shared data;
- backup/restore evidence, forward-repair plan, session/grant/link revocation runbooks, alerts/dashboards, owner/on-call assignments, rollback rehearsal, conflict review, support communication, and explicit release approval are recorded;
- both separate code PRs are green and reviewed. Merge alone does not authorize target configuration or migration.

Until all gates clear, the release decision is **NOT READY FOR PRODUCTION CUTOVER**.
