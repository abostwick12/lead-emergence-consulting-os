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
  if (!value || typeof value !== 'object') throw new Error('An outcomes action is required.');
  const input = value as Record<string, unknown>;
  const required = (key: string) => {
    const field = input[key];
    if (typeof field !== 'string' || !field.trim()) throw new Error(`${key} is required.`);
    return field.trim();
  };
  if (input.action === 'RECORD_OUTCOME') return { action: input.action, measuredValue: required('measuredValue'), statement: required('statement') };
  if (input.action === 'EVALUATE_VALUE') return { action: input.action, harvest: required('harvest'), soil: required('soil') };
  if (input.action === 'VALIDATE_LEARNING') {
    const disposition = required('disposition') as OutcomeDisposition;
    if (!outcomeDispositions.includes(disposition)) throw new Error('The outcome decision is invalid.');
    return { action: input.action, statement: required('statement'), disposition };
  }
  if (input.action === 'ESTABLISH_BASELINE') return { action: input.action, profileName: required('profileName'), actualState: required('actualState'), difference: required('difference') };
  throw new Error('The outcomes action is not supported.');
}
