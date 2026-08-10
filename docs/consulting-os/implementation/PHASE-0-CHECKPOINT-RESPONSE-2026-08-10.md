Recommended domain topology

Given the product-separation requirement, I would now choose:

www.leademergence.com
        │
        │  Public Lead Emergence brand/landing site
        │
        ├──────── Consulting ─────────┐
        │                             │
        ▼                             ▼
consulting.leademergence.com
        │
        ├── Consultant Login
        │       ↓
        │   Consultant Portal
        │
        └── Client Login
                ↓
            Client Portal


ministry.leademergence.com
        │
        └── Ministry Login
                ↓
          Ministry Platform

That is cleaner than /consulting and /ministry if commercial separability is a real requirement.

The root becomes the Lead Emergence brand.

The two applications become independently deployable product surfaces.

Consultant and Consulting Client remain two authorization contexts within the same Consulting product, rather than pretending they are separate products.

Authentication can still share infrastructure if Phase 0 determines that is appropriate.

It also creates a natural future architecture:

Lead Emergence
│
├── Brand / Marketing
│
├── Consulting
│   ├── Consultant Portal
│   └── Client Portal
│
├── Ministry
│
└── Shared Platform Packages

You could eventually hand someone the Ministry application without handing them the Consulting application.

Licensing

I would make this explicit now because Codex is right to stop.

Unless you intend to open-source Consulting OS, I recommend:

Lead Emergence Consulting OS is proprietary software. Consulting-specific source code, architecture, methodology implementation, prompts, migrations, documentation, tests, and business logic are not licensed for redistribution as part of the Lead Emergence Ministry product.

Then shared code needs intentional classification.

Something like:

SHARED PLATFORM
License explicitly determined per package/component

MINISTRY
Retains its existing applicable licensing obligations

CONSULTING OS
Proprietary / All Rights Reserved

This is especially important because you already have a public Ministry repository. You do not want Codex casually adding proprietary Consulting code to a repository under an existing permissive license and creating ambiguity about what you've licensed.

I would also tell Codex:

Do not change existing licenses or make legal conclusions about existing licensing obligations. Create an ADR documenting the proposed licensing boundary and flag any existing repository license that may cause Consulting OS code to inherit or appear to inherit redistribution rights. Consulting-specific proprietary implementation must not be committed into a location where an existing repository-wide license would unambiguously license it without explicit human approval.

That is safer than asking Codex to act as your licensing lawyer.

What I would send Codex now

You can paste this as the checkpoint response:

Checkpoint decisions / unblock instructions

1. Document 03

Do not reconstruct missing Document 03 content by ADR.

The canonical Document 03 is complete. The version available to you appears to have been truncated during attachment ingestion or conversion.

I will provide/re-provide the complete canonical Document 03. Replace the incomplete local/repository conversion with a faithful copy of the complete source. Do not alter its architecture while restoring it.

After restoration, verify that the local/repository canonical copy is complete before continuing.

2. Goal Definition of Done

Confirmed: the current Goal constraints, Product Separation / Repository Architecture Constraint, and Canonical Documents 01–07 together define the authoritative V1 Definition of Done.

Canonical Document 07 is the sole authority for current V1 Phase 0–9 sequencing, phase boundaries, acceptance criteria, and completion.

The Full Build Plan remains supporting context and post-V1 architectural direction only.

Do not infer additional V1 requirements from later phases described in the Full Build Plan.

3. Licensing Boundary

Lead Emergence Consulting OS is intended to remain proprietary and commercially separable from the Ministry product.

Consulting-specific source code, architecture, methodology implementation, AI prompts/workflows, migrations, documentation, tests, and business logic must not be included in a Ministry-only distribution.

Existing Ministry licensing obligations remain unchanged unless explicitly approved separately.

Shared platform code must be intentionally classified. Do not assume that code becomes shared merely because both products use it.

Do not modify existing licenses or make irreversible licensing decisions automatically.

Add/update the Product Boundary ADR to document:

existing repository licensing;
Ministry licensing boundary;
Consulting proprietary boundary;
shared-code licensing considerations;
any conflict created by storing proprietary Consulting code in the existing repository;
and a recommended repository/package strategy that preserves this boundary.

Flag any legal/licensing ambiguity for human review rather than improvising.

4. Phase 0 ADR packet

Do not treat the ADR packet as approved merely from this message.

First restore and verify complete Document 03 and update the Phase 0 ADR packet against it and the decisions in this checkpoint.

Then present the final Phase 0 completion report and ADR packet for explicit approval before Phase 1.

Phase 1 is not yet authorized until that final Phase 0 review occurs.

5. Entry/domain topology

Use the following as the target architecture unless repository/deployment inspection reveals a material blocker that requires an ADR:

www.leademergence.com
= public Lead Emergence parent-brand landing experience.

It presents the two product environments:

Lead Emergence Consulting
Lead Emergence Ministry

Consulting provides two entry roles:

Consultant Login
Consulting Client Login

Target Consulting application boundary:

consulting.leademergence.com

This contains both the Consultant Portal and Client Portal. Authentication/authorization determines which portal/context the user may enter.

Target Ministry application boundary:

ministry.leademergence.com

This contains the existing Lead Emergence Ministry application and Ministry login.

Authentication infrastructure may be shared if genuinely product-agnostic, but authorization for Ministry and Consulting must remain independent.

A user's access to one product never grants access to the other.

The architecture may later support a product switcher for users independently authorized for multiple products.

Treat these domains as the target topology, not permission to break the existing production leademergence.com deployment immediately.

Phase 0 must provide a safe migration/deployment plan from the current production topology to this target before DNS, production routing, or deployment configuration is changed.

Do not make production DNS/domain changes during Phase 0.

6. Continue Phase 0 only

With these decisions and the restored complete Document 03:

update the Product Boundary ADR;
update the ERD/domain mapping;
update licensing-boundary analysis;
update entry/domain architecture;
update migration strategy;
update IMPLEMENTATION-PLAN.md;
update PHASE-STATUS.md;
rerun the Phase 0 verifier;
ensure the worktree is clean;
and present the final Phase 0 checkpoint report.

STOP after Phase 0. Do not begin Phase 1 until I explicitly approve the final Phase 0 packet.