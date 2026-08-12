# V1 Access and Ministry Handoff Decisions

## Approved decision 1 — two invitation models

Named client users receive an expiring Supabase email invitation or magic link tied to a pending `client_invitations` record for one organization, one engagement, and one client role. Membership is not activated until the authenticated email and Auth user match the pending invitation. Invitations remain revocable and auditable.

Assessment participants use a separate high-entropy, single-use, expiring link. This link grants no portal account or general engagement access. Anonymous links retain no person, name, or email reference. Confidential identity metadata is stored in the private partition and response records do not expose that identity. Assessment responses remain evidence, not diagnosis, and anonymous reporting still requires the administration's minimum cohort.

## Approved decision 2 — consultant-guided Ministry OS handoff

V1 uses a structured `Ministry OS Setup Handoff` containing the authorized administrator, ministry areas and leaders, first priorities, meeting/planning rhythm, first events/workflows, readiness, handoff status, and a completion checklist.

Consulting OS does not write to the Ministry product database and the Ministry repository does not depend on the Consulting repository. The consultant guides the authorized church administrator through setup in the independently distributed Ministry product. Cross-product provisioning remains deferred to a future ADR covering consent, identity mapping, idempotency, rollback, audit, and a product-neutral API boundary.
