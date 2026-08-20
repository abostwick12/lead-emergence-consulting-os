# Consulting-only unified onboarding and 3-2-1 checklist

**Boundary:** This checklist implements only the Consulting-owned slice on
`feature/unified-onboarding-321-review`. It does not create the future Entry
application, global identity authority, Personal or Ministry access, shared
sessions, production infrastructure, an email vendor, or a global analytics
service.

## Phase A — Consulting context model

| Requirement | Files | Security/test evidence |
| --- | --- | --- |
| Preserve consultant and client contexts for one person | `lib/portal/types.ts`, `lib/portal/context.ts`, `lib/portal/fixtures.ts` | Unit coverage for dual-context resolution; portal guards still enforce the selected context. |
| Select a Consulting context separately from product entry | `app/consulting-context/page.tsx`, `components/portal/consulting-context-chooser.tsx`, `app/api/portal-context/route.ts` | Server validates every selected organization and engagement before setting host-only context cookies. |

## Phase B — prospect schema and RLS

| Requirement | Files | Security/test evidence |
| --- | --- | --- |
| Prospect, immutable intake, 3-2-1 revision, approval, delivery, follow-up, timeline, conversion, and identity-link data | `supabase/migrations/20260819110000_consulting_prospect_321.sql` | Additive constrained tables, immutable triggers, and pgTAP hostile tests. |
| Consultant-private notes | Same migration, `consulting_private.prospect_notes` | No direct authenticated schema grant; consultant-only scoped functions/policies. |
| Canonical identity preparation only | Same migration | `consulting_os.canonical_identity_links` maps a Consulting person to a future canonical identity without rewriting `people.auth_user_id`. |

## Phase C — public Consulting intake

| Requirement | Files | Security/test evidence |
| --- | --- | --- |
| Mobile-first, one-question flow and completion-only visitor state | `app/intake/consulting/page.tsx`, `components/prospects/public-intake.tsx`, `components/prospects/prospects.css` | Browser test verifies no 3-2-1 is disclosed. |
| Public anonymous submission | `app/api/prospects/intake/route.ts`, `lib/prospects/workflow.ts`, `lib/prospects/repository.ts` | Validated payloads, opaque idempotency key, no public read endpoint. |

## Phase D — consultant review

| Requirement | Files | Security/test evidence |
| --- | --- | --- |
| Queue, review, editable draft, source-response provenance, approval, history | `app/consultant/prospects/**`, `components/prospects/prospect-center.tsx`, `app/api/prospects/route.ts`, `lib/prospects/**` | Approval is an explicit mutation; unapproved delivery is rejected. |
| AI is a suggestion, not truth | `lib/prospects/types.ts`, `lib/prospects/fixtures.ts`, migration constraints | Draft origin/status and response links are retained; no AI output is represented as validated evidence. |

## Phase E — follow-up and delivery state

| Requirement | Files | Security/test evidence |
| --- | --- | --- |
| Follow-up owner, status, due date, notes, timeline | `lib/prospects/**`, `components/prospects/prospect-center.tsx` | Fixture/browser mutation coverage and database constraints. |
| Delivery preview/status without an email provider | Same files | Only an approved revision can be marked ready/sent; actual transport remains an explicit blocker. |

## Phase F — controlled conversion

| Requirement | Files | Security/test evidence |
| --- | --- | --- |
| Consultant-controlled prospect to Consulting organization/engagement interface | `app/api/prospects/route.ts`, `lib/prospects/workflow.ts`, migration | Conversion records target references and never creates memberships or promotes AI text to validated facts. |

## Phase G — identity-link preparation

| Requirement | Files | Security/test evidence |
| --- | --- | --- |
| Local interface for later Entry canonical identity handoff | migration, `lib/prospects/types.ts`, `docs/consulting-os/adrs/ADR-0005-canonical-identity-entry.md` | Mapping is local, auditable, unique, and cannot grant Consulting membership. |

## Phase H — verification and documentation

| Requirement | Files | Security/test evidence |
| --- | --- | --- |
| Unit, browser, and hostile database assertions | `lib/prospects/*.test.ts`, `tests/e2e/prospects.spec.ts`, `supabase/tests/database/prospect_321_security.test.sql` | Tests cover public non-readability, consultant-private notes, approval-before-delivery, and cross-tenant denial. |
| Architecture references | `docs/consulting-os/adrs/ADR-0005-canonical-identity-entry.md`, this checklist | Records the future Entry contract without implementing it here. |

## Explicit deferred work

- Global product chooser and canonical Lead Emergence Auth.
- Personal and Ministry product access, trials, data, or authorization.
- Cross-subdomain sessions, production DNS/Vercel/Auth callback changes.
- An email transport vendor or automatic delivery of a 3-2-1.
- Global analytics service.