import { createMcpHandler, getOAuthProtectedResourceMetadataUrl, requireBearerAuth } from '@modelcontextprotocol/server';
import { SupabaseMcpTokenVerifier } from '@/lib/mcp/auth';
import { mcpResourceUrl } from '@/lib/mcp/configuration';
import { createLeadEmergenceMcpServer } from '@/lib/mcp/server';
import { runWithSupabaseAccessToken } from '@/lib/supabase/token-context';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

const handler = createMcpHandler(({ authInfo }) => {
  if (!authInfo) throw new Error('Authenticated MCP context is required.');
  return createLeadEmergenceMcpServer(authInfo);
}, { legacy: 'stateless', responseMode: 'json', onerror: (error) => console.error('[mcp.protocol]', error) });

async function serve(request: Request) {
  const requestOrigin = new URL(request.url).origin;
  const resourceUrl = mcpResourceUrl(requestOrigin);
  if (new URL(request.url).origin !== resourceUrl.origin) {
    return Response.json({ error: 'invalid_request', error_description: 'The MCP endpoint must be accessed through its canonical origin.' }, { status: 421 });
  }
  const resourceMetadataUrl = getOAuthProtectedResourceMetadataUrl(resourceUrl);
  const gate = requireBearerAuth({
    verifier: new SupabaseMcpTokenVerifier(requestOrigin),
    resourceMetadataUrl,
  });
  const authInfo = await gate(request);
  if (authInfo instanceof Response) return authInfo;
  return runWithSupabaseAccessToken(authInfo.token, () => handler.fetch(request, { authInfo }));
}

export const POST = serve;
export const GET = serve;
export const DELETE = serve;

export function OPTIONS() {
  return new Response(null, {
    status: 204,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, GET, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Authorization, Content-Type, MCP-Protocol-Version, MCP-Session-Id, Last-Event-ID',
      'Access-Control-Expose-Headers': 'MCP-Protocol-Version, MCP-Session-Id, WWW-Authenticate',
    },
  });
}
