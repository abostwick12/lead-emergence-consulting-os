# ADR-0005: Canonical Lead Emergence Identity and Neutral Entry Boundary

- **Status:** Accepted conceptually; implementation owned outside Consulting
- **Date:** 2026-08-19
- **Depends on:** ADR-0001, ADR-0002, ADR-0004

## Decision

Lead Emergence will use a future neutral Entry and Identity layer for one login,
minimal product entitlement resolution, and product handoff. The Entry layer
knows identity, active product entitlement, and destination only. It does not
resolve Consulting roles, organizations, engagements, visibility, private
notes, Ministry permissions, or Personal permissions.

Consulting remains a separately deployable product. Its local authorization is
derived from `people`, consultant assignments, organization memberships,
engagement memberships, visibility grants, and RLS. A global `CONSULTING`
entitlement will never imply Consultant, Client, organization, engagement, or
record access.

## Consulting preparation in this repository

The Consulting-only migration adds `canonical_identity_links` as a future
mapping between a local Consulting person and a canonical user ID. It does not
rewrite `people.auth_user_id`, grant membership, create a shared session, or
implement a global identity provider. Linking requires an approved future
verification and handoff protocol.

The Consulting product has a separate internal context chooser. It distinguishes
Consultant and Client surfaces before selecting an organization and engagement.
This is deliberately separate from the future global Personal / Ministry /
Consulting chooser.

## Consequences

- The current public landing within Consulting remains transitional.
- No Personal or Ministry authorization/data is added to this repository.
- Product sessions remain host-local.
- Existing Consulting RLS and private-schema boundaries remain authoritative.