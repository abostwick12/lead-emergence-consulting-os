# 12. Domain G — Meetings, Assessments, and Consulting Activity

| Entity | Canonical definition | Core attributes / notes |
|---|---|---|
| Meeting | Structured interaction with participants, purpose, agenda, notes, decisions, and actions. | meeting_type; date; participants; visibility; status |
| Meeting Note | A note associated with a meeting and explicit visibility scope. | author; content; shared/private classification |
| Action Item | Operational follow-up created from a meeting or engagement. | owner; action; due date; status |
| Assessment Instrument | Versioned structured set of prompts/items used for organizational inquiry. | name; version; dimensions; status |
| Assessment Administration | Assignment/instance of an instrument to a population or participant. | instrument; engagement; audience; dates |
| Assessment Response | Participant response to an assessment item. | administration; respondent; item; response; confidentiality |
| Interview | Structured or semi-structured stakeholder conversation. | participant; interviewer; guide; date; consent/visibility |
| Interview Response | Response or excerpt from an interview. | question; response; source location |
| Artifact | Named consulting output assembled from domain objects. | artifact_type; version; approval; constituent objects |

## 12.1 Coaching Privacy Invariant

Coaching Session, Meeting Note, and related records must support partitioning between consultant-private, individual-private, coaching-shared, and broader organizational visibility.

Organizational insight may be promoted from coaching only through an explicit, permission-aware action.

Private coaching content is never automatically organizational telemetry.


# 13. Domain H — New Reality and Longitudinal State

| Entity | Canonical definition | Core attributes / notes |
|---|---|---|
| Emergent Organization Profile | Stage-6 structured account of what actually became true after transformation. | identity; culture; people; structure; systems; technology; relationships; value; stories; assumptions |
| Baseline Snapshot | Time-stamped immutable snapshot of selected organizational state used for later comparison. | snapshot date; scope; source profile/artifacts |
| Emergent Reality Difference | Structured comparison between intended future and what actually emerged. | intended state; actual state; difference; interpretation; unexpected value; new tensions |
| Organizational Story | Preserved narrative of a meaningful chapter in organizational development. | story; period; people; related decisions/outcomes |
| Current Signal Set | Collection/view of current observations, indicators, feedback, and changes available for SEE AGAIN. | derived view; not itself diagnosis |
| Drift Candidate | Later-stage suggestion that current reality may be diverging from the organization's operative model. | dimension; evidence; baseline; review status |
| Emergence Candidate | Later-stage suggestion that a valuable new capability, behavior, opportunity, or relationship may be developing. | dimension; evidence; review status |

## 13.1 Drift Classification Vocabulary

| Class | Meaning |
|---|---|
| NOISE | Normal variation without sufficient evidence of meaningful change. |
| FRICTION | Local resistance or inefficiency within the current model. |
| ADAPTATION | Appropriate adjustment within the existing organizational narrative. |
| EMERGENCE | Something meaningfully new is becoming possible or visible. |
| DRIFT | Growing distance between operative organizational story/design and current reality. |
| REINVENTION | Underlying assumptions no longer adequately explain reality; re-entry into the roadmap is warranted. |

These classifications are not V1 autonomous diagnoses.

They are controlled concepts for later human-reviewed longitudinal intelligence.


# 14. Relationship Ontology

Lead Emergence uses strongly typed domain records plus a controlled relationship layer.

A relationship is meaningful only when its type, direction, source type, target type, organization, provenance, and review state are valid.

| Relationship | Allowed source → target | Meaning |
|---|---|---|
| SUPPORTED_BY | Observation / Assumption / Interpretation / Insight / Outcome → Evidence | Evidence supports the claim. |
| CHALLENGED_BY | Assumption / Interpretation / Insight / Design Principle → Evidence / Observation / Outcome | Evidence calls the claim into question. |
| DERIVED_FROM | Pattern / Interpretation / Insight / Artifact → one or more source objects | Object was synthesized from these sources. |
| CONTRIBUTES_TO | Observation / Signal → Pattern | Source contributes to a recurring pattern. |
| SUGGESTS | Pattern / Tension → Hypothesis / Interpretation / Opportunity | Invites investigation; does not validate. |
| EXPLAINS | Interpretation / Diagnosis → Pattern / Tension | Proposed or validated explanatory relationship, according to review state. |
| VALIDATES | Authorized human review → Interpretation / Insight / Diagnosis | Marks acceptance through explicit review workflow. |
| REJECTS | Authorized human review → AI Suggestion / Interpretation / Hypothesis | Explicitly rejects a proposed claim while preserving history. |
| SUPERSEDES | Versioned entity → prior same-family entity | New operative version replaces prior version without deletion. |
| INFORMS | Insight / Assumption / Future-State Principle → Decision | Reasoning input to an authorized decision. |
| RESPONDS_TO | Decision / Intervention → Insight / Risk / Opportunity / Goal / Tension | Action intentionally addresses the target. |
| AUTHORIZES | Decision → Intervention / Authority / Workflow change | Decision grants permission for downstream change. |
| CREATES | Decision / Intervention → organizational design object | Change creates a new role, boundary, workflow, etc. |
| REQUIRES | Future State / Role / Intervention / Workflow → Capability Requirement | Target cannot function as intended without the capability. |
| DEVELOPS | Development Plan / Activity / Coaching → Capability | Development work aims to increase capability. |
| ENABLES | Capability / System / Authority → Future State / Intervention / Role | Source makes target more feasible or executable. |
| CONSTRAINS | Boundary / Policy / Design Principle → Role / Authority / Workflow / System | Defines a limit or non-negotiable condition. |
| OWNS | Role / Team / Person assignment → Goal / Workflow / Responsibility / Intervention | Operational ownership. |
| MEASURED_BY | Goal / Capability / Value Hypothesis → Indicator | Indicator is selected as evidence of progress/state. |
| MEASURES | Measurement → Indicator | Measurement instantiates an indicator at a point/period. |
| EVALUATES | Outcome / Value Evaluation → Goal / Value Hypothesis / Intervention | Observed result is used to assess expectation/performance. |
| ASSOCIATED_WITH | Any compatible organizational objects | Non-causal association. |
| CONTRIBUTED_TO | Intervention / Capability / Decision → Outcome | Human-reviewed contribution claim weaker than sole causation. |
| CAUSES | Eligible cause object → Outcome | Strong causal assertion; exceptional, human-validated, rationale/evidence required. |
| BECOMES_BASELINE_FOR | Emergent Organization Profile / Baseline Snapshot → next cycle/engagement | Carries New Reality forward into SEE AGAIN / SEE REALITY. |
| REENTERS_AS | Signal / Drift Candidate / Learning → Observation / new Engagement issue | Explicitly moves learning back into renewed inquiry. |

## 14.1 Relationship Record Contract

| Field | Meaning |
|---|---|
| id | Stable relationship UUID. |
| organization_id | Must match both endpoints. |
| engagement_id | Context where relationship was created, if applicable. |
| relationship_type | Controlled vocabulary above. |
| source_type / source_id | Typed source endpoint. |
| target_type / target_id | Typed target endpoint. |
| origin | human / system / ai / imported |
| review_status | For inferential edges: suggested / accepted / rejected / superseded |
| rationale | Why this relationship is asserted. |
| confidence | Optional calibrated confidence; never substitutes for evidence. |
| created_by / created_at | Audit origin. |
| effective dates | Where the relationship itself is time-bound. |

## 14.2 Relationship Invariants

- Both endpoints must belong to the same organization.
- Cross-tenant relationship creation is prohibited.
- A relationship may not be used to bypass endpoint visibility.
- AI-created inferential relationships default to SUGGESTED and cannot be treated as accepted truth.
- CAUSES cannot be created automatically by AI.
- SUPERSEDES must normally remain within the same entity family and preserve the superseded record.
- DERIVED_FROM and SUPPORTED_BY must preserve enough source location to allow a reviewer to inspect the underlying material.
- Deleting an endpoint must not silently erase historical reasoning; use archival/soft-delete rules for canonical knowledge.


# 15. Epistemic Object Boundaries

| Object | What it may claim | What it may not claim |
|---|---|---|
| Evidence | This source exists and contains/records X. | What X means. |
| Observation | X was seen/heard/reported/measured in this context. | Why X happened. |
| Signal | X may deserve attention. | That X is a recurring pattern. |
| Pattern | X recurs or relates across multiple observations. | That X caused Y. |
| Tension | These states may be meaningfully inconsistent. | Which side is correct or why the mismatch exists. |
| Assumption | The organization/person is treating X as true. | That X is objectively true. |
| Hypothesis | X may explain/predict Y and can be tested. | That X has been validated. |
| Interpretation | X is a proposed meaning of the evidence. | That the proposal is established fact. |
| Insight | Authorized reviewers judge X sufficiently supported for action. | Absolute or permanent truth. |
| Diagnosis | This evidence-supported account best explains the scoped organizational condition. | Permission to intervene without a Decision. |
| Decision | Authorized humans chose X for stated reasons. | That X will cause the intended outcome. |
| Outcome | X actually occurred. | That a preceding Intervention caused it. |


# 16. Versioning and Temporal Semantics

Lead Emergence must be able to answer both:

- What is true now?
- What did we believe or design then?

Therefore canonical organizational constructs are temporal.

Rules:

- Version rather than overwrite:
  - Identity Elements
  - Organizational DNA
  - Future-State Narratives
  - Future-State Principles
  - Roles
  - Responsibilities
  - Authorities
  - Boundaries
  - Workflows
  - Design Principles
  - Goals
  - Value Hypotheses
  - Assumptions
  - Emergent Organization Profiles

- Operational edits that do not change meaning may update a record.
- Meaning-changing edits create a new version.
- Superseded records remain queryable in historical context.
- Effective dates represent when a construct governed organizational life, not merely when the database row was edited.
- Historical Meeting Notes, Evidence, Observations, Measurements, and Outcomes are append-oriented and should not be rewritten except for correction with audit history.
- Meridian retrieval defaults to currently effective versions for present-state questions and time-appropriate versions for historical questions.


# 17. Roadmap-to-Entity Production Matrix

| Stage | Primary inputs | Primary entities created/changed | Canonical artifact |
|---|---|---|---|
| SEE REALITY | People, documents, assessments, workflows, metrics, interviews | Evidence; Observation; Signal; Pattern; Assumption status; Strength; Risk; Unrealized Potential | Current-State Reality Map |
| REFRAME REALITY | Reality Map; patterns; assumptions; identity | Hypothesis; Interpretation; Insight; Diagnosis; Opportunity; Identity Element; Future-State Narrative; Future-State Principle | Future-State Narrative / Organizational Blueprint |
| ALIGN WITH REALITY | Validated insights; future-state principles | Decision; Design Principle; Responsibility; Authority; Boundary; Interface; Workflow; Reinvention Initiative; Goal / Metric Definition | Organizational Alignment Architecture |
| BUILD CAPABILITY | Alignment architecture; capability requirements | Capability; Assessment; Gap; Development Plan; Coaching; Practice; Resource; Commitment | Capability Roadmap |
| PRODUCE VALUE | Goals; indicators; interventions; capability evidence | Measurement; Outcome; Value Evaluation; Learning; Outcome Decision | Value & Outcomes Map |
| NEW REALITY | Operating experience; outcomes; normalized practices | Emergent Organization Profile; Organizational Story; Baseline Snapshot; updated assumptions/identity | Emergent Organization Profile |
| SEE AGAIN | Baseline; current signals; new observations | Signal; Observation; assumption retest; Drift/Emergence Candidate; re-entry issue | Organizational Reality Pulse — later-stage |


# 18. Canonical Reasoning Chains

## 18.1 Diagnostic-to-Design Chain

Evidence
→ Observation
→ Pattern
→ Assumption / Hypothesis
→ Interpretation
→ Insight / Diagnosis
→ Future-State Principle
→ Decision
→ Intervention

## 18.2 Capability Chain

Future State / Role / Intervention
→ Capability Requirement
→ Assessment
→ Gap
→ Development Plan
→ Practice / Coaching
→ Readiness Evidence

## 18.3 Value Chain

Purpose
→ Value Hypothesis
→ Intervention + Capability
→ Goal
→ Indicator
→ Measurement
→ Outcome
→ Evaluation
→ Learning
→ Decision

## 18.4 Reinvention Spiral

Emergent Organization Profile
→ Baseline
→ Current Signals
→ New Observation
→ Pattern
→ Assumption Retest
→ Adapt / Re-enter SEE REALITY


# 19. Causality and Attribution Rules

- Default to temporal or associative language unless stronger evidence exists.
- Value Hypothesis records expected causal logic before results are known; it is not proof.
- Outcome may be evaluated against an Intervention without asserting the Intervention caused it.
- CONTRIBUTED_TO is preferred when multiple plausible influences exist and reviewers judge the Intervention materially relevant.
- CAUSES is exceptional.
- CAUSES requires:
  - explicit human validation;
  - supporting evidence;
  - consideration of alternative explanations;
  - and documented rationale.
- AI may suggest possible causal hypotheses.
- AI may not create an accepted CAUSES edge.


# 20. AI-Originated Objects

AI is represented as an origin and review state, not as a privileged truth source.

Where AI generates a candidate:

- Pattern
- Tension
- Interpretation
- Alignment Conflict
- Drift Candidate
- Emergence Candidate
- or another inferential object

the record must remain visibly suggested until reviewed.

Canonical workflow:

AI SUGGESTION
→ Consultant / Authorized Human Review

Possible outcomes:

- Reject
  - preserved as rejected

- Modify
  - create a new human-authored or human-validated version linked to the original suggestion

- Accept
  - accepted/validated according to the object's legitimate epistemic class

Rules:

- AI suggestions retain source citations and provenance.
- AI retrieval may only use records visible to the requesting user/context.
- Private coaching content cannot become general organizational evidence through AI inference.
- AI cannot silently promote a suggestion to Insight, Diagnosis, Decision, or accepted causal relationship.


# 21. Artifact Composition

Roadmap artifacts are not giant unstructured documents in the domain model.

An Artifact is a versioned composition of typed underlying objects plus narrative presentation.

| Artifact | Composed primarily from |
|---|---|
| Current-State Reality Map | Evidence; observations; stakeholder perspectives; workflows; systems; patterns; assumptions; strengths; risks; unrealized potential |
| Future-State Narrative | Identity; interpretations; insights; challenged assumptions; future-state principles |
| Organizational Blueprint | Approved future states and principles across identity, people, culture, leadership, capability, systems, technology, value, measurement |
| Organizational Alignment Architecture | Roles; responsibilities; authorities; boundaries; interfaces; workflows; systems; goals; metrics; initiatives |
| Capability Roadmap | Capability requirements; assessments; gaps; development plans; practices; technology; authority growth; evidence; maturity |
| Value & Outcomes Map | Purpose; value hypotheses; capabilities; behaviors; goals; indicators; outcomes; evaluations; learning; decisions |
| Emergent Organization Profile | What actually became true across identity, culture, people, structure, systems, technology, relationships, value, stories, assumptions |
| Organizational Reality Pulse | Later-stage view over current signals, trends, assumption confidence, and human-reviewed drift/emergence candidates |


# 22. Assessment Model Boundary

Assessment data is evidence, not diagnosis.

An Assessment Response is a participant's response.

Aggregation may create Measurements or Observations.

A consultant may interpret those results in context.

The software must not treat a survey score as self-explanatory organizational truth.

Rules:

- Assessment Instrument versions are immutable after use.
- Revisions create new versions.
- Responses retain the instrument/item version used at collection time.
- Confidentiality and anonymity rules are explicit per administration.
- Comparisons across administrations require compatible dimensions/scoring rules.
- Emergence 360 terminology must not imply psychometric validation unless such validation has actually been completed.


# 23. Security-Relevant Domain Requirements

Detailed security policies belong in Canonical Document 05, but the domain model must make secure enforcement possible.

Requirements:

- Every organization-owned object has `organization_id`.
- Every relationship has `organization_id` and same-tenant endpoints.
- Sensitive objects carry `visibility_scope` or participate in an equivalent access-control association.
- Coaching and Meeting Notes support field/record partitioning rather than relying on UI hiding.
- Engagement Membership is distinct from Organization Membership.
- Role Assignment is organizational structure, not software authorization by itself.
- Exports, search indexes, embeddings, and AI retrieval must preserve tenant and visibility metadata.


# 24. V1 Core vs. Deferred Domain

## V1 Core

- Organization
- Engagement
- Person
- Membership
- Team
- Role
- Role Assignment
- Evidence
- Observation
- Pattern
- Assumption
- Hypothesis
- Interpretation
- Insight
- Diagnosis
- Identity
- Future-State Narrative
- Future State
- Organizational Blueprint
- Decision
- Responsibility
- Authority
- Boundary
- Interface
- Workflow
- Reinvention Initiative
- Capability
- Capability Gap
- Development Plan
- Coaching
- Commitment
- Goal
- Indicator
- Measurement
- Value Hypothesis
- Outcome
- Learning
- Meetings
- Interviews
- Assessments
- Artifacts
- Emergent Organization Profile
- Baseline Snapshot

## Deferred / Later Intelligence

- Cross-client benchmarking
- Autonomous drift diagnosis
- Predictive organizational modeling
- Automated system reconfiguration without human approval
- Advanced adaptive assessment algorithms
- Causal inference engine
- Cross-organization learning unless separately consented and governed
- Mature Pulse / Drift / Emergence intelligence


# 25. Database Implementation Guidance

The canonical model does not require one database table per conceptual noun.

Implementation may normalize or combine tables where semantics remain intact.

Guidance:

- Prefer strongly typed tables for major entities such as:
  - observations
  - assumptions
  - decisions
  - capabilities
  - goals
  - indicators
  - outcomes
  - meetings
  - assessments

- Use a controlled `entity_relationships` layer for graph-like cross-domain reasoning.

- Do not implement the entire domain as generic nodes with JSON blobs; this weakens constraints, RLS clarity, querying, and maintainability.

- Use JSON only for bounded flexible metadata, instrument definitions, or snapshots where relational decomposition would add little value.

- Use foreign keys and check constraints wherever the ontology makes a relationship structurally knowable.

- Create database views for current effective organizational state rather than deleting historical versions.

- Design indexes around `organization_id` first, then common temporal, engagement, status, and relationship lookups.

- Embeddings and search indexes are derived data and must never become the source of truth.


# 26. Minimum Domain Acceptance Tests

1. Model two organizations with overlapping names and prove no domain relationship can cross the organization boundary.

2. Model one organization with two engagements years apart; preserve the first engagement's assumptions and decisions while allowing the second to retest and supersede them.

3. Construct a complete chain:

   Evidence
   → Observation
   → Pattern
   → Assumption
   → Interpretation
   → Insight
   → Decision
   → Intervention
   → Capability
   → Goal
   → Indicator
   → Outcome
   → Learning

4. Represent two competing interpretations of the same pattern without overwriting either.

5. Reject an AI-generated interpretation and preserve both the rejected suggestion and the human reasoning.

6. Supersede an assumption and query what the organization believed before and after the effective date.

7. Create a decision whose rationale references multiple insights and assumptions, and reconstruct why it was made.

8. Record an outcome associated with an intervention without asserting causation.

9. Create a human-validated `CONTRIBUTED_TO` relationship and separately demonstrate the stronger requirements for `CAUSES`.

10. Create a coaching session with shared notes and private notes that remain distinct domain records/scopes.

11. Generate an Emergent Organization Profile that differs from the Future State and preserve the differences rather than rewriting the Future State.

12. Use the Emergent Organization Profile as the baseline for a new SEE AGAIN / SEE REALITY cycle.

13. Version an Assessment Instrument and prove historical responses remain attached to the version originally administered.

14. Archive or supersede a Role or Boundary without breaking historical Decisions, Meetings, or Outcomes that referenced it.


# 27. Worked Example — Distributed Decision Authority

This example demonstrates the ontology using a recurring scenario from the Emergence methodology.

It is illustrative, not a claim about any real organization.

| Step | Domain Object | Example |
|---|---|---|
| 1 | Evidence | Interview excerpts, approval workflow records, and decision-latency measurements. |
| 2 | Observation | Routine team decisions frequently require senior approval. |
| 3 | Pattern | Decision authority repeatedly escalates upward across several workflows. |
| 4 | Tension | Stated commitment to empowered teams may conflict with observed approval structure. |
| 5 | Assumption | Senior approval protects decision quality. |
| 6 | Hypothesis | Centralized approval may be maintained because oversight is equated with quality assurance. |
| 7 | Interpretation | The primary constraint may be authority architecture rather than lack of employee initiative. |
| 8 | Insight | After review, leadership concludes that selected routine decisions can move downward if capability and boundaries are explicit. |
| 9 | Future-State Principle | Authority should expand alongside demonstrated capability. |
| 10 | Decision | Delegate defined decision categories to team leads within specified limits. |
| 11 | Boundary / Authority | Team leads may decide within the defined domain; exceptions and escalation thresholds remain explicit. |
| 12 | Capability Requirement | Team leads require financial judgment, escalation judgment, and decision documentation capability. |
| 13 | Development Plan | Training, coached practice, and staged authority expansion. |
| 14 | Value Hypothesis | If decision authority is moved closer to the work while capability and boundaries are strengthened, decision latency should fall without degrading decision quality. |
| 15 | Indicators | Decision latency; escalation rate; rework/error rate; leader confidence; staff intervention frequency. |
| 16 | Outcome | Observed results after implementation. |
| 17 | Learning | Human-reviewed interpretation of what the outcomes taught the organization. |
| 18 | New Reality | Emergent Organization Profile records how authority actually operates after normalization. |
| 19 | See Again | Later evidence can retest whether the assumptions supporting the authority model remain true. |


# 28. Worked Example — Organizational DNA and Multiplication

The methodology's multiplication concept should not be represented as cultural conformity.

Organizational DNA captures the purpose, principles, judgment, and capabilities that should be reproducible while preserving legitimate difference among people.

Canonical relationship:

Identity Elements
→ compose
Organizational DNA
→ informs
Role / Capability Requirements
→ cultivated through
Development + Coaching + Practice
→ evidenced by
Independent decisions consistent with purpose and boundaries
→ evaluated as
Transferable Organizational Capability

A future multiplication measure should therefore focus less on whether people repeat organizational slogans and more on whether purpose-consistent judgment and capability can be reproduced without constant dependence on original leaders.


# 29. Open Design Questions Requiring ADRs

The ontology is sufficiently defined to begin schema design, but the following implementation choices should be settled through Architecture Decision Records rather than silently embedded in code:

- Whether `Person` is a separate global profile table from authentication identity, and what minimum personally identifiable data it stores.

- Whether `Diagnosis` is a dedicated table or a constrained subtype of validated synthesis / `Insight`.

- Whether `Organizational Blueprint` is materialized as its own versioned aggregate or generated as an `Artifact` over approved Future-State objects.

- Whether `Responsibility`, `Authority`, `Boundary`, and `Interface` use separate tables or a shared typed organizational-design table with strong constraints.

- How generic `entity_relationships` endpoints are implemented while retaining referential integrity.

- How immutable Evidence source fragments are represented for uploaded documents, transcripts, Assessment Responses, and system data.

- How private Coaching Notes are physically partitioned from shared session records.

- Which versioned entities use `supersedes_id` chains versus a stable `logical_id` plus version number.

- How current-state views are materialized for fast Meridian retrieval.

- How organizational snapshots are stored without duplicating excessive live relational data.


# 30. Definition of Domain Integrity

Lead Emergence has domain integrity when the platform can reconstruct not merely what an organization did, but the disciplined reasoning through which it understood reality and chose to change.

Canonical reasoning chain:

We observed THIS

→ which contributed to THIS PATTERN

→ which caused us to test THIS ASSUMPTION

→ which we interpreted THIS WAY

→ which we validated as THIS INSIGHT

→ which informed THIS DECISION

→ which created THIS INTERVENTION

→ which required THIS CAPABILITY

→ which pursued THIS GOAL

→ which we measured through THIS INDICATOR

→ which produced THIS OUTCOME

→ which taught us THIS

→ which became part of THIS NEW REALITY

→ which we can now SEE AGAIN.

That traceability is the canonical center of the Lead Emergence domain model.

Portals, assessments, coaching, dashboards, Meridian retrieval, AI assistance, and future Pulse intelligence are interfaces over this underlying organizational reasoning system.


# Appendix A — Canonical Entity Index

## Tenancy, People, and Structure

- Organization
- Engagement
- Person
- Membership
- Engagement Membership
- Team
- Role
- Role Assignment
- Organizational Area

## Evidence and Organizational Knowledge

- Evidence
- Observation
- Signal
- Pattern
- Tension
- Assumption
- Hypothesis
- Interpretation
- Insight
- Diagnosis
- Opportunity
- Risk
- Strength
- Unrealized Potential

## Identity, Meaning, and Future State

- Identity Element
- Organizational DNA
- Future-State Narrative
- Future-State Principle
- Future State
- Organizational Blueprint

## Alignment and Organizational Design

- Decision
- Design Principle
- Responsibility
- Authority
- Boundary
- Interface
- Workflow
- System
- Metric Definition
- Alignment Conflict
- Reinvention Initiative

## Capability, Formation, and Coaching

- Capability
- Capability Requirement
- Capability Assessment
- Capability Gap
- Development Plan
- Development Activity
- Practice
- Resource
- Coaching Relationship
- Coaching Session
- Commitment
- Readiness / Maturity

## Goals, Value, Outcomes, and Learning

- Strategic Priority
- Goal
- Indicator
- Measurement
- Value Hypothesis
- Outcome
- Value Evaluation
- Learning
- Outcome Decision

## Meetings, Assessments, and Consulting Activity

- Meeting
- Meeting Note
- Action Item
- Assessment Instrument
- Assessment Administration
- Assessment Response
- Interview
- Interview Response
- Artifact

## New Reality and Longitudinal State

- Emergent Organization Profile
- Baseline Snapshot
- Emergent Reality Difference
- Organizational Story
- Current Signal Set
- Drift Candidate
- Emergence Candidate


# Appendix B — Canonical Relationship Vocabulary

- `SUPPORTED_BY`
- `CHALLENGED_BY`
- `DERIVED_FROM`
- `CONTRIBUTES_TO`
- `SUGGESTS`
- `EXPLAINS`
- `VALIDATES`
- `REJECTS`
- `SUPERSEDES`
- `INFORMS`
- `RESPONDS_TO`
- `AUTHORIZES`
- `CREATES`
- `REQUIRES`
- `DEVELOPS`
- `ENABLES`
- `CONSTRAINS`
- `OWNS`
- `MEASURED_BY`
- `MEASURES`
- `EVALUATES`
- `ASSOCIATED_WITH`
- `CONTRIBUTED_TO`
- `CAUSES`
- `BECOMES_BASELINE_FOR`
- `REENTERS_AS`


# Appendix C — Canonical Status Vocabularies

| Object Family | Initial Canonical Statuses |
|---|---|
| Assumption | `UNTESTED` / `SUPPORTED` / `CHALLENGED` / `DISPROVEN` / `SUPERSEDED` |
| Inferential AI / Human Suggestion | `SUGGESTED` / `ACCEPTED` / `REJECTED` / `SUPERSEDED` |
| Hypothesis | `PROPOSED` / `TESTING` / `SUPPORTED` / `PARTIALLY_SUPPORTED` / `UNSUPPORTED` / `SUPERSEDED` |
| Decision | `PROPOSED` / `APPROVED` / `ACTIVE` / `RECONSIDER` / `SUPERSEDED` / `RETIRED` |
| Intervention / Initiative | `PLANNED` / `ACTIVE` / `PAUSED` / `COMPLETED` / `STOPPED` / `SUPERSEDED` |
| Goal | `DRAFT` / `ACTIVE` / `ACHIEVED` / `MISSED` / `RETIRED` / `SUPERSEDED` |
| Commitment / Action | `OPEN` / `IN_PROGRESS` / `COMPLETED` / `CANCELLED` |
| Assessment Administration | `DRAFT` / `OPEN` / `CLOSED` / `ARCHIVED` |
| Engagement | `PLANNED` / `ACTIVE` / `PAUSED` / `COMPLETED` / `ARCHIVED` |
| Drift / Emergence Candidate | `SUGGESTED` / `UNDER_REVIEW` / `ACCEPTED` / `REJECTED` / `RESOLVED` |


# Appendix D — Implementation Hand-off Checklist

- Translate canonical entities into an ERD without changing definitions.

- Create ADRs for the unresolved implementation questions in Section 29.

- Design tenant-aware primary-key and foreign-key strategy and an RLS-compatible schema.

- Define typed relationship constraints and validation layer.

- Define versioning strategy for durable organizational constructs.

- Define provenance and source-fragment model before AI synthesis features.

- Build domain fixtures that exercise all four canonical reasoning chains.

- Run the Minimum Domain Acceptance Tests before polished portal UI work begins.


# End of Canonical Document 03
