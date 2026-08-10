# Phase 3 — Consulting Core

**Status:** PASS — evidence gate and mandatory human checkpoint approved 2026-08-10

**Branch/worktree:** `codex/consulting-os-phase3` / `.worktrees/consulting-os-phase3`

**Production application:** Not authorized and not performed.

## Bounded deliverable

Phase 3 provides the database-first Consulting Core needed to complete SEE REALITY and REFRAME. Phase 4 remains responsible for polished Consultant and Client portal presentation.

- Structured Organizational Portrait and Current-State Reality Map artifacts with controlled sections and typed members.
- Risk, Strength, Unrealized Potential, and Diagnosis as distinct epistemic types.
- Interview and Emergence 360 inquiry collection with exact evidence fragments, explicit consent/confidentiality, and physical private partitions.
- Immutable used Assessment Instrument versions/items, historical response binding, explicit comparison compatibility, and no unsupported psychometric-validation claim.
- Assumption Register projection with evidence-for and evidence-against counts.
- Versioned Identity Elements and curated Organizational DNA.
- The canonical six-part Future-State Narrative.
- Versioned Future-State Principles and structured Future States.
- Materialized approved Organizational Blueprint composition.
- Fail-closed composition rules preventing private analysis from becoming client-visible content by reference.

Phase 3 does not ship portal UI, meetings, coaching, alignment architecture, capabilities, outcomes, New Reality, AI generation, or descriptive Signals.

## Canonical Document 07 acceptance mapping

| Requirement | Automated evidence |
|---|---|
| Complete Organizational Portrait inside platform | Ten controlled Portrait sections, typed member composition, and completion projection |
| Collect assessment and interview evidence with provenance/privacy | Activity-specific Evidence Sources/Fragments, response provenance triggers, anonymity/cohort rules, and private partitions |
| Create source-grounded Observations and review Patterns | Existing Phase 2 citation/relationship chain plus explicit Pattern review fixture |
| Build Reality Map from typed objects rather than a dead report | Ten canonical sections, allowed member-type matrix, and typed artifact membership |
| Maintain Assumption Register with evidence for/against | Security-invoker current Assumption Register with supporting/challenging relationship counts |
| Create Identity/DNA and canonical six-part Future-State Narrative | Versioned identity chain, DNA composition, six required narrative fields, Future States/principles, and Blueprint |
| Separate consultant-private analysis from client-visible conclusions | Physical private schemas, visibility-broadening trigger, validated shared conclusion view, and client RLS attacks |

## Security and epistemic invariants

- Every typed record has a same-tenant registry identity and inherits Phase 1 visibility enforcement.
- Artifact and Blueprint members require same-tenant endpoints and an allowed controlled type.
- Shared compositions cannot reference consultant-private, individual-private, or coaching-private members.
- Assessment and Interview responses must cite fragments from the activity's own Evidence Source without broadening source visibility; confidential and anonymous assessment responses are physically private.
- Anonymous responses contain no respondent identity and require a non-reversible participant token hash.
- Emergence 360 is recorded as an organizational inquiry framework unless real validation evidence supports a stronger claim.
- Used assessment definitions are immutable; revisions create new versions and historical responses retain their administered version.
- Versioned identity/future constructs are append-only and validate same-logical-record predecessor chains.
- Current views use `security_invoker = true`; private or cross-tenant records remain subject to RLS before projection.

## Exit evidence required

1. Phase 0–3 static verifiers pass.
2. All three migrations apply from an empty disposable Supabase state.
3. Consulting schema lint passes.
4. All 104 cumulative database assertions pass: 32 security, 27 Meridian, and 45 Consulting Core.
5. Both structured artifacts are complete and the six-part narrative/Blueprint are queryable.
6. Assessment history, source provenance, version immutability, and private/client-visible separation attacks pass.
7. The Ministry repository remains independent and untouched.
8. The completion review does not claim Phase 4 portal presentation or later-phase functionality.
