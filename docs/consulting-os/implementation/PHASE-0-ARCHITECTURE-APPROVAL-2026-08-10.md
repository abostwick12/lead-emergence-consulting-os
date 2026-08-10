# Phase 0 architecture decisions

I approve the architectural principles and recommendations in ADR-0002, ADR-0003, ADR-0004, the proposed ERD, and the Domain-to-Schema Mapping.

I approve ADR-0001 with the following required repository/licensing decision:

Lead Emergence Consulting OS will be implemented in a separate private repository.

The existing emergence-ministry-platform repository remains the Lead Emergence Ministry product repository and retains its existing licensing/distribution model.

Do not add Consulting OS application source, proprietary business logic, Consulting migrations, Consulting AI prompts/workflows, Consulting tests/fixtures, deployment configuration, or future proprietary implementation to the Ministry repository.

The Consulting architecture and implementation materials currently created during Phase 0 must be migrated into the new private Consulting repository as part of repository-boundary execution.

Do not assume deletion from the existing repository changes any historical licensing consequences. Preserve the existing repository history and flag the already-committed Consulting documents as a licensing matter requiring owner/legal review.

Shared code is not being extracted into a third shared repository/package at this time.

For now:

* keep genuinely Ministry functionality in the Ministry repository;
* keep Consulting functionality in the private Consulting repository;
* permit duplication where necessary rather than prematurely creating shared dependencies;
* identify future genuinely product-neutral shared components as candidates only;
* require a future ADR before extracting shared packages/services.

Update ADR-0001 accordingly.

Update ADR-0002 migration ownership/path to reflect the private Consulting repository.

Preserve the target topology:

* leademergence.com — future parent brand/entry experience
* consulting.leademergence.com — Consulting OS
* ministry.leademergence.com — Ministry product

Do not change production DNS or deployment topology yet.

Before Phase 1, execute only the repository-boundary work needed to establish the private Consulting repository and migrate the canonical Consulting architecture package into it.

Then rerun the Phase 0 acceptance audit from the new Consulting repository and verify that:

1. the Consulting canonical documents and implementation architecture exist in the private Consulting repository;
2. the Ministry repository does not depend on the private Consulting repository;
3. no Consulting implementation has been added to the Ministry repository;
4. the Ministry product still typechecks, lints, tests, and builds independently;
5. ADR-0001–0004 and the ERD/schema mapping are updated to reflect the final repository boundary.

After that, present the final Phase 0 completion checkpoint.

Phase 1 remains unauthorized until that checkpoint is reviewed and explicitly approved.
