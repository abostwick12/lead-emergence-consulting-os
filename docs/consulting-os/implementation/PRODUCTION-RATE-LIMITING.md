# Production Rate-Limiting Runbook

## Accepted Boundary

Rate limiting protects public mutation surfaces without changing normal consultant, client, development, or automated-test workflows.

- Local development and automated tests do not invoke Vercel Firewall rate checks.
- Supabase Auth remains the only login limiter. Do not add a second application login limiter.
- Public assessment submission is protected through the Vercel Firewall SDK using the ID `assessment-response`.
- A firewall service failure is logged and fails open so a valid participant is not locked out by a protection-layer outage.

## Supabase Authentication

The repository's local Supabase configuration allows 30 sign-in/sign-up attempts per five minutes per IP address. Before production launch, verify the hosted project retains this value under **Authentication → Rate Limits**.

This is intentionally separate from assessment traffic. Ordinary sign-in, token refresh, local development, and automated browser testing should not be affected.

## Vercel Assessment Rule

The deployed Vercel project must define a rate-limit rule whose `@vercel/firewall` identifier is exactly `assessment-response`.

Initial parameters:

- Counting key: client IP
- Window: 60 seconds
- Threshold: 60 requests
- First rollout action: log only
- Enforced action after review: return HTTP 429

Sixty submissions per minute is far above normal human completion speed while still limiting automated request floods.

## Staged Rollout

1. Link this private repository to the correct Consulting OS Vercel project. Never reuse the Ministry product's project linkage.
2. Create the `assessment-response` rule in log-only mode and publish it.
3. Review matched traffic for at least one representative consulting workflow. Confirm that ordinary participant submissions and preview automation are not being classified as abuse.
4. Enforce HTTP 429 in Preview and complete the assessment browser tests against that preview.
5. Change Production from log-only to HTTP 429 only after the Preview check passes.
6. Review firewall traffic during the first 24 hours. Revert the action to log-only immediately if legitimate participants approach the threshold.

## Acceptance Checks

- A participant can complete every assessment item normally.
- A response at or below the threshold receives its ordinary API result.
- An abusive client above the threshold receives HTTP 429 with no database write.
- Local development and the complete automated test suite remain unrestricted.
- Login continues to rely on Supabase Auth's native protection.
- No firewall setting, environment variable, or deployment is changed without confirming the private Consulting OS project target.
