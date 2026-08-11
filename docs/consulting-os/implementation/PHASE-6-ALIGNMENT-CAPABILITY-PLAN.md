# Phase 6 — Alignment and Capability plan

## Outcome

Phase 6 turns validated organizational meaning into explicit design and cultivates the capabilities required to inhabit that design. The operative chain is:

Validated Insight → Decision → Role / Responsibility / Authority / Boundary / Interface / Workflow / Initiative → Capability Requirement → Evidence-based Assessment → Gap → Development Plan → Activity / Practice / Coaching / Resource → Maturity Evidence

## Canonical implementation

- Roles are versioned organizational functions independent of the people assigned to them.
- A complete Role view composes Purpose, Responsibilities, Authority, Boundaries, Interfaces, Support, Accountability, and Success Measures without collapsing those objects into prose.
- Decisions remain first-class Meridian records and link to the design objects they authorize or create.
- Workflows preserve purpose, owner, ordered steps, handoffs, and decision points.
- Reinvention Initiatives preserve current condition, intended condition, barrier, change, ownership, dependencies, and success evidence.
- Capabilities describe reliable performance, not training completion or possession of a resource.
- Every Capability Requirement points to the Future State, Role, Reinvention Initiative, or Workflow that requires it.
- Capability Assessments cite current evidence; Capability Gaps compare the requirement with that assessment rather than relying on self-description alone.
- Development Plans have an owner, dates, measurable goal, milestones, activities, practice, and expected evidence.
- Readiness / Maturity is an evidence-based assessment recorded after practice; it is never inferred from activity completion alone.

## Versioning and traceability

- Role, Responsibility, Authority, Boundary, Interface, Workflow, and Design Principle use the accepted `logical_id` + `version_number` + effective dates + `supersedes_id` contract.
- Historical versions remain queryable; current-state views select the currently effective version.
- Direct structural foreign keys preserve required composition; controlled `entity_relationships` preserve cross-domain reasoning such as `CREATES`, `AUTHORIZES`, `REQUIRES`, `DEVELOPS`, `ENABLES`, `CONSTRAINS`, and `OWNS`.
- All links remain same-tenant and endpoint visibility never broadens through an edge.

## Role-safe experience

- Consultant Alignment shows traceable Decisions, Role Architecture, Workflows, and Reinvention Initiatives.
- Consultant Development shows capability pathways from requirement through maturity evidence.
- Client Our Organization shows only approved role/design records visible to that person.
- Client My Development shows the person's role, required capabilities, evidence-based current state, gaps, plan, activities, practice, resources, and commitments without exposing consultant-private analysis.
- Mobile prioritizes readable cards and actions; desktop may use denser alignment architecture layouts.

## Verification

- pgTAP proves same-tenant composition, typed relationship rules, version history, complete Role contract, evidence-required assessment/gap integrity, and development-to-maturity traceability.
- Unit tests prove capability-level comparison, current-version selection, and role-safe fixture projections.
- Browser tests complete real create/edit/save/read cycles across Alignment and My Development.
- Static verification checks canonical entities, traceability relationships, routes, privacy boundaries, and Phase 6 acceptance language.
- Existing Phase 0–5 checks remain green; no Ministry source or dependency changes.
