'use client';

import { useState, type FormEvent } from 'react';
import { useRouter } from 'next/navigation';
import { Building2, CalendarRange, Plus, X } from 'lucide-react';
import { postJson } from '@/lib/client/api';

export function ClientSetup() {
  const router = useRouter();
  const [open, setOpen] = useState(false); const [pending, setPending] = useState(false); const [message, setMessage] = useState('');
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); const values = new FormData(event.currentTarget); setPending(true); setMessage('');
    try {
      const body = await postJson<{ organizationId: string }>('/api/engagements', { organizationName: values.get('organizationName'), engagementName: values.get('engagementName'), engagementType: values.get('engagementType'), objective: values.get('objective'), scopeStatement: values.get('scopeStatement'), startsOn: values.get('startsOn'), endsOn: values.get('endsOn') }, 'Client setup failed.');
      const returnTo = `/consultant/clients/${body.organizationId}/overview`;
      router.push(returnTo);
      router.refresh();
    } catch (error) { setMessage(error instanceof Error ? error.message : 'Client setup failed.'); setPending(false); }
  }
  return <section className="client-setup" aria-labelledby="client-setup-heading">
    <div><p className="eyebrow">New engagement</p><h2 id="client-setup-heading">Set up an organization for discovery</h2><p>Create the protected client context before collecting interviews, assessments, workflows, or organizational evidence.</p></div>
    {!open ? <button className="primary-button" type="button" onClick={() => setOpen(true)}><Plus aria-hidden="true" /> Start client setup</button> : <button className="text-button" type="button" onClick={() => setOpen(false)}><X aria-hidden="true" /> Close</button>}
    {open && <form className="client-setup-form" onSubmit={submit}>
      <label><Building2 aria-hidden="true" />Church or organization name<input name="organizationName" required autoFocus placeholder="Grace Community Church" /></label>
      <label><Building2 aria-hidden="true" />Engagement name<input name="engagementName" required placeholder="Healthy Ministry Rhythm 2026" /></label>
      <label><Building2 aria-hidden="true" />Engagement type<select name="engagementType" defaultValue="ORGANIZATIONAL_TRANSFORMATION"><option value="ORGANIZATIONAL_TRANSFORMATION">Organizational transformation</option><option value="OPERATIONAL_PRODUCT_AI_TRANSFORMATION">Operational Product AI transformation</option></select></label>
      <label><Building2 aria-hidden="true" />Engagement objective <small>Required for Product AI</small><textarea name="objective" placeholder="What this engagement should make possible" /></label>
      <label className="wide"><Building2 aria-hidden="true" />Scope statement <small>Required for Product AI</small><textarea name="scopeStatement" placeholder="Authorized products, workflow boundaries, evidence sources, and explicit exclusions" /></label>
      <label><CalendarRange aria-hidden="true" />Start date<input name="startsOn" type="date" required /></label>
      <label><CalendarRange aria-hidden="true" />Target end date <small>Optional</small><input name="endsOn" type="date" /></label>
      <p className="form-guidance">This creates a separate tenant boundary and active consultant assignment. Client members can be invited after discovery scope is confirmed.</p>
      {message && <p className="form-error" role="alert">{message}</p>}
      <button className="primary-button" disabled={pending} type="submit">{pending ? 'Creating secure workspace…' : 'Create engagement'}</button>
    </form>}
  </section>;
}
