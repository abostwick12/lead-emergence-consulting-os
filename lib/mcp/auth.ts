import 'server-only';

import { OAuthError, OAuthErrorCode, type AuthInfo, type OAuthTokenVerifier } from '@modelcontextprotocol/server';
import { createClient } from '@supabase/supabase-js';
import { isFixtureMode, requireSupabasePublicConfig } from '@/lib/supabase/config';
import { mcpResourceUrl, supabaseAuthIssuer } from './configuration';

type JwtClaims = Record<string, unknown> & {
  sub?: string;
  exp?: number;
  iss?: string;
  client_id?: string;
  scope?: string;
  scopes?: string[];
  resource?: string;
};

export class SupabaseMcpTokenVerifier implements OAuthTokenVerifier {
  constructor(private readonly requestOrigin?: string) {}

  async verifyAccessToken(token: string): Promise<AuthInfo> {
    if (isFixtureMode() && token === 'fixture-consultant-oauth-token') {
      return {
        token,
        clientId: 'fixture-mcp-client',
        scopes: ['openid', 'email', 'profile'],
        expiresAt: Math.floor(Date.now() / 1000) + 3600,
        resource: mcpResourceUrl(this.requestOrigin),
        extra: { userId: 'fixture-consultant-user' },
      };
    }

    const { url, key } = requireSupabasePublicConfig();
    const supabase = createClient(url, key, {
      auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
    });
    const { data, error } = await supabase.auth.getUser(token);
    if (error || !data.user) throw invalidToken('The access token is invalid or expired.');

    const claims = decodeJwtClaims(token);
    if (claims.sub !== data.user.id || claims.iss !== supabaseAuthIssuer()) {
      throw invalidToken('The access token issuer or subject is invalid.');
    }
    if (typeof claims.exp !== 'number' || claims.exp <= Math.floor(Date.now() / 1000)) {
      throw invalidToken('The access token is expired.');
    }
    if (typeof claims.client_id !== 'string' || !claims.client_id) {
      throw invalidToken('An OAuth-issued access token is required.');
    }

    const expectedResource = mcpResourceUrl(this.requestOrigin);
    if (typeof claims.resource === 'string' && stripHash(claims.resource) !== stripHash(expectedResource.toString())) {
      throw invalidToken('The access token was issued for a different protected resource.');
    }

    return {
      token,
      clientId: claims.client_id,
      scopes: tokenScopes(claims),
      expiresAt: claims.exp,
      resource: expectedResource,
      extra: { userId: data.user.id },
    };
  }
}

function decodeJwtClaims(token: string): JwtClaims {
  try {
    const payload = token.split('.')[1];
    if (!payload) throw new Error('missing payload');
    return JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')) as JwtClaims;
  } catch {
    throw invalidToken('The access token is malformed.');
  }
}

function tokenScopes(claims: JwtClaims) {
  if (Array.isArray(claims.scopes)) return claims.scopes.filter((scope): scope is string => typeof scope === 'string');
  if (typeof claims.scope === 'string') return claims.scope.split(/\s+/).filter(Boolean);
  return [];
}

function stripHash(value: string) {
  const url = new URL(value);
  url.hash = '';
  return url.toString();
}

function invalidToken(message: string) {
  return new OAuthError(OAuthErrorCode.InvalidToken, message);
}
