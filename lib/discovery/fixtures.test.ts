import { beforeEach, describe, expect, it } from 'vitest';
import { fixtureSession } from '../portal/fixtures';
import { fixtureDiscoveryIntake, mutateFixtureDiscovery, resetDiscoveryFixtures } from './fixtures';

const consultant = () => fixtureSession('consultant')!;
const client = () => fixtureSession('client')!;

describe('discovery intake fixture projections', () => {
  beforeEach(() => {
    resetDiscoveryFixtures();
  });

  it('starts empty and carries the session organization, engagement, and role', () => {
    const data = fixtureDiscoveryIntake(client());
    expect(data.organizationId).toBe(client().organization.id);
    expect(data.engagementId).toBe(client().engagement.id);
    expect(data.role).toBe('client');
    expect([data.evidenceCount, data.interviewCount, data.assessmentCount]).toEqual([0, 0, 0]);
    expect(data.recentItems).toHaveLength(0);
  });

  it('counts captured evidence, interviews, and assessments by kind', () => {
    mutateFixtureDiscovery(consultant(), {
      action: 'CAPTURE_EVIDENCE', sourceType: 'UPLOADED_DOCUMENT', title: 'Approval workflow export',
      provenanceContext: 'Operations system export', content: 'Six of eight exceptions escalated.',
      relevanceNote: 'Shows routine escalation.', limitations: 'Single month.',
    });
    mutateFixtureDiscovery(consultant(), {
      action: 'RECORD_INTERVIEW', participantLabel: 'Team lead 04', guideName: 'Authority guide',
      question: 'Where do you wait for approval?', response: 'Routine client exceptions.', consentRecorded: true,
    });
    const data = mutateFixtureDiscovery(consultant(), {
      action: 'CREATE_ASSESSMENT', name: 'Decision Rhythm', dimension: 'Authority',
      prompt: 'Routine decisions are made close to the work.', audience: 'Team leads',
      opensAt: '2026-09-01T00:00:00.000Z', closesAt: '2026-09-12T22:00:00.000Z', confidentiality: 'CONFIDENTIAL',
    });

    expect([data.evidenceCount, data.interviewCount, data.assessmentCount]).toEqual([1, 1, 1]);
    expect(data.recentItems[0]).toEqual({
      id: 'assessment-3', kind: 'ASSESSMENT', title: 'Decision Rhythm', detail: 'Team leads · CONFIDENTIAL',
    });
  });

  it('lists the most recent items first and caps the recent list at eight', () => {
    for (let index = 0; index < 9; index += 1) {
      mutateFixtureDiscovery(consultant(), {
        action: 'CAPTURE_EVIDENCE', sourceType: 'UPLOADED_DOCUMENT', title: `Evidence ${index}`,
        provenanceContext: 'Export', content: 'Content', relevanceNote: `Note ${index}`, limitations: 'None.',
      });
    }
    const data = fixtureDiscoveryIntake(consultant());
    expect(data.evidenceCount).toBe(9);
    expect(data.recentItems).toHaveLength(8);
    expect(data.recentItems[0].title).toBe('Evidence 8');
  });

  it('clears captured items on reset', () => {
    mutateFixtureDiscovery(consultant(), {
      action: 'RECORD_INTERVIEW', participantLabel: 'Team lead 05', guideName: 'Authority guide',
      question: 'What slows a decision?', response: 'Unclear thresholds.', consentRecorded: true,
    });
    resetDiscoveryFixtures();
    expect(fixtureDiscoveryIntake(consultant()).interviewCount).toBe(0);
  });
});
