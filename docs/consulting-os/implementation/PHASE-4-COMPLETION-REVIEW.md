# Phase 4 — Portals V1 completion review

Date: 2026-08-10

## Decision summary

Phase 4 implements the Consultant and Client portal shells and the safe read projections required by Canonical Document 07. Both roles see one organizational reasoning system through different visibility boundaries. No production or hosted environment was changed.

## Delivered

- Next.js 16 App Router application with separate Consultant and Client route trees.
- Supabase SSR session refresh and server-side claims validation.
- Consulting-owned membership/assignment authorization; no user-metadata roles.
- Persistent organization and engagement context.
- Canonical seven-stage roadmap rail.
- Consultant portfolio and six-part client workspace.
- Client attention view and role-appropriate navigation.
- Distinct AI Suggestion, Interpretation, Validated Insight, and Decision states.
- Current-effective narrative with accessible historical state.
- Evidence/provenance and audit-history record detail.
- Client-safe validated-conclusion read model.
- Synthetic non-production fixture adapter and role-safe browser harness.
- Responsive mobile client navigation and reduced-motion/focus support.
- Truthful bounded states for later-phase functionality.

## Acceptance evidence

| Requirement | Result | Evidence |
|---|---|---|
| Current organization and engagement are always known | PASS | Persistent header plus browser assertions on Consultant routes. |
| Client Home clearly shows attention | PASS | Review, commitment, meeting, and assessment attention cards with due-state labels. |
| Roadmap is visible without seven separate apps | PASS | One canonical-order roadmap component and seven-stage browser assertion. |
| Knowledge states are visually distinct | PASS | State-specific labels/styles, explanatory legend, unit test, browser test. |
| Client cannot see raw consultant-private analysis | PASS | Client-safe database view, filtered DTO, unit record-substitution test, browser URL attack and cross-role attack. |
| Current effective state defaults; history remains accessible | PASS | Current-state panel and browser-tested historical disclosure. |
| Client mobile reaches V1 interaction areas | PASS | Mobile browser path through Meetings and My Development; organization, progress, commitment, assessment, and coaching boundaries remain visible and truthful. |

## Security consequences

- The browser receives only a Supabase publishable key.
- The app has no service-role access path.
- Fixture mode is rejected in production.
- Live Client reads use `client_visible_validated_conclusions` and remain subject to RLS.
- Direct URL guessing and record-ID substitution do not broaden a Client projection.
- Consultant-private and individual-private material is not promoted into general organizational knowledge.

## Validation results

| Gate | Result |
|---|---|
| Dependency audit | PASS — 0 vulnerabilities. |
| Phase 4 static verifier | PASS — 11 required surfaces plus auth, read-model, roadmap, state, privacy, and mobile contracts. |
| TypeScript | PASS. |
| ESLint | PASS. |
| Unit tests | PASS — 14/14, including client-private filtering and unsafe return-path rejection. |
| Next.js production build | PASS — 13 application routes plus Proxy. |
| Playwright | PASS — 10/10 across desktop and Pixel 7 projects. |
| Visual review | PASS — fresh Consultant desktop and Client mobile captures inspected for layout and readability. |
| Retained database regression | PASS — schema lint and all 104 cumulative pgTAP assertions. |
| Private-repository CI | PASS — run `31429268095` on portal source head `4825137f06579cd4f4bea3bf54116712d7d3eaf0`. |

## Phase boundary audit

The following are intentionally not credited:

- Meetings and Coaching show truthful preparation/deferred states but do not claim Phase 5 persistence.
- Development shows role-safe context but does not claim Phase 6 domain workflows.
- Progress shows current approved records but does not claim Phase 7 outcomes/New Reality workflows.
- Meridian is not generating AI output in Phase 4.
- Signals does not diagnose drift or emergence.

## Product separation

All Phase 4 source, configuration, tests, fixtures, and documentation exist only in the private Consulting repository. The Ministry repository was not edited, imported, or used as a runtime dependency. No Consulting code was placed under the Ministry repository's MIT license.

## Remaining risks

- A real hosted Supabase/Vercel environment has not been selected or configured; local production build and disposable database gates are the evidence boundary.
- The live portal will remain empty until authorized identities, organizations, engagements, and domain records exist in a separately approved environment.
- Final Consulting licensing terms and historical Phase 0 material remain owner/legal-review matters.

## Checkpoint

Phase 4 has no mandatory human checkpoint in Canonical Document 07. The exact portal source head passed private-repository CI in run `31429268095`; the phase may merge under the standing authorization. Phase 5 may begin from the merged result. Deployment remains separately unauthorized.
