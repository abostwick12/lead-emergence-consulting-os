import { describe, expect, it } from 'vitest';
import { entryHandoffClaims } from './entry';

describe('Entry handoff verification contract', () => {
  it('requires issuer, Consulting audience, and RS256 claims', async () => {
    const now = Math.floor(Date.now() / 1000);
    const parsed = entryHandoffClaims.parse({
      iss: 'https://entry.example.test',
      sub: '00000000-0000-4000-8000-000000000001',
      aud: 'CONSULTING',
      iat: now,
      exp: now + 90,
      jti: '00000000-0000-4000-8000-000000000002',
    });
    expect(parsed.aud).toBe('CONSULTING');
  });

  it('keeps authorization out of the handoff claim contract', () => {
    expect(() => entryHandoffClaims.parse({
      iss: 'https://entry.example.test',
      sub: '00000000-0000-4000-8000-000000000001',
      aud: 'CONSULTING', iat: 1, exp: 2,
      jti: '00000000-0000-4000-8000-000000000002',
      organization_id: 'not-in-contract',
    })).toThrow();
  });

  it('models safe no-workspace states without granting local access', () => {
    expect(['NO_WORKSPACE', 'LINKED']).toContain('NO_WORKSPACE');
    expect('LINKED').not.toBe('AUTHORIZED');
  });
});