# Consulting-only onboarding and 3-2-1 delivery

## Delivered on `feature/unified-onboarding-321-review`

- A product-internal Consulting context chooser, separate from the future global
  product chooser. It supports deliberate Consultant or Client surface selection
  and validates organization/engagement context before host-only cookies change.
- A public Consulting intake route at `/intake/consulting` with six structured,
  mobile-first questions, post-intake contact capture, separate newsletter
  consent, and completion-only visitor messaging.
- Additive prospect tables for immutable raw responses, AI/consultant revisions,
  response provenance, approvals, delivery state, follow-ups, timeline events,
  controlled conversion records, and future canonical identity links.
- A consultant Prospect queue/review workspace with editable 3-2-1 revisions,
  approval, delivery-preview state, follow-up scheduling, consultant-private
  fixture/UI behavior, conversion authorization, and relationship timeline.
- Explicit controls that keep AI drafts non-authoritative, require approval
  before delivery state, and preserve prospect responses as reported input.

## Verification

- `npm run lint` passed.
- `npm run typecheck` passed.
- `npm run test:unit` passed: 39 files, 153 tests.
- Focused Playwright coverage passed: public intake completion-only behavior,
  approval-before-delivery behavior, and product-internal Consulting context.
- `git diff --check` passed.

## Database verification blocker

The local Supabase lint and pgTAP suites could not run because Docker Desktop's
Linux engine was not available on this machine. `supabase start` failed before a
local database could be created; `supabase db lint` and `supabase test db` then
could not reach `127.0.0.1:54322`. The added pgTAP file must be executed in CI
or after Docker is started.

## Explicitly deferred to Entry / identity work

- Canonical Lead Emergence Auth and global product entitlements.
- Personal and Ministry access, data, authorization, trials, or navigation.
- Global product chooser and cross-subdomain sessions.
- Root-domain/DNS/Vercel/OAuth callback changes.
- Email transport/provider integration and automatic 3-2-1 delivery.
- Global analytics.