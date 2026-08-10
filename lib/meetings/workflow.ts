import { meetingPhases, type MeetingMutation, type MeetingPhase } from './types';

export function canMoveToPhase(current: MeetingPhase, next: MeetingPhase) {
  const currentIndex = meetingPhases.indexOf(current);
  const nextIndex = meetingPhases.indexOf(next);
  return nextIndex === currentIndex || nextIndex === currentIndex + 1;
}

export function validateMeetingMutation(value: unknown): MeetingMutation {
  if (!value || typeof value !== 'object') throw new Error('A meeting action is required.');
  const input = value as Record<string, unknown>;
  if (typeof input.action !== 'string') throw new Error('A meeting action is required.');
  const required = (key: string) => {
    const field = input[key];
    if (typeof field !== 'string' || !field.trim()) throw new Error(`${key} is required.`);
    return field.trim();
  };
  switch (input.action) {
    case 'CREATE_MEETING': {
      const meetingType = required('meetingType');
      if (meetingType !== 'CONSULTING' && meetingType !== 'COACHING') throw new Error('Meeting type is invalid.');
      return { action: input.action, meetingType, title: required('title'), purpose: required('purpose'), scheduledStart: required('scheduledStart'), participantPersonId: required('participantPersonId'), developmentFocus: typeof input.developmentFocus === 'string' ? input.developmentFocus.trim() : undefined };
    }
    case 'UPDATE_MEETING': {
      const phase = required('phase') as MeetingPhase;
      if (!meetingPhases.includes(phase)) throw new Error('Meeting phase is invalid.');
      return { action: input.action, meetingId: required('meetingId'), title: required('title'), purpose: required('purpose'), agenda: required('agenda'), sharedSummary: typeof input.sharedSummary === 'string' ? input.sharedSummary.trim() : undefined, followUp: typeof input.followUp === 'string' ? input.followUp.trim() : undefined, phase };
    }
    case 'ADD_SHARED_NOTE':
      return { action: input.action, meetingId: required('meetingId'), content: required('content') };
    case 'ADD_PRIVATE_NOTE': {
      const kind = required('kind');
      if (kind !== 'CONSULTANT_NOTE' && kind !== 'INDIVIDUAL_REFLECTION') throw new Error('Private note kind is invalid.');
      return { action: input.action, meetingId: required('meetingId'), content: required('content'), kind };
    }
    case 'ADD_DECISION':
      return { action: input.action, meetingId: required('meetingId'), statement: required('statement'), rationale: required('rationale'), intendedEffect: required('intendedEffect'), reviewTrigger: required('reviewTrigger') };
    case 'ADD_COMMITMENT':
      return { action: input.action, meetingId: required('meetingId'), ownerPersonId: required('ownerPersonId'), actionText: required('actionText'), dueOn: typeof input.dueOn === 'string' && input.dueOn ? input.dueOn : undefined };
    case 'UPDATE_COMMITMENT': {
      const status = required('status');
      if (!['OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'].includes(status)) throw new Error('Commitment status is invalid.');
      return { action: input.action, meetingId: required('meetingId'), commitmentId: required('commitmentId'), status: status as 'OPEN' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED' };
    }
    default:
      throw new Error('Meeting action is not supported.');
  }
}
