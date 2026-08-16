import { afterEach, describe, expect, it, vi } from 'vitest';
import { SupabaseMcpTokenVerifier } from './auth';

describe('SupabaseMcpTokenVerifier', () => {
  afterEach(() => vi.unstubAllEnvs());

  it('accepts only the explicit local OAuth fixture token in fixture mode', async () => {
    vi.stubEnv('E2E_MOCK_AUTH', 'true');
    vi.stubEnv('NODE_ENV', 'test');
    const verifier = new SupabaseMcpTokenVerifier('http://localhost:3200');
    const auth = await verifier.verifyAccessToken('fixture-consultant-oauth-token');
    expect(auth.clientId).toBe('fixture-mcp-client');
    expect(auth.resource?.toString()).toBe('http://localhost:3200/mcp');
    await expect(verifier.verifyAccessToken('ordinary-browser-token')).rejects.toThrow();
  });
});
