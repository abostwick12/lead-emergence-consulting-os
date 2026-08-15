import 'server-only';

import type { PortalSession } from '@/lib/portal/types';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { fixtureMeetingCenter, mutateFixtureMeeting } from './fixtures';
import type { MeetingCenterData, MeetingCommitmentView, MeetingMutation, MeetingNoteView, MeetingPerson, MeetingView } from './types';
import { canMoveToPhase } from './workflow';
import { dataAccessError } from '@/lib/http/errors';

export async function getMeetingCenter(session: PortalSession): Promise<MeetingCenterData> {
  if (session.fixture) return fixtureMeetingCenter(session);
  const supabase = await createSupabaseServerClient();
  const { data: peopleRows, error: peopleError } = await supabase.rpc('meeting_people_directory', {
    p_organization_id: session.organization.id,
    p_engagement_id: session.engagement.id,
  });
  if (peopleError) throw dataAccessError(peopleError, 'lib/meetings/repository.ts');
  const people: MeetingPerson[] = (peopleRows ?? []).map((row: { person_id: string; display_name: string; relationship: string }) => ({ id: row.person_id, name: row.display_name, relationship: row.relationship as 'CONSULTANT' | 'CLIENT' }));
  const names = new Map(people.map((person) => [person.id, person.name]));
  const { data: meetingRows, error: meetingError } = await supabase.from('meetings').select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).order('scheduled_start', { ascending: true });
  if (meetingError) throw dataAccessError(meetingError, 'lib/meetings/repository.ts');
  const ids = (meetingRows ?? []).map((row) => row.id);
  if (!ids.length) return { meetings: [], people, currentPersonId: session.personId, role: session.role as 'consultant' | 'client' };

  const [participantsResult, notesResult, commitmentsResult, coachingResult, contextResult, decisionLinksResult] = await Promise.all([
    supabase.from('meeting_participants').select('*').eq('organization_id', session.organization.id).in('meeting_id', ids),
    supabase.from('meeting_notes').select('*').eq('organization_id', session.organization.id).in('meeting_id', ids).order('created_at'),
    supabase.from('commitments').select('*').eq('organization_id', session.organization.id).in('source_meeting_id', ids).order('created_at'),
    supabase.from('coaching_sessions').select('*, coaching_relationships(*)').eq('organization_id', session.organization.id).in('id', ids),
    supabase.from('meeting_context_items').select('meeting_id, context_domain_object_id').eq('organization_id', session.organization.id).in('meeting_id', ids),
    supabase.from('meeting_decisions').select('meeting_id, decision_id').eq('organization_id', session.organization.id).in('meeting_id', ids),
  ]);
  for (const result of [participantsResult, notesResult, commitmentsResult, coachingResult, contextResult, decisionLinksResult]) if (result.error) throw dataAccessError(result.error, 'lib/meetings/repository.ts');

  const privateNotes = new Map<string, MeetingNoteView[]>();
  for (const id of ids) {
    const { data, error } = await supabase.rpc('private_meeting_notes_for_meeting', { p_meeting_id: id });
    if (error) throw dataAccessError(error, 'lib/meetings/repository.ts');
    privateNotes.set(id, (data ?? []).map((row: { note_id: string; kind: MeetingNoteView['kind']; content: string; author_person_id: string; created_at: string }) => ({ id: row.note_id, kind: row.kind, content: row.content, authorName: names.get(row.author_person_id) ?? 'Private author', createdLabel: formatDate(row.created_at), privacy: 'PRIVATE' as const })));
  }
  const contextIds = [...new Set((contextResult.data ?? []).map((row) => row.context_domain_object_id))];
  const { data: contextDomains } = contextIds.length ? await supabase.from('domain_objects').select('id, object_type').eq('organization_id', session.organization.id).in('id', contextIds) : { data: [] };
  const contextMap = new Map((contextDomains ?? []).map((row) => [row.id, row.object_type]));
  const decisionIds = [...new Set((decisionLinksResult.data ?? []).map((row) => row.decision_id))];
  const { data: decisionRows, error: decisionsError } = decisionIds.length
    ? await supabase.from('decisions').select('*').eq('organization_id', session.organization.id).in('id', decisionIds)
    : { data: [], error: null };
  if (decisionsError) throw dataAccessError(decisionsError, 'lib/meetings/repository.ts');

  const meetings: MeetingView[] = (meetingRows ?? []).map((row) => {
    const participants = (participantsResult.data ?? []).filter((item) => item.meeting_id === row.id).map((item) => people.find((person) => person.id === item.person_id) ?? { id: item.person_id, name: 'Named participant', relationship: 'CLIENT' as const });
    const notes: MeetingNoteView[] = (notesResult.data ?? []).filter((item) => item.meeting_id === row.id).map((item) => ({ id: item.id, kind: item.note_kind, content: item.content, authorName: names.get(item.author_person_id) ?? 'Participant', createdLabel: formatDate(item.created_at), privacy: 'SHARED' }));
    notes.push(...(privateNotes.get(row.id) ?? []));
    const decisions = (decisionLinksResult.data ?? []).filter((item) => item.meeting_id === row.id).map((item) => (decisionRows ?? []).find((decision) => decision.id === item.decision_id)).filter(Boolean).map((decision) => ({ id: decision.id, statement: decision.statement, rationale: decision.rationale, intendedEffect: decision.intended_effect, reviewTrigger: decision.review_trigger, status: decision.decision_status, authorityName: names.get(decision.authority_person_id) ?? 'Authorized participant', decidedLabel: formatDate(decision.decided_at) }));
    const commitments: MeetingCommitmentView[] = (commitmentsResult.data ?? []).filter((item) => item.source_meeting_id === row.id).map((item) => ({ id: item.id, ownerPersonId: item.owner_person_id, ownerName: names.get(item.owner_person_id) ?? 'Participant', action: item.action, dueOn: item.due_on ?? undefined, status: item.status, sourceMeetingId: row.id }));
    const sessionRow = (coachingResult.data ?? []).find((item) => item.id === row.id);
    const relationship = sessionRow?.coaching_relationships;
    return {
      id: row.id, organizationId: row.organization_id, engagementId: row.engagement_id, type: row.meeting_type, title: row.title, purpose: row.purpose,
      scheduledStart: row.scheduled_start, scheduledEnd: row.scheduled_end ?? undefined, status: row.status, phase: row.current_phase, agenda: row.agenda,
      sharedSummary: row.shared_summary ?? undefined, followUp: row.follow_up ?? undefined, participants, notes, decisions, commitments,
      context: (contextResult.data ?? []).filter((item) => item.meeting_id === row.id).map((item) => ({ id: item.context_domain_object_id, label: titleCase(contextMap.get(item.context_domain_object_id) ?? 'PERMITTED_CONTEXT'), state: titleCase(contextMap.get(item.context_domain_object_id) ?? 'CONTEXT') })),
      coaching: relationship ? { relationshipId: relationship.id, participantName: names.get(relationship.participant_person_id) ?? 'Participant', coachName: names.get(relationship.coach_person_id) ?? 'Coach', developmentFocus: sessionRow.development_focus ?? relationship.development_focus, confidentialityStatement: relationship.confidentiality_statement, sessionNumber: sessionRow.session_number } : undefined,
    };
  });
  return { meetings, people, currentPersonId: session.personId, role: session.role as 'consultant' | 'client' };
}

export async function mutateMeeting(session: PortalSession, mutation: MeetingMutation) {
  if (session.fixture) return mutateFixtureMeeting(session, mutation);
  const supabase = await createSupabaseServerClient();
  if (mutation.action === 'CREATE_MEETING') {
    if (session.role !== 'consultant') throw new Error('Only a consultant can create a meeting.');
    const data = await getMeetingCenter(session);
    const participant = data.people.find((person) => person.id === mutation.participantPersonId);
    if (!participant) throw new Error('The selected participant is not available.');
    await checked(supabase.rpc('create_meeting', {
      p_organization_id: session.organization.id,
      p_engagement_id: session.engagement.id,
      p_meeting_type: mutation.meetingType,
      p_title: mutation.title,
      p_purpose: mutation.purpose,
      p_scheduled_start: new Date(mutation.scheduledStart).toISOString(),
      p_agenda: 'Opening check-in\nPurpose and desired outcome\nDecisions and commitments',
      p_participant_person_id: participant.id,
      p_development_focus: mutation.developmentFocus || null,
    }));
  } else {
    const current = (await getMeetingCenter(session)).meetings.find((meeting) => meeting.id === mutation.meetingId);
    if (!current) throw new Error('Meeting is not available.');
    if (mutation.action === 'UPDATE_MEETING') {
      if (session.role !== 'consultant' || !canMoveToPhase(current.phase, mutation.phase)) throw new Error('Move through the meeting workflow one phase at a time.');
      await checked(supabase.from('meetings').update({ title: mutation.title, purpose: mutation.purpose, agenda: mutation.agenda, shared_summary: mutation.sharedSummary || null, follow_up: mutation.followUp || null, current_phase: mutation.phase, status: mutation.phase === 'PREPARE' ? 'PREPARED' : mutation.phase === 'FOLLOW_UP' ? 'COMPLETED' : 'IN_PROGRESS' }).eq('id', mutation.meetingId).eq('organization_id', session.organization.id));
    } else if (mutation.action === 'ADD_PRIVATE_NOTE') {
      await checked(supabase.rpc('create_private_meeting_note', { p_meeting_id: mutation.meetingId, p_kind: mutation.kind, p_subject_person_id: session.personId, p_content: mutation.content }));
    } else if (mutation.action === 'ADD_SHARED_NOTE') {
      await checked(supabase.rpc('add_shared_meeting_note', { p_meeting_id: current.id, p_content: mutation.content }));
    } else if (mutation.action === 'ADD_DECISION') {
      await checked(supabase.rpc('add_meeting_decision', { p_meeting_id: current.id, p_statement: mutation.statement, p_rationale: mutation.rationale, p_intended_effect: mutation.intendedEffect, p_review_trigger: mutation.reviewTrigger }));
    } else if (mutation.action === 'ADD_COMMITMENT') {
      if (!current.participants.some((person) => person.id === mutation.ownerPersonId)) throw new Error('Commitment owner must be a meeting participant.');
      await checked(supabase.rpc('add_meeting_commitment', { p_meeting_id: current.id, p_owner_person_id: mutation.ownerPersonId, p_action: mutation.actionText, p_due_on: mutation.dueOn ?? null }));
    } else if (mutation.action === 'UPDATE_COMMITMENT') {
      const commitment = current.commitments.find((item) => item.id === mutation.commitmentId);
      if (!commitment || (session.role === 'client' && commitment.ownerPersonId !== session.personId)) throw new Error('Commitment is not available.');
      await checked(supabase.from('commitments').update({ status: mutation.status, completed_at: mutation.status === 'COMPLETED' ? new Date().toISOString() : null }).eq('id', mutation.commitmentId).eq('organization_id', session.organization.id));
    }
  }
  return getMeetingCenter(session);
}

async function checked(resultPromise: PromiseLike<{ error: { message: string } | null }>) {
  const { error } = await resultPromise;
  if (error) throw dataAccessError(error, 'lib/meetings/repository.ts');
}

function formatDate(value: string) {
  return new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric' }).format(new Date(value));
}

function titleCase(value: string) {
  return value.toLowerCase().replaceAll('_', ' ').replace(/(^|\s)\w/g, (letter) => letter.toUpperCase());
}
