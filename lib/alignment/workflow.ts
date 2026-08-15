import { objectInput } from '../validation/input';
import type { AlignmentMutation, CapabilityLevel } from './types';

export const capabilityLevels: CapabilityLevel[] = ['NOT_DEMONSTRATED', 'FOUNDATIONAL', 'DEVELOPING', 'RELIABLE', 'TRANSFERABLE'];

export function capabilityGap(required: CapabilityLevel, current: CapabilityLevel) {
  return Math.max(0, capabilityLevels.indexOf(required) - capabilityLevels.indexOf(current));
}

export function validateAlignmentMutation(value: unknown): AlignmentMutation {
  const { raw: input, required, oneOf } = objectInput(value, 'An alignment action is required.');
  if (input.action === 'ADD_PRACTICE') return {
    action: input.action,
    pathwayId: required('pathwayId'),
    practice: required('practice'),
    conditions: required('conditions'),
    repetitionTarget: required('repetitionTarget'),
    feedbackMethod: required('feedbackMethod'),
  };
  if (input.action === 'UPDATE_ACTIVITY') {
    const status = oneOf('status', ['ACTIVE', 'COMPLETED'] as const, 'Activity status is invalid.');
    return { action: input.action, pathwayId: required('pathwayId'), activityId: required('activityId'), status };
  }
  throw new Error('The alignment action is not supported.');
}
