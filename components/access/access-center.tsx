'use client';

import { useState, type FormEvent } from 'react';
import { ClipboardCheck, Copy, MailCheck, ShieldCheck, UserRoundPlus } from 'lucide-react';
import type { AccessCenterData, AccessMutation, AccessMutationResult, ClientPlatformRole } from '@/lib/access/types';
import { postJson } from '@/lib/client/api';

export function AccessCenter({ initialData }: { initialData: AccessCenterData }) {
  const [data, setData] = useState(initialData);
  const [pending, setPending] = useState(false);
  const [message, setMessage] = useState('');
  const [participantUrl, setParticipantUrl] = useState('');

  async function mutate(mutation: AccessMutation, form?: HTMLFormElement) {
    setPending(true); setMessage('');
    try {
      const body = await postJson<AccessMutationResult>('/api/access', mutation, 'Access action failed.');
      setData(body);
      if (body.participantUrl) { setParticipantUrl(body.participantUrl); setMessage('Participant link created. Copy it now; the raw token is not stored.'); }
      else { form?.reset(); setMessage('Secure client invitation sent. Access activates only after verification.'); }
    } catch (error) { setMessage(error instanceof Error ? error.message : 'Access action failed.'); }
    finally { setPending(false); }
  }

  return <section className="access-center" aria-labelledby="access-center-heading">
    <header><div><p className="eyebrow">Access & participation</p><h2 id="access-center-heading">Invite the right people, in the right context.</h2><p>Client accounts are engagement-bound. Assessment links are separate, expiring capabilities with explicit privacy.</p></div><ShieldCheck aria-hidden="true" /></header>
    <div className="access-grid">
      <article className="access-panel"><div className="panel-heading"><UserRoundPlus aria-hidden="true" /><div><h3>Client portal invitation</h3><p>For named leaders and members who need an ongoing account.</p></div></div>
        <form className="access-form" onSubmit={(event) => { event.preventDefault(); const form = event.currentTarget; const values = new FormData(form); void mutate({ action: 'INVITE_CLIENT', displayName: String(values.get('displayName')), email: String(values.get('email')), role: String(values.get('role')) as ClientPlatformRole }, form); }}>
          <label>Name<input name="displayName" required /></label><label>Email<input name="email" type="email" required /></label><label className="wide">Access role<select name="role"><option value="CLIENT_ADMIN">Client administrator</option><option value="CLIENT_LEADER">Client leader</option><option value="CLIENT_MEMBER">Client member</option></select></label><button className="primary-button" disabled={pending}>Send secure invitation</button>
        </form>
        {data.invitations.length > 0 && <div className="access-list">{data.invitations.map((invite) => <div key={invite.id}><MailCheck aria-hidden="true" /><span><strong>{invite.displayName}</strong><small>{invite.email} · {invite.role.replaceAll('_', ' ')}</small></span><em>{invite.status}</em></div>)}</div>}
      </article>
      <article className="access-panel"><div className="panel-heading"><ClipboardCheck aria-hidden="true" /><div><h3>Assessment participant links</h3><p>Accountless links for the bounded inquiry—not client portal access.</p></div></div>
        {data.assessments.length === 0 ? <p className="access-empty">Create an assessment administration in Discovery first.</p> : data.assessments.map((assessment) => <form className="assessment-link-form" key={assessment.id} onSubmit={(event: FormEvent<HTMLFormElement>) => { event.preventDefault(); const values = new FormData(event.currentTarget); void mutate({ action: 'CREATE_ASSESSMENT_LINK', administrationId: assessment.id, recipientName: String(values.get('recipientName') ?? ''), recipientEmail: String(values.get('recipientEmail') ?? '') }); }}><div><strong>{assessment.name}</strong><small>{assessment.audience} · {assessment.confidentiality}</small></div>{assessment.confidentiality !== 'ANONYMOUS' && <><label>Participant name <small>Optional</small><input name="recipientName" /></label><label>Participant email <small>Optional</small><input name="recipientEmail" type="email" /></label></>}<button className="secondary-button" disabled={pending}>Create expiring link</button></form>)}
        {participantUrl && <div className="participant-link"><label>One-time participant link<input readOnly value={participantUrl} /></label><button type="button" className="secondary-button" onClick={() => void navigator.clipboard.writeText(participantUrl)}><Copy aria-hidden="true" />Copy link</button></div>}
      </article>
    </div>
    {message && <p className="access-message" role="status">{message}</p>}
  </section>;
}
