import { beforeEach, describe, expect, it } from 'vitest';
import { fixtureSession } from '../portal/fixtures';
import { fixtureMinistryHandoff, resetHandoffFixtures, saveFixtureMinistryHandoff } from './fixtures';
import { defaultHandoffChecklist } from './workflow';

const consultant = () => fixtureSession('consultant')!;

describe('ministry handoff fixture projections', () => {
  beforeEach(() => {
    resetHandoffFixtures();
  });

  it('defaults to an unassessed draft seeded from the session organization', () => {
    const data = fixtureMinistryHandoff(consultant());
    expect(data.churchName).toBe(consultant().organization.name);
    expect(data.readiness).toBe('NOT_ASSESSED');
    expect(data.status).toBe('DRAFT');
    expect(data.checklist).toEqual(defaultHandoffChecklist);
  });

  it('keeps the product boundary explicit and read-only', () => {
    const data = fixtureMinistryHandoff(consultant());
    expect(data.ministryProductUrl).toBe('https://ministry.leademergence.com');
    expect(data.boundaryNote).toContain('does not write to the Ministry product database');
  });

  it('persists saved handoff details while preserving the boundary fields', () => {
    const saved = saveFixtureMinistryHandoff(consultant(), {
      churchName: 'Northstar Community Church',
      authorizedAdminName: 'Jordan Lee',
      authorizedAdminEmail: 'jordan@example.com',
      ministryAreasAndLeaders: 'Worship · Jordan Lee',
      priorities: 'Stabilize the weekly planning rhythm.',
      meetingAndPlanningRhythm: 'Weekly staff meeting; monthly planning.',
      eventsAndWorkflows: 'Sunday service workflow.',
      readiness: 'READY',
      status: 'READY_FOR_SETUP',
      checklist: defaultHandoffChecklist.map((item) => ({ ...item, complete: true })),
    });

    expect(saved.readiness).toBe('READY');
    expect(saved.checklist.every((item) => item.complete)).toBe(true);
    expect(saved.organizationId).toBe(consultant().organization.id);
    expect(saved.ministryProductUrl).toBe('https://ministry.leademergence.com');
    expect(fixtureMinistryHandoff(consultant())).toEqual(saved);
  });

  it('discards saved details on reset', () => {
    saveFixtureMinistryHandoff(consultant(), {
      churchName: 'Temporary Church',
      authorizedAdminName: '',
      authorizedAdminEmail: '',
      ministryAreasAndLeaders: '',
      priorities: '',
      meetingAndPlanningRhythm: '',
      eventsAndWorkflows: '',
      readiness: 'PREPARING',
      status: 'READY_FOR_REVIEW',
      checklist: defaultHandoffChecklist,
    });
    resetHandoffFixtures();
    expect(fixtureMinistryHandoff(consultant()).churchName).toBe(consultant().organization.name);
  });
});
