import { objectInput } from '../validation/input';
import { meetingPhases, type MeetingMutation, type MeetingPhase } from './types';

export function canMoveToPhase(current: MeetingPhase, next: MeetingPhase) {
  const currentIndex = meetingPhases.indexOf(current);
  const nextIndex = meetingPhases.indexOf(next);
  return nextIndex === currentIndex || nextIndex === currentIndex + 1;
}

export function validateMeetingMutation(value: unknown): MeetingMutation {
  const { raw: input, required, oneOf } = objectInput(value, 'A meeting action is required.');
  if (typeof input.action !== 'string') throw new Error('A meeting action is required.');
  switch (input.action) {
    case 'CREATE_MEETING': {
      const meetingType = oneOf('meetingType', ['CONSULTING', 'COACHING'] as const, 'Meeting type is invalid.');
      return { action: input.action, meetingType, title: required('title'), purpose: required('purpose'), scheduledStart: required('scheduledStart'), participantPersonId: required('participantPersonId'), developmentFocus: typeof input.developmentFocus === 'string' ? input.developmentFocus.trim() : undefined };
    }
    case 'UPDATE_MEETING': {
      const phase = oneOf('phase', meetingPhases, 'Meeting phase is invalid.');
      return { action: input.action, meetingId: required('meetingId'), title: required('title'), purpose: required('purpose'), agenda: required('agenda'), sharedSummary: typeof input.sharedSummary === 'string' ? input.sharedSummary.trim() : undefined, followUp: typeof input.followUp === 'string' ? input.followUp.trim() : undefined, phase };
    }
    case 'ADD_SHARED_NOTE':
      return { action: input.action, meetingId: required('meetingId'), content: required('content') };
    case 'ADD_PRIVATE_NOTE': {
      const kind = oneOf('kind', ['CONSULTANT_NOTE', 'INDIVIDUAL_REFLECTION'] as const, 'Private note kind is invalid.');
      return { action: input.action, meetingId: required('meetingId'), content: required('content'), kind };
    }
    case 'ADD_DECISION':
      return { action: input.action, meetingId: required('meetingId'), statement: required('statement'), rationale: required('rationale'), intendedEffect: required('intendedEffect'), reviewTrigger: required('reviewTrigger') };
    case 'ADD_COMMITMENT':
      return { action: input.action, meetingId: required('meetingId'), ownerPersonId: required('ownerPersonId'), actionText: required('actionText'), dueOn: typeof input.dueOn === 'string' && input.dueOn ? input.dueOn : undefined };
    case 'UPDATE_COMMITMENT': {
      const status = oneOf('status', ['OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'] as const, 'Commitment status is invalid.');
      return { action: input.action, meetingId: required('meetingId'), commitmentId: required('commitmentId'), status };
    }
    default:
      throw new Error('Meeting action is not supported.');
  }
}
