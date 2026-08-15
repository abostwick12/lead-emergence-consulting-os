import 'server-only';
import { authorizationError, notFoundError, validationError } from '@/lib/errors';

import type { PortalSession } from '@/lib/portal/types';
import type { MeetingCenterData, MeetingMutation, MeetingPerson, MeetingView } from './types';
import { canMoveToPhase } from './workflow';

const consultant: MeetingPerson = { id: '40000000-0000-4000-8000-000000000001', name: 'Alex Morgan', relationship: 'CONSULTANT' };
const client: MeetingPerson = { id: '40000000-0000-4000-8000-000000000002', name: 'Jordan Lee', relationship: 'CLIENT' };

const initialMeetings: MeetingView[] = [
  {
    id: '50000000-0000-4000-8000-000000000001', organizationId: '10000000-0000-4000-8000-000000000001', engagementId: '20000000-0000-4000-8000-000000000001',
    type: 'CONSULTING', title: 'Authority alignment workshop', purpose: 'Translate the validated authority insight into clear decision boundaries.',
    scheduledStart: '2026-08-14T15:00:00.000Z', scheduledEnd: '2026-08-14T16:30:00.000Z', status: 'PREPARED', phase: 'PREPARE',
    agenda: 'Review examples\nDefine routine decision categories\nAgree escalation thresholds',
    participants: [consultant, client],
    notes: [{ id: '51000000-0000-4000-8000-000000000001', kind: 'PREPARATION', content: 'Bring two routine decisions and one escalation example.', authorName: 'Alex Morgan', createdLabel: 'Aug 10', privacy: 'SHARED' }],
    decisions: [{ id: '51500000-0000-4000-8000-000000000001', statement: 'Team leads may make routine decisions inside the documented boundary.', rationale: 'Validated insight and workshop examples support moving defined authority closer to the work.', intendedEffect: 'Reduce decision latency without weakening escalation judgment.', reviewTrigger: 'Review after four weeks or if exception rates rise.', status: 'APPROVED', authorityName: 'Jordan Lee', decidedLabel: 'Aug 10' }],
    commitments: [{ id: '52000000-0000-4000-8000-000000000001', ownerPersonId: client.id, ownerName: client.name, action: 'Bring two routine decisions and one escalation example.', dueOn: '2026-08-14', status: 'OPEN', sourceMeetingId: '50000000-0000-4000-8000-000000000001' }],
    context: [{ id: '30000000-0000-4000-8000-000000000003', label: 'Validated authority insight', state: 'VALIDATED INSIGHT' }],
  },
  {
    id: '50000000-0000-4000-8000-000000000002', organizationId: '10000000-0000-4000-8000-000000000001', engagementId: '20000000-0000-4000-8000-000000000001',
    type: 'COACHING', title: 'Decision judgment coaching', purpose: 'Practice bounded delegation judgment in current leadership situations.',
    scheduledStart: '2026-08-12T18:00:00.000Z', scheduledEnd: '2026-08-12T18:50:00.000Z', status: 'IN_PROGRESS', phase: 'CAPTURE',
    agenda: 'Check in on prior commitment\nPractice escalation judgment\nChoose next experiment',
    participants: [consultant, client],
    notes: [
      { id: '51000000-0000-4000-8000-000000000002', kind: 'SHARED_NOTE', content: 'Jordan will test the decision-boundary prompt in two live situations.', authorName: 'Jordan Lee', createdLabel: 'Aug 10', privacy: 'SHARED' },
      { id: '51000000-0000-4000-8000-000000000003', kind: 'CONSULTANT_NOTE', content: 'Private coaching reflection retained only for Alex.', authorName: 'Alex Morgan', createdLabel: 'Aug 10', privacy: 'PRIVATE' },
    ],
    decisions: [],
    commitments: [{ id: '52000000-0000-4000-8000-000000000002', ownerPersonId: client.id, ownerName: client.name, action: 'Use the boundary prompt in two decisions and record what happened.', dueOn: '2026-08-19', status: 'IN_PROGRESS', sourceMeetingId: '50000000-0000-4000-8000-000000000002' }],
    context: [{ id: '30000000-0000-4000-8000-000000000004', label: 'Delegation decision', state: 'DECISION' }],
    coaching: { relationshipId: '53000000-0000-4000-8000-000000000001', participantName: client.name, coachName: consultant.name, developmentFocus: 'Purpose-consistent decision judgment', confidentialityStatement: 'Shared coaching records are visible only to Alex and Jordan. Private reflections remain separate.', sessionNumber: 3 },
  },
];

declare global {
  var __leMeetingFixtures: MeetingView[] | undefined;
}

function store() {
  globalThis.__leMeetingFixtures ??= structuredClone(initialMeetings);
  return globalThis.__leMeetingFixtures;
}

export function resetMeetingFixtures() { globalThis.__leMeetingFixtures = structuredClone(initialMeetings); }

export function fixtureMeetingCenter(session: PortalSession): MeetingCenterData {
  const meetings = store()
    .filter((meeting) => session.role === 'consultant' || meeting.participants.some((person) => person.id === session.personId))
    .map((meeting) => ({
      ...structuredClone(meeting),
      notes: meeting.notes.filter((note) => note.privacy === 'SHARED' || (session.role === 'consultant' && note.authorName === session.displayName) || (note.kind === 'INDIVIDUAL_REFLECTION' && note.authorName === session.displayName)),
    }));
  return { meetings, people: [consultant, client], currentPersonId: session.personId, role: session.role as 'consultant' | 'client' };
}

export function mutateFixtureMeeting(session: PortalSession, mutation: MeetingMutation): MeetingCenterData {
  const meetings = store();
  const person = [consultant, client].find((item) => item.id === session.personId)!;
  if (mutation.action === 'CREATE_MEETING') {
    if (session.role !== 'consultant') throw authorizationError('Only a consultant can create a meeting.');
    const participant = [consultant, client].find((item) => item.id === mutation.participantPersonId);
    if (!participant) throw notFoundError('The selected participant is not available.');
    const id = crypto.randomUUID();
    const meeting: MeetingView = {
      id, organizationId: session.organization.id, engagementId: session.engagement.id, type: mutation.meetingType, title: mutation.title, purpose: mutation.purpose,
      scheduledStart: new Date(mutation.scheduledStart).toISOString(), status: 'PLANNED', phase: 'PREPARE', agenda: 'Opening check-in\nPurpose and desired outcome\nDecisions and commitments',
      participants: [consultant, participant].filter((item, index, items) => items.findIndex((candidate) => candidate.id === item.id) === index), notes: [], decisions: [], commitments: [], context: [],
      coaching: mutation.meetingType === 'COACHING' ? { relationshipId: crypto.randomUUID(), participantName: participant.name, coachName: consultant.name, developmentFocus: mutation.developmentFocus || 'Current development focus', confidentialityStatement: 'Shared coaching records remain limited to the named coach and participant. Private reflections remain separate.', sessionNumber: 1 } : undefined,
    };
    meetings.unshift(meeting);
  } else {
    const meeting = meetings.find((item) => item.id === mutation.meetingId);
    if (!meeting || (session.role === 'client' && !meeting.participants.some((item) => item.id === session.personId))) throw notFoundError('Meeting is not available.');
    if (mutation.action === 'UPDATE_MEETING') {
      if (session.role !== 'consultant') throw authorizationError('Only a consultant can edit the meeting plan.');
      if (!canMoveToPhase(meeting.phase, mutation.phase)) throw validationError('Move through the meeting workflow one phase at a time.');
      Object.assign(meeting, { title: mutation.title, purpose: mutation.purpose, agenda: mutation.agenda, sharedSummary: mutation.sharedSummary, followUp: mutation.followUp, phase: mutation.phase, status: mutation.phase === 'PREPARE' ? 'PREPARED' : mutation.phase === 'FOLLOW_UP' ? 'COMPLETED' : 'IN_PROGRESS' });
    } else if (mutation.action === 'ADD_SHARED_NOTE') {
      meeting.notes.push({ id: crypto.randomUUID(), kind: 'SHARED_NOTE', content: mutation.content, authorName: person.name, createdLabel: 'Just now', privacy: 'SHARED' });
    } else if (mutation.action === 'ADD_PRIVATE_NOTE') {
      if (mutation.kind === 'CONSULTANT_NOTE' && session.role !== 'consultant') throw authorizationError('Consultant-private notes are limited to the assigned consultant.');
      meeting.notes.push({ id: crypto.randomUUID(), kind: mutation.kind, content: mutation.content, authorName: person.name, createdLabel: 'Just now', privacy: 'PRIVATE' });
    } else if (mutation.action === 'ADD_DECISION') {
      meeting.decisions.push({ id: crypto.randomUUID(), statement: mutation.statement, rationale: mutation.rationale, intendedEffect: mutation.intendedEffect, reviewTrigger: mutation.reviewTrigger, status: 'APPROVED', authorityName: person.name, decidedLabel: 'Just now' });
    } else if (mutation.action === 'ADD_COMMITMENT') {
      const owner = meeting.participants.find((item) => item.id === mutation.ownerPersonId);
      if (!owner) throw validationError('Commitment owner must be a meeting participant.');
      meeting.commitments.push({ id: crypto.randomUUID(), ownerPersonId: owner.id, ownerName: owner.name, action: mutation.actionText, dueOn: mutation.dueOn, status: 'OPEN', sourceMeetingId: meeting.id });
    } else if (mutation.action === 'UPDATE_COMMITMENT') {
      const commitment = meeting.commitments.find((item) => item.id === mutation.commitmentId);
      if (!commitment || (session.role === 'client' && commitment.ownerPersonId !== session.personId)) throw notFoundError('Commitment is not available.');
      commitment.status = mutation.status;
    }
  }
  return fixtureMeetingCenter(session);
}
