import { describe, expect, it } from 'vitest';
import { capabilityGap, validateAlignmentMutation } from './workflow';

describe('alignment and capability workflow', () => {
  it('compares required capability with evidence-based current level', () => {
    expect(capabilityGap('RELIABLE', 'DEVELOPING')).toBe(1);
    expect(capabilityGap('FOUNDATIONAL', 'RELIABLE')).toBe(0);
  });
  it('accepts bounded practice and activity changes', () => {
    expect(validateAlignmentMutation({ action: 'ADD_PRACTICE', pathwayId: 'p1', practice: 'Reviewed a live exception' }).action).toBe('ADD_PRACTICE');
    expect(validateAlignmentMutation({ action: 'UPDATE_ACTIVITY', pathwayId: 'p1', activityId: 'a1', status: 'COMPLETED' })).toMatchObject({ action: 'UPDATE_ACTIVITY', status: 'COMPLETED' });
  });
  it('rejects unsupported or empty updates', () => {
    expect(() => validateAlignmentMutation({ action: 'ADD_PRACTICE', pathwayId: 'p1', practice: '' })).toThrow('practice is required');
    expect(() => validateAlignmentMutation({ action: 'PROMOTE_MATURITY', pathwayId: 'p1' })).toThrow('not supported');
  });
});
