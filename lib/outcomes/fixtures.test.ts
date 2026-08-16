import { beforeEach, describe, expect, it } from 'vitest';
import { fixtureSession } from '../portal/fixtures';
import { fixtureOutcomesNewReality, mutateFixtureOutcomes, resetOutcomeFixtures } from './fixtures';
import { nextOutcomeAction } from './workflow';

const consultant = () => fixtureSession('consultant')!;
const client = () => fixtureSession('client')!;

const recordOutcome = {
  action: 'RECORD_OUTCOME' as const,
  measuredValue: '3.4 days',
  statement: 'Routine decision latency fell to 3.4 days.',
  evidenceId: 'evidence-decision-sample',
  collectionContext: 'Ten routine decisions sampled in Aug 2026',
  limitations: 'Two measurement periods only.',
  periodStart: '2026-08-01',
  periodEnd: '2026-08-31',
};

const evaluateValue = {
  action: 'EVALUATE_VALUE' as const,
  harvest: 'Decisions resolve faster with no added rework.',
  soil: 'Boundary clarity and coaching support the change.',
  significance: 'Meaningful against the 3.0 day target.',
  alternativeExplanations: 'Seasonal volume may contribute.',
  limitations: 'Descriptive evidence only.',
};

const validateLearning = {
  action: 'VALIDATE_LEARNING' as const,
  statement: 'Bounded authority reduces latency where capability is present.',
  disposition: 'SCALE' as const,
  implications: 'Extend the boundary pattern to two more workflows.',
  contraryEvidence: 'One team still escalates ambiguous exceptions.',
  limitations: 'Single engagement.',
};

const establishBaseline = {
  action: 'ESTABLISH_BASELINE' as const,
  profileName: 'Distributed Authority · New Reality',
  actualState: 'Routine decisions are made at the closest capable level.',
  difference: 'Latency halved with escalation quality retained.',
};

describe('outcomes and new reality fixture projections', () => {
  beforeEach(() => {
    resetOutcomeFixtures();
  });

  it('starts with a goal, hypothesis, and baseline-only indicator history', () => {
    const data = fixtureOutcomesNewReality(consultant());
    expect(data.goal.baseline).toBe('6.2 days');
    expect(data.valueHypothesis.createdLabel).toBe('Established before implementation');
    expect(data.indicator.history).toHaveLength(1);
    expect(nextOutcomeAction(data)).toBe('RECORD_OUTCOME');
  });

  it('walks the full outcome sequence to a completed new-reality baseline', () => {
    const recorded = mutateFixtureOutcomes(consultant(), recordOutcome);
    expect(recorded.outcome?.measuredValue).toBe('3.4 days');
    expect(recorded.outcome?.causalStatus).toBe('No causal claim');
    expect(recorded.indicator.history).toHaveLength(2);

    const evaluated = mutateFixtureOutcomes(consultant(), evaluateValue);
    expect(evaluated.evaluation?.dimensions).toHaveLength(5);

    const learned = mutateFixtureOutcomes(consultant(), validateLearning);
    expect(learned.learning?.disposition).toBe('SCALE');
    expect(learned.learning?.reviewState).toBe('VALIDATED');

    const baselined = mutateFixtureOutcomes(consultant(), establishBaseline);
    expect(baselined.emergentProfile?.status).toBe('APPROVED');
    expect(baselined.baseline?.immutable).toBe(true);
    expect(nextOutcomeAction(baselined)).toBe('COMPLETE');
  });

  it('refuses to skip a preceding outcome step', () => {
    expect(() => mutateFixtureOutcomes(consultant(), evaluateValue)).toThrow('Complete the preceding outcome step first.');
  });

  it('limits outcome mutations to the assigned consultant', () => {
    expect(() => mutateFixtureOutcomes(client(), recordOutcome)).toThrow('Only the assigned consultant may advance this workflow.');
  });

  it('returns to the pre-measurement state on reset', () => {
    mutateFixtureOutcomes(consultant(), recordOutcome);
    resetOutcomeFixtures();
    expect(fixtureOutcomesNewReality(consultant()).outcome).toBeUndefined();
  });
});
