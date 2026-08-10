# Phase 1 service-role inventory

## Approved privileged surface

| Operation | Location | Purpose | Tenant assertion | Audit |
|---|---|---|---|---|
| Record privileged operation | `consulting_security.record_privileged_operation` | Establish the fail-closed contract for later named background/support operations. It does not read or mutate client content. | Non-null existing organization, service-role JWT context, reason, and correlation ID are mandatory. | Inserts an immutable `PRIVILEGED_OPERATION` event. |

## Explicit non-uses

- No service-role key, secret, environment variable, browser client, server repository, background job, or deployment configuration exists in Phase 1.
- Service role is not an ordinary application data path.
- No generic privileged read/write function exists.
- No client-supplied organization ID alone authorizes an operation.
- Every later privileged operation requires a named addition to this inventory, minimum source/row scope, negative tests, and audit behavior.
