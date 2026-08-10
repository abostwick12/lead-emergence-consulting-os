# ADR-0003: Typed domain tables with a relationship registry and explicit versioning

- **Status:** Accepted — approved 2026-08-10
- **Date:** 2026-08-09; restored Canonical Document 03 reconciled 2026-08-10
- **Depends on:** ADR-0002

## Context

Document 03 requires strongly typed entities and controlled graph-shaped relationships. A pure generic node store would weaken semantics; only direct typed foreign keys would make cross-domain reasoning relationships difficult. Durable organizational truth must retain history.

## Decision

Use a small `consulting_os.domain_objects` registry plus strongly typed tables:

- Every relationship-capable typed record has one registry row with `id`, `organization_id`, controlled `object_type`, origin, creator, timestamps, and lifecycle metadata.
- Typed tables use the same `(id, organization_id)` key and contain entity-specific required fields and constraints.
- `consulting_os.entity_relationships` references registry endpoints through composite foreign keys and carries controlled relationship type, direction, rationale, origin/review state, and provenance.
- Each relationship row carries the Canonical Section 14 contract: stable ID, direct `organization_id`, optional `engagement_id`, controlled type, typed source and target IDs, origin, review status, rationale, optional confidence, audit origin, and applicable effective dates.
- Endpoint-type constraints are enforced against the Section 14 allowed source-to-target matrix by database validation plus product service validation and acceptance tests. Relationships never substitute for typed foreign keys where a required structural relationship exists.
- Composite endpoint keys make `entity_relationships.organization_id = source.organization_id = target.organization_id` structurally mandatory. Endpoint visibility is checked independently; an edge can never broaden access to either endpoint.
- AI-created inferential edges begin `SUGGESTED`. AI cannot create an accepted `CAUSES` edge. `SUPERSEDES` normally remains within one entity family, while `DERIVED_FROM` and `SUPPORTED_BY` retain inspectable source location.

This is a registry for integrity and graph traversal, not a generic content store.

## Versioning

Versioned constructs use:

- `logical_id` - stable identity across versions.
- `version_number` - monotonic within organization/logical ID.
- `effective_from` / `effective_to` - operative time.
- `supersedes_id` - immediate prior version.
- immutable historical versions; edits create a new version after approval where the object is canonical organizational truth.

The pattern applies at minimum to Identity Elements, Organizational DNA, Future-State Narratives, Future-State Principles, Roles, Responsibilities, Authorities, Boundaries, Workflows, Design Principles, Goals, Value Hypotheses, Assumptions, and Emergent Organization Profiles. Assessment Instrument versions become immutable once used. Decisions are append-oriented and superseded/reconsidered rather than overwritten. Baseline Snapshots are immutable time-stamped manifests rather than mutable current-state rows.

## Evidence and source fragments

- `evidence_sources` represents the source object.
- `evidence_fragments` is append-oriented and immutable, with locator, content hash, provenance, sensitivity, and captured context.
- `evidence` points to one or more fragments and describes how the material is relevant without collapsing it into Observation.
- Corrections append a corrected fragment and relationship; they do not erase the fragment used by historical reasoning.

## Decisions and causality

- Decision is a dedicated typed table containing statement, authority, rationale, alternatives, review trigger, and status.
- `ASSOCIATED_WITH`, temporal sequence, `CONTRIBUTED_TO`, `CAUSES`, and prospective Value Hypothesis remain distinct.
- `CONTRIBUTED_TO` is the preferred human-reviewed attribution when multiple influences plausibly matter.
- `CAUSES` is exceptional and requires explicit human validation, supporting evidence, alternative-explanation consideration, and documented rationale. AI may suggest a causal hypothesis but cannot create an accepted `CAUSES` edge.

## Current-state and snapshots

- Current-state views select the effective accepted/validated version and use security-invoker semantics.
- Baseline Snapshot stores a manifest of versioned object IDs and snapshot metadata, not an uncontrolled duplicate of all live rows.
- Emergent Organization Profile remains distinct from the Future State and can become the next baseline through an explicit relationship.
- Present-state retrieval resolves currently effective versions; historical retrieval resolves the versions effective at the requested time.

## Consequences

- Referential integrity and generic reasoning traversal coexist.
- Typed tables are more verbose than a universal claims table but preserve canonical meanings.
- Historical queries can reconstruct what was operative when a Decision was made.
- Materialized current-state views can be optimized later without changing truth history.

## Canonical reconciliation

The authoritative Section 12-to-end continuation supplied on 2026-08-10 has been restored after Section 11 and verified without duplicated tail sections. This decision incorporates the meeting/coaching privacy invariant, New Reality objects, Section 14 relationship contract and endpoint vocabulary, epistemic boundaries, temporal semantics, artifact composition, assessment boundaries, security requirements, and database guidance from Sections 12-25. `LECO-001` is resolved and the decision is approved.

## Rejected alternatives

- One generic `nodes` table for all content.
- One polymorphic JSON table without entity-specific constraints.
- Overwriting current rows and relying only on audit logs for history.
- Automatic causal edges from correlated outcomes.
