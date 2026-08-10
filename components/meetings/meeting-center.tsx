'use client';

import { useMemo, useState, type FormEvent } from 'react';
import { CalendarPlus, Check, ChevronRight, Clock3, LockKeyhole, MessageSquareText, ShieldCheck, UserRoundCheck, UsersRound } from 'lucide-react';
import { meetingPhases, type MeetingCenterData, type MeetingMutation, type MeetingView } from '@/lib/meetings/types';

export function MeetingCenter({ initialData, initialMeetingId }: { initialData: MeetingCenterData; initialMeetingId?: string }) {
  const [data, setData] = useState(initialData);
  const [selectedId, setSelectedId] = useState(initialMeetingId ?? initialData.meetings[0]?.id ?? '');
  const [creating, setCreating] = useState(false);
  const [pending, setPending] = useState(false);
  const [message, setMessage] = useState('');
  const selected = useMemo(() => data.meetings.find((meeting) => meeting.id === selectedId) ?? data.meetings[0], [data.meetings, selectedId]);

  async function mutate(mutation: MeetingMutation) {
    setPending(true); setMessage('');
    try {
      const response = await fetch('/api/meetings', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(mutation) });
      const body = await response.json();
      if (!response.ok) throw new Error(body.error ?? 'The change could not be saved.');
      setData(body);
      if (mutation.action === 'CREATE_MEETING') setSelectedId(body.meetings[0]?.id ?? selectedId);
      setCreating(false); setMessage('Saved. The shared meeting record and its privacy boundary are current.');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'The change could not be saved.');
    } finally { setPending(false); }
  }

  return (
    <div className="meeting-center">
      <section className="meeting-command-bar" aria-label="Meeting controls">
        <div><p className="eyebrow">Shared interaction engine</p><strong>{data.meetings.length} active meeting records</strong></div>
        {data.role === 'consultant' && <button className="primary-button" type="button" onClick={() => setCreating((value) => !value)}><CalendarPlus aria-hidden="true" />New meeting</button>}
      </section>
      {message && <p className="meeting-message" role="status">{message}</p>}
      {creating && <CreateMeetingForm data={data} pending={pending} onCreate={mutate} />}
      <div className="meeting-layout">
        <aside className="meeting-list" aria-label="Meeting history">
          {data.meetings.map((meeting) => <button type="button" className={meeting.id === selected?.id ? 'meeting-list-item active' : 'meeting-list-item'} key={meeting.id} onClick={() => setSelectedId(meeting.id)}>
            <span className={`meeting-type type-${meeting.type.toLowerCase()}`}>{meeting.type}</span>
            <strong>{meeting.title}</strong>
            <small><Clock3 aria-hidden="true" />{formatDateTime(meeting.scheduledStart)}</small>
            <span>{meeting.phase.replace('_', ' ')} <ChevronRight aria-hidden="true" /></span>
          </button>)}
        </aside>
        {selected ? <MeetingWorkspace meeting={selected} data={data} pending={pending} onMutate={mutate} /> : <section className="empty-state"><strong>No meetings yet</strong><p>Create the first permission-bounded interaction record.</p></section>}
      </div>
    </div>
  );
}

function CreateMeetingForm({ data, pending, onCreate }: { data: MeetingCenterData; pending: boolean; onCreate: (mutation: MeetingMutation) => void }) {
  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const values = new FormData(event.currentTarget);
    onCreate({ action: 'CREATE_MEETING', meetingType: String(values.get('meetingType')) as 'CONSULTING' | 'COACHING', title: String(values.get('title')), purpose: String(values.get('purpose')), scheduledStart: String(values.get('scheduledStart')), participantPersonId: String(values.get('participantPersonId')), developmentFocus: String(values.get('developmentFocus') ?? '') });
  }
  return <form className="meeting-form create-meeting-form" onSubmit={submit}>
    <div className="section-heading"><div><p className="eyebrow">Create</p><h2>New interaction</h2></div><p className="section-note">Coaching uses the same engine with named-participant privacy.</p></div>
    <div className="meeting-form-grid">
      <label>Type<select name="meetingType" defaultValue="CONSULTING"><option value="CONSULTING">Consulting meeting</option><option value="COACHING">Coaching session</option></select></label>
      <label>Participant<select name="participantPersonId" defaultValue={data.people.find((person) => person.relationship === 'CLIENT')?.id}>{data.people.filter((person) => person.id !== data.currentPersonId).map((person) => <option value={person.id} key={person.id}>{person.name}</option>)}</select></label>
      <label className="wide">Title<input name="title" required placeholder="Alignment working session" /></label>
      <label className="wide">Purpose<textarea name="purpose" required rows={2} placeholder="What must become clearer or more actionable?" /></label>
      <label>Starts<input name="scheduledStart" type="datetime-local" required /></label>
      <label>Development focus<input name="developmentFocus" placeholder="Required for coaching" /></label>
    </div>
    <button className="primary-button" disabled={pending} type="submit">{pending ? 'Saving…' : 'Create meeting'}</button>
  </form>;
}

function MeetingWorkspace({ meeting, data, pending, onMutate }: { meeting: MeetingView; data: MeetingCenterData; pending: boolean; onMutate: (mutation: MeetingMutation) => void }) {
  return <article className="meeting-workspace">
    <header className="meeting-workspace-header">
      <div><div className="record-meta"><span className={`meeting-type type-${meeting.type.toLowerCase()}`}>{meeting.type}</span><span>{meeting.status}</span>{meeting.type === 'COACHING' && <span className="privacy-chip"><LockKeyhole aria-hidden="true" />NAMED PARTICIPANTS</span>}</div><h2>{meeting.title}</h2><p>{meeting.purpose}</p></div>
      <div className="meeting-people"><UsersRound aria-hidden="true" /><span>{meeting.participants.map((person) => person.name).join(' · ')}</span></div>
    </header>
    <ol className="meeting-phases" aria-label="Meeting workflow">{meetingPhases.map((phase, index) => <li className={phase === meeting.phase ? 'current' : meetingPhases.indexOf(meeting.phase) > index ? 'complete' : ''} key={phase}><span>{index + 1}</span>{phase.replace('_', ' ')}</li>)}</ol>
    {meeting.coaching && <section className="coaching-contract"><ShieldCheck aria-hidden="true" /><div><strong>{meeting.coaching.developmentFocus}</strong><p>{meeting.coaching.confidentialityStatement}</p></div><span>Session {meeting.coaching.sessionNumber}</span></section>}
    <div className="meeting-panels">
      <section><p className="eyebrow">Before we meet</p><h3>Agenda & permitted context</h3>{data.role === 'consultant' ? <MeetingPlanForm meeting={meeting} pending={pending} onMutate={onMutate} /> : <p className="agenda-copy">{meeting.agenda}</p>}
        <div className="context-items">{meeting.context.length ? meeting.context.map((item) => <span key={item.id}><ShieldCheck aria-hidden="true" />{item.label}<small>{item.state}</small></span>) : <p>No shared context has been attached.</p>}</div>
      </section>
      <section><p className="eyebrow">Capture</p><h3>Shared conversation</h3><NoteList notes={meeting.notes.filter((note) => note.privacy === 'SHARED')} empty="No shared notes yet." /><QuickForm label="Add shared note" placeholder="Capture what participants may revisit together…" button="Save shared note" pending={pending} onSubmit={(content) => onMutate({ action: 'ADD_SHARED_NOTE', meetingId: meeting.id, content })} /></section>
      <section className="private-panel"><p className="eyebrow">Private partition</p><h3>{data.role === 'consultant' ? 'Consultant notes' : 'My reflection'}</h3><p className="privacy-explainer"><LockKeyhole aria-hidden="true" />This content stays outside shared notes, organizational telemetry, search, and unrelated preparation.</p><NoteList notes={meeting.notes.filter((note) => note.privacy === 'PRIVATE')} empty="No private reflections saved by you." /><QuickForm label="Add private reflection" placeholder="Write within your private boundary…" button="Save privately" pending={pending} onSubmit={(content) => onMutate({ action: 'ADD_PRIVATE_NOTE', meetingId: meeting.id, content, kind: data.role === 'consultant' ? 'CONSULTANT_NOTE' : 'INDIVIDUAL_REFLECTION' })} /></section>
      <section><p className="eyebrow">Commit</p><h3>Commitments across sessions</h3><div className="commitment-list">{meeting.commitments.map((commitment) => <div className="commitment-row" key={commitment.id}><button disabled={pending || (data.role === 'client' && commitment.ownerPersonId !== data.currentPersonId)} aria-label={`Mark ${commitment.action} complete`} type="button" onClick={() => onMutate({ action: 'UPDATE_COMMITMENT', meetingId: meeting.id, commitmentId: commitment.id, status: commitment.status === 'COMPLETED' ? 'OPEN' : 'COMPLETED' })}>{commitment.status === 'COMPLETED' && <Check aria-hidden="true" />}</button><div><strong>{commitment.action}</strong><small>{commitment.ownerName}{commitment.dueOn ? ` · due ${formatDate(commitment.dueOn)}` : ''}</small></div><span>{commitment.status.replace('_', ' ')}</span></div>)}</div><CommitmentForm meeting={meeting} currentPersonId={data.currentPersonId} pending={pending} onMutate={onMutate} /></section>
    </div>
  </article>;
}

function MeetingPlanForm({ meeting, pending, onMutate }: { meeting: MeetingView; pending: boolean; onMutate: (mutation: MeetingMutation) => void }) {
  function submit(event: FormEvent<HTMLFormElement>) { event.preventDefault(); const values = new FormData(event.currentTarget); onMutate({ action: 'UPDATE_MEETING', meetingId: meeting.id, title: String(values.get('title')), purpose: String(values.get('purpose')), agenda: String(values.get('agenda')), phase: String(values.get('phase')) as MeetingView['phase'] }); }
  const currentIndex = meetingPhases.indexOf(meeting.phase);
  return <form className="meeting-form plan-form" onSubmit={submit}><label>Title<input name="title" defaultValue={meeting.title} required /></label><label>Purpose<textarea name="purpose" defaultValue={meeting.purpose} rows={2} required /></label><label>Agenda<textarea name="agenda" defaultValue={meeting.agenda} rows={5} required /></label><label>Workflow stage<select name="phase" defaultValue={meeting.phase}>{meetingPhases.filter((_, index) => index === currentIndex || index === currentIndex + 1).map((phase) => <option value={phase} key={phase}>{phase.replace('_', ' ')}</option>)}</select></label><button className="secondary-button" disabled={pending} type="submit">Save meeting plan</button></form>;
}

function QuickForm({ label, placeholder, button, pending, onSubmit }: { label: string; placeholder: string; button: string; pending: boolean; onSubmit: (content: string) => void }) {
  function submit(event: FormEvent<HTMLFormElement>) { event.preventDefault(); const form = event.currentTarget; const content = String(new FormData(form).get('content')); onSubmit(content); form.reset(); }
  return <form className="quick-form" onSubmit={submit}><label><span>{label}</span><textarea name="content" placeholder={placeholder} rows={3} required /></label><button className="secondary-button" disabled={pending} type="submit"><MessageSquareText aria-hidden="true" />{button}</button></form>;
}

function CommitmentForm({ meeting, currentPersonId, pending, onMutate }: { meeting: MeetingView; currentPersonId: string; pending: boolean; onMutate: (mutation: MeetingMutation) => void }) {
  function submit(event: FormEvent<HTMLFormElement>) { event.preventDefault(); const form = event.currentTarget; const values = new FormData(form); onMutate({ action: 'ADD_COMMITMENT', meetingId: meeting.id, ownerPersonId: String(values.get('ownerPersonId')), actionText: String(values.get('actionText')), dueOn: String(values.get('dueOn') ?? '') || undefined }); form.reset(); }
  return <form className="meeting-form commitment-form" onSubmit={submit}><label>Owner<select name="ownerPersonId" defaultValue={currentPersonId}>{meeting.participants.map((person) => <option value={person.id} key={person.id}>{person.name}</option>)}</select></label><label>Due<input name="dueOn" type="date" /></label><label className="wide">Commitment<input name="actionText" required placeholder="What will be done before the next review?" /></label><button className="secondary-button" disabled={pending} type="submit"><UserRoundCheck aria-hidden="true" />Add commitment</button></form>;
}

function NoteList({ notes, empty }: { notes: MeetingView['notes']; empty: string }) { return <div className="note-list">{notes.length ? notes.map((note) => <div className={note.privacy === 'PRIVATE' ? 'note-card private' : 'note-card'} key={note.id}><p>{note.content}</p><small>{note.authorName} · {note.createdLabel}</small></div>) : <p className="panel-empty">{empty}</p>}</div>; }
function formatDate(value: string) { return new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric' }).format(new Date(`${value}T12:00:00`)); }
function formatDateTime(value: string) { return new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' }).format(new Date(value)); }
