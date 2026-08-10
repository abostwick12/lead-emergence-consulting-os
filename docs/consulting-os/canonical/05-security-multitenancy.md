LEAD EMERGENCE

# 05 — Security &
Multi-Tenancy Specification

Canonical Architecture Specification

Version 1.0 • August 2026

Purpose

Define the tenant boundaries, authorization layers, confidentiality rules, database enforcement, AI retrieval constraints, and adversarial tests required before Lead Emergence stores real client data.

# 1. Security Posture

Lead Emergence will hold strategy, interviews, assessments, consulting analysis, coaching records, decisions, and institutional memory. Security is therefore part of the product architecture, not a UI feature.

Canonical rule: Organization is the hard tenant boundary. Application code may narrow access further, but it may never be the only mechanism preventing cross-organization access.

| Dependency | Security relevance |
| --- | --- |
| 03 — Domain Model | Defines tenant-owned entities, memberships, visibility-bearing records, and same-tenant relationships. |
| 04 — Meridian Epistemology | Requires permission-aware derivation, retrieval, citations, coaching privacy, and AI source filtering. |
| 05 — This document | Defines access boundaries and enforcement requirements. |

# 2. Security Objectives

- Prevent cross-client read, write, update, delete, search, export, embedding, and inference leakage.

- Separate platform authorization from organizational role design.

- Allow consultants to work across explicitly assigned clients without global ordinary-user access.

- Protect consultant-private, individual-private, and coaching-confidential information.

- Apply the same boundaries to AI, search, exports, background jobs, APIs, files, and derived indexes.

- Fail closed when authorization context is missing, stale, ambiguous, or inconsistent.

- Make access revocation effective promptly and keep sensitive changes auditable.

# 3. Threat Model

| Threat | Example | Required defense |
| --- | --- | --- |
| Cross-tenant read | Org A guesses Org B UUID. | Database RLS rejects. |
| Cross-tenant write | Org A links to Org B record. | RLS plus same-tenant validation. |
| Horizontal escalation | Member reads executive/coaching record. | Visibility policy rejects. |
| Vertical escalation | Client admin invokes platform-admin action. | Separate platform authorization. |
| Consultant overreach | Consultant opens unassigned client. | Explicit assignment required. |
| Service-role bypass | Privileged backend forgets tenant filter. | Minimize, assert tenant, audit, test. |
| AI leakage | Meeting brief uses private coaching note. | Filter before retrieval/generation. |
| Search leakage | Semantic search exposes hidden snippet. | Secure filtering before ranking. |
| Export leakage | Export includes hidden rows. | Same authorization context. |
| Inference leakage | AI paraphrases confidential source. | Derived data inherits sensitivity. |
| Stale access | Former member retains access. | Current membership checks. |
| IDOR | Modified URL/API id reveals record. | RLS/object authorization. |

# 4. Tenancy Model

## 4.1 Organization

Every client-owned V1 record should carry organization_id directly unless a stronger database-enforceable parent relationship is intentionally documented. Direct attribution simplifies RLS, indexing, auditing, exports, and testing.

## 4.2 Engagement

Engagement is a sub-context within one Organization, not a tenant. Engagement participation may narrow access but never cross the Organization boundary.

## 4.3 Relationship invariant

relationship.organization_id = source.organization_id = target.organization_id

Cross-organization relationship creation is prohibited.

## 4.4 Consultant practice

Consultants may aggregate safe practice metadata only across organizations to which they are explicitly assigned. Client content is never pooled merely because the same consultant serves multiple clients.

# 5. Identity and Authorization Layers

| Layer | Question answered |
| --- | --- |
| Authentication Identity | Who is signed in? |
| Person | Which human profile is this? |
| Organization Membership | Is this person authorized for this tenant? |
| Engagement Membership | May this member participate in this engagement? |
| Platform Role | What product actions may this person perform? |
| Content Visibility | May this person see this specific record? |
| Organizational Role | What does this person own in the organization? Not software authorization by itself. |

# 6. Platform Roles

| Role | Initial authority |
| --- | --- |
| PLATFORM_ADMIN | Exceptional platform operations; client-content access minimized and audited. |
| CONSULTANT | Assigned organizations and engagements only. |
| CLIENT_ADMIN | Permitted organization administration; no automatic coaching/private override. |
| CLIENT_LEADER | Permitted leadership/team content and assigned development/meeting functions. |
| CLIENT_MEMBER | Own development, assessments, meetings/actions, and shared organization content. |

Keep V1 roles small. Add roles only when a real authorization distinction cannot safely be represented through membership, assignment, ownership, team, engagement, or visibility.

# 7. Visibility Scopes

| Scope | Normal audience |
| --- | --- |
| CONSULTANT_PRIVATE | Specifically authorized consultants. |
| INDIVIDUAL_PRIVATE | Individual owner and narrowly authorized system functions. |
| COACHING_SHARED | Named coach(es) and participant(s). |
| TEAM_SHARED | Authorized members/leaders of a specified team. |
| LEADERSHIP_RESTRICTED | Authorized leadership cohort and assigned consultants as appropriate. |
| ENGAGEMENT_SHARED | Authorized engagement participants. |
| ORGANIZATION_SHARED | Authorized organization members. |
| PLATFORM_RESTRICTED | Exceptional platform/security operations. |

ALLOW = tenant access ∧ action permission ∧ visibility permission ∧ record-specific constraints

Missing or invalid visibility metadata on a sensitive record fails closed.

# 8. Consultant and Client Access

- Consultant access requires explicit organization assignment or engagement participation.

- CONSULTANT_PRIVATE does not mean every consultant in the practice.

- Consultant working notes become client-visible only through explicit publication or promotion.

- Client users can access only their organization.

- CLIENT_ADMIN is not a universal confidentiality override.

- Leadership hierarchy does not automatically unlock individual-private or coaching-confidential records.

- Leadership-restricted artifacts remain restricted even inside a broadly shared engagement.

# 9. Coaching and Meeting Confidentiality

| Record | Default posture |
| --- | --- |
| Coaching relationship | Named coach/participant plus necessary administration. |
| Shared coaching session | COACHING_SHARED. |
| Coach private note | CONSULTANT_PRIVATE or coach-specific private scope. |
| Participant private reflection | INDIVIDUAL_PRIVATE. |
| Shared commitment | COACHING_SHARED until explicitly promoted. |
| Systemic insight from coaching | New derivative requiring abstraction, review, provenance, and chosen visibility. |
| Client meeting shared notes | Specified audience or ENGAGEMENT_SHARED. |
| Consultant meeting prep | CONSULTANT_PRIVATE unless published. |

Private coaching material may not automatically feed organization-level pattern detection, executive dashboards, Pulse, assessment synthesis, or unrelated AI meeting preparation.

PRIVATE SOURCE → explicit abstraction/redaction → choose visibility → validate derivative → shared object

# 10. Assessment and Interview Privacy

- Each assessment administration defines identified, confidential, or anonymous handling and permitted aggregates.

- Anonymous reporting uses conservative minimum-group thresholds to reduce re-identification risk.

- Interview consent and visibility are explicit at collection time.

- Client-facing derivatives from confidential interviews preserve promised confidentiality.

- AI may not reveal protected respondent identity or source content.

- Privacy terms must not be silently broadened after collection.

# 11. Row Level Security

For Supabase/Postgres, RLS is mandatory on every client-owned table exposed through application-accessible database paths before production client data is allowed.

- Enable RLS on all tenant-owned tables.

- Reason and test SELECT, INSERT, UPDATE, and DELETE separately.

- Verify current membership or consultant assignment rather than trusting user-supplied organization_id.

- INSERT cannot create records in unauthorized tenants.

- UPDATE cannot move records across tenants or broaden visibility without authority.

- DELETE is conservative; canonical knowledge should normally archive or supersede.

- Relationship tables validate same-tenant ownership of both endpoints.

- Storage objects receive equivalent tenant and visibility enforcement.

- Security-definer functions are exceptional, narrowly scoped, audited, and tested.

authenticated user → active tenant assignment → action allowed → visibility allowed → record-specific rule passes

# 12. Privileged Backend Operations

- The service-role credential must not become the default application data-access path.

- Prefer user-context access where possible.

- Privileged functions independently verify organization context and authorization.

- Never treat client-supplied organization_id as authorization.

- Background jobs carry scoped authorization or a precomputed authorized source set.

- Privileged sensitive access is logged.

- Service-role secrets never reach browser/client code.

# 13. AI, Meridian, Search, and Embeddings

USER CONTEXT → AUTHORIZED RECORD SET → retrieval/ranking → AI synthesis → citations

Security filtering occurs before retrieval, ranking, synthesis, and citation generation - never afterward.

- Vector indexes and semantic search preserve organization and visibility metadata.

- Embeddings inherit source sensitivity.

- Prompts receive the minimum source content needed.

- Generated outputs inherit source sensitivity until explicitly reviewed or promoted.

- Meeting-prep AI respects meeting context and requester authorization.

- Cross-client model context or benchmarking is prohibited in V1 unless future explicit consent and governance authorize it.

- AI citations cannot reveal inaccessible source existence, title, author, or content.

# 14. Files, APIs, and Exports

- Every uploaded client file is tenant-attributed; storage paths are not authorization.

- Private attachments, extracted text, previews, transcripts, and embeddings inherit source restrictions.

- Treat every record identifier as attacker-controlled.

- Never authorize by hidden navigation or route structure.

- Bulk operations authorize every affected row.

- Counts and pagination must not leak inaccessible record existence.

- Errors should not confirm existence of inaccessible records.

- Exports use the same authorization rules as interactive views.

# 15. Revocation, Audit, and Retention

- Removed or disabled membership stops granting access promptly.

- Authorization consults current membership state rather than indefinitely trusting stale client claims.

- Sensitive role or visibility changes invalidate or quickly expire cached authorization state.

- Audit membership changes, visibility changes, consultant assignments, private-to-shared promotion, privileged operations, and exports.

- Audit logs are sensitive and access-restricted.

- Store only personal data needed for consulting, product operation, security, or agreed client purposes.

- Define retention classes for engagement data, organizational memory, private coaching, audit logs, and identity references.

- Use anonymization or redaction when long-term learning does not require identity.

- Retention must align with contract, policy, and applicable law; this document is not legal advice.

# 16. New Reality and SEE AGAIN

Longitudinal intelligence increases privacy risk because records from different periods and contexts can be combined. Historical availability does not expand current authorization.

- Baseline snapshots retain tenant and visibility metadata.

- SEE AGAIN compares only records authorized for the requesting context.

- Drift or Emergence suggestions cannot use private coaching material unless explicitly permitted and promoted.

- Historical staff records do not become broadly visible merely because a person left.

- Cross-client trend comparison is out of V1 scope.

- Pulse must be security-filtered before signal generation, not merely before display.

# 17. Administrative Safety

- Platform administrators should not routinely browse client content.

- Break-glass or support access, if implemented, requires explicit purpose, limited duration, audit logging, and appropriate governance.

- Impersonation, if implemented, must be conspicuous, logged, and tightly restricted.

- Production database consoles and secrets require least-privilege operational access.

- Development and test environments should use synthetic or properly sanitized fixtures rather than casual copies of client data.

# 18. Acceptance Criteria Before Real Client Data

1. Org A user requests Org B record by known UUID: rejected or zero rows.

1. Org A user attempts INSERT with Org B organization_id: rejected.

1. Org A user attempts UPDATE to move a record into Org B: rejected.

1. Relationship creation with endpoints from different tenants: rejected.

1. Unassigned consultant queries a client: rejected.

1. CLIENT_ADMIN reads consultant-private note: rejected.

1. Leader reads individual-private reflection: rejected.

1. Manager reads private coaching note: rejected.

1. Coach can read coaching-shared session; unrelated users cannot.

1. AI retrieval for executive meeting excludes coaching-private sources before ranking.

1. Semantic search cannot reveal inaccessible title, snippet, or count.

1. Export contains exactly records visible to requester.

1. Removing membership causes subsequent access to fail.

1. Broadening visibility requires authorized action and an audit event.

1. Anonymous assessment aggregate does not expose individuals or undersized groups.

1. Privileged backend operation without explicit tenant context fails closed.

1. Storage object from another tenant cannot be downloaded by guessed path or id.

1. Historical query respects current authorization while retrieving time-appropriate versions.

1. Pulse or Signals processing excludes unauthorized private records.

1. Audit log records membership, visibility, export, promotion, and privileged operations.

# 19. Security Test Harness

- Seed at least two organizations with deliberately similar names and overlapping object types.

- Seed users in every canonical platform role.

- Seed a consultant assigned to one client but not the other.

- Seed every visibility scope, including coaching and individual-private data.

- Test direct database and API paths rather than browser behavior alone.

- Include negative tests for SELECT, INSERT, UPDATE, DELETE, relationships, search, files, exports, and AI retrieval.

- Treat any cross-tenant read or write as a release-blocking defect.

# 20. V1 Security Gate

No real client data should enter Lead Emergence until all of the following are true:

- Canonical tenant and membership schema is implemented.

- RLS is enabled and tested on every client-owned table.

- Visibility scopes are implemented for sensitive records.

- Coaching and private-note partitioning is implemented.

- AI and search authorization filtering occurs before retrieval.

- File and storage access is tenant-aware.

- Service-role usage is inventoried and minimized.

- Audit logging exists for high-risk administrative changes.

- Automated adversarial tests in Section 18 pass.

- Manual review confirms there is no known UI-only security boundary.

# 21. Required Architecture Decision Records

- Exact authentication provider and mapping between auth identity, Person, and Membership.

- RLS helper functions and whether they use security-definer behavior.

- Physical representation of visibility scopes and team or coaching ACLs.

- Consultant-to-organization assignment model.

- Private coaching note partitioning strategy.

- Storage bucket/path strategy and file authorization.

- Embedding/vector storage strategy with tenant and visibility filtering.

- Service-role inventory and approved privileged operations.

- Audit-log storage, retention, and administrator access.

- Membership revocation and session/cache invalidation behavior.

- Anonymous assessment minimum reporting threshold.

- Break-glass support access, if any.

# 22. Definition of Security Integrity

Lead Emergence has security integrity when possession of an identifier, route, search term, file path, embedding similarity, administrative title, or AI capability never grants access that the user's current tenant, role, visibility, and record-specific authorization do not permit.

Authenticate → establish tenant → authorize action → enforce visibility → retrieve minimum data → perform task → audit sensitive action

Security must remain true at the database, storage, retrieval, AI, export, and background-processing layers - not merely in the interface.

# Appendix A — Canonical Role Vocabulary

- PLATFORM_ADMIN

- CONSULTANT

- CLIENT_ADMIN

- CLIENT_LEADER

- CLIENT_MEMBER

# Appendix B — Canonical Visibility Vocabulary

- CONSULTANT_PRIVATE

- INDIVIDUAL_PRIVATE

- COACHING_SHARED

- TEAM_SHARED

- LEADERSHIP_RESTRICTED

- ENGAGEMENT_SHARED

- ORGANIZATION_SHARED

- PLATFORM_RESTRICTED

# Appendix C — Implementation Hand-off Checklist

- Translate Document 03 entities into tenant-owned tables with organization_id.

- Write RLS policies before polished portal development.

- Build multi-tenant adversarial fixtures and CI tests.

- Implement coaching/private-note partitioning before coaching ships.

- Implement secure search/embedding filters before Meridian AI ships.

- Inventory all service-role and privileged functions.

- Implement audit events for high-risk changes.

- Do not load real client data until the V1 Security Gate passes.
