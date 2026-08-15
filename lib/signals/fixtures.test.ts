import { beforeEach, describe, expect, it } from 'vitest';
import { fixtureSession } from '../portal/fixtures';
import { fixtureSignalsWorkspace, mutateFixtureSignals, resetSignalsFixtures } from './fixtures';

const consultant = () => fixtureSession('consultant')!;
const client = () => fixtureSession('client')!;

describe('signals fixture workspace', () => {
  beforeEach(() => {
    resetSignalsFixtures();
  });

  it('hides leadership-restricted signals from the client projection', () => {
    const consultantSignals = fixtureSignalsWorkspace(consultant()).signals;
    const clientSignals = fixtureSignalsWorkspace(client()).signals;
    expect(consultantSignals.some((signal) => signal.visibility === 'LEADERSHIP_RESTRICTED')).toBe(true);
    expect(clientSignals.every((signal) => signal.visibility === 'ENGAGEMENT_SHARED')).toBe(true);
  });

  it('keeps the trend descriptive and the baseline immutable', () => {
    const workspace = fixtureSignalsWorkspace(consultant());
    expect(workspace.trends[0].direction).toBe('DECREASED');
    expect(workspace.trends[0].limitations).toContain('not proof of cause');
    expect(workspace.baseline?.immutable).toBe(true);
    expect(workspace.fixture).toBe(true);
  });

  it('adds a signal labelled with the selected evidence source', () => {
    const evidenceId = fixtureSignalsWorkspace(consultant()).evidenceSources[0].id;
    const added = mutateFixtureSignals(consultant(), {
      action: 'ADD_SIGNAL',
      statement: 'Exception volume dropped in the pilot workflow.',
      kind: 'OPERATING_CHANGE',
      context: 'Weekly operating review',
      evidenceId,
    }).signals.find((signal) => signal.statement === 'Exception volume dropped in the pilot workflow.')!;
    expect(added.sourceLabel).toBe('Workflow exception log · Aug 2026');
    expect(added.status).toBe('NEW');
  });

  it('falls back to a generic source label for an unknown evidence id', () => {
    const added = mutateFixtureSignals(consultant(), {
      action: 'ADD_SIGNAL',
      statement: 'Unsourced observation.',
      kind: 'REPORTED_CHANGE',
      context: 'Ad hoc conversation',
      evidenceId: 'evidence-missing',
    }).signals.find((signal) => signal.statement === 'Unsourced observation.')!;
    expect(added.sourceLabel).toBe('Selected evidence');
  });

  it('re-enters a signal once and marks it as re-entered', () => {
    const signalId = fixtureSignalsWorkspace(consultant()).signals[0].id;
    const workspace = mutateFixtureSignals(consultant(), {
      action: 'REENTER_SIGNAL', signalId, observationStatement: 'Escalations cluster around ambiguous thresholds.', context: 'Operating review',
    });
    expect(workspace.reentries).toHaveLength(1);
    expect(workspace.signals.find((signal) => signal.id === signalId)!.status).toBe('REENTERED');
    expect(() => mutateFixtureSignals(consultant(), {
      action: 'REENTER_SIGNAL', signalId, observationStatement: 'Duplicate re-entry.', context: 'Operating review',
    })).toThrow('This Signal has already re-entered inquiry.');
  });

  it('completes a due assumption review idempotently', () => {
    const first = mutateFixtureSignals(consultant(), {
      action: 'COMPLETE_ASSUMPTION_REVIEW', scheduleId: 'schedule-quality-assumption', reviewNote: 'Quality held steady.',
    });
    expect(first.assumptions.find((item) => item.id === 'schedule-quality-assumption')!.status).toBe('COMPLETED');
    const second = mutateFixtureSignals(consultant(), {
      action: 'COMPLETE_ASSUMPTION_REVIEW', scheduleId: 'schedule-quality-assumption', reviewNote: 'Repeated review.',
    });
    expect(second.assumptions.filter((item) => item.status === 'COMPLETED')).toHaveLength(1);
  });

  it('limits SEE AGAIN mutations to the consultant', () => {
    expect(() => mutateFixtureSignals(client(), {
      action: 'COMPLETE_ASSUMPTION_REVIEW', scheduleId: 'schedule-quality-assumption', reviewNote: 'Not permitted.',
    })).toThrow('Only the assigned consultant may advance SEE AGAIN.');
  });

  it('clears added signals and re-entries on reset', () => {
    mutateFixtureSignals(consultant(), {
      action: 'ADD_SIGNAL', statement: 'Temporary signal.', kind: 'OPERATING_CHANGE', context: 'Review', evidenceId: 'evidence-workflow-log',
    });
    resetSignalsFixtures();
    const workspace = fixtureSignalsWorkspace(consultant());
    expect(workspace.signals).toHaveLength(2);
    expect(workspace.reentries).toHaveLength(0);
  });
});
