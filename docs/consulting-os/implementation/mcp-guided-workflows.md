# MCP-Guided Product, Audit, Interview, and Assessment Workflows

## Decision

Products, written audits, interviews, and versioned Mission Product assessments use guided contracts across the native Consulting OS interface and the OAuth-protected remote MCP used by ChatGPT, Claude, Microsoft Copilot, and GitHub Copilot.

The native interface remains a fully functional fallback. Conversation mode in a supported AI assistant is the preferred facilitation surface when the client permits a custom remote MCP connection.

## Current implementation

- Every product, audit, and interview card opens a focused guided workspace.
- An incomplete record opens at its first unanswered question.
- Consultants may skip a question, revisit any question, edit confirmed responses, and review the complete working record.
- Product identity, owner, purpose, and status remain directly editable.
- Audit and interview workflow statuses remain directly editable.
- The conversation brief identifies the engagement, record type, record ID, next guided question, confirmation rule, and sanitized-data boundary.
- Guided responses are rejected when they contain controlled-information indicators covered by the engagement guardrail.
- Product, audit, and interview question sets remain distinct typed workflows.
- The two Mission Product assessments preserve every authoritative section, prompt, checklist, rating, ranking, and matrix field from their source documents.
- Assessment responses remain evidence and are never automatically scored, diagnosed, or promoted into a finding.

## MCP tool contract

`lib/operational-ai/mcp-tools.ts` defines seven focused domain operations. The hosted server adds `list_available_engagements` so a newly connected assistant can discover only the organizations and engagements already assigned to the signed-in consultant:

1. `list_available_engagements`
2. `list_engagement_records`
3. `get_guided_record`
4. `save_guided_response`
5. `list_assessment_instruments`
6. `get_assessment_instrument`
7. `start_assessment_administration`
8. `save_assessment_response`

The write operation requires `confirmed: true`. The contract never authorizes the model to infer an answer, silently summarize a response, promote evidence into diagnosis, or bypass the tenant/role boundary.

This follows OpenAI's guidance to build focused tools around user goals, provide explicit schemas and descriptions, mark read/write behavior accurately, and require confirmation for consequential writes:

- [Build an MCP server](https://developers.openai.com/plugins/build/mcp-server)
- [Define tools](https://developers.openai.com/plugins/plan/tools)

## Hosted authorization boundary

The remote MCP is served at `/mcp` and publishes OAuth 2.1 authorization-server and protected-resource discovery metadata. Supabase Auth is the authorization server and the Consulting OS is the protected resource.

- Users never copy an API key or bearer token.
- A connection must complete authorization-code flow with PKCE and explicit Consulting OS consent.
- Ordinary web-session tokens are rejected; the MCP requires an OAuth-issued token containing a client ID.
- The token is resolved to the existing Consultant identity and every repository call continues through row-level security.
- Organization and engagement assignment are checked again for every tool call.
- Writes require `confirmed: true`; the model may not infer or silently rewrite an answer.
- MCP audit rows contain the client ID, tool name, organization, engagement, time, and success state only. Prompts, arguments, answers, and results are not copied into the audit table.
- Connections may be reviewed and revoked from Consultant Settings.

Production activation and provider verification are governed by `OAUTH-MCP-OPERATIONS.md`.

## Login boundary

The public landing page remains the role-selection surface. A role-specific Consulting OS entry now proceeds directly into that role's authentication/session path and does not ask the user to choose consultant versus client a second time.
