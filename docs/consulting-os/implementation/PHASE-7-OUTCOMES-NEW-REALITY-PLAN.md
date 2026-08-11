# Phase 7 — Outcomes and New Reality plan

Date: 2026-08-10

## Outcome

Implement the complete manual value and New Reality loop from prospective Value Hypothesis through Goal, Indicator, Measurement, Outcome, Harvest & Soil evaluation, human-reviewed Learning and Outcome Decision, then preserve what actually emerged in an Emergent Organization Profile and immutable Baseline Snapshot without overwriting Intended Future State.

## Canonical acceptance map

| Requirement | Planned proof |
|---|---|
| Value criteria/hypotheses exist before evaluation | Versioned Value Hypothesis with explicit change, capability, expected value, rationale, dimensions, and pre-outcome effective date; deferred evaluation constraint. |
| Goal and Indicator preserve baseline, target, owner, and measurement history | Versioned Goal and Indicator plus append-only Measurement; typed owner/source and same-tenant constraints. |
| Outcome relates to Intervention without automatic causation | `EVALUATES`/`ASSOCIATED_WITH` by default; `CONTRIBUTED_TO` only after human review; no automatic `CAUSES`. |
| Harvest and Soil are both evaluated | Value Evaluation stores all five value dimensions plus separate harvest and soil findings, health, limitations, and evidence. |
| Learning results in Sustain / Improve / Scale / Stop / Reinvent | Human-reviewed Learning linked to Evaluation and first-class Outcome Decision with controlled disposition. |
| Future State is not overwritten by Emergent Reality | Separate versioned Emergent Organization Profile and Emergent Reality Difference records with typed Future State/Profile endpoints. |
| Emergent profile becomes next baseline | Immutable Baseline Snapshot and manifest, explicit `BECOMES_BASELINE_FOR`, and next-cycle context without modifying prior Future State. |

## Implementation slice

- Add typed Phase 7 tables in `consulting_os` with `organization_id`-first indexes, composite tenant keys, RLS, explicit grants, and security-invoker current-state views.
- Preserve prospective, observed, interpreted, and authorized classes as separate records.
- Keep Measurements and Outcomes append-oriented; meaning-changing Goal, Value Hypothesis, and Emergent Profile edits create versions.
- Create Consultant Outcomes and New Reality workspaces plus curated Client Progress view within the existing Consulting OS shell and visual language.
- Support a non-production fixture workflow that records Measurement, Outcome, Evaluation, Learning disposition, Profile, Difference, and Baseline with reload persistence.
- Add adversarial database tests for tenant crossing, visibility broadening, causality, temporal ordering, immutability, human review, Future State preservation, and baseline manifests.
- Add browser coverage for the complete manual value/New Reality loop on desktop and client-safe progress/baseline presentation on mobile.

## Boundary

- Phase 8 AI is not implemented.
- Phase 9 descriptive Signals and SEE AGAIN observation entry are not implemented.
- Mature Pulse, Drift/Emergence diagnosis, predictive analytics, cross-client comparison, and autonomous causal inference remain deferred.
- No production database, Vercel project, DNS, secrets, Ministry repository, or unapproved landing-page branch is changed.

## Human checkpoint

Phase 7 completion is a mandatory human checkpoint. After all evidence gates pass, publish a concise review covering the complete manual consulting loop, portals, meetings/coaching, alignment, capability, outcomes, Harvest & Soil, New Reality, Emergent Organization Profile, baseline creation, and end-to-end reasoning traceability. Stop before Phase 8 until that checkpoint is reviewed.
