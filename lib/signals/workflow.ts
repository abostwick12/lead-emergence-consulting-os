import { validationError } from '@/lib/errors';
import type { SignalKind, SignalsMutation, TrendDirection } from './types';

export const signalKinds: SignalKind[] = ['REPORTED_CHANGE', 'MEASURED_CHANGE', 'OPERATING_CHANGE', 'RELATIONSHIP_CHANGE', 'CONTEXT_CHANGE'];
export const trendDirections: TrendDirection[] = ['INCREASED', 'DECREASED', 'STABLE', 'MIXED'];

const diagnosticLanguage = /\b(drift detected|emergence detected|autonomous diagnosis|organizational diagnosis|caused by)\b/i;

export function assertDescriptiveLanguage(statement: string) {
  if (diagnosticLanguage.test(statement)) throw validationError('Signals must describe observed change without diagnosing drift, emergence, or cause.');
  return statement.trim();
}

export function indicatorsAreCompatible(
  baseline: { logicalId: string; definition: string; direction: string; unit: string },
  current: { logicalId: string; definition: string; direction: string; unit: string },
) {
  return baseline.logicalId === current.logicalId
    && baseline.definition === current.definition
    && baseline.direction === current.direction
    && baseline.unit.trim().toLowerCase() === current.unit.trim().toLowerCase();
}

export function validateSignalsMutation(value: unknown): SignalsMutation {
  if (!value || typeof value !== 'object') throw validationError('A Signals action is required.');
  const input = value as Record<string, unknown>;
  const required = (key: string) => {
    const field = input[key];
    if (typeof field !== 'string' || !field.trim()) throw validationError(`${key} is required.`);
    return field.trim();
  };
  if (input.action === 'ADD_SIGNAL') {
    const kind = required('kind') as SignalKind;
    if (!signalKinds.includes(kind)) throw validationError('The Signal type is invalid.');
    return { action: input.action, statement: assertDescriptiveLanguage(required('statement')), kind, context: required('context'), evidenceId: required('evidenceId') };
  }
  if (input.action === 'REENTER_SIGNAL') return {
    action: input.action,
    signalId: required('signalId'),
    observationStatement: assertDescriptiveLanguage(required('observationStatement')),
    context: required('context'),
  };
  if (input.action === 'COMPLETE_ASSUMPTION_REVIEW') return {
    action: input.action,
    scheduleId: required('scheduleId'),
    reviewNote: required('reviewNote'),
  };
  throw validationError('The Signals action is not supported.');
}
