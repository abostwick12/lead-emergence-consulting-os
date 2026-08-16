import { afterEach, describe, expect, it, vi } from 'vitest';
import { mcpResourceMetadataUrl, mcpResourceUrl, protectedResourceMetadata, supabaseAuthIssuer } from './configuration';

describe('MCP OAuth discovery configuration', () => {
  afterEach(() => vi.unstubAllEnvs());

  it('publishes a path-aware protected resource document in local review mode', () => {
    vi.stubEnv('E2E_MOCK_AUTH', 'true');
    vi.stubEnv('NODE_ENV', 'test');
    expect(mcpResourceUrl('http://localhost:3200').toString()).toBe('http://localhost:3200/mcp');
    expect(mcpResourceMetadataUrl('http://localhost:3200').toString()).toBe('http://localhost:3200/.well-known/oauth-protected-resource/mcp');
    expect(supabaseAuthIssuer()).toBe('https://fixture-auth.leademergence.invalid/auth/v1');
    expect(protectedResourceMetadata('http://localhost:3200')).toMatchObject({
      resource: 'http://localhost:3200/mcp',
      authorization_servers: ['https://fixture-auth.leademergence.invalid/auth/v1'],
      bearer_methods_supported: ['header'],
    });
  });
});
