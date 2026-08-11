# Phase 8 — Grounded AI plan

## Outcome

Phase 8 adds contextual Meridian assistance without creating a generic chatbot or a privileged truth source. Assistance operates only inside the assigned consultant's current organization and engagement. The deterministic V1 adapter proves the full authorization, provenance, review, and refusal contract without provider credentials or production calls.

Permission filtering before ranking is a hard execution boundary, not a presentation convention.

## Canonical acceptance map

| Document 07 acceptance | Implementation and proof |
|---|---|
| Every substantive AI suggestion records AI origin, exact source set, and review state | `domain_objects.origin = AI`; Pattern begins `SUGGESTED`; `ai_generation_runs`, `ai_run_sources`, `ai_outputs`, and exact `claim_citations`; database and browser assertions. |
| AI cannot validate Insight or Diagnosis or make a Decision | `enforce_ai_authority_boundary` rejects AI-origin Insight, Diagnosis, Decision, Record Review, Outcome Decision, and Value Evaluation; task validator refuses authoritative actions. |
| Authorization filtering occurs before ranking | `permission_filter_applied_at` is recorded before any run-source rank; `assert_ai_source_eligible` rejects cross-tenant, inaccessible, private, coaching, platform-restricted, and non-Evidence sources before insertion or synthesis. |
| Citations resolve to actual source objects | Run sources carry tenant-aware foreign keys to the Evidence domain object and immutable Evidence Fragment; every substantive Pattern writes `claim_citations`. |
| Pattern suggestions expose supporting and contrary evidence | A completed Pattern requires two `SUPPORTING` sources and one `CHALLENGING` source; both are visually distinct in the review card and tested. |
| Rejected suggestions never later appear as truth | Rejection creates a human `record_reviews` entry, preserves the AI Pattern, removes it from active fixture retrieval, and remains excluded from `ai_truth_eligible_records`. |
| Insufficient evidence is stated | Requests below the evidence threshold persist `INSUFFICIENT_EVIDENCE` with an explicit limitation and create no suggestion. |

## Contextual experience

- Discovery and Strategy show a grounded review queue inside the existing cohesive Consulting OS shell.
- Each suggestion exposes AI origin, `SUGGESTED`, scope, recurrence basis, limitations, source visibility, exact locators, supporting evidence, and contrary evidence.
- Meeting preparation uses only the displayed permission-eligible shared source set and states that private coaching notes were not searched or summarized.
- Client contexts do not expose the consultant's raw AI review queue.

## Security and epistemic boundaries

- AI tables have RLS and no direct authenticated write grants; narrowly scoped functions enforce the assigned-consultant workflow.
- Output visibility inherits the most restrictive eligible source visibility.
- Private, individual-private, coaching-shared, and platform-restricted objects are not AI sources.
- AI cannot assert `CAUSES` or `CONTRIBUTED_TO` relationships.
- Human rejection rationale and source snapshots remain append-oriented audit evidence.
- Hosted model calls, provider credentials, production migrations, and deployment changes are outside this phase.

## Verification

- Unit: source authorization before synthesis, insufficient evidence, exact source roles, authoritative-task refusal, and rejection history.
- Browser: consultant provenance/review workflow, supporting and contrary evidence, client non-exposure, narrow viewport, and fresh screenshots.
- Database: tenant isolation, private coaching exclusion, permission-before-rank timestamp, exact citations, output sensitivity, AI authority bans, attribution bans, insufficient evidence, rejection history, and truth-retrieval exclusion.
- Static: `scripts/consulting-os/verify_phase8_grounded_ai.ps1` maps the phase implementation back to the canonical criteria.
