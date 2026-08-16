import { protectedResourceMetadata, supabaseAuthIssuer, supabaseAuthorizationServerMetadataUrl } from './configuration';
import { getSupabasePublicConfig, isFixtureMode } from '@/lib/supabase/config';

const metadataHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Cache-Control': 'public, max-age=300',
  'Content-Type': 'application/json',
};

export function protectedResourceResponse(request: Request) {
  if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: { ...metadataHeaders, Allow: 'GET, OPTIONS' } });
  if (request.method !== 'GET') return new Response('Method not allowed.', { status: 405, headers: { ...metadataHeaders, Allow: 'GET, OPTIONS' } });
  return Response.json(protectedResourceMetadata(new URL(request.url).origin), { headers: metadataHeaders });
}

export async function authorizationServerResponse(request: Request) {
  if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: { ...metadataHeaders, Allow: 'GET, OPTIONS' } });
  if (request.method !== 'GET') return new Response('Method not allowed.', { status: 405, headers: { ...metadataHeaders, Allow: 'GET, OPTIONS' } });
  if (isFixtureMode() && !getSupabasePublicConfig()) {
    const issuer = supabaseAuthIssuer();
    return Response.json({
      issuer,
      authorization_endpoint: `${issuer}/oauth/authorize`,
      token_endpoint: `${issuer}/oauth/token`,
      registration_endpoint: `${issuer}/oauth/register`,
      response_types_supported: ['code'],
      grant_types_supported: ['authorization_code', 'refresh_token'],
      code_challenge_methods_supported: ['S256'],
      token_endpoint_auth_methods_supported: ['none', 'client_secret_basic', 'client_secret_post'],
      scopes_supported: ['openid', 'email', 'profile'],
    }, { headers: metadataHeaders });
  }
  const upstream = await fetch(supabaseAuthorizationServerMetadataUrl(), { headers: { Accept: 'application/json' }, cache: 'no-store' });
  const body = await upstream.text();
  return new Response(body, { status: upstream.status, headers: metadataHeaders });
}
