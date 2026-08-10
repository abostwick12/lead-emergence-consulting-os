# ADR-0001: Product Boundary Architecture

- **Status:** Accepted — private repository decision approved 2026-08-10
- **Date:** 2026-08-09; final repository decision 2026-08-10
- **Decision owners:** Lead Emergence product owner and architecture reviewer
- **Scope:** Repository, runtime, authentication, data, documentation, testing, deployment, distribution, and licensing boundaries

## Context

Lead Emergence Ministry is working software in the public `emergence-ministry-platform` repository under its existing root MIT license. Consulting OS is a distinct commercial product with Consultant and Client portals. The products may share identity infrastructure and later use genuinely product-neutral components, but the Ministry product must remain independently buildable and distributable without Consulting source, migrations, prompts, tests, documentation, or proprietary dependencies.

The unqualified license at the Ministry repository root creates an unacceptable ambiguity for new proprietary Consulting implementation. The repository boundary must therefore be established before Phase 1.

## Decision

Lead Emergence Consulting OS will be implemented in the separate private `lead-emergence-consulting-os` repository.

The existing `emergence-ministry-platform` repository remains the Lead Emergence Ministry product repository and retains its existing licensing and distribution model. Consulting application source, proprietary business logic, migrations, AI prompts/workflows, tests/fixtures, deployment configuration, and future proprietary implementation must not be added to the Ministry repository.

The Consulting repository owns:

```text
lead-emergence-consulting-os/
  app/ components/ lib/ tests/       # introduced only in approved implementation phases
  supabase/migrations/                # Consulting-owned migrations only
  docs/consulting-os/                 # canonical and implementation architecture
  scripts/consulting-os/              # Consulting-only developer tooling
```

The current Phase 0 Consulting architecture package is migrated into this private repository. Removing historical copies from the Ministry repository, if authorized later, will use a separate explicit cleanup commit and will not be described as changing historical licensing consequences.

## Product and dependency boundaries

### Ministry-only

- The public `emergence-ministry-platform` repository, root Next.js application, Ministry deployment, `public` database schema, migrations, RLS, integrations, Meridian/EMMA, meetings, Camp, Scripture, events, tasks, communications, documentation, and tests.
- Ministry authorization remains entirely within Ministry profiles and access controls.

### Consulting-only

- This private repository and its Consultant/Client portals, domain services, Consulting Meridian ontology, prompts, retrieval workflows, schemas, migrations, storage, tests, docs, and deployment configuration.
- Consulting roles, organizations, memberships, assignments, engagements, visibility, coaching privacy, assessments, outcomes, baselines, and Signals.

### Shared-neutral candidates

No third shared repository or package is approved at this time. Duplication is preferable to prematurely introducing a dependency between the public Ministry distribution and proprietary Consulting OS.

Potentially neutral authentication utilities, design primitives, provider transports, generic types, or audit envelopes remain candidates only. Extraction requires a future ADR that proves product neutrality and defines ownership, versioning, dependency direction, distribution, and licensing. Until then, neither product imports source from the other.

## Route and deployment architecture

The approved target topology remains:

- `www.leademergence.com` / `leademergence.com`: future parent-brand entry experience;
- `consulting.leademergence.com`: independently deployable Consulting OS with Consultant and Client authorization contexts;
- `ministry.leademergence.com`: independently deployable Ministry product.

The topology decision does not authorize Vercel project creation, deployment, aliases, DNS, callbacks, environment variables, or provider changes. The parent-brand Entry implementation location remains deferred; it must not create a Ministry-to-Consulting source dependency.

## Authentication and data boundaries

- Authentication identity may be shared, but each product resolves authorization independently.
- Ministry membership never grants Consulting access, and Consulting membership never grants Ministry access.
- Consulting owns its schemas, migration history, storage conventions, exports, backups, prompts, and retrieval rules.
- Any future cross-product data exchange requires an explicit versioned interface and purpose-specific consent. V1 has no cross-product client-data exchange.

## Ministry-only distribution

The Ministry repository and release must install, build, test, license, deploy, and operate without cloning or reading this private repository. No Ministry package manifest, build, migration, environment schema, runtime route, CI job, or documentation link may require Consulting content.

## Licensing boundary

- Existing Ministry licensing obligations remain unchanged unless separately approved.
- No license text is authored or changed by this ADR.
- Final Consulting licensing terms and the status of Phase 0 materials previously committed in the Ministry repository context require owner/legal review.
- The absence or later removal of a file from the Ministry repository must not be represented as retroactively changing rights or repository history.

## Consequences

- New proprietary Consulting implementation is kept outside the public Ministry repository license context.
- Ministry remains stable and independently distributable.
- Some neutral-looking code may be duplicated until sharing is justified.
- Two product repositories require separate CI, release, environment, migration, and security ownership.
- A future Entry experience and any shared-neutral extraction require later decisions.

## Reversibility

The private repository boundary is established before implementation, when correction cost is lowest. Code may later be extracted into deliberately governed neutral packages through a future ADR. Recombining the products or introducing cross-repository runtime dependencies would require a new Product Boundary ADR and Ministry-only distribution proof.

## Rejected alternatives

- Add Consulting routes or implementation to the public Ministry repository.
- Depend on path-level notices alone while the repository root remains unqualified MIT.
- Create a shared repository/package before a concrete neutral capability is proven.
- Reuse Ministry organizations, authorization, Meridian, meeting tables, or root migrations for Consulting.
- Move or restructure the working Ministry application merely to establish the Consulting boundary.

## Approval record

- [x] Product owner selected the separate private Consulting repository.
- [x] Target `www` / `consulting` / `ministry` topology selected; production execution remains unapproved.
- [x] Independent product authorization and Consulting schema ownership approved through ADR-0002 and ADR-0004.
- [x] No third shared repository/package approved; future extraction requires an ADR.
- [x] Ministry-only independent distribution remains mandatory.
- [ ] Owner/legal review addresses final Consulting license terms and the historical Phase 0 materials.
