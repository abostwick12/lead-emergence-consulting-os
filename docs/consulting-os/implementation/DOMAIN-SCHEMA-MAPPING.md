# Canonical domain-to-schema mapping

**Status:** Accepted for Phase 0 on 2026-08-10.

All names below are Consulting-owned proposals under `consulting_os` unless another schema is shown. Each relationship-capable row also has a same-ID entry in `domain_objects`. This table maps every entity in the restored Document 03 Appendix A and preserves the constraints in Sections 12-25.

## Tenancy, people, and structure

| Canonical entity | Proposed representation | Notes |
|---|---|---|
| Organization | `organizations` | Hard tenant boundary; never `public.ministries`. |
| Engagement | `engagements` | Exactly one organization; durable truth may outlive it. |
| Person | `people` | Product profile plus auth identity mapping; no global org role. |
| Membership | `organization_memberships` | Organization-specific platform role/status. |
| Engagement Membership | `engagement_memberships` | Same-organization membership required. |
| Team | `teams` | Versionable hierarchy within organization. |
| Role | `roles` | Function independent of holder. |
| Role Assignment | `role_assignments` | Time-bounded membership/role/team link. |
| Organizational Area | `organizational_areas` | Typed flexible hierarchy. |

## Evidence and organizational knowledge

| Canonical entity | Proposed representation | Notes |
|---|---|---|
| Evidence | `evidence_items` plus `evidence_sources` / immutable `evidence_fragments` | Evidence remains distinct from Observation. |
| Observation | `observations` | Directness/type/time/source constraints. |
| Signal | `signals` | Attention candidate, not Pattern. |
| Pattern | `patterns` | Recurrence basis, scope, contrary evidence, review state. |
| Tension | `tensions` | Possible mismatch, not automatic conflict/diagnosis. |
| Assumption | `assumptions` | Versioned lifecycle and dependent-object links. |
| Hypothesis | `hypotheses` | Test criteria and strengthening/weakening evidence. |
| Interpretation | `interpretations` | Multiple alternatives may coexist. |
| Insight | `insights` | Human validation required. |
| Diagnosis | `diagnoses` | Dedicated table because required scope/alternatives/limitations differ from Insight. |
| Opportunity | `opportunities` | Evidence-supported possibility. |
| Risk | `risks` | Evidence/status and affected scope. |
| Strength | `strengths` | Existing useful condition/capacity. |
| Unrealized Potential | `unrealized_potentials` | Evidence-supported constrained capacity. |

## Identity, meaning, and future state

| Canonical entity | Proposed representation | Notes |
|---|---|---|
| Identity Element | `identity_elements` | Versioned canonical type vocabulary. |
| Organizational DNA | `organizational_dna_versions` + `organizational_dna_elements` | Curated versioned aggregate. |
| Future-State Narrative | `future_state_narratives` | Six canonical fields; versioned. |
| Future-State Principle | `future_state_principles` | Derived design constraint; versioned. |
| Future State | `future_states` | Domain/baseline/desired condition/horizon. |
| Organizational Blueprint | `organizational_blueprints` + `blueprint_members` | Materialized approved versioned aggregate. |

## Alignment and organizational design

| Canonical entity | Proposed representation | Notes |
|---|---|---|
| Decision | `decisions` + `decision_alternatives` | First-class append-oriented reasoning memory. |
| Design Principle | `design_principles` | Versioned normative rule. |
| Responsibility | `responsibilities` | Versioned subject/outcome. |
| Authority | `authorities` | Versioned decision domain/limits/escalation. |
| Boundary | `boundaries` | Versioned inside/outside/constraints/interfaces. |
| Interface | `interfaces` | Versioned parties, purpose, inputs/outputs, rules. |
| Workflow | `workflows` + `workflow_versions` + `workflow_steps` | Versioned flow and decision points. |
| System | `organizational_systems` | Human-independent mechanism/technology. |
| Metric Definition | `metric_definitions` | Purpose linkage and calculation; Indicator remains outcome evaluation object. |
| Alignment Conflict | `alignment_conflicts` | Defaults suggested/reviewable; never automatic declaration. |
| Reinvention Initiative | `reinvention_initiatives` | Current/future/barrier/change/owner/dependencies/measures. |

## Capability, formation, and coaching

| Canonical entity | Proposed representation | Notes |
|---|---|---|
| Capability | `capabilities` | Reliable performance definition and scope. |
| Capability Requirement | `capability_requirements` | Required level and source requirement. |
| Capability Assessment | `capability_assessments` | Evidence-based current level. |
| Capability Gap | `capability_gaps` | Requirement vs current assessment. |
| Development Plan | `development_plans` | Subject, goals, milestones, evidence. |
| Development Activity | `development_activities` | Learning/practice/coaching/experience. |
| Practice | `practices` | Context, expected behavior, reflection. |
| Resource | `resources` | Product-owned or practice-level; client resources tenant-scoped. |
| Coaching Relationship | `coaching_relationships` | Named coach/participant and privacy contract. |
| Coaching Session | `coaching_sessions` | Shared session record; private content separate. |
| Commitment | `commitments` | Owner/action/review date/status. |
| Readiness / Maturity | `capability_maturity_assessments` | Evidence, assessor, level, date. |

## Goals, value, outcomes, and learning

| Canonical entity | Proposed representation | Notes |
|---|---|---|
| Strategic Priority | `strategic_priorities` | Owner/horizon/status; versionable. |
| Goal | `goals` | Baseline/target/owner/horizon. |
| Indicator | `indicators` | Definition/direction/cadence/source. |
| Measurement | `measurements` | Time-stamped observed indicator value. |
| Value Hypothesis | `value_hypotheses` | Prospective If-X-and-Y-expect-Z-because logic. |
| Outcome | `outcomes` | Observed result; no automatic cause. |
| Value Evaluation | `value_evaluations` | Mission/Human/Operational/Economic/Sustainable. |
| Learning | `learnings` | Human-reviewed conclusion and implications. |
| Outcome Decision | `outcome_decisions` | SUSTAIN / IMPROVE / SCALE / STOP / REINVENT. |

## Meetings, assessments, interviews, artifacts, and New Reality

| Canonical entity | Proposed representation | Canonical constraint preserved |
|---|---|---|
| Meeting | `meetings` + `meeting_participants` | Structured type, date, participants, purpose/agenda, visibility, status, notes, decisions, and actions. |
| Meeting Note | `meeting_notes` plus restricted `consulting_private.meeting_notes` | Explicit consultant-private, individual-private, coaching-shared, or organizational visibility; no automatic telemetry promotion. |
| Action Item | `action_items` | Owner, action, due date, and controlled operational status. |
| Assessment Instrument | `assessment_instruments` + immutable `assessment_instrument_versions` | Used versions are immutable; revisions create new versions and must not imply unearned psychometric validation. |
| Assessment Administration | `assessment_administrations` | Instrument version, audience, dates, confidentiality/anonymity, and scoring compatibility fixed explicitly. |
| Assessment Response | `assessment_responses` plus restricted `consulting_private.assessment_responses` | Response remains attached to the administered instrument/item version; it is evidence, not diagnosis. |
| Interview | `interviews` | Participant, interviewer, guide, date, consent, and visibility. |
| Interview Response | `interview_responses` plus restricted `consulting_private.interview_responses` | Question/response and source location retain confidentiality and provenance. |
| Artifact | `artifacts` + `artifact_members` | Versioned composition of typed domain objects plus narrative presentation; not a giant truth-bearing document blob. |
| Emergent Organization Profile | `emergent_organization_profiles` + members | Versioned account of what became true, distinct from intended Future State. |
| Baseline Snapshot | `baseline_snapshots` + `baseline_snapshot_members` | Immutable time-stamped manifest of selected organizational state. |
| Emergent Reality Difference | `emergent_reality_differences` | Intended and actual states, difference, interpretation, unexpected value, and new tensions remain preserved. |
| Organizational Story | `organizational_stories` | Period, people, related decisions/outcomes, and narrative provenance. |
| Current Signal Set | `current_signal_sets` + members or a secured derived view | Derived collection/view for SEE AGAIN; never itself a diagnosis. |
| Drift Candidate | `drift_candidates` | Controlled class, evidence/baseline, and human review state; no V1 autonomous diagnosis. |
| Emergence Candidate | `emergence_candidates` | Evidence-backed later-stage suggestion with human review state; no autonomous diagnosis. |

## Cross-cutting supporting tables

| Representation | Purpose |
|---|---|
| `domain_objects` | Same-tenant object identity and controlled object type. |
| `entity_relationships` | Section 14 contract: same-tenant typed endpoints, controlled direction/type, rationale, origin/review, provenance, confidence, and effective dates. |
| `record_reviews` | Review/validation event, reviewer, rationale, limitations, dissent. |
| `record_versions` or typed version columns | Stable logical identity, version, effective dates, supersession. |
| `visibility_grants` | Named/team/coaching/leadership access where scope alone is insufficient. |
| `audit_events` | Membership, visibility, export, promotion, privileged access, security changes. |
| `file_objects` | Storage object mapping, tenant, source record, visibility, retention. |
| `ai_generation_events` | Task class, exact source set, model/process metadata, origin and review state. |

No representation may be consolidated or renamed during implementation if doing so merges canonical meanings. Any consolidation requires an approved ADR demonstrating equivalent constraints and queryability.

The implementation must validate every relationship against the exact allowed source-to-target vocabulary in Canonical Document 03 Section 14. Direct foreign keys remain authoritative for structurally knowable parentage. JSON is limited to bounded metadata, assessment definitions, and snapshots where decomposition adds little value; embeddings and search indexes remain derived data only.
