import { beforeEach, describe, expect, it } from 'vitest';
import { fixtureSession } from '../portal/fixtures';
import { fixtureMeetingCenter, mutateFixtureMeeting, resetMeetingFixtures } from './fixtures';

const consultant = () => fixtureSession('consultant')!;
const client = () => fixtureSession('client')!;

describe('meeting fixture projections', () => {
  beforeEach(() => {
    resetMeetingFixtures();
  });

  it('exposes the seeded meetings with role context for both roles', () => {
    const consultantCenter = fixtureMeetingCenter(consultant());
    expect(consultantCenter.meetings.map((meeting) => meeting.type)).toEqual(['CONSULTING', 'COACHING']);
    expect(consultantCenter.role).toBe('consultant');
    expect(consultantCenter.currentPersonId).toBe(consultant().personId);
    expect(fixtureMeetingCenter(client()).role).toBe('client');
  });

  it('withholds consultant-private notes from the client projection', () => {
    const consultantNotes = fixtureMeetingCenter(consultant()).meetings.flatMap((meeting) => meeting.notes);
    const clientNotes = fixtureMeetingCenter(client()).meetings.flatMap((meeting) => meeting.notes);
    expect(consultantNotes.some((note) => note.kind === 'CONSULTANT_NOTE')).toBe(true);
    expect(clientNotes.every((note) => note.privacy === 'SHARED')).toBe(true);
  });

  it('creates a coaching meeting with a coaching relationship for the consultant only', () => {
    const created = mutateFixtureMeeting(consultant(), {
      action: 'CREATE_MEETING',
      meetingType: 'COACHING',
      title: 'Escalation judgment coaching',
      purpose: 'Practice escalation judgment under time pressure.',
      scheduledStart: '2026-09-01T15:00:00.000Z',
      participantPersonId: client().personId,
      developmentFocus: 'Escalation judgment',
    }).meetings[0];
    expect(created.title).toBe('Escalation judgment coaching');
    expect(created.phase).toBe('PREPARE');
    expect(created.status).toBe('PLANNED');
    expect(created.coaching?.developmentFocus).toBe('Escalation judgment');
    expect(created.participants).toHaveLength(2);

    expect(() => mutateFixtureMeeting(client(), {
      action: 'CREATE_MEETING',
      meetingType: 'CONSULTING',
      title: 'Client-created meeting',
      purpose: 'Not permitted.',
      scheduledStart: '2026-09-01T15:00:00.000Z',
      participantPersonId: consultant().personId,
    })).toThrow('Only a consultant can create a meeting.');
  });

  it('rejects a meeting created for an unavailable participant', () => {
    expect(() => mutateFixtureMeeting(consultant(), {
      action: 'CREATE_MEETING',
      meetingType: 'CONSULTING',
      title: 'Unknown participant',
      purpose: 'Not permitted.',
      scheduledStart: '2026-09-01T15:00:00.000Z',
      participantPersonId: 'missing-person',
    })).toThrow('The selected participant is not available.');
  });

  it('advances the meeting plan one phase at a time', () => {
    const meetingId = fixtureMeetingCenter(consultant()).meetings[0].id;
    const update = {
      action: 'UPDATE_MEETING' as const,
      meetingId,
      title: 'Authority alignment workshop',
      purpose: 'Translate the validated authority insight into clear decision boundaries.',
      agenda: 'Review examples',
    };
    const moved = mutateFixtureMeeting(consultant(), { ...update, phase: 'MEET' })
      .meetings.find((meeting) => meeting.id === meetingId)!;
    expect(moved.phase).toBe('MEET');
    expect(moved.status).toBe('IN_PROGRESS');
    expect(() => mutateFixtureMeeting(consultant(), { ...update, phase: 'FOLLOW_UP' }))
      .toThrow('Move through the meeting workflow one phase at a time.');
    expect(() => mutateFixtureMeeting(client(), { ...update, phase: 'CAPTURE' }))
      .toThrow('Only a consultant can edit the meeting plan.');
  });

  it('records shared notes, private notes, decisions, and commitments', () => {
    const meetingId = fixtureMeetingCenter(consultant()).meetings[0].id;
    mutateFixtureMeeting(client(), { action: 'ADD_SHARED_NOTE', meetingId, content: 'Client observation' });
    mutateFixtureMeeting(client(), { action: 'ADD_PRIVATE_NOTE', meetingId, content: 'Personal reflection', kind: 'INDIVIDUAL_REFLECTION' });
    mutateFixtureMeeting(consultant(), {
      action: 'ADD_DECISION', meetingId,
      statement: 'Delegate routine client exceptions.',
      rationale: 'Evidence supports local judgment.',
      intendedEffect: 'Reduce decision latency.',
      reviewTrigger: 'Review in four weeks.',
    });
    const withCommitment = mutateFixtureMeeting(consultant(), {
      action: 'ADD_COMMITMENT', meetingId, ownerPersonId: client().personId, actionText: 'Log two live decisions.', dueOn: '2026-09-05',
    }).meetings.find((meeting) => meeting.id === meetingId)!;

    expect(withCommitment.notes.some((note) => note.content === 'Client observation')).toBe(true);
    expect(withCommitment.decisions.some((decision) => decision.status === 'APPROVED')).toBe(true);
    expect(withCommitment.commitments.some((commitment) => commitment.action === 'Log two live decisions.')).toBe(true);

    const clientMeeting = fixtureMeetingCenter(client()).meetings.find((meeting) => meeting.id === meetingId)!;
    expect(clientMeeting.notes.some((note) => note.content === 'Personal reflection')).toBe(true);
  });

  it('limits consultant-private notes and unowned commitment updates for the client', () => {
    const meetingId = fixtureMeetingCenter(consultant()).meetings[0].id;
    expect(() => mutateFixtureMeeting(client(), { action: 'ADD_PRIVATE_NOTE', meetingId, content: 'Not permitted', kind: 'CONSULTANT_NOTE' }))
      .toThrow('Consultant-private notes are limited to the assigned consultant.');

    const commitment = mutateFixtureMeeting(consultant(), {
      action: 'ADD_COMMITMENT', meetingId, ownerPersonId: consultant().personId, actionText: 'Consultant-owned follow-up.',
    }).meetings.find((meeting) => meeting.id === meetingId)!.commitments.find((item) => item.ownerPersonId === consultant().personId)!;

    expect(() => mutateFixtureMeeting(client(), { action: 'UPDATE_COMMITMENT', meetingId, commitmentId: commitment.id, status: 'COMPLETED' }))
      .toThrow('Commitment is not available.');
  });

  it('updates a commitment owned by the acting client', () => {
    const meeting = fixtureMeetingCenter(client()).meetings[0];
    const commitment = meeting.commitments.find((item) => item.ownerPersonId === client().personId)!;
    const updated = mutateFixtureMeeting(client(), {
      action: 'UPDATE_COMMITMENT', meetingId: meeting.id, commitmentId: commitment.id, status: 'COMPLETED',
    }).meetings.find((item) => item.id === meeting.id)!.commitments.find((item) => item.id === commitment.id)!;
    expect(updated.status).toBe('COMPLETED');
  });

  it('rejects mutations against an unknown meeting', () => {
    expect(() => mutateFixtureMeeting(consultant(), { action: 'ADD_SHARED_NOTE', meetingId: 'missing', content: 'note' }))
      .toThrow('Meeting is not available.');
  });

  it('restores the seeded state on reset', () => {
    const meetingId = fixtureMeetingCenter(consultant()).meetings[0].id;
    mutateFixtureMeeting(consultant(), { action: 'ADD_SHARED_NOTE', meetingId, content: 'Temporary note' });
    resetMeetingFixtures();
    const notes = fixtureMeetingCenter(consultant()).meetings.flatMap((meeting) => meeting.notes);
    expect(notes.some((note) => note.content === 'Temporary note')).toBe(false);
  });
});
