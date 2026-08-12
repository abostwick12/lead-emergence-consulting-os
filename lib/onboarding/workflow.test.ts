import { describe, expect, it } from 'vitest';
import { validateStartEngagement } from './workflow';

describe('client engagement onboarding', () => {
  it('accepts a bounded organization and engagement setup', () => {
    expect(validateStartEngagement({ organizationName: 'Grace Church', engagementName: 'Healthy Rhythm', startsOn: '2026-09-01', endsOn: '2027-02-01' })).toMatchObject({ organizationName: 'Grace Church', engagementName: 'Healthy Rhythm' });
  });
  it('rejects a reversed engagement window', () => {
    expect(() => validateStartEngagement({ organizationName: 'Grace Church', engagementName: 'Healthy Rhythm', startsOn: '2027-02-01', endsOn: '2026-09-01' })).toThrow('cannot precede');
  });
});
