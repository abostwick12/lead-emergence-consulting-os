import 'server-only';

import { resolveTrustedOrigin } from '@/lib/http/origin';
import { getSupabasePublicConfig, isFixtureMode, requireSupabasePublicConfig } from '@/lib/supabase/config';

export const MCP_PATH = '/mcp';
export const CLIENT_MCP_PATH = '/mcp/client';
export const MCP_OAUTH_SCOPES = ['openid', 'email', 'profile'] as const;

export function mcpResourceUrl(requestOrigin?: string, path = MCP_PATH) {
  return new URL(path, resolveTrustedOrigin(requestOrigin));
}

export function mcpResourceMetadataUrl(requestOrigin?: string, path = MCP_PATH) {
  return new URL(`/.well-known/oauth-protected-resource${path}`, resolveTrustedOrigin(requestOrigin));
}

export function supabaseAuthIssuer() {
  if (isFixtureMode() && !getSupabasePublicConfig()) return 'https://fixture-auth.leademergence.invalid/auth/v1';
  return new URL('/auth/v1', `${requireSupabasePublicConfig().url}/`).toString().replace(/\/$/, '');
}

export function supabaseAuthorizationServerMetadataUrl() {
  if (isFixtureMode() && !getSupabasePublicConfig()) return new URL('https://fixture-auth.leademergence.invalid/.well-known/oauth-authorization-server/auth/v1');
  const { url } = requireSupabasePublicConfig();
  return new URL('/.well-known/oauth-authorization-server/auth/v1', `${url}/`);
}

export function protectedResourceMetadata(requestOrigin?: string, path = MCP_PATH) {
  return {
    resource: mcpResourceUrl(requestOrigin, path).toString(),
    resource_name: path === CLIENT_MCP_PATH ? 'Lead Emergence Client Workspace' : 'Lead Emergence Consulting OS',
    authorization_servers: [supabaseAuthIssuer()],
    bearer_methods_supported: ['header'],
    scopes_supported: [...MCP_OAUTH_SCOPES],
    resource_documentation: new URL(path === CLIENT_MCP_PATH ? '/client/settings' : '/consultant/settings', resolveTrustedOrigin(requestOrigin)).toString(),
  };
}

export async function mcpOAuthReadiness() {
  if (isFixtureMode()) return { ready: true, label: 'Local review mode' };
  try {
    const response = await fetch(supabaseAuthorizationServerMetadataUrl(), { headers: { Accept: 'application/json' }, cache: 'no-store' });
    if (!response.ok) return { ready: false, label: 'Activation pending' };
    const metadata = await response.json() as { registration_endpoint?: unknown; code_challenge_methods_supported?: unknown };
    const supportsRegistration = typeof metadata.registration_endpoint === 'string';
    const supportsPkce = Array.isArray(metadata.code_challenge_methods_supported) && metadata.code_challenge_methods_supported.includes('S256');
    return { ready: supportsRegistration && supportsPkce, label: supportsRegistration && supportsPkce ? 'Ready to connect' : 'Activation pending' };
  } catch {
    return { ready: false, label: 'Activation pending' };
  }
}
