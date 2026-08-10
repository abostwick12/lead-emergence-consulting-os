import { describe, expect, it } from 'vitest';
import { canMoveToPhase, validateMeetingMutation } from './workflow';

describe('meeting workflow', () => {
  it('allows only the current or next canonical phase', () => {
    expect(canMoveToPhase('PREPARE', 'MEET')).toBe(true);
    expect(canMoveToPhase('PREPARE', 'CAPTURE')).toBe(false);
    expect(canMoveToPhase('COMMIT', 'FOLLOW_UP')).toBe(true);
  });

  it('rejects an unsupported or incomplete mutation', () => {
    expect(() => validateMeetingMutation({ action: 'CREATE_MEETING', title: '' })).toThrow('meetingType is required');
    expect(() => validateMeetingMutation({ action: 'PROMOTE_PRIVATE_NOTE' })).toThrow('not supported');
  });

  it('normalizes a shared note mutation', () => {
    expect(validateMeetingMutation({ action: 'ADD_SHARED_NOTE', meetingId: 'm1', content: '  agreed note  ' })).toEqual({ action: 'ADD_SHARED_NOTE', meetingId: 'm1', content: 'agreed note' });
  });
});
