# Lead Emergence Consulting OS implementation plan

## Current outcome

Phase 0 established and received human approval for the repository, licensing, domain, tenancy, and security architecture. Phases 1–8 implemented and proved the isolated security foundation, Meridian Core, Consulting Core, cohesive role-safe portals, one privacy-specialized meeting/coaching engine, the validated Insight-to-organizational-design-to-capability pathway, the complete prospective-value-to-observed-outcome-to-New-Reality-to-immutable-Baseline loop, and contextual permission-first grounded AI with exact provenance and human review.

Canonical Document 07 controls the phase sequence below. The older Full Build Plan remains explanatory reference only.

## Architecture

The ecosystem has independently governed product contexts:

| Context | Approved/current location | Owns |
|---|---|---|
| Ministry app | public `emergence-ministry-platform` repository; target `ministry.leademergence.com` | Existing ministry operations product, routes, data model, migrations, tests, branding, and release process. |
| Consulting OS | this private `lead-emergence-consulting-os` repository; target `consulting.leademergence.com` | Consultant and Client portals, Consulting domain model, prompts, tests, migrations, storage conventions, and release process. |
| Lead Emergence entry | future source boundary to be decided; target `www.leademergence.com` | Public parent-brand product selection and product-context routing only. No product business logic. |

No third shared repository/package is approved. The products may duplicate small utilities, types, or UI primitives rather than create premature coupling. A genuinely neutral capability may be extracted only through a future ADR defining ownership, licensing, interfaces, versioning, and distribution. Product repositories may not import source from one another.

Consulting data uses owned PostgreSQL schemas (`consulting_os`, `consulting_security`, and `consulting_private`) and product-owned migrations. A shared Supabase Auth identity may be used, but authorization is derived from Consulting membership and assignment tables, never Ministry roles or mutable user metadata. The complete data and access decisions are in `ADR-0002` and `ADR-0004`.

The domain uses typed tables for canonical meaning, a same-tenant object registry for graph relationships, explicit provenance/review records, and immutable or superseding versions where history matters. The complete decision is in `ADR-0003`.

The target topology and safe staged cutover are defined in `TARGET-TOPOLOGY-MIGRATION-PLAN.md`. The current Ministry app continues serving `www`; the Ministry subdomain and origin-sensitive dependencies must be proven before `www` can move to the Entry app. Phase 0 changes no production infrastructure.

## Phase sequence and gates

| Phase | Deliverable | Entry dependency | Exit evidence |
|---|---|---|---|
| 0 — Architecture Freeze | Canonical terminology, ADRs, ERD, schema mapping, conflict map, boundary and release plan. | All nine sources reconciled. | Every V1 entity represented or explicitly blocked; all proposed ADRs reviewed; Phase 0 checkpoint approved. |
| 1 — Security Foundation | Organizations, engagements, identities, memberships, assignments, visibility, RLS, storage, audit. | Approved Phase 0 and licensing decision. | Canonical security tests, cross-tenant attacks, private-data attacks, storage tests, and service-role isolation pass. Human checkpoint required. |
| 2 — Meridian Core | Evidence, fragments, reasoning-chain entities, relationships, decisions, provenance, review, versioning. | Phase 1 security primitives. | A manual evidence-to-decision chain is complete, cited, reviewable, versioned, and same-tenant constrained. |
| 3 — Consulting Core | Portrait, evidence library, interviews, Emergence 360 framework, Reality Map, Assumptions, Identity/DNA, Future State and Blueprint. | Meridian Core. | Consultant can complete SEE REALITY and REFRAME inside the product. Human checkpoint required. |
| 4 — Portals V1 | Consultant and Client portals, workspaces, roadmap rail, details, attention states. | Consulting Core plus role-safe read models. | Same domain is presented safely and usefully to each role. |
| 5 — Meetings + Coaching | Shared meeting interaction pattern, coaching relationships, private/shared notes, commitments, history. | Portal shell and private partition. | Real create/edit/save/read cycles persist with correct privacy. |
| 6 — Alignment + Capability | Roles, authorities, boundaries, interfaces, workflows, initiatives, capability requirements/gaps/development. | Consulting Core and Meridian traceability. | Insights trace into design decisions and capability work. |
| 7 — Outcomes + New Reality | Goals, indicators, value hypotheses, measurements, outcomes, Harvest & Soil, learning, emergent profile and baseline. | Alignment and capability records. | Intended Future State and observed Emergent Reality remain distinct and traceable. Human checkpoint required. |
| 8 — Grounded AI | Permission-filtered summaries/extraction, suggestions, meeting preparation, provenance. | Secure retrieval over approved domain records. | Every output is cited, reviewable, source-scoped, and access-safe; no autonomous validation or diagnosis. |
| 9 — Descriptive Signals | New observations, trends, assumptions due, emerging questions, baseline comparisons. | Reviewed New Reality baseline and Meridian chain. | SEE AGAIN is descriptive and transparent without unsupported drift intelligence. Final human checkpoint required. |

No later phase begins merely because code from an older implementation resembles its features. Each phase must satisfy Document 07 acceptance criteria with fresh evidence.

## Dependencies and ordering constraints

1. The private Consulting repository and canonical source boundary are established; Phase 1 was explicitly authorized on 2026-08-10.
2. Tenant attribution, access helpers, RLS, private partitions, audit, and storage policy land before domain features.
3. Meridian provenance and human review land before consulting synthesis or AI.
4. Consulting records land before portals; portals are projections over the same domain, not parallel databases.
5. Coaching privacy lands before coaching features or retrieval indexing.
6. Outcomes and actual Emergent Reality land before descriptive signal comparison.
7. AI reads only records already authorized by the same server/database path used by ordinary product reads.

## Migration strategy

- Consulting migrations live under `supabase/migrations/` in this private repository and never in the Ministry repository or migration directory.
- Phase 1 begins with additive schemas, helper functions, identity/membership/assignment tables, audit tables, storage conventions, and RLS. No production migration is applied during architecture work.
- All exposed tables have RLS enabled before grants. Policies name the intended roles and implement `USING` and `WITH CHECK` as required.
- Tenant-scoped foreign keys include `organization_id`; graph endpoints use composite foreign keys so cross-tenant relationships cannot be represented.
- Private coaching, assessment, interview, and reflection records live in `consulting_private` with narrowly scoped access functions and safe projections.
- Service-role operations are server-only, explicit, audited, and tested because service-role credentials bypass RLS.
- Storage object paths begin with the product and organization boundary, but authorization is enforced by database policy rather than path naming alone.
- Rollback and backfill instructions accompany every migration. Production application requires a separately approved environment plan.
- Ministry tables are not renamed, repurposed, or backfilled into Consulting tables. Any future extraction is a deliberate data migration, not an implicit join.
- Domain/deployment migration is separately staged: establish independent previews, shadow-launch Ministry at its subdomain, migrate origin-sensitive dependencies, launch Consulting, then move `www` to the Entry app last. DNS-only cutover is prohibited; see `TARGET-TOPOLOGY-MIGRATION-PLAN.md`.

## Testing and acceptance strategy

Each phase maintains a requirements matrix from Document 07 acceptance statements to automated tests, manual evidence, or an explicit human decision. At minimum:

- unit tests for visibility, state transitions, provenance, and version selection;
- database tests for RLS, cross-tenant foreign keys, grants, and storage policy;
- integration tests for create/edit/save/read and complete reasoning-chain workflows;
- browser tests for role-appropriate portals, keyboard use, responsive behavior, and truthful UI states;
- adversarial tests for URL guessing, record-ID substitution, export leakage, private coaching leakage, and AI retrieval leakage;
- a complete synthetic engagement test before dogfood or pilot readiness;
- an independent Ministry-only distribution build and test.

AI evaluation uses fixed, permission-scoped fixtures and verifies citations, source-set recording, review state, limitations, and refusal to convert suggestions into validated conclusions.

## Phase completion procedure

For each phase:

1. Update `PHASE-STATUS.md` with requirement-level evidence.
2. Record unresolved source conflicts or human decisions in `BLOCKERS.md`.
3. Run product-specific checks plus the repository checks required by `AGENTS.md`.
4. Verify the relevant product can build independently and the Ministry-only distribution remains free of Consulting files and dependencies.
5. Commit the coherent phase result on its dedicated branch.
6. At Phases 0, 1, 3, 7, and 9, record the required human-review packet and evidence. Under the standing authorization dated 2026-08-10, work may continue when the gate passes; pause only when an issue requires human validation.

## Governing decisions

- Phase 0 is complete and approved.
- Phases 1–8 are complete at their evidence gates; all implementation remains confined to the private Consulting repository.
- Separate phase-start and phase-completion permission is no longer required; evidence gates remain mandatory, and unresolved issues still require human validation.
- Track owner/legal review of final Consulting licensing terms and historical Phase 0 materials without claiming retroactive confidentiality or licensing changes.
- Keep production topology execution unauthorized until a separate infrastructure change plan is approved.

## Next executable step

Phase 9 Descriptive Signals is the next executable phase after the verified Phase 8 gate. It must show recent Observations, compatible version-aware trends, Assumptions due for review, emerging questions, and the current Baseline without autonomous diagnosis or fake drift intelligence. A Signal must remain weaker than a Pattern and be able to re-enter SEE REALITY as a new Observation/re-entry item. Private coaching content remains excluded unless a separate human-authored derivative was explicitly promoted. The final phase must also run the Complete Engagement Acceptance Test, cross-cutting security/privacy gates, and Ministry-only distribution verification before the final human checkpoint. Production migrations, provider credentials, hosted AI calls, and topology changes remain separately unauthorized.
