# Existing implementation classification

The current repository is working Ministry software. The classifications below apply only when evaluating possible Consulting OS reuse.

| Existing primitive | Classification | Evidence and consequence |
|---|---|---|
| Root Next.js application (`app/`, root `package.json`) | MINISTRY-SPECIFIC | Product copy, navigation, guest flow, routes, and deployment all describe the Ministry product. Consulting code must not enter this shell. |
| Root `/` and `/login` | INTERFACE REQUIRED / CONFLICTING | Root redirects to a Ministry login containing guest competition behavior. The unified three-path entry must be a separate ecosystem surface; do not turn the Ministry login into a coupled multi-product shell. |
| `lib/auth/server.ts` Supabase identity verification | EXTENDABLE in concept | Identity verification and secure cookies are generic concepts. Current `AuthSession.role`, profile lookup, guest mode, and metadata fallback are Ministry-specific. Extract a new generic package only after tests prove no Ministry/Consulting policy leaked into it. |
| `public.profiles` and `public.ministries` | MINISTRY-SPECIFIC / CONFLICTING | A profile has one `ministry_id` and one Ministry role. `current_ministry_id()` falls back to the default Ministry. Consulting requires many organizations per consultant and fail-closed organization membership. Never reuse the fallback. |
| `public.platform_user_access` and page permissions | MINISTRY-SPECIFIC | Roles/page keys and guest visibility govern the current Ministry deployment. They do not establish Consulting product entitlement. |
| `lib/supabase.ts` and Supabase client construction | REUSABLE concept, EXTENDABLE code | Client construction is generic, but environment ownership and authorization context must be product-specific. No service-role default path. |
| `lib/ai/azure-openai.ts` URL normalization | REUSABLE candidate | Provider URL normalization is product-agnostic. Provider invocation, prompts, retrieval, audit, and review policy remain product-owned. |
| `lib/meridian/**`, `app/api/meridian/**`, `public.meridian_*` | MINISTRY-SPECIFIC / CONFLICTING | Source kinds include sermons, doctrine, Scripture, pastoral sensitivity, `ministry_id`, and Ministry role policies. Consulting Meridian must be a separate product implementation; future sharing can occur behind a generic contract, not direct imports. |
| `lib/meetings/**`, Ministry Meetings routes and `public.meeting_*` | MINISTRY-SPECIFIC / INTERFACE REQUIRED | The interaction pattern is useful, but schema and RLS depend on `ministry_id`, Ministry profiles, and page permissions. Consulting Phase 5 gets product-owned storage/privacy and may share only an extracted generic contract later. |
| `components/**` and global CSS tokens | CASE-BY-CASE EXTENDABLE | Brand-neutral tokens and accessibility primitives may be extracted. Ministry navigation, shells, content, and feature components must not be shared wholesale. |
| `supabase/migrations/**` | MINISTRY-SPECIFIC | Current migration history owns Ministry production. Consulting migrations live under the Consulting product boundary and are applied through a separate product workflow. |
| Root `tests/` and colocated `lib/*.test.ts` | MINISTRY-SPECIFIC | Consulting unit, integration, security, and E2E tests are product-owned and excluded from Ministry distributions. Existing suites remain required regression evidence. |
| Root Vercel project/deployment from `main` | MINISTRY-SPECIFIC | Do not attach Consulting deployment or change domains/env scopes until the Phase 0 topology is approved. |
| Root `LICENSE` | CONFLICTING | Unqualified MIT terms conflict with independent Consulting OS licensing. See `LECO-002`. |
| Existing generic architecture documentation | MINISTRY-SPECIFIC unless explicitly extracted | Existing Meridian and platform documents describe church/ministry behavior. Consulting architecture stays under `docs/consulting-os/`. |

## Authoritative source conflicts

| Conflict | Governing resolution |
|---|---|
| Canonical 01 language describes consulting and software as “inseparable.” | Product Separation is higher authority. Treat this as a customer-value thesis, not a code/repository coupling instruction. |
| Full Build Plan contains phase numbering through Phase 13 and says Documents 03-07 still need creation. | Document 07 governs V1 Phases 0-9; supplied Documents 03-07 supersede the older plan. |
| Full Build Plan proposes concepts beyond V1, including Pulse and drift/emergence detection. | Preserve extensibility only. Do not implement post-V1 features unless Document 07 requires a foundation. |
| Existing Ministry Meridian looks superficially similar to Consulting Meridian. | Similar naming does not make it shared. Ministry-specific ontology and RLS prevent direct reuse. |
| The original Document 03 omitted Sections 12-25 while its appendix listed related entities. | **Resolved source issue.** Use the retained owner-supplied authoritative continuation and restored canonical file; do not revive provisional inferred definitions. See `LECO-001`. |
