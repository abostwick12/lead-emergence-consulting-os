import { describe, expect, it } from 'vitest';
import { isAppError } from '@/lib/errors';
import { assertSucceeded, unwrap } from './errors';

describe('supabase result helpers', () => {
  it('returns rows when the query succeeded', () => {
    expect(unwrap('scope', { data: [{ id: 'a' }], error: null })).toEqual([{ id: 'a' }]);
  });

  it('never reports a failed query as empty data', () => {
    expect(() => unwrap('portal.dashboard', { data: null, error: { message: 'timeout' } })).toThrowError();
    try {
      unwrap('portal.dashboard', { data: null, error: { message: 'timeout' } });
    } catch (error) {
      expect(isAppError(error) && error.kind).toBe('DATA_ACCESS');
      expect(isAppError(error) && error.scope).toBe('portal.dashboard');
    }
  });

  it('fails when any result in a batch carries an error', () => {
    expect(() => assertSucceeded('scope', { error: null }, { error: null })).not.toThrow();
    expect(() => assertSucceeded('scope', { error: null }, { error: { message: 'denied' } })).toThrowError();
  });
});
