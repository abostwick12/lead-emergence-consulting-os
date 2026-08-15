import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import {
  getSupabasePublicConfig,
  isFixtureMode,
  requireSupabasePublicConfig,
  requireSupabaseSecretKey,
} from './config';

const keys = [
  'E2E_MOCK_AUTH',
  'NEXT_PUBLIC_SUPABASE_URL',
  'NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY',
  'SUPABASE_SECRET_KEY',
] as const;

describe('supabase configuration', () => {
  beforeEach(() => {
    for (const key of keys) vi.stubEnv(key, undefined);
  });

  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it('enables fixture mode only outside production', () => {
    expect(isFixtureMode()).toBe(false);
    vi.stubEnv('E2E_MOCK_AUTH', 'true');
    vi.stubEnv('NODE_ENV', 'test');
    expect(isFixtureMode()).toBe(true);
    vi.stubEnv('NODE_ENV', 'production');
    expect(isFixtureMode()).toBe(false);
  });

  it('treats any value other than the exact opt-in string as disabled', () => {
    vi.stubEnv('E2E_MOCK_AUTH', 'TRUE');
    expect(isFixtureMode()).toBe(false);
  });

  it('returns the public configuration only when both values are present', () => {
    expect(getSupabasePublicConfig()).toBeNull();
    vi.stubEnv('NEXT_PUBLIC_SUPABASE_URL', 'https://project.supabase.co');
    expect(getSupabasePublicConfig()).toBeNull();
    vi.stubEnv('NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY', 'publishable-key');
    expect(getSupabasePublicConfig()).toEqual({ url: 'https://project.supabase.co', key: 'publishable-key' });
  });

  it('names both required public variables when configuration is missing', () => {
    expect(() => requireSupabasePublicConfig()).toThrow(
      'Supabase is not configured. Set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY.',
    );
    vi.stubEnv('NEXT_PUBLIC_SUPABASE_URL', 'https://project.supabase.co');
    vi.stubEnv('NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY', 'publishable-key');
    expect(requireSupabasePublicConfig().url).toBe('https://project.supabase.co');
  });

  it('requires a secret key for trusted server access without disclosing it in the error', () => {
    expect(() => requireSupabaseSecretKey()).toThrow('Supabase trusted server access is not configured.');
    vi.stubEnv('SUPABASE_SECRET_KEY', 'secret-key');
    expect(requireSupabaseSecretKey()).toBe('secret-key');
  });
});
