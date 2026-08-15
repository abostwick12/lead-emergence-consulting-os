import { describe, expect, it } from 'vitest';
import { validateOperationalMutation } from './workflow';

describe('operational product AI boundary', () => {
  it('accepts sanitized consulting evidence', () => {
    expect(validateOperationalMutation({ action: 'ADD_EVIDENCE', title: 'Review practice', sourceType: 'OBSERVATION', observation: 'A named human reviewer checks the product.', sourceLocator: 'Sanitized walkthrough', visibility: 'CONSULTANT_PRIVATE' })).toMatchObject({ action: 'ADD_EVIDENCE', title: 'Review practice' });
  });

  it('rejects controlled or operational detail indicators', () => {
    expect(() => validateOperationalMutation({ action: 'ADD_EVIDENCE', title: 'Classified mission timeline', sourceType: 'OBSERVATION', observation: 'Unsafe', sourceLocator: 'Unsafe', visibility: 'CONSULTANT_PRIVATE' })).toThrow(/sanitized consulting content only/i);
  });

  it('accepts a confirmed sanitized guided response', () => {
    expect(validateOperationalMutation({ action: 'SAVE_GUIDED_RESPONSE', recordKind: 'PRODUCT', recordId: 'product-1', questionId: 'product-purpose', answer: 'It gives reviewers a consistent, traceable preparation structure.' })).toMatchObject({ action: 'SAVE_GUIDED_RESPONSE', questionId: 'product-purpose' });
  });

  it('rejects a question from the wrong guided workflow', () => {
    expect(() => validateOperationalMutation({ action: 'SAVE_GUIDED_RESPONSE', recordKind: 'AUDIT', recordId: 'audit-1', questionId: 'product-purpose', answer: 'A response.' })).toThrow(/not valid/i);
  });
});
