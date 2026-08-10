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

  it('requires complete first-class decision semantics', () => {
    expect(() => validateMeetingMutation({ action: 'ADD_DECISION', meetingId: 'm1', statement: 'Decide', rationale: '' })).toThrow('rationale is required');
    expect(validateMeetingMutation({ action: 'ADD_DECISION', meetingId: 'm1', statement: '  Delegate routine decisions  ', rationale: '  Authority is explicit  ', intendedEffect: '  Reduce latency  ', reviewTrigger: '  Review in four weeks  ' })).toEqual({ action: 'ADD_DECISION', meetingId: 'm1', statement: 'Delegate routine decisions', rationale: 'Authority is explicit', intendedEffect: 'Reduce latency', reviewTrigger: 'Review in four weeks' });
  });
});
