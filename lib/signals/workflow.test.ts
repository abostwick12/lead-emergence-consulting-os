import { describe, expect, it } from 'vitest';
import { assertDescriptiveLanguage, indicatorsAreCompatible, validateSignalsMutation } from './workflow';

describe('SEE AGAIN Signals workflow', () => {
  it('keeps Signal language descriptive rather than diagnostic', () => {
    expect(assertDescriptiveLanguage('Escalation frequency increased in the last four weeks.')).toContain('increased');
    expect(() => assertDescriptiveLanguage('Drift detected in the authority model.')).toThrow('without diagnosing');
    expect(() => assertDescriptiveLanguage('This change was caused by coaching.')).toThrow('without diagnosing');
  });

  it('compares only compatible indicator definitions and units', () => {
    const base = { logicalId: 'latency', definition: 'Median routine decision latency', direction: 'LOWER_IS_BETTER', unit: 'days' };
    expect(indicatorsAreCompatible(base, { ...base, unit: 'DAYS' })).toBe(true);
    expect(indicatorsAreCompatible(base, { ...base, definition: 'Mean latency' })).toBe(false);
    expect(indicatorsAreCompatible(base, { ...base, unit: 'hours' })).toBe(false);
  });

  it('requires explicit human re-entry context', () => {
    expect(validateSignalsMutation({ action: 'REENTER_SIGNAL', signalId: 'signal-1', observationStatement: 'Exceptions now cluster in two workflows.', context: 'Renewed inquiry' })).toMatchObject({ action: 'REENTER_SIGNAL' });
    expect(() => validateSignalsMutation({ action: 'REENTER_SIGNAL', signalId: 'signal-1', observationStatement: '', context: 'Renewed inquiry' })).toThrow('observationStatement is required');
  });

  it('keeps the Signal type vocabulary controlled', () => {
    expect(() => validateSignalsMutation({ action: 'ADD_SIGNAL', statement: 'A change was reported.', kind: 'DRIFT', context: 'Weekly review', evidenceId: 'evidence-1' })).toThrow('invalid');
  });
});
