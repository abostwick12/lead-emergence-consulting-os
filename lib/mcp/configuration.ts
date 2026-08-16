import 'server-only';

import { resolveTrustedOrigin } from '@/lib/http/origin';
import { getSupabasePublicConfig, isFixtureMode, requireSupabasePublicConfig } from '@/lib/supabase/config';

export const MCP_PATH = '/mcp';
export const MCP_OAUTH_SCOPES = ['openid', 'email', 'profile'] as const;

export function mcpResourceUrl(requestOrigin?: string) {
  return new URL(MCP_PATH, resolveTrustedOrigin(requestOrigin));
}

export function mcpResourceMetadataUrl(requestOrigin?: string) {
  return new URL('/.well-known/oauth-protected-resource/mcp', resolveTrustedOrigin(requestOrigin));
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

export function protectedResourceMetadata(requestOrigin?: string) {
  return {
    resource: mcpResourceUrl(requestOrigin).toString(),
    resource_name: 'Lead Emergence Consulting OS',
    authorization_servers: [supabaseAuthIssuer()],
    bearer_methods_supported: ['header'],
    scopes_supported: [...MCP_OAUTH_SCOPES],
    resource_documentation: new URL('/consultant/settings', resolveTrustedOrigin(requestOrigin)).toString(),
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
