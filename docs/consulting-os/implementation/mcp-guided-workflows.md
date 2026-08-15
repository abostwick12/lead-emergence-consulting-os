# MCP-Guided Product, Audit, and Interview Workflows

## Decision

Products, written audits, and interviews use one guided-record contract across the native Consulting OS interface and future ChatGPT MCP access.

The native interface is the immediate, fully functional fallback. ChatGPT conversation mode is the preferred facilitation surface once the Consulting OS MCP server is hosted behind the approved authorization boundary.

## Current implementation

- Every product, audit, and interview card opens a focused guided workspace.
- An incomplete record opens at its first unanswered question.
- Consultants may skip a question, revisit any question, edit confirmed responses, and review the complete working record.
- Product identity, owner, purpose, and status remain directly editable.
- Audit and interview workflow statuses remain directly editable.
- The ChatGPT brief identifies the engagement, record type, record ID, next guided question, confirmation rule, and sanitized-data boundary.
- Guided responses are rejected when they contain controlled-information indicators covered by the engagement guardrail.
- Product, audit, and interview question sets remain distinct typed workflows.

## MCP tool contract

`lib/operational-ai/mcp-tools.ts` defines three focused operations:

1. `list_engagement_records`
2. `get_guided_record`
3. `save_guided_response`

The write operation requires `confirmed: true`. The contract never authorizes the model to infer an answer, silently summarize a response, promote evidence into diagnosis, or bypass the tenant/role boundary.

This follows OpenAI's guidance to build focused tools around user goals, provide explicit schemas and descriptions, mark read/write behavior accurately, and require confirmation for consequential writes:

- [Build an MCP server](https://developers.openai.com/plugins/build/mcp-server)
- [Define tools](https://developers.openai.com/plugins/plan/tools)

## Hosted activation gate

The tool contract is implemented, but it is not exposed as an unauthenticated public endpoint. A production ChatGPT connection still requires:

- an approved public HTTPS MCP endpoint;
- OAuth/resource-server metadata;
- bearer-token validation;
- consultant-role and engagement-scope enforcement;
- tenant-aware persistence instead of fixture storage;
- production audit logging and idempotency for writes.

Until that infrastructure checkpoint is completed, the in-product guided workspace and copied ChatGPT brief provide the same question sequence without implying that a live MCP write occurred.

## Login boundary

The public landing page remains the role-selection surface. A role-specific Consulting OS entry now proceeds directly into that role's authentication/session path and does not ask the user to choose consultant versus client a second time.
