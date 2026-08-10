# Lead Emergence Consulting OS

This is the private repository boundary for Lead Emergence Consulting OS. It contains the canonical Consulting source package, Phase 0 architecture, and Consulting-only developer tooling.

## Repository boundary

- This repository owns Consulting architecture, application source, business logic, migrations, prompts/workflows, fixtures, tests, and deployment configuration.
- The existing `emergence-ministry-platform` repository remains the independently distributable Ministry product and does not depend on this repository.
- No shared package repository is approved. Duplication is preferred until a future ADR identifies a genuinely product-neutral capability and defines its governance and licensing.
- No license text was created or changed during the repository migration. Owner/legal review remains responsible for final licensing terms and the historical Phase 0 materials originally committed in the Ministry repository context.

## Authority and documentation

The Consulting architecture source of truth begins at [`docs/consulting-os/README.md`](docs/consulting-os/README.md). Canonical Documents 01-07, the build constraints, approved ADRs, ERD, schema mapping, blockers, and Phase 0 audit are retained beneath that directory.

## Current status

- ADR-0001 through ADR-0004: approved for Phase 0.
- ERD and Domain-to-Schema Mapping: approved for Phase 0.
- Repository boundary: separate private Consulting repository selected and established.
- Production DNS/deployment changes: not authorized.
- Phase 0: complete and approved on 2026-08-10.
- Phase 1: complete; its isolated migration, lint, and 32 adversarial security assertions passed twice. The security foundation is not deployed.
- Phase 2: complete at the evidence gate; its typed Meridian migration, schema lint, and 27 Phase 2 assertions passed with the 32 Phase 1 security assertions. Nothing is deployed.
- Phase 3: in progress on `codex/consulting-os-phase3`; the database-first Consulting Core and 45-assertion acceptance suite are not deployed.

Target topology remains:

- `leademergence.com` / `www.leademergence.com` — future parent-brand entry experience;
- `consulting.leademergence.com` — Consulting OS;
- `ministry.leademergence.com` — Ministry product.
