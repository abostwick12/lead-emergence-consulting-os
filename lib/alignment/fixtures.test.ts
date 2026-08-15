import { beforeEach, describe, expect, it } from 'vitest';
import { fixtureSession } from '../portal/fixtures';
import { fixtureAlignmentCapability, mutateFixtureAlignment, resetAlignmentFixtures } from './fixtures';

const consultant = () => fixtureSession('consultant')!;
const pathwayId = 'pathway-decision-judgment';

const practice = {
  action: 'ADD_PRACTICE' as const,
  pathwayId,
  practice: 'Rehearse escalation thresholds before committing',
  conditions: 'Live routine decisions under time pressure',
  repetitionTarget: 'Six decisions',
  feedbackMethod: 'Weekly exception review',
};

describe('alignment and capability fixture projections', () => {
  beforeEach(() => {
    resetAlignmentFixtures();
  });

  it('exposes the role architecture, workflow, and pathway for the session engagement', () => {
    const data = fixtureAlignmentCapability(consultant());
    expect(data.organizationId).toBe(consultant().organization.id);
    expect(data.roleArchitectures[0].boundaries.length).toBeGreaterThan(0);
    expect(data.workflows[0].steps.filter((step) => step.decisionPoint)).toHaveLength(2);
    expect(data.initiatives[0].status).toBe('ACTIVE');
    expect(data.capabilityPathways[0].requiredLevel).toBe('RELIABLE');
    expect(data.capabilityPathways[0].currentLevel).toBe('DEVELOPING');
  });

  it('records a practice against the capability pathway', () => {
    const pathway = mutateFixtureAlignment(consultant(), practice).capabilityPathways[0];
    expect(pathway.practices).toHaveLength(2);
    expect(pathway.practices[1]).toBe('Rehearse escalation thresholds before committing · practice 1');
  });

  it('completes and reopens a development activity', () => {
    const completed = mutateFixtureAlignment(consultant(), {
      action: 'UPDATE_ACTIVITY', pathwayId, activityId: 'activity-boundary-lab', status: 'COMPLETED',
    }).capabilityPathways[0].activities;
    expect(completed.find((activity) => activity.id === 'activity-boundary-lab')!.status).toBe('COMPLETED');

    const reopened = mutateFixtureAlignment(consultant(), {
      action: 'UPDATE_ACTIVITY', pathwayId, activityId: 'activity-boundary-lab', status: 'ACTIVE',
    }).capabilityPathways[0].activities;
    expect(reopened.find((activity) => activity.id === 'activity-boundary-lab')!.status).toBe('ACTIVE');
  });

  it('rejects an unknown pathway or activity', () => {
    expect(() => mutateFixtureAlignment(consultant(), { ...practice, pathwayId: 'pathway-missing' }))
      .toThrow('Capability pathway is not available.');
    expect(() => mutateFixtureAlignment(consultant(), {
      action: 'UPDATE_ACTIVITY', pathwayId, activityId: 'activity-missing', status: 'COMPLETED',
    })).toThrow('Development activity is not available.');
  });

  it('clears recorded practices and completions on reset', () => {
    mutateFixtureAlignment(consultant(), practice);
    mutateFixtureAlignment(consultant(), {
      action: 'UPDATE_ACTIVITY', pathwayId, activityId: 'activity-coached-decisions', status: 'COMPLETED',
    });
    resetAlignmentFixtures();
    const pathway = fixtureAlignmentCapability(consultant()).capabilityPathways[0];
    expect(pathway.practices).toHaveLength(1);
    expect(pathway.activities.every((activity) => activity.status === 'ACTIVE')).toBe(true);
  });
});
