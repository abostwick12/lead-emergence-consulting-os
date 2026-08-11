# Phase 8 completion review — Grounded AI

**Result: PASS**  
**Evidence gate:** 2026-08-11  
**Functional source head:** `0e537b850669fd31ddf1abb68b095374dd0200bb`  
**Exact-head CI:** run `31464998310` — success

## Outcome

Phase 8 adds contextual, grounded Meridian assistance inside the Consultant Discovery and Strategy workspaces. It does not add a generic chatbot, provider credential, hosted model call, production migration, or autonomous consulting authority. The deterministic provider-neutral adapter proves the V1 execution boundary over fixed evidence while the database preserves the same contract for a future hosted adapter.

## Canonical acceptance evidence

| Document 07 requirement | Result | Evidence |
|---|---|---|
| Substantive AI suggestion records AI origin, source set, review state | PASS | AI Pattern is a typed domain object with `origin=AI`, begins `SUGGESTED`, and links through `ai_generation_runs`, `ai_run_sources`, `ai_outputs`, `ai_output_citations`, and `claim_citations`. |
| AI cannot validate Insight/Diagnosis or make a Decision | PASS | Database authority trigger and task validator reject authoritative AI actions; pgTAP tests both Insight and Decision attempts. |
| Authorization filtering occurs before ranking | PASS | Every requested source is tenant/visibility checked before a `rank_after_authorization` is assigned; cross-tenant and private-coaching substitution attacks fail. |
| Citations point to actual source objects | PASS | Composite foreign keys bind each source to the Evidence domain object and immutable Evidence Fragment; the tested Pattern has three exact citations. |
| Pattern shows supporting and contrary evidence | PASS | Completed Pattern contract requires two supporting and one challenging source; both groups and exact locators are inspectable in the UI. |
| Rejected suggestions never later appear as truth | PASS | Human rejection creates durable `record_reviews`, preserves the AI Pattern, removes it from active fixture retrieval, and excludes it from `ai_truth_eligible_records`. Browser reload proves the rejected item stays non-operative. |
| Insufficient evidence is stated | PASS | Under-threshold requests record `INSUFFICIENT_EVIDENCE` and an explicit limitation without creating a suggestion. |

## Security and privacy evidence

- Cross-tenant Evidence cannot enter an AI run.
- Consultant-private, individual-private, coaching-shared, team-shared, and platform-restricted records cannot enter V1 AI retrieval.
- Output visibility inherits the most restrictive eligible source visibility.
- AI cannot assert `CAUSES` or `CONTRIBUTED_TO`.
- AI persistence tables have RLS and no direct authenticated write grants.
- Client contexts do not expose the consultant AI review queue.
- Meeting preparation states its exact shared source set and confirms private coaching notes were not searched or summarized.

## Verification record

| Check | Result |
|---|---|
| Phase 8 static verifier | PASS — permission-first retrieval, provenance, review, refusal, privacy, and portal contracts. |
| `npm run typecheck` | PASS. |
| `npm run lint` | PASS. |
| `npm run test:unit` | PASS — 7 files, 29 tests. |
| `npm run build` | PASS — Next.js production build, including `/api/meridian-ai`. |
| `npm run test:e2e` | PASS — 22 browser tests, including Phase 8 desktop/narrow review, rejection persistence, insufficiency, and client non-exposure. |
| Migration apply | PASS in isolated Supabase CI. |
| Schema lint | PASS for `consulting_os`, `consulting_security`, and `consulting_private`. |
| Phase 8 pgTAP | PASS — 22 assertions. |
| Cumulative pgTAP | PASS — 7 files, 230 assertions. |

Fresh visual evidence is retained in the CI artifact and local test results as `phase8-grounded-ai-desktop.png` and `phase8-grounded-ai-mobile.png`. The new surface uses the existing Consulting OS shell, typography, spacing, panels, cyan/gold knowledge-state language, and responsive navigation.

## Boundaries retained

- No production Supabase target, storage bucket, Vercel project, DNS, environment variable, or deployment was changed.
- No live AI provider or credential was introduced.
- Phase 9 descriptive Signals and mature drift/emergence intelligence are not claimed.
- The separate landing-artwork branch remains isolated and unmerged pending human visual acceptance.

Phase 8 therefore passes its evidence gate under the owner's standing phase authorization. Phase 9 Descriptive Signals is the next executable phase.
