# Lead Emergence Consulting OS architecture set

This directory is the canonical documentation source of truth inside the separate private Lead Emergence Consulting OS repository. The public Ministry repository must not depend on this directory or receive it in a Ministry-only handoff.

## Authority order

When sources differ, use this order:

1. [`constraints/build-goal.md`](constraints/build-goal.md)
2. [`constraints/product-separation-repository-architecture.md`](constraints/product-separation-repository-architecture.md)
3. Canonical Documents 01-07 in [`canonical/`](canonical/)
4. Approved Architecture Decision Records in [`adrs/`](adrs/)
5. [`reference/full-build-plan.docx`](reference/full-build-plan.docx)
6. Other reference or planning material
7. Existing implementation
8. Developer inference

The Product Separation constraint controls product, repository, documentation, branch/worktree, distribution, licensing, shared-platform, and Ministry-versus-Consulting boundaries. Canonical Document 07 alone controls current V1 phase numbering, phase boundaries, build order, acceptance criteria, and completion.

## Canonical documents

| # | Canonical authority | Repository source |
|---|---|---|
| 01 | Lead Emergence Product Constitution | [`01-product-constitution.docx`](canonical/01-product-constitution.docx) |
| 02 | Emergence Methodology & Consulting Workflow | [`02-emergence-methodology.docx`](canonical/02-emergence-methodology.docx) |
| 03 | Domain Model & Relationship Ontology | [`03-domain-model.docx`](canonical/03-domain-model.docx) |
| 04 | Meridian Epistemology & Provenance | [`04-meridian-epistemology.docx`](canonical/04-meridian-epistemology.docx) |
| 05 | Security & Multi-Tenancy | [`05-security-multitenancy.docx`](canonical/05-security-multitenancy.docx) |
| 06 | Portal Information Architecture & UX | [`06-portal-ux.docx`](canonical/06-portal-ux.docx) |
| 07 | V1 Scope & Acceptance Criteria | [`07-v1-scope-acceptance.docx`](canonical/07-v1-scope-acceptance.docx) |

The original `.docx` files are retained sources except Canonical Document 03, whose owner-supplied authoritative continuation has been appended after Section 11 and whose stale Section 26-to-end tail was replaced once to avoid duplication. The exact continuation is retained beside it. Adjacent Markdown files are searchable companions. Checksums and conversion notes are in [`SOURCE-MANIFEST.md`](SOURCE-MANIFEST.md).

## Supporting reference

The Full Build Plan explains the broader vision and rationale, but it predates the canonical set. It does not authorize scope, terminology, sequencing, or phase numbering that conflicts with the Goal or Documents 01-07.

## Conflict handling

Do not silently reconcile a material conflict. Record it in [`implementation/BLOCKERS.md`](implementation/BLOCKERS.md) and, where an architectural choice is possible, create an ADR. Stop only work dependent on the conflict and continue independent work safely.

## Implementation record

- [`implementation/IMPLEMENTATION-PLAN.md`](implementation/IMPLEMENTATION-PLAN.md) - architecture, phases, dependencies, migration strategy, decisions, and next steps.
- [`implementation/PHASE-STATUS.md`](implementation/PHASE-STATUS.md) - evidence-based phase status and checkpoint state.
- [`implementation/BLOCKERS.md`](implementation/BLOCKERS.md) - unresolved human decisions and source defects.
- [`implementation/ERD-PROPOSAL.md`](implementation/ERD-PROPOSAL.md) - Phase 0 data architecture proposal.
- [`implementation/DOMAIN-SCHEMA-MAPPING.md`](implementation/DOMAIN-SCHEMA-MAPPING.md) - canonical entity-to-schema mapping.
- [`implementation/LEGACY-CONFLICT-MAP.md`](implementation/LEGACY-CONFLICT-MAP.md) - existing implementation classification.
- [`implementation/MINISTRY-ONLY-DISTRIBUTION.md`](implementation/MINISTRY-ONLY-DISTRIBUTION.md) - independent Ministry handoff boundary and acceptance test.
- [`implementation/PHASE-0-CHECKPOINT.md`](implementation/PHASE-0-CHECKPOINT.md) - decision packet and explicit approval record.
- [`implementation/PHASE-0-ACCEPTANCE-AUDIT.md`](implementation/PHASE-0-ACCEPTANCE-AUDIT.md) - exact Document 07 and Goal checkpoint evidence matrix.
- [`implementation/PHASE-0-CHECKPOINT-RESPONSE-2026-08-10.md`](implementation/PHASE-0-CHECKPOINT-RESPONSE-2026-08-10.md) - exact owner checkpoint direction.
- [`implementation/PHASE-0-COMPLETION-APPROVAL-2026-08-10.md`](implementation/PHASE-0-COMPLETION-APPROVAL-2026-08-10.md) - exact owner approval completing Phase 0 and authorizing Phase 1.
- [`implementation/TARGET-TOPOLOGY-MIGRATION-PLAN.md`](implementation/TARGET-TOPOLOGY-MIGRATION-PLAN.md) - staged, reversible production topology plan; no execution authorization.

Consulting OS implementation work must use dedicated `codex/consulting-os-*` branches and worktrees in this private repository. Phase 0 is recorded on `main`; Phase 1 is authorized but no Phase 1 implementation branch or worktree has been created yet.

## Approved repository boundary

The 2026-08-10 architecture approval selected this separate private repository for all Consulting-specific implementation, architecture, migrations, prompts/workflows, tests, fixtures, and deployment configuration. No third shared repository/package is approved. Future shared-neutral extraction requires a new ADR; duplication is preferred until neutrality is proven.

ADR-0001 through ADR-0004, the ERD, and Domain-to-Schema Mapping are approved. Phase 0 is complete, and Phase 1 is authorized but has not yet started.
