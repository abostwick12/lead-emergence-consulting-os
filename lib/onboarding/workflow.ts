import { objectInput } from '../validation/input';
import type { StartEngagementInput } from './types';

export function validateStartEngagement(value: unknown): StartEngagementInput {
  const { raw: input, text, required } = objectInput(value, 'Client setup details are required.');
  const startsOn = required('startsOn');
  const endsOn = text('endsOn');
  if (Number.isNaN(Date.parse(startsOn))) throw new Error('The engagement start date is invalid.');
  if (endsOn && Number.isNaN(Date.parse(endsOn))) throw new Error('The engagement end date is invalid.');
  if (endsOn && endsOn < startsOn) throw new Error('The engagement end date cannot precede its start date.');
  const engagementType = input.engagementType === 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION' ? input.engagementType : 'ORGANIZATIONAL_TRANSFORMATION';
  const objective = text('objective');
  const scopeStatement = text('scopeStatement');
  if (engagementType === 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION' && (!objective || !scopeStatement)) throw new Error('Objective and scope are required for an Operational Product AI engagement.');
  return { organizationName: required('organizationName'), engagementName: required('engagementName'), startsOn, endsOn: endsOn || undefined, engagementType, objective: objective || undefined, scopeStatement: scopeStatement || undefined };
}
