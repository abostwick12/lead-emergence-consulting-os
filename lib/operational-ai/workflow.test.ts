import { describe, expect, it } from 'vitest';
import { validateOperationalMutation } from './workflow';

describe('operational product AI boundary', () => {
  it('accepts sanitized consulting evidence', () => {
    expect(validateOperationalMutation({ action: 'ADD_EVIDENCE', title: 'Review practice', sourceType: 'OBSERVATION', observation: 'A named human reviewer checks the product.', sourceLocator: 'Sanitized walkthrough', visibility: 'CONSULTANT_PRIVATE' })).toMatchObject({ action: 'ADD_EVIDENCE', title: 'Review practice' });
  });

  it('rejects controlled or operational detail indicators', () => {
    expect(() => validateOperationalMutation({ action: 'ADD_EVIDENCE', title: 'Classified mission timeline', sourceType: 'OBSERVATION', observation: 'Unsafe', sourceLocator: 'Unsafe', visibility: 'CONSULTANT_PRIVATE' })).toThrow(/sanitized consulting content only/i);
  });
});
