import { afterEach, describe, expect, it, vi } from 'vitest';
import { resolveTrustedOrigin } from './origin';

afterEach(() => vi.unstubAllEnvs());

describe('resolveTrustedOrigin', () => {
  it('uses the configured application origin instead of a request Host header', () => {
    vi.stubEnv('NODE_ENV', 'production');
    vi.stubEnv('APP_ORIGIN', 'https://consulting.leademergence.com/path');
    expect(resolveTrustedOrigin('https://attacker.example')).toBe('https://consulting.leademergence.com');
  });

  it('requires an HTTPS application origin in production', () => {
    vi.stubEnv('NODE_ENV', 'production');
    vi.stubEnv('APP_ORIGIN', 'http://consulting.leademergence.com');
    expect(() => resolveTrustedOrigin()).toThrow(/application origin is invalid/i);
  });

  it('allows only loopback request origins as a development fallback', () => {
    vi.stubEnv('NODE_ENV', 'development');
    vi.stubEnv('APP_ORIGIN', '');
    expect(resolveTrustedOrigin('http://localhost:3200')).toBe('http://localhost:3200');
    expect(() => resolveTrustedOrigin('https://attacker.example')).toThrow(/not configured/i);
  });
});
