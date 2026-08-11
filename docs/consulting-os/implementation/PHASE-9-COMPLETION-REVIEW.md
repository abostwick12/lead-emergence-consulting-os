# Phase 9 completion review — Signals / SEE AGAIN

**Result: PASS**
**Evidence gate:** 2026-08-11
**Functional source head:** `c47b7fe8eb67cc3bb6a16d2f4fd214e7bb75602b`
**Exact-head CI:** run `31469825087` — success

## Outcome

Phase 9 closes the V1 reinvention spiral with a governed Signals workspace in both Consultant and Client contexts. It uses the approved New Reality baseline to notice change, compare compatible measurements, revisit time-bound assumptions, preserve emerging questions, and explicitly renew inquiry. It does not add mature Pulse intelligence, autonomous drift detection, predictive modeling, or causal diagnosis.

## Canonical acceptance evidence

| Document 07 requirement | Result | Evidence |
|---|---|---|
| Signal describes observed change without autonomous diagnosis | PASS | `signals` is a typed Evidence-backed object; database and application validators reject diagnostic/causal language; the interface repeatedly states Signal ≠ Pattern. |
| Trend comparisons use compatible data and correct versions | PASS | `descriptive_trends` requires matching indicator logical identity, definition, direction, unit, tenant, engagement, visibility, and chronological order. Incompatible indicator substitution fails in pgTAP. |
| Private coaching content is excluded unless explicitly promoted | PASS | Signal/trend sources reject consultant-private, individual-private, coaching-shared, team-shared, and platform-restricted scopes before composition; browser and database proofs confirm non-exposure. |
| Assumptions due for review can be surfaced | PASS | `assumption_review_schedules` and `current_assumptions_due` retain the effective Assumption, trigger, due state, and controlled human completion. |
| Signal can become a new Observation/re-entry item | PASS | `reenter_signal_as_observation` creates an evidence-backed Observation, preserves the original Signal, records audit evidence, and creates a typed accepted human `REENTERS_AS` relationship. |
| V1 never markets Signals as validated drift detection | PASS | Product copy, static verifier, unit tests, browser tests, and database checks state and enforce the descriptive-only boundary. |

## Complete engagement acceptance

`tests/e2e/z-complete-engagement.spec.ts` starts from a clean fixture and moves one organization and engagement through grounded discovery, competing meaning, validated Insight, authorized design, capability formation, a privacy-partitioned coaching context, prospective value, observed Outcome without causality, Harvest & Soil, human-reviewed Learning, distinct New Reality, immutable Baseline, descriptive Signal, and explicit Signal-to-Observation re-entry. It then switches to the Client portal and verifies that only the shared projection is available.

Phase 3's retained database acceptance adds the same V1 engagement prerequisites—Organizational Portrait, versioned Assessment Instrument and administration, interviews, Evidence fragments, Reality Map, Identity/DNA, Future-State Narrative, and Blueprint. The cumulative database suite keeps those contracts green alongside the end-to-end browser path.

No major acceptance step requires an off-platform document to complete the synthetic engagement.

## Security, privacy, and epistemic evidence

- Same-tenant foreign keys and controlled functions prevent cross-organization Signal sources and re-entry edges.
- Phase 9 tables have RLS; authenticated users cannot bypass controlled Signal creation.
- Private coaching content is excluded before longitudinal composition, not merely hidden in the interface.
- AI-originated Signals and Emerging Questions must remain `SUGGESTED` pending human review.
- Client Progress shows only deliberately shared longitudinal material and exposes no creation, review, or re-entry controls.
- Baseline remains immutable, Signal remains weaker than Pattern, Trend remains descriptive, and re-entry does not validate a conclusion.
- The current Signal Set is a derived permission-aware view, never a separate source of truth.

## Ministry-only distribution evidence

The release-blocking product-separation check uses a detached clean worktree of public Ministry `main` at `dd28c74ee484484f028465de25ede0b4655374cf`; the owner's unrelated dirty Ministry working tree remains untouched.

- A fresh Ministry archive contains 1,478 tracked entries and zero Consulting-owned paths.
- Archive SHA-256: `CBDB23A3C65FD9B65CF0609C4FC72C30BDB070D1D34CC63CE772F2174EA4B6F5`.
- Git tree manifest SHA-256: `EC5F2100E2F2D911E8CF49FAF9FF7BF32F8F3D4351B9060002131C7FD0D76DC5`.
- Ministry source, package manifests, migrations, CI configuration, and compiled `.next` output contain no private repository name, Consulting schema, Signals route/module, `REENTERS_AS`, or canonical Signals copy.
- Ministry dependency installation, design check, typecheck, lint, and 183-page production build pass independently with no access to this private repository.
- The optional Ministry unit suite passes 1,411 tests; its one unchanged Logos companion-script import error predates and is unrelated to Consulting OS.
- The previously slow desktop sidebar navigation case passes unchanged with a 180-second per-test budget, proving route behavior and identifying cold compilation—not Consulting coupling—as the default-timeout cause.
- A bounded four-worker run reached 122 passes and 1 skip; six unrelated cases failed under contention and three were not run. All six observed failures then passed unchanged in one serial rerun.

The exact Ministry results and limitations are recorded in `MINISTRY-ONLY-DISTRIBUTION.md`. No Ministry source or test file is modified to obtain this evidence.

## Verification record

| Check | Result |
|---|---|
| Phase 9 static verifier | PASS — descriptive Signals, compatible trends, privacy, assumption review, baseline, and re-entry contracts. |
| `npm run typecheck` | PASS. |
| `npm run lint` | PASS. |
| `npm run test:unit` | PASS — 8 files, 33 tests. |
| `npm run build` | PASS — Next.js production build, including `/api/signals`. |
| `npm run test:e2e -- --workers=1` | PASS — 26 browser tests, including Phase 9 desktop/mobile, client sharing, and complete engagement acceptance. |
| Migration apply | PASS in isolated Supabase CI. |
| Schema lint | PASS for `consulting_os`, `consulting_security`, and `consulting_private`. |
| Phase 9 pgTAP | PASS — 22 assertions. |
| Cumulative pgTAP | PASS — 8 files, 252 assertions. |

Fresh visual evidence is retained in the CI artifact and local test results as `phase9-signals-desktop.png`, `phase9-signals-mobile.png`, and `complete-engagement-client-checkpoint.png`. Direct inspection confirmed that the Signals workspace uses the existing Consulting OS shell, typography, spacing, cyan/gold meaning states, panel surfaces, and responsive navigation.

## Boundaries retained

- No hosted Supabase target, production migration, client data, storage bucket, Vercel project, environment variable, DNS record, provider credential, or deployment was changed.
- No live AI provider or autonomous authority was introduced.
- Mature Pulse, Drift Candidate, Emergence Candidate, prediction, and causal inference remain deferred.
- The separate landing-artwork branch remains isolated and unmerged pending human visual acceptance.
- Final Consulting license terms and historical Phase 0 materials remain owner/legal review items; no retroactive legal claim is made.

Phase 9 therefore passes its evidence gate under the owner's standing phase authorization. Final completion of the broader Goal remains pending human visual validation and merge of the corrected unified-entry PR #10; production environment selection, live migration, deployment, and pilot data remain separate human decisions.
