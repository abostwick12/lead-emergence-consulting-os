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

## Final V1 distribution audit — 2026-08-11

The final audit used a detached clean worktree of public Ministry `main` at `dd28c74ee484484f028465de25ede0b4655374cf`. The owner's original Ministry working tree contained unrelated modified and untracked files and was not changed.

### Archive and dependency boundary

| Evidence | Result |
|---|---|
| Ministry archive | PASS — 1,478 tracked entries. |
| Consulting-owned path scan | PASS — zero matches. |
| Archive SHA-256 | `CBDB23A3C65FD9B65CF0609C4FC72C30BDB070D1D34CC63CE772F2174EA4B6F5` |
| Git tree manifest SHA-256 | `EC5F2100E2F2D911E8CF49FAF9FF7BF32F8F3D4351B9060002131C7FD0D76DC5` |
| Source/package/migration/CI scan | PASS — no private repository name, `consulting_os`, `consulting_private`, Signals route/module, `REENTERS_AS`, or canonical Signals copy. |
| Compiled `.next` scan | PASS — the same Consulting identifiers and canonical copy are absent. |
| Cross-repository dependency | PASS — Ministry installs, builds, and runs without this private repository. |

### Independent Ministry verification

| Check | Result |
|---|---|
| `npm ci` | PASS — 752 packages installed from the Ministry lockfile; 13 existing audit findings were reported and no dependency change was made. |
| `npm run design-check` | PASS. |
| `npm run typecheck` | PASS. |
| `npm run lint` | PASS with no warnings. |
| `npm run build` | PASS — 183 pages generated. |
| Optional unit suite | 1,411 tests pass; the unchanged Logos companion-script suite fails during import with `SyntaxError: Invalid or unexpected token`, as documented before Phase 9. |
| Default-timeout browser evidence | 99 passed, 1 skipped, then the unchanged desktop sidebar route traversal exhausted the 60-second per-test budget; 31 were not scheduled after the failure. |
| Exact sidebar rerun | PASS — unchanged test completes in 1.3 minutes with a 180-second budget. |
| Bounded four-worker browser run | 122 passed, 1 skipped, 6 failed under concurrent cold compilation/provider-fixture contention, and 3 were not run. |
| Exact six-failure serial rerun | PASS — all 6 unchanged cases pass with one worker and the same 180-second budget. |

No Ministry source, test, dependency, migration, configuration, or repository history was changed to obtain these results. The current Ministry browser harness is concurrency- and cold-compilation-sensitive, but every observed failure passes unchanged under serial or realistic-timeout execution. This is a Ministry test-harness maintenance limitation, not a Consulting dependency or product-boundary failure.

### Acceptance conclusion

The release-blocking product-separation criterion passes: a clean Ministry-only artifact can be produced, understood, installed, built, and exercised without shipping or accessing Consulting source, canonical documents, migrations, AI workflows, tests, or business logic. The archive and compiled output contain no Consulting identifiers, and no Ministry dependency reaches the private repository.

## Failure interpretation

Any Ministry-only handoff that requires Consulting files to build has failed the product-separation requirement. The remedy is to move truly neutral code behind an explicit interface or duplicate a small neutral primitive; it is not to include Consulting source in the Ministry handoff.
