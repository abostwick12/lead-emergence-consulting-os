LEAD EMERGENCE

# 07 — V1 Scope &
Acceptance Criteria

Canonical Architecture Specification

Version 1.0 • August 2026

Purpose

Define exactly what Consulting OS V1 must accomplish, what it will not attempt, the order in which it should be built, and the objective gates for internal use, pilot clients, and real client data.

# 1. V1 Product Definition

V1 is a secure, multi-tenant consulting operating system capable of supporting one complete Lead Emergence engagement from discovery through implementation planning, capability development, basic outcome evaluation, and establishment of a new organizational baseline.

V1 SUCCESS = one real engagement can be conducted faithfully inside the platform without disconnected documents becoming the system of record

Artifacts may still be exported, but evidence, reasoning, decisions, development work, and outcomes remain structured Lead Emergence objects.

# 2. V1 Product Promise

A consultant can help a client see present reality, test assumptions, name meaning, define a future state, align architecture, cultivate capabilities, establish value hypotheses and measures, preserve decisions and reasoning in Meridian, and give the client a usable portal through which that work becomes organizational life.

A client can participate without learning the consultant's entire diagnostic cockpit.

# 3. In Scope vs. Explicitly Deferred

| V1 Core | Deferred |
| --- | --- |
| Consultant Portal + Client Portal | Full generalized operating suite |
| Secure multi-tenancy and RLS | Cross-client benchmarking |
| Meridian reasoning/provenance | Autonomous consulting recommendations |
| Discovery/evidence/interviews/assessments | Predictive analytics |
| Reality Map + Assumption Register | Autonomous drift diagnosis |
| Identity/DNA + Future-State Narrative | Mature Pulse intelligence |
| Alignment architecture | HRIS/payroll/recruiting |
| Capability/development/coaching | Project-management replacement |
| Goals/indicators/outcomes/Harvest & Soil | Generic task-management suite |
| Meetings/commitments | Complex workflow automation engine |
| Descriptive Signals/trends | Organization-wide agent autonomy |

# 4. Roadmap Coverage

| Stage | V1 capability |
| --- | --- |
| SEE REALITY | Portrait, evidence, interviews, assessments, observations, patterns, assumptions, Reality Map. |
| REFRAME REALITY | Hypotheses, interpretations, validated insights/diagnosis, Identity/DNA, Future-State Narrative/principles. |
| ALIGN WITH REALITY | Decisions, responsibilities, authority, boundaries, interfaces, workflows, initiatives, goals/measures. |
| BUILD CAPABILITY | Requirements/gaps, development plans, coaching, resources, commitments, maturity evidence. |
| PRODUCE VALUE | Value hypotheses, indicators, measurements, outcomes, Harvest & Soil, learning decisions. |
| NEW REALITY | Approved identity/design becomes client-visible; Emergent Organization Profile and baseline. |
| SEE AGAIN | New observations, descriptive trends, assumptions to review, emerging questions; no mature autonomous drift detection. |

# 5. V1 Roles and Portals

| Role | V1 expectation |
| --- | --- |
| CONSULTANT | Assigned organizations/engagements only; conducts workflow and reviews AI suggestions. |
| CLIENT_ADMIN | Permitted client administration; no confidentiality override. |
| CLIENT_LEADER | Leadership-level participation, development, meetings, permitted content. |
| CLIENT_MEMBER | Assigned assessments, development, meetings, commitments, shared content. |
| PLATFORM_ADMIN | Exceptional operations only. |

| Consultant Portal | Client Portal |
| --- | --- |
| Home | Home |
| Clients | Our Organization |
| Client → Overview | My Development |
| Client → Discovery | Meetings |
| Client → Strategy | Progress |
| Client → Development | Settings |
| Client → Outcomes |  |
| Client → Signals |  |
| Meetings |  |
| Resources |  |
| Settings |  |

# 6. Build Sequence and Phase Gates

| Phase | Build | Exit gate |
| --- | --- | --- |
| Phase 0 — Architecture Freeze | Canonical terminology; ERD proposal; ADRs; legacy conflict map. | Every V1 entity has agreed representation or ADR; roadmap identifiers fixed. |
| Phase 1 — Security Foundation | Organizations, engagements, identity, memberships, assignments, roles, visibility, RLS, storage foundations. | Cross-tenant and confidential-access attacks fail; no UI-only boundary. |
| Phase 2 — Meridian Core | Evidence, observations, patterns, assumptions, hypotheses, interpretations, insights/diagnosis, relationships, decisions, provenance/versioning. | Complete evidence-to-decision chain works manually and is traceable. |
| Phase 3 — Consulting Core | Portrait, evidence library, interviews, Emergence 360 framework, Reality Map, Assumptions, Identity/DNA, Future-State Narrative/Blueprint. | Consultant can complete SEE REALITY and REFRAME inside platform. |
| Phase 4 — Portals V1 | Consultant and Client portals, workspaces, roadmap rail, record details, attention states. | Role-appropriate experiences expose same domain safely. |
| Phase 5 — Meetings + Coaching | Shared meeting engine, coaching relationships, shared/private notes, commitments, history. | Consulting/coaching work persists with correct privacy. |
| Phase 6 — Alignment + Capability | Role architecture, authority, boundaries, interfaces, workflows, initiatives, capabilities, gaps, development. | Insight can trace into design and capability requirements. |
| Phase 7 — Outcomes + New Reality | Goals, indicators, value hypotheses, measurements, outcomes, Harvest & Soil, learning, emergent profile/baseline. | Future State and actual Emergent Reality are separately preserved. |
| Phase 8 — Grounded AI | Source-grounded summaries/extraction, pattern and interpretation suggestions, meeting prep, secure retrieval. | AI suggestions remain reviewable, cited, permission-aware. |
| Phase 9 — Descriptive Signals | New observations, trends, assumptions due, emerging questions, baseline comparisons. | SEE AGAIN works descriptively without fake drift intelligence. |

# 7. Phase 0 Acceptance — Architecture

1. Translate Document 03 into an ERD without changing domain meanings.

1. Create ADRs for unresolved implementation choices.

1. Document legacy table/concept conflicts.

1. Define migration strategy instead of forcing ontology into legacy schema.

1. Mark Documents 01–07 as canonical build constraints.

# 8. Phase 1 Acceptance — Security

1. Org A cannot SELECT Org B data by UUID.

1. Org A cannot INSERT/UPDATE records into Org B.

1. Cross-tenant relationships are rejected.

1. Unassigned consultant cannot access client.

1. CLIENT_ADMIN cannot read consultant-private or coaching-private material.

1. Membership removal stops access.

1. Files, search, exports, and AI retrieval obey the same tenant/visibility rules.

1. All Document 05 release-blocking tests pass.

# 9. Phase 2 Acceptance — Meridian Core

1. Construct Evidence → Observation → Pattern → Assumption/Hypothesis → Interpretation → Insight → Decision.

1. Trace substantive conclusions backward to sources.

1. Store competing interpretations simultaneously.

1. Reject/supersede claims without erasing history.

1. Represent AI origin/review state even before AI generation ships.

1. Historical versions answer time-appropriate questions.

# 10. Phase 3 Acceptance — Consulting Core

1. Complete Organizational Portrait inside platform.

1. Collect assessment and interview evidence with provenance/privacy.

1. Create source-grounded Observations and review Patterns.

1. Build Reality Map from typed objects rather than a dead report.

1. Maintain Assumption Register with evidence for/against.

1. Create Identity/DNA and canonical six-part Future-State Narrative.

1. Separate consultant-private analysis from client-visible conclusions.

# 11. Phase 4 Acceptance — Portals

1. Consultant always knows current organization/engagement.

1. Client Home clearly shows what requires attention.

1. Roadmap is visible without becoming seven apps.

1. AI suggestion, Interpretation, validated Insight, and Decision are visually distinct.

1. Client cannot see raw consultant-private analysis.

1. Current state is default while history remains accessible.

1. Client mobile flows support assessments, meetings, commitments, and coaching.

# 12. Phase 5 Acceptance — Meetings and Coaching

1. One meeting engine supports consulting and coaching.

1. Flow supports Prepare → Meet → Capture → Decide → Commit → Follow Up.

1. Private coaching notes are technically partitioned from shared notes.

1. Coaching material does not feed organizational intelligence automatically.

1. Commitments persist across sessions.

1. Meeting preparation retrieves only permission-eligible context.

# 13. Phase 6 Acceptance — Alignment and Capability

1. Validated Insight can lead to a Decision and concrete design objects.

1. Role can represent Purpose + Responsibility + Authority + Boundaries + Interfaces + Support + Accountability + Success Measures.

1. Required capabilities trace to Future State, Role, Intervention, or Workflow.

1. Capability Gap compares requirement to evidence-based current state.

1. Development Plan traces forward to practice and maturity evidence.

# 14. Phase 7 Acceptance — Outcomes and New Reality

1. Value criteria/hypotheses exist before outcome evaluation.

1. Goal and Indicator preserve baseline, target, owner, and measurement history.

1. Outcome can relate to Intervention without automatically claiming causation.

1. Harvest and Soil are both evaluated.

1. Learning can result in Sustain / Improve / Scale / Stop / Reinvent.

1. Future State is not overwritten by Emergent Reality.

1. Emergent Organization Profile can become the next baseline.

# 15. Phase 8 Acceptance — Grounded AI

1. Every substantive AI suggestion has AI origin, source set, and review state.

1. AI cannot validate Insight/Diagnosis or make Decision.

1. AI retrieval filters authorization before ranking.

1. AI citations point to actual source objects.

1. Pattern suggestions expose supporting and contrary evidence.

1. Rejected suggestions do not later appear as truth.

1. Insufficient evidence is stated rather than filled with generic confident output.

# 16. Phase 9 Acceptance — Signals

1. Signals describes observed change without autonomous diagnosis.

1. Trend comparisons use compatible data and correct versions.

1. Private coaching content is excluded unless explicitly promoted.

1. Assumptions due for review can be surfaced.

1. A Signal can become a new Observation/re-entry item for SEE REALITY.

1. V1 never markets descriptive Signals as validated drift detection.

# 17. Complete Engagement Acceptance Test

This is the strongest V1 functional test.

DISCOVER → UNDERSTAND → NAME → DESIGN → CULTIVATE → MEASURE → INHABIT → SEE AGAIN

1. Create Organization and Engagement.

1. Assign consultant and client users.

1. Build Organizational Portrait.

1. Run one assessment administration and collect multiple interviews/evidence sources.

1. Create source-grounded Observations.

1. Review Patterns and Assumptions.

1. Build Current-State Reality Map.

1. Create competing Interpretations and validate an Insight/Diagnosis.

1. Define Identity/DNA and Future-State Narrative.

1. Create a Decision traceable to reasoning.

1. Define an Alignment change: role, authority, boundary, workflow, or initiative.

1. Define required Capability and Development Plan.

1. Run a Meeting/Coaching cycle with commitments.

1. Create Value Hypothesis, Goal, Indicator, Measurement, and Outcome.

1. Evaluate Harvest & Soil and record Learning.

1. Create Emergent Organization Profile/Baseline.

1. Enter a new SEE AGAIN Observation and trace it into renewed inquiry.

If major off-platform documents are required to preserve the reasoning chain, V1 is not complete.

# 18. Cross-Cutting Acceptance

| Area | Release expectation |
| --- | --- |
| Domain integrity | Evidence, Observation, Pattern, Interpretation, Decision, and Outcome remain distinct. |
| Meridian trust | Claims are traceable; contrary evidence and history are preserved. |
| Security | Document 05 tests are release-blocking. |
| UX | Two portals remain clear and permission-appropriate. |
| Causality | Outcome does not imply cause automatically. |
| Versioning | Current and historical organizational truth are both queryable. |
| Privacy | Coaching/private sources cannot leak through AI, search, export, or summaries. |
| Terminology | Canonical roadmap names and domain terms are consistent. |

# 19. Performance and Reliability Baselines

V1 should measure operational quality without inventing arbitrary latency promises before implementation data exists.

- Common pages should avoid unnecessary multi-second blocking under ordinary pilot data volumes.

- Tenant queries must be indexed and avoid unbounded cross-tenant scans.

- AI failure must not destroy or replace validated content.

- Forms/autosave must expose clear saved/error state and avoid silent data loss.

- Audit/security events must be durably recorded.

- Backup/recovery strategy must be documented before pilot data.

- Production errors must be observable without logging sensitive content unnecessarily.

# 20. Legacy and Migration Guardrails

- Existing ministry tables are not automatically canonical for Consulting OS.

- Reuse primitives intentionally; do not distort Document 03 to avoid migrations.

- Preserve existing production behavior where required through explicit migration/feature flags.

- Separate generic organizational primitives from ministry-domain extensions where practical.

- Do not let guest/demo permissions weaken Consulting OS tenant security.

# 21. Internal Dogfood Gate

Before a paying pilot, run Lead Emergence on Lead Emergence and then on a substantially different synthetic organization.

1. Use the platform to model Lead Emergence's own purpose, assumptions, future state, capabilities, goals, and value hypotheses.

1. Complete the end-to-end reasoning chain.

1. Identify ontology/UI friction and record changes as ADRs rather than ad hoc patches.

1. Run a second synthetic organization with different structure and mission to expose overfitting.

1. Repeat security fixtures after schema changes.

# 22. Pilot Readiness Gate

1. Architecture/ERD and required ADRs approved.

1. Document 05 Security Gate passes.

1. Complete Engagement Acceptance Test passes on synthetic/dogfood data.

1. Consultant Portal and Client Portal core flows are usable.

1. Coaching privacy is verified.

1. Meridian provenance and history are inspectable.

1. Grounded AI features, if enabled, pass AI acceptance tests.

1. Backup, error monitoring, and audit strategy are operational.

1. Pilot data retention/export expectations are documented.

1. Known limitations are documented for pilot participants.

# 23. Production Readiness Direction

V1 pilot readiness is not automatically broad commercial production readiness. Before wider release, establish operational SLOs, incident response, privacy/legal documentation, support procedures, database recovery drills, dependency/security update process, and evidence from real pilot usage that the domain model does not require major restructuring.

# 24. Definition of Done

Consulting OS V1 is done when it can faithfully support the Lead Emergence methodology with secure client participation and persistent organizational reasoning - not when every future platform idea has been built.

SEE → REFRAME → ALIGN → BUILD → PRODUCE → NEW REALITY → SEE AGAIN

The V1 product should prove the closed loop: consulting creates structured organizational knowledge and design; the client can live inside the approved outputs; outcomes create new evidence; and the organization can begin the next cycle without losing why the previous one existed.

# Appendix A — V1 Must-Have Checklist

- Multi-tenancy/RLS

- Organizations + engagements + memberships

- Consultant Portal

- Client Portal

- Evidence/provenance

- Interviews

- Assessment framework/Emergence 360

- Observations + Patterns

- Assumption Register

- Reality Map

- Identity/DNA

- Future-State Narrative

- Decisions + Alignment architecture

- Capabilities + Development Plans

- Meetings + Coaching

- Goals + Indicators + Measurements

- Value Hypotheses + Outcomes

- Harvest & Soil

- Emergent Organization Profile/Baseline

- Descriptive Signals

- Grounded, permission-aware AI assistance

# Appendix B — Explicit V1 Non-Goals

- Autonomous consulting

- Predictive organizational analytics

- Mature drift detection/Pulse

- Cross-client benchmarking

- Full HRIS

- Payroll/recruiting

- Project-management replacement

- Generic task suite

- Broad workflow automation

- Organization-wide autonomous agents

- Psychometric-validation claims not supported by actual validation

# Appendix C — Recommended Development Order

0 Architecture → 1 Security → 2 Meridian Core → 3 Consulting Core → 4 Portals → 5 Meetings/Coaching → 6 Alignment/Capability → 7 Outcomes/New Reality → 8 Grounded AI → 9 Signals
