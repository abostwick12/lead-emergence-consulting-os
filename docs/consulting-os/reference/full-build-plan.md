Lead Emergence Consulting OS — Full Build Plan

I. Product definition

Core thesis

Most software digitizes the organization you already have. Lead Emergence helps you build the organization you need next—and preserves why you built it that way.

Lead Emergence combines a consulting methodology with a persistent organizational operating environment.

The consulting process helps an organization:

See → Reframe → Align → Build → Produce → Live → See Again

The software preserves the reasoning behind that transformation and provides the environment through which the organization continues to develop.

The canonical roadmap

These names should become fixed terminology throughout the codebase, database, documentation, and UI.

| # | Stage | Leadership posture | Governing question |
| --- | --- | --- | --- |
| 1 | SEE REALITY | Be Present | What is actually happening? |
| 2 | REFRAME REALITY | Lead With Your Voice | What does what we're seeing actually mean? |
| 3 | ALIGN WITH REALITY | Establish Boundaries & Create Space | What needs to be ordered differently? |
| 4 | BUILD CAPABILITY | Cultivate Growth | What must people become capable of doing? |
| 5 | PRODUCE VALUE | Evaluate the Harvest | What did our changes actually produce? |
| 6 | NEW REALITY | Live in Your Organization | How does this become the way the organization actually lives? |
| 7 | SEE AGAIN | Be Present in the PRESENT | What is true now? |

Technically:

SEE_REALITY

REFRAME_REALITY

ALIGN_WITH_REALITY

BUILD_CAPABILITY

PRODUCE_VALUE

NEW_REALITY

SEE_AGAIN

Don't casually rename these later.

II. Five architectural principles

These should become product-development guardrails.

1. The roadmap governs workflow; it does not dictate navigation

We do not need seven giant portals.

Users interact with a smaller set of useful workspaces. The roadmap tells Lead Emergence what those activities mean and how they relate.

2. Meridian is infrastructure, not a module

Meridian is the organizational meaning-and-memory layer underneath the entire platform.

It remembers:

what we observed → what we thought it meant → what we decided → why we decided it → what we changed → what happened.

3. AI does not establish organizational truth

AI may:

detect

compare

summarize

retrieve

suggest

identify possible patterns

propose hypotheses

Humans:

interpret

validate

name

decide

authorize

This distinction must exist in the database, not merely prompts.

4. Organization is a hard security boundary

No application-layer convention is sufficient.

Cross-organization isolation must be enforced with database-level RLS and tested adversarially.

5. Lead Emergence must distinguish evidence from meaning

At minimum:

Fact ≠ Observation ≠ Pattern ≠ AI Suggestion ≠ Hypothesis ≠ Interpretation ≠ Validated Insight ≠ Decision

This may eventually become one of the strongest features of the product.

III. The Lead Emergence domain model

This is Build Phase 0.

Do not start major UI development until this is settled.

Rather than immediately creating dozens of tables, first define six domains.

Domain A — Organizational structure

Organization

├── Engagement

├── Person

├── Membership

├── Team

├── Role

└── Organizational Area

An Engagement matters because an organization could hire you multiple times.

Example:

ACME Corporation

│

├── Engagement 2027

│ └── Leadership decentralization

│

└── Engagement 2029

└── Regional restructuring

Meridian should preserve both.

Domain B — Organizational knowledge

This becomes Meridian's epistemological core.

Evidence

Source material.

Examples:

interview transcript

assessment response

uploaded document

KPI

workflow

meeting

survey

consultant field note

Observation

Something directly observed, reported, or measured.

17 of 24 interviewed managers described waiting for executive approval.

Pattern

A recurring relationship among observations.

Routine decisions frequently escalate upward.

Tension

Two pieces of reality that appear potentially inconsistent.

Stated value: decentralized leadership.

Observed pattern: routine decisions escalate upward.

Notice that this does not yet explain why.

Assumption

A belief being treated as true.

Executive approval protects decision quality.

Interpretation

A proposed explanation.

Centralization may persist because leaders equate oversight with quality assurance.

Insight

A human-reviewed interpretation sufficiently supported to inform action.

That transition should require human authorization.

Domain C — Organizational identity

Separate this from diagnosis.

Identity

├── Purpose

├── Mission

├── Vision

├── Values

├── Principles

├── Distinctives

└── Organizational DNA

This supports your questions:

What were you created to do?

What makes your organization uniquely valuable?

What must remain true about this organization as it grows?

Domain D — Organizational design

Future State

├── Strategic Priority

├── Decision

├── Intervention

├── Boundary

├── Authority

├── Responsibility

├── Workflow

└── Design Principle

This is where consulting becomes architecture.

Domain E — Capability

Capability

├── Person Capability

├── Team Capability

├── Development Plan

├── Coaching Relationship

├── Coaching Session

├── Commitment

├── Resource

└── Assessment

Important distinction:

A role describes responsibility.

A capability describes the ability required to fulfill it.

Domain F — Value

Goal

├── Indicator

├── Baseline

├── Target

├── Measurement

├── Outcome

└── Value Dimension

Initial value dimensions:

Mission | Human | Operational | Economic | Sustainable

IV. The relationship graph

This is more important than the individual objects.

We should explicitly define permissible relationships.

For example:

Evidence

↓ supports

Observation

↓ contributes_to

Pattern

↓ may_suggest

Assumption

↓ examined_through

Interpretation

↓ may_be_validated_as

Insight

↓ informs

Decision

↓ authorizes

Intervention

↓ requires

Capability

↓ expected_to_affect

Goal

↓ measured_by

Indicator

↓ produces evidence_of

Outcome

↓ becomes

NEW OBSERVATION

But Meridian must support branching.

One assumption can influence five decisions.

One decision can produce three interventions.

One intervention can affect several goals.

One outcome can challenge multiple assumptions.

So I would use relational Postgres initially but treat the domain conceptually as a graph.

V. Provenance architecture

This is the strongest part of Claude's feedback.

Every important knowledge object needs provenance.

Conceptually:

origin

human

system

ai

imported

And epistemic status:

OBSERVED

SUGGESTED

HYPOTHESIZED

INTERPRETED

VALIDATED

CHALLENGED

REJECTED

SUPERSEDED

Where appropriate, records also need:

created_by

created_at

source

source_location

confidence

review_status

reviewed_by

reviewed_at

organization_id

engagement_id

visibility_scope

Critical AI rule

An AI suggestion can never silently become a validated insight.

It requires an explicit transition:

AI SUGGESTION

↓

Consultant Review

↙ ↓ ↘

Reject Modify Accept

↓

Human Insight

And preserve the original AI output even if modified.

That gives Lead Emergence an audit trail.

VI. Multi-tenant security architecture

This is Phase 1, before real client data.

Every organization-owned record gets

organization_id

Engagement-specific records also get:

engagement_id

Then define membership.

Platform roles

Start simple:

platform_admin

consultant

client_admin

client_leader

client_member

Don't create 37 roles.

Visibility is separate from role

This distinction is important.

A consultant may create:

Consultant Private

A coach/client pair may share:

Coaching Confidential

Executives may have:

Leadership Restricted

Everyone may see:

Organization Shared

Potential scopes:

CONSULTANT_PRIVATE

INDIVIDUAL_PRIVATE

COACHING_SHARED

TEAM_SHARED

LEADERSHIP_RESTRICTED

ENGAGEMENT_SHARED

ORGANIZATION_SHARED

Roles answer:

What can this person do?

Visibility answers:

Who may see this particular information?

Don't conflate them.

VII. Security acceptance criteria

Before production client data:

Org A cannot retrieve Org B records by API, query manipulation, guessed UUID, direct database client, or modified URL.

Client members cannot retrieve consultant-private records.

Managers cannot retrieve private coaching notes without authorization.

Removing membership immediately removes organization access.

AI retrieval respects exactly the same visibility boundaries.

Search respects those boundaries.

Meridian retrieval respects them.

Export respects them.

Server-side functions cannot bypass RLS accidentally.

Automated tests explicitly attempt unauthorized access.

This deserves its own test suite.

VIII. Consulting workflow

Now map your roadmap onto the domain model.

1. SEE REALITY

Inputs

Organizational Portrait

Emergence 360

Interviews

Surveys

Documents

Operational data

Consultant observations

Existing metrics

Creates

Evidence

Observations

Patterns

Possible Tensions

Baseline Measurements

Rule

Observation before interpretation.

AI can surface:

“These seven observations may represent a recurring pattern.”

Not:

“Your leadership team has a trust problem.”

2. REFRAME REALITY

Inputs

Patterns, tensions, observations, identity.

Creates

Assumptions

Interpretations

Validated Insights

Organizational DNA

Future-State Narrative

This is where Naming happens.

A significant UX feature should be the ability to select a pattern and ask:

What might this mean?

Then work through competing interpretations rather than immediately choosing one.

3. ALIGN WITH REALITY

Inputs

Validated insights + future state.

Creates

Decisions

Design Principles

Roles

Boundaries

Authority

Responsibilities

Strategic Priorities

Interventions

Goals

Lead Emergence should be able to show:

Why is this designed this way?

and trace backward to the evidence.

4. BUILD CAPABILITY

Inputs

Future architecture.

Creates

Capability Requirements

Capability Gaps

Development Plans

Coaching

Training

Commitments

Resources

And here's the multiplication idea:

Can the organization reproduce the purpose, judgment and capability necessary to operate without concentrating those things in a few exceptional people?

Eventually that could become a measurable organizational characteristic.

5. PRODUCE VALUE

Inputs

Goals, indicators, interventions, capabilities.

Creates

Measurements

Outcomes

Evaluations

Lessons

And evaluate both:

Harvest

What did we produce?

Soil

What condition did producing it leave the system and its people in?

6. NEW REALITY

This isn't primarily an analytical stage.

It's operationalization.

Approved consulting outputs become persistent organizational reality:

roles

goals

boundaries

coaching

priorities

identity

capabilities

operating principles

workflows

meeting rhythms

The Client Portal becomes increasingly useful here.

7. SEE AGAIN

Now ask:

What is true in the present?

Initially this should be human-led.

New observations enter Meridian.

And the cycle begins again.

IX. Consultant Portal V1

Once the foundation works, build the interface.

Global navigation

Home

Practice dashboard:
clients, meetings, actions, outstanding reviews.

Clients

Client portfolio.

Meetings

Cross-client meeting/coaching calendar and preparation.

Resources

Consulting frameworks/templates/resources.

Settings

Practice/user configuration.

X. Client Workspace

Selecting a client gives the consultant:

Overview

Where are we?

engagement objective

roadmap

organizational identity

priorities

key findings

actions

health

upcoming meetings

Discovery

Tabs:

Portrait | Assessments | Interviews | Evidence | Observations | Patterns

Primarily SEE REALITY.

Strategy

Tabs:

Reality Map | Assumptions | Identity | Future | Alignment

Primarily REFRAME + ALIGN.

Development

Tabs:

Capabilities | People | Coaching | Development Plans | Resources

Primarily BUILD.

Outcomes

Tabs:

Goals | Indicators | Outcomes | Harvest & Soil

Primarily PRODUCE.

Signals

Not Pulse yet.

Simply:

Trends | New Observations | Items to Revisit

Eventually this evolves into Pulse.

XI. Client Portal V1

Much simpler.

Home

What matters to me right now?

priorities

actions

meetings

assessments

goals

development commitments

Our Organization

Identity | Vision | Priorities | Teams | How We Work

This becomes increasingly important in NEW REALITY.

My Development

Role | Capabilities | Goals | Development Plan | Coaching | Resources

Meetings

Upcoming | Preparation | Shared Notes | Decisions | Commitments

Progress

Goals | Indicators | Outcomes | Organizational Progress

No raw consultant diagnostic cockpit.

XII. Shared Meeting Engine

I would actually build this relatively early because it creates immediate usefulness.

One underlying meeting model supports:

Consulting Meeting

Organization ↔ consultant.

Coaching Meeting

Coach ↔ person.

Team Meeting

Team-based.

Potential flow:

PREPARE

↓

MEET

↓

CAPTURE

↓

DECIDE

↓

COMMIT

↓

FOLLOW UP

Meeting preparation can pull appropriate Meridian context.

But again:

retrieval is permission-scoped.

The AI cannot prepare an executive meeting using confidential coaching notes merely because they're in the same database.

XIII. Emergence 360

This should probably be the first major consulting instrument we build.

Don't build five assessments.

Build one defensible organizational assessment aligned with your methodology.

Potential dimensions:

Presence / Reality Awareness

Identity & Purpose

Leadership Voice / Direction

Boundaries & Agency

Alignment

Capability

Growth & Development

Value Creation

Sustainability

Adaptability

But before coding questions, this needs a separate methodological-development effort.

We should determine:

What exactly is being measured?

Is it validated measurement or structured consulting inquiry?

Until psychometrically validated, don't market it as a scientifically validated diagnostic instrument.

Call it an organizational assessment/inquiry framework, not a validated psychometric test.

That's an important credibility boundary.

XIV. AI architecture

AI comes after the evidence model works manually.

I'd divide AI capabilities into levels.

AI Level 1 — Low risk

Build first.

transcription

summarization

formatting

document extraction

meeting recap

semantic retrieval

drafting

AI Level 2 — Evidence synthesis

Next.

similar observations

recurring terminology

evidence clustering

stated-vs-observed comparison

contradictory evidence surfacing

All with provenance.

AI Level 3 — Interpretive assistance

Later.

“Here are three possible interpretations.”

“This assumption may be challenged by these observations.”

“These two organizational commitments appear potentially inconsistent.”

Requires consultant review.

AI Level 4 — Longitudinal intelligence

Much later.

emerging patterns

assumption deterioration

system drift

capability trends

Pulse

This sequencing protects trust.

XV. Pulse roadmap

I agree with Claude that sophisticated Pulse is premature.

So:

V1 — Baseline

Capture:

observations

assessments

indicators

outcomes

assumptions

historical snapshots

V1.5 — Trends

Show changes over time without interpretation.

V2 — Signals

AI may surface:

“This measure has declined for three consecutive periods.”

V2.5 — Pulse

Combine multiple longitudinal signals.

V3 — Drift/Emergence Detection

Only after we understand what real longitudinal client data looks like.

And we should prioritize within-organization longitudinal comparison rather than depending upon cross-client benchmarking.

XVI. Build sequence

This is the order I'd actually hand to Codex/development.

Phase 0 — Architecture freeze

No production features.

Deliver:

canonical terminology

domain dictionary

entity definitions

relationship ontology

epistemic-state model

provenance model

permission model

roadmap mapping

architecture diagrams

ADRs for major decisions

Exit criterion: We can explain exactly what every foundational object means and how it relates to others.

Phase 1 — Multi-tenant foundation

Build:

organizations

users

memberships

engagements

roles

visibility

RLS

security test harness

Exit: Cross-tenant and visibility attacks fail.

Phase 2 — Meridian Core

Build:

evidence

observations

patterns

assumptions

interpretations

insights

relationships

provenance

review/validation workflows

Initially, ugly admin UI is fine.

Exit: We can manually construct and trace a complete reasoning chain.

Phase 3 — Consulting Core

Build:

organizations/clients

engagements

portrait

evidence upload

interviews

observations

assumption register

Reality Map

organizational identity

future state

This enables your first actual consulting engagement.

Phase 4 — Portal V1

Build the polished:

Consultant Portal

and

Client Portal.

Now clients can participate directly.

Phase 5 — Meetings + Coaching

Build the shared meeting engine and coaching experience modeled on your Ministry Meeting concept.

This starts making Lead Emergence useful between formal consulting sessions.

Phase 6 — Alignment + Capability

Build the parts that translate consulting conclusions into organizational design.

Core features:

roles and responsibilities

authority and decision boundaries

team structure

strategic priorities

interventions

capability requirements

capability gaps

development plans

goals and indicators

This is where the system must be able to answer:

Why is this designed this way?

A role boundary, intervention, development plan, or goal should be traceable backward to the insight, assumption, evidence, and desired future state that justified it.

Exit criterion: we can move from a validated organizational insight to an implemented design decision and preserve the complete reasoning chain.

Phase 7 — Outcomes + New Reality

Now make the consulting architecture operational.

Build:

goal tracking

indicators

measurements

outcomes

Harvest & Soil reviews

client-facing organizational identity

priorities

roles/boundaries

development expectations

operating principles

At this point NEW REALITY becomes tangible.

The consulting process has produced an organization that can now live inside the software.

For example:

Consulting finding

↓

Validated insight

↓

Design decision

↓

New authority boundary

↓

New capability requirement

↓

Leader development plan

↓

Goal + indicator

↓

Ongoing operation

The Client Portal should increasingly stop feeling like a consulting portal here and start feeling like:

This is how our organization works.

Exit criterion: approved consulting outputs persist as usable organizational structures rather than static reports.

Phase 8 — Meridian AI

Only now start introducing serious AI functionality.

Not because AI is unimportant, but because Meridian needs something trustworthy to reason over first.

First AI capabilities

Start with the low-risk, high-value functions:

meeting summaries

interview summaries

document extraction

semantic retrieval

assessment synthesis

source-grounded briefing generation

identifying similar observations

clustering evidence

surfacing contradictory evidence

Every substantive AI result needs:

Source → Provenance → AI origin → Review state

For example:

Possible pattern

Several managers describe delayed decisions associated with approval requirements.

Sources: Interview 04, Interview 07, Interview 12, Workflow Analysis 03

AI-generated suggestion — awaiting consultant review.

No bare AI-generated organizational facts.

Phase 9 — Trend Intelligence

Only after enough longitudinal information exists.

Build:

assessment-over-assessment comparisons

indicator history

capability trends

assumption history

repeated pattern tracking

intervention history

outcome comparisons

Important distinction:

Lead Emergence can initially say:

Decision latency increased from 3.2 days to 4.7 days over three measurement periods.

It should not yet say:

Your organization is drifting toward centralized leadership.

The first is measurement.

The second is interpretation.

That distinction continues to matter.

Phase 10 — Pulse

Now develop SEE AGAIN into a serious capability.

Pulse should combine multiple longitudinal signals and ask:

What appears to be changing?

Potential categories:

Purpose

Identity

Narrative

Structure

Authority

Capability

Behavior

Culture

Performance

People

Sustainability

Environment

But again, the output is initially:

Signal

not:

Diagnosis

Example:

Signal requiring review

Three indicators associated with distributed decision authority have moved away from their established baseline during the past two quarters.

Related assumption: “Regional teams possess sufficient decision capability.”

Review recommended.

The consultant and organization determine meaning.

Phase 11 — Drift & Emergence Detection

This is later-stage product intelligence.

And I would deliberately distinguish drift from emergence.

A deviation from the original design is not inherently bad.

Lead Emergence eventually needs categories like:

NOISE

Normal variation

FRICTION

Design is producing unintended resistance

ADAPTATION

People are appropriately adjusting to reality

EMERGENCE

Something valuable is developing that was not originally designed

DRIFT

Behavior is separating from purpose/design in a harmful way

REINVENTION

Reality has changed enough that foundational assumptions

should be reconsidered

That is much more consistent with the name Lead Emergence than treating all deviation as failure.

The V1 boundary

This is important because the full vision can become enormous.

I would define V1 as a product capable of supporting one complete consulting engagement from discovery through implementation planning.

V1 does not need sophisticated Pulse, drift detection, benchmarking, workflow automation, or a full organizational-management suite.

V1 must include

multi-tenant organizations

engagements

secure roles and visibility

consultant portal

client portal

Organizational Portrait

evidence/document collection

interviews

Emergence 360

observations

patterns

assumption register

Reality Map

organizational identity/DNA

future-state narrative

alignment decisions

capability requirements

goals and indicators

meetings

coaching

development plans

basic outcomes

Meridian reasoning relationships

provenance

human review of AI suggestions

That is already a substantial platform.

What specifically should NOT be in V1

I would explicitly backlog:

predictive analytics

autonomous consulting recommendations

sophisticated drift detection

cross-client benchmarking

generalized HRIS

payroll

task-management replacement

project-management replacement

broad workflow automation

complex OKR suite

performance-review system

extensive employee engagement tooling

automated psychological diagnosis

organization-wide AI agent autonomy

Otherwise Lead Emergence will rapidly become an unfocused enterprise platform.

The differentiation is not:

“We can also manage your tasks.”

It is:

We preserve and operationalize the reasoning through which your organization changes.

The two-portal information architecture

With the underlying architecture now clearer, I would freeze V1 navigation roughly here.

Consultant Portal

Home

Practice-level attention dashboard.

Clients

Organization portfolio.

Opening a client gives:

Overview

Current engagement, roadmap position, priorities, major findings, actions.

Discovery

Portrait
Assessments
Interviews
Evidence
Observations
Patterns

Strategy

Reality Map
Assumptions
Identity/DNA
Future State
Alignment

Development

Capabilities
People
Coaching
Development Plans
Resources

Outcomes

Goals
Indicators
Measurements
Outcomes
Harvest & Soil

Signals

Initially just new observations, trends and things requiring review.

Not full Pulse yet.

Meetings

All consulting/coaching meetings.

Resources

Reusable consulting resources and frameworks.

Settings

Practice and account settings.

Client Portal

The client should see far less diagnostic machinery.

Home

priorities

current engagement stage

actions

upcoming meetings

assessments

goals

development items

Our Organization

purpose

identity

mission

vision

values/principles

organizational DNA

priorities

teams

roles

appropriate boundaries

how we work

My Development

role

capabilities

goals

coaching

development plan

resources

commitments

Meetings

upcoming meetings

prep

shared notes

decisions

commitments

follow-ups

Progress

strategic priorities

indicators

outcomes

appropriate organizational trends

That is enough.

The roadmap should remain visible without becoming navigation clutter

Within a client engagement, keep this visually present:

SEE REALITY → REFRAME REALITY → ALIGN WITH REALITY → BUILD CAPABILITY → PRODUCE VALUE → NEW REALITY → SEE AGAIN

But don't force one page per stage.

Instead, every artifact knows which roadmap stage produced it.

For example:

Observation

Roadmap stage: SEE_REALITY

Interpretation

Roadmap stage: REFRAME_REALITY

Authority boundary

Roadmap stage: ALIGN_WITH_REALITY

Capability plan

Roadmap stage: BUILD_CAPABILITY

Outcome review

Roadmap stage: PRODUCE_VALUE

Then the platform can visually reconstruct the consulting journey.

One database decision I would make early

Rather than creating a completely generic nodes table for everything, I would use strongly typed domain tables plus a relationship layer.

Something like:

observations

patterns

assumptions

interpretations

insights

decisions

interventions

capabilities

goals

indicators

outcomes

with a generic:

entity_relationships

that allows relationships such as:

observation SUPPORTS pattern

pattern CHALLENGES assumption

assumption INFORMS decision

decision CREATES intervention

intervention REQUIRES capability

intervention TARGETS goal

goal MEASURED_BY indicator

outcome CHALLENGES assumption

This gives us relational integrity without losing graph-like reasoning.

I would avoid a pure graph database initially. Postgres/Supabase is more than sufficient for this stage.

One additional primitive we should add: Decision

I want to emphasize this because it could easily get buried.

Decision should be a first-class Meridian object.

Most organizational memory systems preserve information.

Lead Emergence needs to preserve judgment.

A decision should record:

Decision

What did we decide?

Why?

Who had authority to decide?

What evidence informed it?

What assumptions were involved?

What alternatives were considered?

What future state was it intended to create?

What intervention resulted?

When should this decision be reconsidered?

Imagine someone joining the organization four years later and asking:

Why are regional directors allowed to approve expenses up to $50,000?

Meridian shouldn't merely find a policy.

It should be able to reconstruct:

The authority was decentralized during the 2027 regional restructuring because decision latency had become a strategic constraint. Leadership concluded that centralized approval was no longer necessary after regional financial capability reached the established threshold. The boundary was originally established at $50,000 and was scheduled for annual review.

That is organizational memory with meaning.

We also need versioning

Organizations change their minds.

Never overwrite important organizational truth.

For:

mission

vision

assumptions

roles

boundaries

decisions

goals

capabilities

identity

future states

we should preserve versions.

Conceptually:

Assumption V1

"Executive approval protects quality."

2027

↓ challenged

Assumption V2

"Quality depends upon clear decision boundaries and capability,

not universal executive approval."

2028

Meridian needs to understand both what the organization believes now and what it believed then.

Otherwise SEE AGAIN loses much of its value.

Phase gates

I'd put hard checkpoints into the development plan.

Gate A — Domain integrity

Before portal development:

Can we model one complete fictional organizational transformation without inventing awkward exceptions?

If not, fix the schema.

Gate B — Security integrity

Before real client data:

Can hostile tests cross tenant or privacy boundaries?

Any yes = no production launch.

Gate C — Consulting usability

Before major AI:

Can a consultant complete the methodology manually using the platform?

If not, AI will only hide workflow defects.

Gate D — AI trust

Before AI-generated synthesis is client-facing:

Can every substantive AI claim be traced to its evidence and identified as AI-generated?

If not, it doesn't ship.

Gate E — Longitudinal integrity

Before Pulse:

Do we have sufficient real longitudinal data to distinguish useful signals from noise?

If not, stay with descriptive trends.

The first internal dogfood engagement

Before putting a paying organization through it, I would run Lead Emergence on Lead Emergence.

Use the platform to answer:

Why does Lead Emergence exist?

What problem are we solving?

What assumptions are we making about consulting?

What is distinctive?

What capability must the platform possess?

What evidence supports our product thesis?

What are the risks?

What indicators would demonstrate actual value?

That would expose awkward schema assumptions very quickly.

Then run a simulated second organization with substantially different characteristics so we don't accidentally design the entire ontology around ourselves.

What I would produce before coding

We now need a small set of canonical architecture documents.

Not a 150-page speculative spec.

I'd create:

| # | Canonical document | Source/status |
| --- | --- | --- |
| 01 | Lead Emergence Product Constitution | Your Overview, cleaned and normalized |
| 02 | Emergence Methodology & Consulting Workflow Specification | Your Full Emergence Roadmap |
| 03 | Lead Emergence Domain Model & Relationship Ontology | Needs to be created |
| 04 | Meridian Epistemology & Provenance Specification | Needs to be created |
| 05 | Security & Multi-Tenancy Specification | Needs to be created |
| 06 | Portal Information Architecture & UX Specification | Needs to be created |
| 07 | V1 Scope & Acceptance Criteria | Needs to be created |

Those seven documents give Codex a much safer foundation than one giant software-generation prompt.

The build order I'd now commit to

0 Product Constitution + Architecture Freeze

↓

1 Domain & Relationship Model

↓

2 Multi-Tenant Security / RLS

↓

3 Meridian Core + Provenance

↓

4 Manual Consulting Workflow

↓

5 Consultant Portal

↓

6 Client Portal

↓

7 Meetings + Coaching

↓

8 Alignment + Capability

↓

9 Outcomes + New Reality

↓

10 Grounded Meridian AI

↓

11 Longitudinal Trends

↓

12 Pulse

↓

13 Drift / Emergence Intelligence
