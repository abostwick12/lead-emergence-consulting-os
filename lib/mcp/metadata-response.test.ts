import { afterEach, describe, expect, it, vi } from 'vitest';
import { authorizationServerResponse, protectedResourceResponse } from './metadata-response';

describe('MCP metadata responses', () => {
  afterEach(() => {
    vi.unstubAllEnvs();
    vi.unstubAllGlobals();
  });

  it('serves protected resource metadata with the required CORS and cache headers', async () => {
    vi.stubEnv('E2E_MOCK_AUTH', 'true');
    vi.stubEnv('NODE_ENV', 'test');

    const response = protectedResourceResponse(new Request('http://localhost:3200/.well-known/oauth-protected-resource/mcp'));

    expect(response.status).toBe(200);
    expect(response.headers.get('access-control-allow-origin')).toBe('*');
    expect(response.headers.get('cache-control')).toBe('public, max-age=300');
    await expect(response.json()).resolves.toMatchObject({
      resource: 'http://localhost:3200/mcp',
      authorization_servers: ['https://fixture-auth.leademergence.invalid/auth/v1'],
    });
  });

  it.each([
    ['OPTIONS', 204],
    ['POST', 405],
  ])('rejects unsupported protected resource metadata method %s', (method, status) => {
    const response = protectedResourceResponse(new Request('http://localhost/.well-known/oauth-protected-resource/mcp', { method }));

    expect(response.status).toBe(status);
    expect(response.headers.get('allow')).toBe('GET, OPTIONS');
  });

  it('serves fixture authorization server metadata without contacting an upstream server', async () => {
    vi.stubEnv('E2E_MOCK_AUTH', 'true');
    vi.stubEnv('NODE_ENV', 'test');
    const fetchMock = vi.fn();
    vi.stubGlobal('fetch', fetchMock);

    const response = await authorizationServerResponse(new Request('http://localhost/.well-known/oauth-authorization-server'));

    expect(response.status).toBe(200);
    expect(fetchMock).not.toHaveBeenCalled();
    await expect(response.json()).resolves.toMatchObject({
      issuer: 'https://fixture-auth.leademergence.invalid/auth/v1',
      registration_endpoint: 'https://fixture-auth.leademergence.invalid/auth/v1/oauth/register',
      code_challenge_methods_supported: ['S256'],
    });
  });

  it('proxies authorization server metadata using the upstream status and a safe response header set', async () => {
    vi.stubEnv('E2E_MOCK_AUTH', 'false');
    vi.stubEnv('NEXT_PUBLIC_SUPABASE_URL', 'https://project.supabase.co');
    vi.stubEnv('NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY', 'publishable-key');
    const fetchMock = vi.fn().mockResolvedValue(new Response('{"issuer":"https://project.supabase.co/auth/v1"}', { status: 503 }));
    vi.stubGlobal('fetch', fetchMock);

    const response = await authorizationServerResponse(new Request('http://localhost/.well-known/oauth-authorization-server'));

    expect(fetchMock).toHaveBeenCalledOnce();
    expect(String(fetchMock.mock.calls[0][0])).toBe('https://project.supabase.co/.well-known/oauth-authorization-server/auth/v1');
    expect(fetchMock.mock.calls[0][1]).toEqual({ headers: { Accept: 'application/json' }, cache: 'no-store' });
    expect(response.status).toBe(503);
    expect(response.headers.get('content-type')).toBe('application/json');
    await expect(response.text()).resolves.toBe('{"issuer":"https://project.supabase.co/auth/v1"}');
  });
});
