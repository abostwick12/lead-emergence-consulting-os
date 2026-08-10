# ADR-0004: Product authorization, coaching privacy, secure retrieval, and entry routing

- **Status:** Accepted — approved 2026-08-10
- **Date:** 2026-08-09; checkpoint direction incorporated 2026-08-10
- **Depends on:** ADR-0001 and ADR-0002

## Context

The public experience needs Consultant, Consulting Client, and Ministry entry paths. Shared authentication must not imply shared authorization. Document 05 makes coaching/private leakage and AI retrieval leakage release-blocking.

## Decision

### Entry and product context

- `www.leademergence.com` is the parent-brand entry app. It presents two product environments—Lead Emergence Consulting and Lead Emergence Ministry—and contains no product business logic.
- Consulting presents two entry intents: Consultant Login and Consulting Client Login. Both route to `consulting.leademergence.com`, where independently resolved Consulting authorization selects the Consultant or Client shell.
- Ministry Login routes to `ministry.leademergence.com`, which contains the existing Ministry login and product.
- Callback state includes a signed/validated product intent and safe relative destination. Product intent never grants access.
- Each product independently validates the session and current product membership on every protected request.
- Shared identity infrastructure does not require shared browser-session cookies. V1 defaults to product-local callback/session handling on each subdomain unless a separately reviewed security design proves cross-subdomain session sharing necessary and safe.
- The root entry app does not inspect private memberships or expose product availability before authentication. A later product switcher may query narrow entitlement endpoints only for an already authenticated identity.

### Auth identity mapping

- Supabase Auth `sub` identifies the signed-in identity.
- Consulting `people.auth_user_id` maps identity to the product profile.
- Authorization is database-backed and current. Mutable `user_metadata` is display data only and is never an authorization source.
- Product roles are not a single global role string. A user can be Consultant in one product context and hold unrelated Ministry access without either role implying the other.
- Revocation checks current membership/assignment. Sensitive paths may additionally validate current session state rather than relying on stale JWT claims.

### Coaching/private partition

- Shared Coaching Relationship, Session, participants, agenda, commitments, and permitted shared notes live in `consulting_os` with `COACHING_SHARED` visibility.
- Coach-private notes and participant-private reflections are stored in separate `consulting_private` tables with no ordinary table grants.
- Access occurs only through narrowly scoped functions or server repositories that verify the named participant/coach and purpose.
- A systemic derivative is a new object created by explicit abstraction/redaction, source permission check, chosen visibility, human review, and provenance. Private source text never silently changes scope.

### Retrieval and AI

The enforced sequence is:

`request identity -> product authorization -> organization/action/visibility filter -> authorized source IDs -> ranking/retrieval -> generation -> citations -> review`.

- Embeddings and indexes carry organization, source, visibility, sensitivity, epistemic class, effective time, and current/review state.
- SQL/RPC authorization produces the eligible source set before similarity ranking.
- Counts, snippets, titles, citations, and errors do not reveal inaccessible source existence.
- Generated output inherits the most restrictive source sensitivity until explicit authorized promotion.
- Every substantive AI output records exact source set, origin `AI`, task class, generated time, review state `SUGGESTED`, and citations.
- AI cannot validate Insight/Diagnosis, make Decision, establish accepted causality, or use private coaching as organizational telemetry.

### Files and exports

- File metadata and derived artifacts inherit source tenant/visibility.
- Exports execute under the requester authorization context and enumerate exactly the visible rows.
- Meeting preparation computes the intersection of requester permissions, meeting context, and record visibility before retrieval.

## Consequences

- One authentication provider can serve the ecosystem without creating one authorization domain.
- Private coaching is physically and logically harder to leak.
- Retrieval may require more database work before semantic ranking, but security is enforceable and auditable.
- Public entry remains replaceable and independently deployable.
- Ministry origin-sensitive endpoints must migrate safely to `ministry.leademergence.com` before `www` is reassigned; the target-domain decision is not a DNS-change authorization.

## Rejected alternatives

- Global `role` claim as product authorization.
- Consulting access inherited from Ministry login or profile.
- Private and shared coaching notes in one row with UI-only hiding.
- Retrieve broadly and filter citations/results afterward.
- Generic AI chat as the primary product workflow.

## Required tests

- A valid Ministry account without Consulting membership cannot enter Consulting routes or APIs.
- A consultant assigned to Org A cannot infer Org B through search, counts, citations, files, exports, or AI.
- Client admin cannot read consultant-private or coaching-private content.
- Coach/participant can read shared session; unrelated users cannot.
- Private-to-shared derivative requires explicit promotion and audit.
- Revoked membership or consultant assignment fails on the next authorized operation.
