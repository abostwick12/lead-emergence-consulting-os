import { beforeEach, describe, expect, it } from 'vitest';
import { fixtureSession } from '../portal/fixtures';
import { fixtureAccessCenter, mutateFixtureAccess, resetAccessFixtures } from './fixtures';

const consultant = () => fixtureSession('consultant')!;
const origin = 'https://consulting.leademergence.com';

describe('access center fixture projections', () => {
  beforeEach(() => {
    resetAccessFixtures();
  });

  it('starts with no invitations and one draft confidential assessment', () => {
    const data = fixtureAccessCenter(consultant());
    expect(data.organizationId).toBe(consultant().organization.id);
    expect(data.invitations).toHaveLength(0);
    expect(data.assessments).toHaveLength(1);
    expect(data.assessments[0].confidentiality).toBe('CONFIDENTIAL');
    expect(data.assessments[0].status).toBe('DRAFT');
  });

  it('records the newest client invitation first with an expiry in the future', () => {
    mutateFixtureAccess(consultant(), {
      action: 'INVITE_CLIENT', email: 'first@example.com', displayName: 'First Leader', role: 'CLIENT_LEADER',
    }, origin);
    const data = mutateFixtureAccess(consultant(), {
      action: 'INVITE_CLIENT', email: 'second@example.com', displayName: 'Second Admin', role: 'CLIENT_ADMIN',
    }, origin);

    expect(data.invitations.map((invitation) => invitation.email)).toEqual(['second@example.com', 'first@example.com']);
    expect(data.invitations[0].status).toBe('SENT');
    expect(new Date(data.invitations[0].expiresAt).getTime()).toBeGreaterThan(Date.now());
    expect(data.participantUrl).toBeUndefined();
  });

  it('issues a distinct participant link per assessment link request', () => {
    const first = mutateFixtureAccess(consultant(), { action: 'CREATE_ASSESSMENT_LINK', administrationId: 'administration-1' }, origin);
    const second = mutateFixtureAccess(consultant(), { action: 'CREATE_ASSESSMENT_LINK', administrationId: 'administration-1' }, origin);
    expect(first.participantUrl).toBe(`${origin}/assessment/fixture-participant-1`);
    expect(second.participantUrl).toBe(`${origin}/assessment/fixture-participant-2`);
  });

  it('clears invitations and link counters on reset', () => {
    mutateFixtureAccess(consultant(), {
      action: 'INVITE_CLIENT', email: 'temporary@example.com', displayName: 'Temporary', role: 'CLIENT_MEMBER',
    }, origin);
    mutateFixtureAccess(consultant(), { action: 'CREATE_ASSESSMENT_LINK', administrationId: 'administration-1' }, origin);
    resetAccessFixtures();

    expect(fixtureAccessCenter(consultant()).invitations).toHaveLength(0);
    const afterReset = mutateFixtureAccess(consultant(), { action: 'CREATE_ASSESSMENT_LINK', administrationId: 'administration-1' }, origin);
    expect(afterReset.participantUrl).toBe(`${origin}/assessment/fixture-participant-1`);
  });
});
