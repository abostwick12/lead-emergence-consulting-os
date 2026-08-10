# Ministry-only distribution strategy

## Acceptance statement

A recipient of a Ministry-only handoff must be able to receive, install, build, test, license, and deploy the public Ministry repository without access to this private Consulting repository or any Consulting source, canonical documents, prompts, migrations, test fixtures, customer data, deployment configuration, or proprietary dependency.

Passing the repository root build is necessary but not sufficient: the produced handoff manifest must also prove that no Consulting path or dependency is present.

## Consulting-owned exclusion set

The Ministry-only distribution excludes the private Consulting repository in full, including:

- all future Consulting application paths;
- `docs/consulting-os/`
- `scripts/consulting-os/`
- `.worktrees/consulting-os-*`
- future Consulting-only packages identified by the workspace ownership manifest
- Consulting environment templates, deployment metadata, prompts, fixtures, exports, and generated artifacts

Root Ministry source, its existing `supabase/migrations/`, Ministry docs, and Ministry tests remain in the Ministry handoff. A neutral shared package may be included only when its license and dependency graph permit independent Ministry use.

The owner selected and established this separate private Consulting repository. Existing Ministry licensing obligations remain unchanged, and Codex does not select or edit legal terms. No Consulting implementation source may be added to the public Ministry repository. Final Consulting license terms and historical Phase 0 materials remain subject to owner/legal review.

## Required repository controls

1. A workspace ownership manifest labels every product and package as `ministry`, `consulting`, `entry`, or `shared-neutral`.
2. Package manifests forbid Ministry dependencies on Consulting or entry packages.
3. Product-specific environment schemas reject variables owned by another product.
4. Consulting migrations remain outside the root Ministry migration directory.
5. CI runs an import/dependency boundary check before building either product.
6. The distribution tool uses an allowlist rooted in Ministry-owned and approved neutral paths, not a fragile Consulting denylist.
7. The resulting file manifest and checksums are retained with the release evidence.
8. Every included shared-neutral package has an explicit owner-approved license classification and no Consulting policy or proprietary dependency.

## Ministry-only distribution test

The future automated test must create a clean temporary checkout or archive from the Ministry allowlist and then:

1. fail if any path, package name, import, environment key, migration, prompt, or document matches a Consulting-owned manifest entry;
2. fail if the Ministry dependency graph reaches a Consulting or entry package;
3. install from the committed lockfile without Consulting workspaces;
4. run Ministry design checks, type checking, linting, unit/integration tests, production build, and end-to-end tests;
5. inspect the production bundle and source maps for Consulting identifiers and canonical document text;
6. verify the Ministry Supabase migration set contains no `consulting_*` schema or table;
7. emit a signed or checksummed distribution manifest suitable for the release record.

The test uses synthetic data only and must never package `.env` files, secrets, local worktrees, test screenshots, database dumps, or customer content.

## Current Phase 0 evidence

- Existing Ministry application files and migrations are untouched by this architecture phase.
- The canonical Consulting package is contained in this private repository under `docs/consulting-os/` and `scripts/consulting-os/`.
- No Consulting runtime dependency, route, database migration, environment variable, or deployment configuration has been added.
- The target topology assigns the Ministry product to `ministry.leademergence.com`, but independent distribution cannot depend on the Entry or Consulting Vercel projects or domains.
- The public Ministry repository has no package, runtime, migration, build, CI, or deployment dependency on this private repository. A later release-boundary checker may automate this proof without becoming a cross-repository runtime dependency.

## Failure interpretation

Any Ministry-only handoff that requires Consulting files to build has failed the product-separation requirement. The remedy is to move truly neutral code behind an explicit interface or duplicate a small neutral primitive; it is not to include Consulting source in the Ministry handoff.
