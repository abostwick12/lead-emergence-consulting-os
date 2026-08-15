import { objectInput } from '../validation/input';
import type { OutcomeDisposition, OutcomesMutation, OutcomesNewRealityData } from './types';

export const outcomeDispositions: OutcomeDisposition[] = ['SUSTAIN', 'IMPROVE', 'SCALE', 'STOP', 'REINVENT'];

export function nextOutcomeAction(data: OutcomesNewRealityData) {
  if (!data.outcome) return 'RECORD_OUTCOME';
  if (!data.evaluation) return 'EVALUATE_VALUE';
  if (!data.learning?.disposition) return 'VALIDATE_LEARNING';
  if (!data.baseline) return 'ESTABLISH_BASELINE';
  return 'COMPLETE';
}

export function validateOutcomesMutation(value: unknown): OutcomesMutation {
  const { raw: input, required, oneOf } = objectInput(value, 'An outcomes action is required.');
  if (input.action === 'RECORD_OUTCOME') return { action: input.action, measuredValue: required('measuredValue'), statement: required('statement'), evidenceId: required('evidenceId'), collectionContext: required('collectionContext'), limitations: required('limitations'), periodStart: required('periodStart'), periodEnd: required('periodEnd') };
  if (input.action === 'EVALUATE_VALUE') return { action: input.action, harvest: required('harvest'), soil: required('soil'), significance: required('significance'), alternativeExplanations: required('alternativeExplanations'), limitations: required('limitations') };
  if (input.action === 'VALIDATE_LEARNING') {
    const disposition = oneOf('disposition', outcomeDispositions, 'The outcome decision is invalid.');
    return { action: input.action, statement: required('statement'), disposition, implications: required('implications'), contraryEvidence: required('contraryEvidence'), limitations: required('limitations') };
  }
  if (input.action === 'ESTABLISH_BASELINE') return { action: input.action, profileName: required('profileName'), actualState: required('actualState'), difference: required('difference') };
  throw new Error('The outcomes action is not supported.');
}
