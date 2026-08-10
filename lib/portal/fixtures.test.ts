import { describe, expect, it } from 'vitest';
import { fixtureDashboard, fixtureRecord, fixtureSession } from './fixtures';

describe('role-safe synthetic portal projections', () => {
  it('keeps the organization and engagement context explicit for both roles', () => {
    for (const role of ['consultant', 'client'] as const) {
      const session = fixtureSession(role);
      expect(session?.organization.name).toBe('Northstar Community Works');
      expect(session?.engagement.name).toBe('Organizational Renewal 2026');
    }
  });

  it('shows private working analysis to the consultant only', () => {
    const consultant = fixtureDashboard('consultant');
    const client = fixtureDashboard('client');
    expect(consultant.records.some((record) => record.visibility === 'CONSULTANT_PRIVATE')).toBe(true);
    expect(client.records.some((record) => record.visibility === 'CONSULTANT_PRIVATE')).toBe(false);
  });

  it('permits client records only when shared and authorized', () => {
    const client = fixtureDashboard('client');
    expect(client.records.length).toBeGreaterThan(0);
    expect(client.records.every((record) => record.visibility === 'ORGANIZATION_SHARED')).toBe(true);
    expect(client.records.every((record) => ['VALIDATED INSIGHT', 'DECISION'].includes(record.state))).toBe(true);
  });

  it('prevents record-id substitution from resolving consultant-private content', () => {
    const privateId = fixtureDashboard('consultant').records.find((record) => record.visibility === 'CONSULTANT_PRIVATE')!.id;
    expect(fixtureRecord('consultant', privateId)).not.toBeNull();
    expect(fixtureRecord('client', privateId)).toBeNull();
  });

  it('keeps all seven roadmap stages visible in canonical order', () => {
    expect(fixtureDashboard('client').roadmap.map((stage) => stage.name)).toEqual([
      'SEE REALITY', 'REFRAME REALITY', 'ALIGN WITH REALITY', 'BUILD CAPABILITY',
      'PRODUCE VALUE', 'NEW REALITY', 'SEE AGAIN',
    ]);
  });
});
