# Consulting OS blockers

## LECO-001 - Canonical Document 03 source gap

- **Status:** RESOLVED on 2026-08-10 by explicit authoritative continuation.
- **Original evidence:** The supplied and re-provided DOCX both proceeded from `11.2 Harvest and Soil` directly to Section 26 and were byte-identical (`81bb357ef14c4f3ff75cdb5d89f2b85fbd7d5b7d54181735ad652c7cd27c15c7`, 48,963 bytes).
- **Resolution:** The owner supplied Sections 12-30 and Appendices A-D as the authoritative continuation and instructed that they be appended verbatim after Section 11 without reconstruction, interpretation, or summary. The continuation is retained at `canonical/03-domain-model-authoritative-continuation-2026-08-10.md` and merged into the canonical DOCX/Markdown with the stale Section 26-to-end tail replaced once to prevent duplication.
- **Verification:** Sections 12-30 each occur exactly once in both the restored Markdown and a fresh DOCX extraction; the canonical tail exactly matches the retained authoritative continuation. New tables have explicit widths and repeating header rows. Visual render QA remains unavailable because LibreOffice/`soffice` is not installed.

## LECO-002 - Consulting OS intellectual property is inside an MIT-licensed repository

- **Status:** RESOLVED FOR ARCHITECTURE AND FUTURE IMPLEMENTATION by establishing the separate private `lead-emergence-consulting-os` repository on 2026-08-10.
- **Evidence:** The repository root `LICENSE` applies the MIT License without a path-specific exclusion. The Product Separation constraint requires independent licensing/distribution.
- **Affected work:** Product source, prompts, migrations, tests, and canonical/implementation documentation may unintentionally be treated as MIT-licensed.
- **Checkpoint direction:** Consulting OS is intended to remain proprietary and commercially separable; existing Ministry obligations remain unchanged; shared packages require intentional classification. Codex must not change licenses or make legal conclusions automatically.
- **Decision:** All future Consulting implementation, migrations, prompts/workflows, tests/fixtures, deployment configuration, and business logic belong only in the private Consulting repository. No third shared repository/package is approved. Owner/legal review remains required for final license terms and the historical Phase 0 materials; no retroactive legal conclusion is made.

## LECO-003 - Phase 0 completion and Phase 1 authorization

- **Status:** RESOLVED on 2026-08-10.
- **Approved:** ADR-0001 through ADR-0004, ERD, Domain-to-Schema Mapping, private repository boundary, and target topology direction.
- **Final checkpoint:** The owner approved Phase 0 completion and authorized Phase 1. The exact authorization is retained in `PHASE-0-COMPLETION-APPROVAL-2026-08-10.md`.
- **Safety boundary:** Phase 1 implementation remains confined to the private Consulting repository. Production topology execution remains separately unauthorized.

## LECO-004 - Public-domain and deployment topology

- **Status:** RESOLVED FOR PHASE 0 TARGET on 2026-08-10; production execution remains unauthorized.
- **Decision:** `www.leademergence.com` is the parent-brand entry, `consulting.leademergence.com` is the Consulting product, and `ministry.leademergence.com` is the Ministry product. Consultant and Client remain independently authorized contexts within Consulting.
- **Safety boundary:** No production DNS, Vercel project/link/alias, callback, environment, provider, or deployment change is authorized. See `TARGET-TOPOLOGY-MIGRATION-PLAN.md`.

## LECO-005 - Goal attachment ends mid-definition

- **Status:** RESOLVED by explicit owner confirmation on 2026-08-10.
- **Evidence:** The 23,072-byte, 712-line `goal-objective.md` physically ends Final Definition of Done item 5 after `evidence -> observation -> pattern -> assumption/hypothesis ->`, followed only by the pasted-text-file reference. Byte inspection confirms there is no hidden remainder.
- **Decision:** The visible Goal constraints, Product Separation constraint, and Canonical Documents 01-07 together define the authoritative V1 Definition of Done. Document 07 alone governs current V1 phase sequencing, boundaries, acceptance, and completion. The Full Build Plan remains supporting context and post-V1 direction only.
- **Evidence:** `PHASE-0-CHECKPOINT-RESPONSE-2026-08-10.md`.

## LECO-006 - Historical Phase 0 licensing review

- **Status:** OWNER/LEGAL REVIEW REQUIRED; not treated as a technical Phase 0 blocker.
- **Evidence:** Phase 0 Consulting documents and scripts were committed locally in the Ministry repository context before the private repository boundary was executed. A remote branch check at migration time found no published `codex/consulting-os-phase0` branch on the public GitHub remote.
- **Boundary:** Preserve repository history. Do not claim that copying or later deleting files changes historical rights, licensing consequences, or confidentiality.
- **Required follow-up:** Owner/legal review should address the final Consulting license terms and the status of those historical materials before commercialization. Codex must not supply that legal conclusion.

## LECO-007 - Recurring phase approval pauses

- **Status:** RESOLVED by owner direction on 2026-08-10.
- **Decision:** Separate permission is no longer required to start or complete a phase. Phase evidence gates and review packets remain mandatory.
- **Human validation boundary:** Pause only when a concrete issue requires owner validation, including an unresolved canonical conflict, security-sensitive unsupported assumption, destructive production action, external cost confirmation, or materially ambiguous target/environment decision.
- **Evidence:** `PHASE-AUTHORIZATION-2026-08-10.md`.

## LECO-008 - Isolated PostgreSQL execution target for Phase 1 security tests

- **Status:** RESOLUTION IN PROGRESS through private-repository CI; no hosted target decision currently required.
- **Issue:** The workstation has no Docker engine or local PostgreSQL server, so the Supabase migration and pgTAP suite cannot be executed locally. The existing hosted projects are the Ministry production project and a Ministry/Meridian sandbox; neither is assumed to be the Consulting test target.
- **Safety boundary:** Do not apply this migration to either existing project merely to obtain a test run. Do not claim Phase 1 security completion from static checks.
- **Resolution path:** `.github/workflows/phase1-security.yml` starts an isolated disposable Supabase database in GitHub Actions, applies the migration, lints the schemas, runs pgTAP, and removes the database. If that runner cannot provide the required environment, human validation will then be requested for a dedicated hosted Consulting target or local Docker installation. Any hosted project/branch cost must be shown and confirmed before creation.
