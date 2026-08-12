import type { AlignmentMutation, CapabilityLevel } from './types';

export const capabilityLevels: CapabilityLevel[] = ['NOT_DEMONSTRATED', 'FOUNDATIONAL', 'DEVELOPING', 'RELIABLE', 'TRANSFERABLE'];

export function capabilityGap(required: CapabilityLevel, current: CapabilityLevel) {
  return Math.max(0, capabilityLevels.indexOf(required) - capabilityLevels.indexOf(current));
}

export function validateAlignmentMutation(value: unknown): AlignmentMutation {
  if (!value || typeof value !== 'object') throw new Error('An alignment action is required.');
  const input = value as Record<string, unknown>;
  const required = (key: string) => {
    const field = input[key];
    if (typeof field !== 'string' || !field.trim()) throw new Error(`${key} is required.`);
    return field.trim();
  };
  if (input.action === 'ADD_PRACTICE') return {
    action: input.action,
    pathwayId: required('pathwayId'),
    practice: required('practice'),
    conditions: required('conditions'),
    repetitionTarget: required('repetitionTarget'),
    feedbackMethod: required('feedbackMethod'),
  };
  if (input.action === 'UPDATE_ACTIVITY') {
    const status = required('status');
    if (status !== 'ACTIVE' && status !== 'COMPLETED') throw new Error('Activity status is invalid.');
    return { action: input.action, pathwayId: required('pathwayId'), activityId: required('activityId'), status };
  }
  throw new Error('The alignment action is not supported.');
}
