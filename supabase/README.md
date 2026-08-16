# Consulting OS Supabase foundation

This directory belongs only to the private Consulting OS repository.

- `migrations/20260810105645_phase1_security_foundation.sql` contains the additive Phase 1 schema and policies.
- `tests/database/phase1_security_foundation.test.sql` contains 32 transactional pgTAP adversarial checks.
- `config.toml` exposes `consulting_os`, not the Ministry `public` schema; anonymous signup is disabled.

Local execution requires a Docker-compatible engine:

```powershell
npx supabase start
npx supabase db reset
npx supabase db lint --local --schema consulting_os,consulting_security,consulting_private
npx supabase test db
```

The approved hosted target is the Supabase project shared by Ministry and Consulting. The product boundary is enforced by schema ownership, explicit grants, RLS, composite tenant keys, and separate migration ownership:

- Apply only the SQL migrations in this private repository to the verified shared target.
- Never push this repository's `config.toml` wholesale to the hosted project; it is the local Consulting sandbox configuration and would overwrite shared API/Auth assumptions.
- Never use the Ministry repository's migration workflow to apply Consulting migrations.
- Never alter Ministry-owned `public` tables, functions, policies, or grants from a Consulting migration without an approved shared-interface ADR.
- Keep `consulting_security` and `consulting_private` out of the Data API. Expose `consulting_os` only with its explicit grants and RLS policies.
- Personal remains on a separate Supabase project.

Each consulting client is a tenant row in `consulting_os.organizations`; do not create a Supabase project per client.

The private repository workflow `.github/workflows/phase1-security.yml` runs the same migration, lint, and pgTAP checks in an isolated disposable CI database when local Docker is unavailable.
