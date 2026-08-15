import { validationError } from '@/lib/errors';
import type { StartEngagementInput } from './types';

export function validateStartEngagement(value: unknown): StartEngagementInput {
  if (!value || typeof value !== 'object') throw validationError('Client setup details are required.');
  const input = value as Record<string, unknown>;
  const required = (key: string) => {
    const field = input[key];
    if (typeof field !== 'string' || !field.trim()) throw validationError(`${key} is required.`);
    return field.trim();
  };
  const startsOn = required('startsOn');
  const endsOn = typeof input.endsOn === 'string' ? input.endsOn.trim() : '';
  if (Number.isNaN(Date.parse(startsOn))) throw validationError('The engagement start date is invalid.');
  if (endsOn && Number.isNaN(Date.parse(endsOn))) throw validationError('The engagement end date is invalid.');
  if (endsOn && endsOn < startsOn) throw validationError('The engagement end date cannot precede its start date.');
  const engagementType = input.engagementType === 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION' ? input.engagementType : 'ORGANIZATIONAL_TRANSFORMATION';
  const objective = typeof input.objective === 'string' ? input.objective.trim() : '';
  const scopeStatement = typeof input.scopeStatement === 'string' ? input.scopeStatement.trim() : '';
  if (engagementType === 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION' && (!objective || !scopeStatement)) throw validationError('Objective and scope are required for an Operational Product AI engagement.');
  return { organizationName: required('organizationName'), engagementName: required('engagementName'), startsOn, endsOn: endsOn || undefined, engagementType, objective: objective || undefined, scopeStatement: scopeStatement || undefined };
}
