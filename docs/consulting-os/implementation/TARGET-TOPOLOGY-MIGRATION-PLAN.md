# Target topology migration plan

## Decision and safety boundary

The 2026-08-10 checkpoint selected:

- `www.leademergence.com` — public Lead Emergence parent-brand entry;
- `consulting.leademergence.com` — Consulting OS, containing Consultant and Client portals;
- `ministry.leademergence.com` — existing Ministry product;
- `leademergence.com` — redirect to `www`.

This is a target architecture, not authorization to change production. Phase 0 performs no Vercel linking, project creation, deployment, alias, DNS, OAuth/provider configuration, environment-variable change, or Supabase configuration change.

## Verified starting point — 2026-08-10

- Repository root is a single Ministry Next.js application with one `package.json`; there is no monorepo workspace configuration or `vercel.json`.
- The primary local checkout is linked to one Vercel project named `emergence-ministry-platform` through ignored `.vercel/project.json`. The Consulting worktree is deliberately unlinked.
- `www.leademergence.com` currently serves the Ministry Vercel deployment; `leademergence.com` redirects to `www`.
- `ministry.leademergence.com` and `consulting.leademergence.com` do not resolve.
- Root `/` redirects to `/login`, confirming that the current `www` experience is the Ministry login path rather than a parent-brand entry.
- Repository references bind Ministry MCP/OAuth discovery, public URLs, judge/competition paths, daily-operation jobs, and some integration behavior to `www.leademergence.com` or the current Vercel production URL.

Live HTTP checks establish routing behavior only. Vercel dashboard configuration, registrar ownership, DNS-zone ownership, provider callback allowlists, and production environment values still require human-authorized inspection before a change window.

## Target release units

| Release unit | Source boundary | Vercel boundary | Product responsibility |
|---|---|---|---|
| Ministry | repository root | Existing project retained, then assigned `ministry.leademergence.com` | Existing app, Ministry login, Ministry APIs/MCP, Ministry data and integrations. |
| Consulting | private `lead-emergence-consulting-os` repository | Separate project rooted at the future Consulting app | Consultant and Client portals, Consulting data, workflows, prompts, tests. |
| Entry | proposed `products/lead-emergence-entry/` or a separate small repository | Separate project | Public brand and links only; no product authorization or business logic. |

The Ministry and Consulting units are in separate repositories. Do not create a cross-repository runtime or build dependency. Do not reuse the Ministry `.vercel/project.json` for Consulting or Entry.

## Origin-sensitive dependency inventory

Before any domain reassignment, create an owner-verified inventory covering:

- `NEXT_PUBLIC_APP_URL`, `VERCEL_PROJECT_PRODUCTION_URL`, scheduled-job target URLs, and monitoring/performance targets;
- Ministry MCP resource URLs, OAuth protected-resource discovery, consent/callback origins, and existing Codex MCP client registrations;
- Supabase Auth Site URL and redirect allowlist entries;
- Google, Gmail, Drive, Calendar, GroupMe, Planning Center, and any other provider callback/redirect allowlists;
- cookie domain, secure/same-site behavior, CSRF origin checks, CORS, CSP, and allowed-host configuration;
- transactional links, email/message templates, QR codes, documentation, bookmarks, competition/judge links, and external webhooks;
- Vercel domains, aliases, protection settings, environment scopes, cron jobs, observability, and project integrations;
- TLS/DNS ownership, TTLs, apex redirect, canonical URLs, robots/sitemaps, analytics, and search-console ownership.

No inventory item is presumed safe merely because an HTTP redirect exists.

## Staged migration

### Gate 0 — Architecture and licensing

1. **Completed in Phase 0:** restore and verify complete Canonical Document 03 from the explicit authoritative continuation.
2. Approve the Phase 0 ADR packet.
3. **Completed in Phase 0:** establish the separate private Consulting repository and migrate the canonical architecture package.
4. Authorize product-specific implementation phases. No production action occurs at this gate.

### Gate 1 — Independent non-production releases

1. Build Consulting and Entry in their approved source boundaries.
2. Create separate Vercel projects only with explicit production-infrastructure approval.
3. Establish previews and product-specific environment schemas without importing another product's secrets.
4. Prove independent install, build, test, rollback, and deployment for all release units.

### Gate 2 — Ministry subdomain shadow launch

1. Attach `ministry.leademergence.com` to the existing Ministry project while `www` remains unchanged.
2. Add required Supabase/provider redirect allowlists without removing existing `www` values.
3. Make the Ministry canonical origin configurable and eliminate hard-coded `www` assumptions where approved.
4. Validate login, logout, invite/password flows, guest behavior, MCP/OAuth, integrations, scheduled jobs, links, APIs, cookies, security headers, and full browser/regression suites at the Ministry subdomain.
5. Keep `www` serving Ministry until acceptance and rollback rehearsal pass.

### Gate 3 — Consulting subdomain launch

1. Attach `consulting.leademergence.com` only to the separate Consulting project.
2. Validate Consultant and Client login intents, independent authorization, redirect safety, tenant isolation, coaching privacy, storage, exports, and retrieval leakage tests.
3. Confirm that a Ministry-only identity receives no Consulting access and vice versa.

### Gate 4 — Parent-brand entry cutover

1. Deploy and verify the Entry app on a preview/temporary alias.
2. Confirm its only product actions route to the two product-owned login endpoints and that it contains no product code, secrets, private entitlements, or APIs.
3. Move `www.leademergence.com` to the Entry project only after every Ministry dependency uses or accepts the Ministry origin.
4. Retain the apex redirect to `www`; verify canonical metadata and monitoring.
5. Run end-to-end journeys from `www` to each login and prove independent denial for unauthorized product contexts.

### Gate 5 — Stabilization and cleanup

1. Monitor authentication failures, callback errors, MCP clients, scheduled jobs, integration webhooks, 4xx/5xx rates, and certificate/DNS status through an approved observation window.
2. Remove obsolete `www` Ministry callback/allowlist entries only after evidence shows no active dependency.
3. Update public documentation and external clients in a versioned release record.

## Rollback

- Lower DNS TTLs only in an approved change window.
- Preserve the last known-good Ministry deployment and domain assignment.
- If Entry cutover fails, reassign `www` to the known-good Ministry project and leave the already-tested Ministry subdomain intact.
- If a product subdomain fails, remove only that alias or restore its previous deployment; do not alter the other product.
- Keep old callback/redirect allowlist entries during the reversible overlap window.
- Never roll back database schema by destructive production action; product migrations require their own approved rollback/backout plan.

## Cutover acceptance

- Each hostname resolves to exactly its intended independent release unit with valid TLS.
- `www` contains no Ministry or Consulting business logic and routes accurately.
- Consultant, Client, and Ministry journeys reach the correct product context.
- One product's identity or membership never grants the other product.
- Ministry MCP/OAuth, provider callbacks, scheduled jobs, integrations, links, and guest/login flows pass on the Ministry origin.
- Consulting cross-tenant, private-data, storage, export, search, and AI-retrieval attacks fail.
- Product builds and rollbacks work independently.
- A Ministry-only distribution excludes Entry and Consulting code, docs, migrations, prompts, tests, and proprietary dependencies.

Production execution requires a separate change plan naming owners, exact Vercel projects, DNS records/TTLs, provider settings, environment values, timing, monitoring, and rollback authority.
