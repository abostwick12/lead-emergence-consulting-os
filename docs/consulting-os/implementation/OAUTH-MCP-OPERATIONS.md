# OAuth-Protected Remote MCP Operations

## Purpose

Consulting OS exposes two remote MCP endpoints for ChatGPT, Claude, Microsoft Copilot Studio, GitHub Copilot, and compatible hosts. The AI host owns the conversation; Lead Emergence owns authorization, engagement state, consulting records, and continuity. No user-managed API keys or separate MCP passwords are used.

The production endpoints are:

| Surface | Endpoint | Authorized user |
| --- | --- | --- |
| Consultant MCP | `https://consulting.leademergence.com/mcp` | Assigned Lead Emergence consultant |
| Client MCP | `https://consulting.leademergence.com/mcp/client` | Active client organization and engagement participant |

`APP_ORIGIN`, the Supabase Auth site URL, redirect allow-list entries, and provider setup must all use this same canonical origin. A generated Vercel deployment URL is for diagnostics only and must not be distributed as the normal MCP address.

## Client workspace continuity

The persistent unit is the Lead Emergence **Engagement**, not an MCP session, AI-host conversation, or vendor-native project. A client may start in one host and later reconnect from another host: `open_workspace` resolves the authenticated person, active organization membership, active engagement membership, explicitly assigned guided work, and confirmed responses again from Consulting OS.

The Client MCP does not create organizations, engagements, memberships, assessments, or native ChatGPT/Claude projects. It returns `selection_required` rather than selecting arbitrarily when multiple active engagements are available. Its initial tool surface is limited to opening a workspace, listing assigned engagements/work, reading an explicitly assigned audit or interview, and saving an explicitly confirmed response. It never exposes consultant-private records or consultant-only administration tools.

## Verified activation status — 2026-08-16

- `consulting.leademergence.com` is attached to the dedicated `lead-emergence-consulting-os` Vercel project.
- Production fixture mode is disabled; `/api/test-session` returns `404` on the public domain.
- The shared Supabase project advertises OAuth authorization, token, dynamic registration, refresh, revocation, and PKCE endpoints.
- The MCP persistence and audit migrations are applied, RLS is active, and Supabase security/performance advisors report no findings for the new objects.
- Live connection tests in the four external provider accounts remain the final release verification after the application deployment containing `/mcp` is live.

## Owner activation

In the shared Consulting/Ministry Supabase project:

1. Open **Authentication → OAuth Server**.
2. Enable the OAuth 2.1 server.
3. Set the authorization path to `/oauth/consent`.
4. Enable dynamic client registration.
5. Confirm the Auth site URL and redirect allow list contain the canonical Consulting OS HTTPS origin.

In the dedicated Consulting OS Vercel project:

1. Set `APP_ORIGIN` to the canonical Consulting OS HTTPS origin.
2. Keep the existing Supabase URL, publishable key, and server secret scoped to the Consulting project.
3. Confirm `E2E_MOCK_AUTH` is absent or `false` in production.
4. Deploy the commit that contains the MCP endpoint and database migration.

No OAuth client secret is stored in Vercel. Supported assistants register or discover their OAuth client through the authorization-server metadata.

## Consultant setup

1. Sign in to the Consultant portal.
2. Open **Settings → Connect your AI assistant**.
3. Copy the secure MCP server address.
4. Expand the card for ChatGPT, Claude, Microsoft Copilot, or GitHub Copilot and follow its three steps.
5. When Consulting OS opens, verify the assistant name and callback domain, then approve the connection.
6. Return to Settings to confirm the assistant appears under **Connected assistants**.

Disconnecting an assistant revokes its Supabase OAuth grant. The consultant can reconnect later through the same provider flow.

## Client setup

1. The consultant creates the client account invitation and engagement membership through Consulting OS.
2. The client signs in, then adds the Client MCP endpoint to a supported AI host.
3. The client completes the same OAuth consent flow.
4. The host calls `open_workspace` to resolve the authorized engagement and the next assigned consulting action.

Revoking organization membership, engagement membership, or the OAuth grant blocks later access. An MCP connection does not create client access or broaden it.

## Provider notes

| Provider | User entry | Expected flow |
|---|---|---|
| ChatGPT | Settings → Apps & Connectors → custom connector | Paste `/mcp`, connect, sign in, approve. Workspace policy may require an administrator to allow custom connectors. |
| Claude | Settings → Connectors → custom connector | Paste `/mcp`, connect, sign in, approve. Team or enterprise policy may require an administrator. |
| Microsoft Copilot | Copilot Studio agent → Tools → Model Context Protocol | Add the remote server and use dynamic OAuth discovery. Publishing an organizational agent remains governed by Microsoft tenant policy. |
| GitHub Copilot | VS Code or Visual Studio MCP settings | Add the generated remote HTTP server configuration, start it, choose Auth, sign in, approve. |

Provider menu labels change over time; the secure server address and OAuth discovery flow are the durable contract.

## Data and safety boundary

- Only sanitized, unclassified, non-CUI, non-operationally-sensitive information may be used.
- If restricted information is introduced, stop the workflow and validate hosting requirements before continuing.
- OAuth does not broaden access. Existing Consultant assignment or Client membership, organization boundary, engagement boundary, role checks, and database row-level security remain authoritative.
- Private coaching information cannot be promoted into organizational evidence by an AI tool.
- Assessment responses remain evidence, not diagnosis.
- The assistant may read only the focused records exposed by the MCP tools.
- Consequential writes require the user to confirm the exact response first.

## Release verification

Before declaring the MCP available:

1. `/.well-known/oauth-protected-resource/mcp` returns the Consulting MCP resource and Supabase authorization server.
2. `/.well-known/oauth-authorization-server` exposes authorization, token, registration, revocation, and PKCE metadata.
3. An unauthenticated `/mcp` request returns `401` with an RFC 9728 protected-resource challenge.
4. A normal Consulting web-session token is rejected because it has no OAuth client ID.
5. An OAuth token can initialize MCP and list tools.
6. A consultant can connect and revoke one test client.
7. Cross-organization, unassigned-engagement, and consultant-private retrieval attempts fail.
8. A confirmed guided response persists and can be read back through both MCP and the native workspace.
9. The audit row contains no prompt, arguments, response, or result content.
10. ChatGPT, Claude, Microsoft Copilot Studio, and GitHub Copilot each complete one live connection test, subject to the account's administrator policy.

## Operational limitation

Supabase OAuth Server is currently a beta capability. Its discovery, token validation, grant revocation, and dynamic registration must be regression-tested after Supabase Auth upgrades. Provider-specific connection screens are also external dependencies and should be checked during release verification.
