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

Do not link or push this project to an existing Supabase target without verifying that it is the isolated Consulting environment. Never use the Ministry migration workflow.

The private repository workflow `.github/workflows/phase1-security.yml` runs the same migration, lint, and pgTAP checks in an isolated disposable CI database when local Docker is unavailable.
