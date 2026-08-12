import type { StartEngagementInput } from './types';

export function validateStartEngagement(value: unknown): StartEngagementInput {
  if (!value || typeof value !== 'object') throw new Error('Client setup details are required.');
  const input = value as Record<string, unknown>;
  const required = (key: string) => {
    const field = input[key];
    if (typeof field !== 'string' || !field.trim()) throw new Error(`${key} is required.`);
    return field.trim();
  };
  const startsOn = required('startsOn');
  const endsOn = typeof input.endsOn === 'string' ? input.endsOn.trim() : '';
  if (Number.isNaN(Date.parse(startsOn))) throw new Error('The engagement start date is invalid.');
  if (endsOn && Number.isNaN(Date.parse(endsOn))) throw new Error('The engagement end date is invalid.');
  if (endsOn && endsOn < startsOn) throw new Error('The engagement end date cannot precede its start date.');
  return { organizationName: required('organizationName'), engagementName: required('engagementName'), startsOn, endsOn: endsOn || undefined };
}
