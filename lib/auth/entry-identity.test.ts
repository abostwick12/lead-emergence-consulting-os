import { describe, expect, it } from 'vitest';
import type { User } from '@supabase/supabase-js';
import { entrySsoCallbackPath, entrySsoModeCookieName, entrySsoModeFromCallback, extractEntryProviderIdentity, isEntrySsoMode, requireEntryProviderIdentifier } from './entry-identity';

const provider = 'custom:lead-emergence-entry-dev';
const canonicalUserId = '21000000-0000-4000-8000-000000000001';
const providerIdentityId = '22000000-0000-4000-8000-000000000001';

function user(overrides: Record<string, unknown> = {}) {
  return {
    id: '23000000-0000-4000-8000-000000000001',
    app_metadata: {},
    user_metadata: {},
    aud: 'authenticated',
    created_at: new Date().toISOString(),
    identities: [{
      id: canonicalUserId,
      user_id: '23000000-0000-4000-8000-000000000001',
      identity_id: providerIdentityId,
      provider,
      identity_data: { sub: canonicalUserId, email: 'not-used-as-proof@example.test', name: 'Synthetic Leader' },
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      last_sign_in_at: new Date().toISOString(),
      ...overrides,
    }],
  } as unknown as User;
}

describe('Entry provider identity contract', () => {
  it('uses the verified provider subject rather than email as the canonical identity', () => {
    const identity = extractEntryProviderIdentity(user(), provider);
    expect(identity.canonicalUserId).toBe(canonicalUserId);
    expect(identity.providerIdentityId).toBe(providerIdentityId);
    expect(identity).not.toHaveProperty('email');
  });

  it('fails closed for a missing provider, malformed subject, or subject mismatch', () => {
    expect(() => extractEntryProviderIdentity(user(), 'custom:other')).toThrow();
    expect(() => extractEntryProviderIdentity(user({ identity_data: { sub: 'not-a-uuid' } }), provider)).toThrow();
    expect(() => extractEntryProviderIdentity(user({ id: '24000000-0000-4000-8000-000000000001' }), provider)).toThrow();
  });

  it('requires an explicit custom provider identifier and recognized flow mode', () => {
    expect(requireEntryProviderIdentifier(provider)).toBe(provider);
    expect(() => requireEntryProviderIdentifier('google')).toThrow();
    expect(isEntrySsoMode('sign_in')).toBe(true);
    expect(isEntrySsoMode('link_existing')).toBe(true);
    expect(isEntrySsoMode('forged')).toBe(false);
  });

  it('binds each callback path and marker cookie to one recognized SSO mode', () => {
    expect(entrySsoCallbackPath('sign_in')).toBe('/auth/callback/sign-in');
    expect(entrySsoModeCookieName('link_existing')).toBe('le_entry_sso_mode_link-existing');
    expect(entrySsoModeFromCallback('sign-in')).toBe('sign_in');
    expect(entrySsoModeFromCallback('../shared')).toBeNull();
  });
});
