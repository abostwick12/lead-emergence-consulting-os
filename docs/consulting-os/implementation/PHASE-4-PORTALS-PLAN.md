# Phase 4 — Portals V1 implementation plan

## Outcome

Phase 4 presents the same Consulting domain safely and usefully through role-specific Consultant and Client portals. It does not create a parallel portal database, elevate AI output, or implement Phase 5–9 workflows early.

## Entry evidence

- Phase 3 is complete, approved, and merged at `c7d2535393b8382c252af08d334b32ba54bb3d83`.
- The typed Meridian and Consulting records, visibility scopes, RLS policies, and client-safe validated-conclusion view already exist.
- Phase 4 is authorized under the standing authorization recorded on 2026-08-10.

## Architecture

### Role-safe server boundary

- Supabase SSR uses the browser-safe publishable credential only.
- Server authentication validates `getClaims()` and resolves authorization from `consultant_assignments` or `organization_memberships`.
- Mutable user metadata is never an authorization source.
- Consultant and Client layouts require their exact role; cross-portal URL guessing returns an unavailable result.
- Live reads continue through RLS and the same tenant-aware database client used by ordinary application requests.
- The application contains no service-role credential or service-role data path.

### Client projection

Client organizational conclusions come from `consulting_os.client_visible_validated_conclusions`, which exposes only human-validated, non-private conclusions already permitted by endpoint RLS. Client record lookup occurs against the role-filtered projection, so record-ID substitution cannot recover consultant-private content.

### Consultant projection

The consultant portal reads tenant-safe epistemic state and domain registry views. Every view remains bounded by the current organization, engagement, visibility, origin, and review state.

### Synthetic test adapter

A deterministic synthetic adapter exists only when `E2E_MOCK_AUTH=true` and `NODE_ENV` is not production. It provides no real client data and has its own HTTP-only test-role cookie. Production cannot enable it.

## Portal inventory

### Consultant

- Home: active-client focus, attention, roadmap, workspaces, current state, recent records.
- Clients: organization selection with explicit engagement context.
- Client workspace: Overview, Discovery, Strategy, Development, Outcomes, Signals.
- Record detail: state, rationale, visibility, citations, and history.
- Meetings, Resources, Settings: truthful bounded surfaces pending their owning phases.

### Client

- Home: current attention, roadmap, workspaces, current state, validated conclusions and decisions.
- Our Organization: validated organizational records only.
- My Development, Meetings, Progress, Settings: mobile-accessible, truthful bounded surfaces pending their owning phases.
- Record detail: only role-visible validated conclusions and decisions.

## UX invariants

1. The current organization and engagement remain visible in every authenticated portal view.
2. The seven-stage roadmap is a single contextual journey, not seven top-level applications.
3. AI Suggestion, Interpretation, Validated Insight, and Decision have distinct labels, colors, borders, and explanatory copy.
4. Current effective state is the default; historical state remains inspectable.
5. Empty and deferred states say what is and is not operational. No fake button or live-integration claim is permitted.
6. Client mobile navigation reaches meetings, development/coaching context, organizational work, and progress.
7. Keyboard focus, semantic headings/navigation, readable contrast, and reduced-motion preferences are preserved.

## Acceptance mapping

| Document 07 Phase 4 requirement | Automated evidence |
|---|---|
| Consultant always knows current organization/engagement | Browser assertion on persistent context header. |
| Client Home clearly shows what needs attention | Client attention browser assertion and synthetic attention fixtures. |
| Roadmap visible without becoming seven apps | Canonical-order browser assertion and single roadmap component. |
| Four knowledge states visually distinct | Unit and browser assertions over distinct state classes and explanatory legend. |
| Client cannot see raw consultant-private analysis | Projection unit test, direct-record URL attack, and role-crossing attack. |
| Current state defaults and history is accessible | Browser disclosure assertion. |
| Client mobile supports assessments, meetings, commitments, coaching | Responsive browser path checks and truthful attention/deferred surfaces; persistence remains with its owning later phases. |

## Validation gates

- `npm ci`
- `npm run verify:phase4:static`
- `npm run typecheck`
- `npm run lint`
- `npm run test:unit`
- `npm run build`
- `npm run test:e2e`
- existing Phase 0–3 static and database gates in private-repository CI
- Ministry source and distribution boundary unchanged

## Deliberate exclusions

- No deployment, Vercel project, DNS, hosted Supabase, secrets, or production data.
- No meeting or coaching persistence before Phase 5.
- No alignment/capability persistence before Phase 6.
- No outcomes/New Reality persistence before Phase 7.
- No AI generation before Phase 8.
- No longitudinal signal classification before Phase 9.
