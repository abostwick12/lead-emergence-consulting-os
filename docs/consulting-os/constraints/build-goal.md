GOAL: BUILD LEAD EMERGENCE CONSULTING OS V1

Implement the Lead Emergence Consulting OS V1 according to the supplied architecture and product documents.

You are being provided nine source documents:

1. Canonical Document 01 — Lead Emergence Product Constitution
2. Canonical Document 02 — Emergence Methodology & Consulting Workflow
3. Canonical Document 03 — Domain Model & Relationship Ontology
4. Canonical Document 04 — Meridian Epistemology & Provenance Specification
5. Canonical Document 05 — Security & Multi-Tenancy Specification
6. Canonical Document 06 — Portal Information Architecture & UX Specification
7. Canonical Document 07 — V1 Scope & Acceptance Criteria
8. Lead Emergence Consulting OS Full Build Plan
9. Product Separation / Repository Architecture Constraint

Read all nine documents in full before beginning implementation.

Do not begin significant implementation until the documents have been reviewed, classified, placed into the repository structure described below, and Phase 0 planning has been completed.


==================================================
1. SOURCE-OF-TRUTH HIERARCHY
==================================================

Use the following authority order when sources differ:

1. Explicit constraints in this Goal
2. Product Separation / Repository Architecture Constraint
3. Canonical Architecture Documents 01–07
4. Approved Architecture Decision Records created during implementation
5. Lead Emergence Consulting OS Full Build Plan
6. Other reference/planning documents
7. Existing implementation
8. Developer inference

SPECIAL AUTHORITY RULE:

The Product Separation / Repository Architecture Constraint is authoritative wherever product separation, repository/code boundaries, documentation boundaries, worktrees/branches, distribution, licensing, shared-platform architecture, or Ministry-vs-Consulting ownership are concerned.

Where that document further restricts an assumption in Documents 01–07, the Product Separation constraint governs.

Document 07 is the sole authority for CURRENT V1 phase numbering, phase boundaries, build order, acceptance criteria, and definition of completion.

Do not derive current V1 phase numbering from the Full Build Plan.

Existing code is evidence of the current system. It is not automatically evidence of intended architecture.

Do not silently reconcile material contradictions between authoritative sources.

If authoritative documents materially conflict:
- document the conflict;
- identify the affected implementation work;
- stop only the dependent work;
- continue independent work where safe;
- surface the conflict for human review.


==================================================
2. FULL BUILD PLAN — SUPPORTING CONTEXT
==================================================

Read the Lead Emergence Consulting OS Full Build Plan in full before beginning implementation.

It provides important context for:
- the broader product vision;
- architectural rationale;
- long-term product evolution;
- dependencies between current and future capabilities;
- Meridian;
- the Emergence methodology;
- AI;
- New Reality;
- longitudinal intelligence;
- Pulse;
- and future Drift/Emergence Detection.

The Full Build Plan is supporting architectural context, NOT the final canonical specification.

It predates the completed canonical architecture set and contains earlier terminology, sequencing, phase numbering, and architectural ideas subsequently refined by Documents 01–07.

Use it to understand WHY the architecture is being designed this way and WHERE the product is ultimately headed.

Do not implement functionality merely because it appears in the Full Build Plan.

Implement only functionality authorized by:
- this Goal;
- the Product Separation constraint;
- Documents 01–07;
- and approved ADRs.

Design V1 so that the broader future described in the Full Build Plan remains reasonably possible without prematurely implementing post-V1 functionality.

Build the foundation for the future; do not build the future prematurely.


==================================================
3. PRODUCT SEPARATION IS A HARD REQUIREMENT
==================================================

Lead Emergence Consulting OS is a separate product surface from the existing Lead Emergence Ministry product.

They belong to the broader Lead Emergence ecosystem and may share genuinely product-agnostic infrastructure, but Consulting OS must not become an inseparable extension of the Ministry application.

This is a commercial, architectural, development, licensing, and distribution requirement.

The following test is release-blocking:

Can a Ministry-only distribution be produced that builds, runs, and is understandable without shipping:

- Consulting OS source code;
- Consulting OS canonical architecture documents;
- consulting-specific database migrations;
- consulting-specific AI prompts or workflows;
- consulting-specific business logic;
- consulting-specific tests;
- consulting-specific implementation documentation?

If NO, the product-boundary architecture has failed.

Likewise, Consulting OS development should not require unnecessary access to Ministry-specific implementation.

Before modifying existing code for Consulting OS, classify the change as:

1. genuinely shared platform infrastructure;
2. Ministry-specific;
3. Consulting-specific; or
4. an explicit interface between the products.

Do not move consulting concepts into shared infrastructure merely because it is convenient.

Do not duplicate genuinely shared infrastructure merely to manufacture separation.

The shared platform layer should remain deliberately thin.

Shared means genuinely applicable to Lead Emergence independent of product domain.


==================================================
4. REQUIRED REPOSITORY AND LOCAL DOCUMENT STRUCTURE
==================================================

The nine uploaded source documents are initial inputs.

During Phase 0, create a durable Consulting OS documentation structure inside the repository.

Use an intentionally isolated hierarchy such as:

/docs/consulting-os/

    canonical/
        01-product-constitution.*
        02-emergence-methodology.*
        03-domain-model.*
        04-meridian-epistemology.*
        05-security-multitenancy.*
        06-portal-ux.*
        07-v1-scope-acceptance.*

    constraints/
        product-separation-repository-architecture.*

    reference/
        full-build-plan.*

    implementation/
        IMPLEMENTATION-PLAN.md
        PHASE-STATUS.md
        BLOCKERS.md

    adrs/
        ADR-*.md

    README.md

Preserve the authoritative content of supplied documents.

If conversion from DOCX or another uploaded format into Markdown is useful for durable repository context, create faithful Markdown versions.

Do not silently rewrite, summarize away, or reinterpret canonical requirements during conversion.

The repository README for this architecture set must explain:
- which documents are authoritative;
- which document is supporting reference;
- source-of-truth hierarchy;
- V1 phase authority;
- and how future developers should handle conflicts.

Consulting-specific architecture documentation must not be placed into generic Ministry documentation folders.


==================================================
5. WORKTREE AND BRANCH ISOLATION
==================================================

Consulting OS development must use dedicated Consulting OS branches and worktrees.

During Phase 0:

1. inspect the existing repository, branches, worktrees, and documentation structure;
2. identify the safest development isolation strategy;
3. create or recommend the dedicated Consulting OS branch/worktree structure;
4. document it in the Product Boundary Architecture ADR;
5. perform Consulting OS work only inside the approved Consulting OS development boundary.

Do not casually mix Consulting OS development commits into Ministry feature branches.

Keep phase commits coherent and clearly identifiable.


==================================================
6. REQUIRED PHASE 0 PRODUCT BOUNDARY ADR
==================================================

Before significant Consulting OS implementation, Phase 0 must produce a Product Boundary Architecture ADR.

It must define:

- Ministry-only code;
- Consulting-only code;
- genuinely shared platform code;
- explicit interfaces between products;
- shared authentication boundaries;
- shared database/infrastructure boundaries;
- product-specific schema ownership;
- product-specific migration ownership;
- route boundaries;
- AI workflow boundaries;
- documentation boundaries;
- test boundaries;
- branch/worktree strategy;
- dependency direction;
- build/deployment boundaries where applicable;
- how a Ministry-only distribution is produced;
- how Consulting OS could later be separated into another repository;
- how shared packages/services could support both products without coupling them;
- and how the unified Lead Emergence landing/authentication entry architecture works.

The architecture should preserve the possibility that Ministry and Consulting OS may later:

- remain in one monorepo;
- move into separate repositories;
- share common packages/services;
- be developed by separate teams;
- or be licensed/distributed independently.

Avoid choices that unnecessarily close those future options.


==================================================
7. UNIFIED LEAD EMERGENCE ENTRY EXPERIENCE
==================================================

Lead Emergence requires a new public landing/authentication entry surface with three distinct entry paths:

CONSULTANT LOGIN
→ Consulting OS Consultant Portal

CONSULTING CLIENT LOGIN
→ Consulting OS Client Portal

MINISTRY LOGIN
→ Existing Lead Emergence Ministry product

These are related Lead Emergence products but distinct authorized application contexts.

Authentication infrastructure may be shared where appropriate.

Authorization for one product must NEVER imply authorization for another.

A user legitimately authorized for multiple Lead Emergence products may later receive an authenticated product switcher, but each product context remains independently authorized.

Phase 0 must determine and document:
- route architecture;
- authentication-context architecture;
- product authorization resolution;
- code boundaries;
- and appropriate deployment implications.

Implement the landing page in the appropriate authorized phase after the Product Boundary Architecture ADR has been reviewed.

Do not prematurely force all three products into one undifferentiated application shell.


==================================================
8. EXISTING MINISTRY PRODUCT PROTECTION
==================================================

The existing Lead Emergence Ministry product is working software and must be protected.

Do not:

- break existing Ministry functionality;
- weaken existing security;
- rewrite working Ministry architecture merely to make Consulting OS easier;
- force Ministry concepts into Consulting domain objects;
- force Consulting concepts into Ministry objects;
- remove working Ministry capabilities unless explicitly authorized;
- or treat existing guest/demo permissions as appropriate Consulting OS security.

When existing architecture conflicts with Consulting OS requirements, classify the conflict as:

REUSABLE
The existing primitive is genuinely product-agnostic.

EXTENDABLE
The primitive can safely become shared without becoming domain-specific.

INTERFACE REQUIRED
The two products should communicate through an explicit boundary.

CONFLICTING
The existing architecture cannot satisfy Consulting OS requirements safely.

OBSOLETE
The existing implementation is no longer appropriate and can be replaced only with explicit justification and migration planning.

Do not choose between these categories silently.

Document consequential classifications.


==================================================
9. IMPLEMENTATION GOVERNANCE
==================================================

Do not silently:

- redefine canonical terminology;
- merge domain concepts;
- weaken security requirements;
- weaken coaching privacy;
- weaken provenance requirements;
- weaken AI review boundaries;
- collapse evidence into interpretation;
- collapse outcome into causation;
- replace prescribed architecture merely because another approach is easier;
- or change canonical roadmap terminology.

Resolve architectural ambiguity through ADRs rather than silent assumptions.

Do not perform destructive production-data migrations without explicit human approval.

Prefer additive, reversible migrations during development where practical.

Do not use AI-generated organizational claims as validated truth.

AI may assist.

Humans interpret, validate, name, decide, and authorize.


==================================================
10. PERSISTENT IMPLEMENTATION STATE
==================================================

Do not rely on Goal-mode conversational memory as the implementation record.

Maintain:

/docs/consulting-os/implementation/IMPLEMENTATION-PLAN.md

/docs/consulting-os/implementation/PHASE-STATUS.md

/docs/consulting-os/implementation/BLOCKERS.md

/docs/consulting-os/adrs/

IMPLEMENTATION-PLAN.md should contain:
- current architecture;
- phase plan;
- dependencies;
- migration strategy;
- major implementation decisions;
- and current next steps.

PHASE-STATUS.md must record for every phase:

- NOT STARTED / IN PROGRESS / BLOCKED / PASS;
- acceptance criteria;
- evidence each criterion passed;
- tests executed;
- relevant commits;
- known limitations;
- unresolved blockers;
- human checkpoint status where applicable.

BLOCKERS.md records unresolved decisions requiring human input.

Do not mark an acceptance criterion complete merely because code exists.

Mark it complete only when demonstrated by:
- automated test;
- inspected artifact;
- verified runtime behavior;
- or explicit review evidence.


==================================================
11. BUILD PHASES
==================================================

Work through V1 Phases 0–9 sequentially exactly as defined by Canonical Document 07.

For avoidance of doubt:

Phase 0 — Architecture Freeze
Phase 1 — Multi-Tenant Security Foundation
Phase 2 — Meridian Core
Phase 3 — Consulting Core
Phase 4 — Consultant and Client Portals V1
Phase 5 — Meetings + Coaching
Phase 6 — Alignment + Capability
Phase 7 — Outcomes + New Reality
Phase 8 — Grounded AI V1
Phase 9 — Descriptive Signals

Document 07 governs the exact requirements and exit criteria.

Do not begin a phase until the previous phase's exit criteria have passed and any required human checkpoint has been approved.


==================================================
12. REQUIRED WORK FOR EACH PHASE
==================================================

For each phase:

1. Inspect the existing repository before changing code.

2. Read the relevant canonical requirements again.

3. Update IMPLEMENTATION-PLAN.md.

4. Identify conflicts between existing architecture and canonical architecture.

5. Resolve architectural ambiguities through ADRs.

6. Implement the smallest coherent set of changes satisfying the phase.

7. Add automated tests for the phase's acceptance criteria.

8. Run relevant existing tests to detect Ministry regressions.

9. Run all new phase-specific tests.

10. Run applicable security tests.

11. Perform a self-review against:
    - this Goal;
    - Product Separation constraint;
    - Documents 01–07;
    - approved ADRs.

12. Update repository documentation.

13. Update PHASE-STATUS.md with evidence.

14. Commit the completed coherent phase separately with a clear commit message.

15. At mandatory checkpoints, stop for human review.


==================================================
13. MANDATORY HUMAN CHECKPOINTS
==================================================

Human review is mandatory after:

PHASE 0
PHASE 1
PHASE 3
PHASE 7
PHASE 9

At each checkpoint:

- finish the phase;
- run acceptance tests;
- update PHASE-STATUS.md;
- produce a concise completion report;
- identify ADRs and deviations;
- commit completed work;
- STOP before beginning the next phase.

PHASE 0 REVIEW MUST INCLUDE:

- repository architecture;
- Product Boundary Architecture ADR;
- ERD proposal;
- domain-to-schema mapping;
- shared vs Ministry vs Consulting classification;
- branch/worktree strategy;
- documentation structure;
- migration strategy;
- unified landing/auth architecture;
- Ministry-only distribution strategy;
- unresolved ADRs.

PHASE 1 REVIEW MUST INCLUDE:

- tenant model;
- RLS;
- roles;
- visibility;
- coaching/privacy boundaries;
- file/storage boundaries;
- service-role usage;
- adversarial security test results.

PHASE 3 REVIEW MUST INCLUDE:

- Meridian/domain fit;
- manual consulting workflow;
- SEE REALITY;
- REFRAME REALITY;
- Reality Map;
- Assumption Register;
- Identity/DNA;
- Future-State Narrative;
- evidence that the methodology can be represented faithfully before major UI investment.

PHASE 7 REVIEW MUST INCLUDE:

- complete manual consulting loop;
- portals;
- meetings/coaching;
- alignment;
- capability;
- outcomes;
- Harvest & Soil;
- New Reality;
- Emergent Organization Profile;
- baseline creation;
- end-to-end reasoning traceability.

PHASE 9 REVIEW MUST INCLUDE:

- final V1 acceptance audit;
- grounded AI behavior;
- descriptive Signals;
- security regression;
- Ministry regression;
- product-separation test;
- Ministry-only distribution test;
- remaining limitations;
- explicitly deferred post-V1 capabilities.


==================================================
14. STOP RATHER THAN IMPROVISE
==================================================

Stop dependent work rather than improvise if completing it requires:

- violating a canonical document;
- violating Product Separation;
- weakening RLS or tenancy;
- weakening coaching confidentiality;
- weakening provenance;
- weakening AI review boundaries;
- making an unresolved product decision;
- destructive production migration;
- breaking Ministry functionality;
- changing canonical roadmap terminology;
- treating AI suggestion as validated truth;
- introducing a hard dependency that prevents Ministry-only distribution;
- or making a security-sensitive assumption not supported by the architecture.

Document the issue in BLOCKERS.md and/or an ADR.

Continue independent work only where safe.


==================================================
15. SECURITY IS RELEASE-BLOCKING
==================================================

Document 05 security acceptance criteria are release-blocking.

Any successful:

- cross-tenant read;
- cross-tenant write;
- unauthorized coaching/private access;
- search leakage;
- file leakage;
- export leakage;
- AI retrieval leakage;
- or service-role authorization bypass

blocks progression to real client data.

Do not claim security completion because policies exist.

Demonstrate the policies through adversarial tests.


==================================================
16. MINISTRY-ONLY DISTRIBUTION IS RELEASE-BLOCKING
==================================================

Treat the Ministry-only handoff test from the Product Separation document as an additional V1 acceptance criterion alongside Document 07.

Demonstrate that the Ministry product can be built, run, understood, and distributed without shipping Consulting OS:

- source;
- canonical docs;
- implementation docs;
- migrations;
- AI logic/prompts;
- tests;
- or business logic.

Shared product-agnostic infrastructure is allowed.

Consulting-specific intellectual property is not.

If this cannot be demonstrated, V1 is not complete.


==================================================
17. AI IMPLEMENTATION RULES
==================================================

Do not introduce substantial AI before the manual epistemic workflow works.

AI functionality must follow Document 04.

Every substantive AI result must preserve:

SOURCE
→ PROVENANCE
→ AI ORIGIN
→ REVIEW STATE

AI-generated Patterns, Tensions, Interpretations, Alignment Conflicts, or Signals default to suggestions.

AI cannot autonomously validate an Insight or Diagnosis.

AI cannot make an organizational Decision.

AI cannot silently create accepted causality.

AI retrieval must be permission-filtered BEFORE semantic ranking or generation.

Private coaching data must not become organizational telemetry.


==================================================
18. POST-V1 BOUNDARY
==================================================

Do not build mature:

- Pulse;
- Drift Detection;
- Emergence Detection;
- predictive analytics;
- cross-client benchmarking;
- generalized HRIS;
- payroll;
- project-management replacement;
- task-management replacement;
- broad workflow automation;
- or autonomous organizational agents

during V1 unless Document 07 explicitly requires an underlying foundation.

Preserve architectural extensibility for these capabilities without implementing them prematurely.


==================================================
19. LEGACY CODE RULE
==================================================

Do not assume the existing implementation should win merely because it already exists.

Do not assume the new architecture should replace existing implementation merely because it is cleaner.

For every consequential conflict:

1. understand current behavior;
2. classify it;
3. determine whether it is reusable, extendable, interface-bound, conflicting, or obsolete;
4. document the decision;
5. preserve working Ministry behavior unless an approved change requires otherwise.


==================================================
20. FINAL DEFINITION OF DONE
==================================================

The Goal is complete only when:

1. Phases 0–9 satisfy Document 07.

2. All mandatory human checkpoints have been approved.

3. Document 05 security criteria pass.

4. The complete consulting engagement acceptance test passes.

5. Meridian preserves the full reasoning chain:
   evidence
   → observation
   → pattern
   → assumption/hypothesis
   →

Referenced pasted text files:
- pasted text file: C:\Users\awbostwick\.codex\attachments\9e3cc67c-7a06-4e3e-88a5-9a93294fd19d\pasted-text-1.txt. Read this file before continuing.