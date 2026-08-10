# Phase 2 — Meridian Core

**Status:** IN PROGRESS

**Branch/worktree:** `codex/consulting-os-phase2` / `.worktrees/consulting-os-phase2`

**Production application:** Not authorized and not performed.

## Bounded deliverable

- Immutable, inspectable Evidence Sources and Evidence Fragments with exact locators, hashes, provenance, and quality dimensions.
- Typed Evidence, Observation, Pattern, Assumption, Hypothesis, Interpretation, Insight, Decision, Review, Alternative, and Citation records.
- Same-ID typed registration and same-tenant composite foreign keys.
- Controlled relationship source/target matrix for the Phase 2 ontology.
- AI-originated inferential records that must begin `SUGGESTED`.
- Append-only human validation/rejection with reviewer, rationale, evidence, contrary evidence, limitations, dissent, and audit history.
- A validated-Insight gate before an Insight may inform a Decision.
- Competing and rejected interpretations preserved without being presented as operative truth.
- Versioned Assumptions with effective-time retrieval and explicit `SUPERSEDES` relationships.
- Security-invoker current/reviewed projections with Phase 1 tenant and visibility filtering.

Phase 2 does not ship AI generation, consulting artifacts, portals, coaching, outcomes, or Pulse intelligence. Those remain later phases.

## Acceptance mapping

| Canonical Document 07 requirement | Automated evidence |
|---|---|
| Construct Evidence → Observation → Pattern → Assumption/Hypothesis → Interpretation → Insight → Decision | Direct typed fixtures and controlled relationship assertions |
| Trace substantive conclusions backward to sources | Claim citation joins to immutable fragment and Evidence Source |
| Store competing interpretations simultaneously | Two Interpretation rows over the same Pattern remain queryable |
| Reject/supersede without erasing history | Rejected AI Interpretation plus append-only Review/REJECTS edge; versioned Assumption/SUPERSEDES edge |
| Represent AI origin/review before AI ships | Registry `origin = AI`, forced `SUGGESTED` initial state, rejected-history retrieval |
| Historical versions answer time-appropriate questions | `assumptions_at` queries return versions 1 and 2 for different effective dates |

The Phase 2 suite contains 27 pgTAP assertions in `supabase/tests/database/phase2_meridian_core.test.sql`. Phase 1's 32 security assertions run in the same clean disposable database job.

## Exit evidence required

1. Phase 0, Phase 1, and Phase 2 static verifiers pass.
2. Both migrations apply from an empty disposable Supabase state.
3. Consulting schema lint passes.
4. All 59 database assertions pass together.
5. The Ministry repository remains independent and untouched.
6. The completion review records any deferred feature-specific Meridian tests without claiming later-phase functionality.

