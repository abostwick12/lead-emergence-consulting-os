import { describe, expect, it } from 'vitest';
import { nextOutcomeAction, outcomeDispositions, validateOutcomesMutation } from './workflow';
import type { OutcomesNewRealityData } from './types';

const base = { outcome: undefined, evaluation: undefined, learning: undefined, baseline: undefined } as unknown as OutcomesNewRealityData;

describe('outcomes and New Reality workflow', () => {
  it('enforces the canonical production order', () => {
    expect(nextOutcomeAction(base)).toBe('RECORD_OUTCOME');
    expect(nextOutcomeAction({ ...base, outcome: {} } as OutcomesNewRealityData)).toBe('EVALUATE_VALUE');
    expect(nextOutcomeAction({ ...base, outcome: {}, evaluation: {} } as OutcomesNewRealityData)).toBe('VALIDATE_LEARNING');
    expect(nextOutcomeAction({ ...base, outcome: {}, evaluation: {}, learning: { statement: 'x', reviewState: 'VALIDATED', disposition: 'IMPROVE' } } as OutcomesNewRealityData)).toBe('ESTABLISH_BASELINE');
  });
  it('keeps the five human outcome decisions controlled', () => {
    expect(outcomeDispositions).toEqual(['SUSTAIN', 'IMPROVE', 'SCALE', 'STOP', 'REINVENT']);
    expect(validateOutcomesMutation({ action: 'VALIDATE_LEARNING', statement: 'Keep boundaries explicit.', disposition: 'SCALE' })).toMatchObject({ disposition: 'SCALE' });
    expect(() => validateOutcomesMutation({ action: 'VALIDATE_LEARNING', statement: 'x', disposition: 'AUTOMATE' })).toThrow('invalid');
  });
  it('requires explicit actual-state and difference records before baseline', () => {
    expect(() => validateOutcomesMutation({ action: 'ESTABLISH_BASELINE', profileName: 'Reality', actualState: '', difference: 'Changed' })).toThrow('actualState is required');
  });
});
