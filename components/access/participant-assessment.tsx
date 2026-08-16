'use client';

import { useState, type FormEvent } from 'react';
import { CheckCircle2, LockKeyhole } from 'lucide-react';
import type { ParticipantAssessment as Assessment } from '@/lib/access/assessment';

export function ParticipantAssessment({ token, assessment }: { token: string; assessment: Assessment }) {
  const [pending, setPending] = useState(false);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [message, setMessage] = useState('');
  const item = assessment.items[currentIndex];
  const complete = currentIndex >= assessment.items.length;

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!item) return;
    const values = new FormData(event.currentTarget);
    setPending(true);
    setMessage('');
    try {
      const response = await fetch('/api/assessment-response', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ token, itemId: item.itemId, value: values.get('response') }),
      });
      const body = await response.json();
      if (!response.ok) throw new Error(body.error);
      setCurrentIndex((index) => index + 1);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Response could not be submitted.');
    } finally {
      setPending(false);
    }
  }

  if (complete) {
    return <main className="participant-page"><section className="participant-card complete"><CheckCircle2 aria-hidden="true" /><p className="eyebrow">Responses received</p><h1>Thank you.</h1><p>Your responses have been recorded as evidence for this inquiry. They are not treated as a diagnosis.</p></section></main>;
  }

  const options = Array.isArray(item.responseOptions) ? item.responseOptions : [1, 2, 3, 4, 5];
  return <main className="participant-page"><section className="participant-card"><header><p className="eyebrow">{assessment.organizationName}</p><h1>{assessment.instrumentName}</h1><p>Focused organizational inquiry · Question {currentIndex + 1} of {assessment.items.length}</p></header><p className="participant-privacy"><LockKeyhole aria-hidden="true" />{assessment.confidentiality === 'ANONYMOUS' ? 'Anonymous: this link retains no name, email, or person reference.' : assessment.confidentiality === 'CONFIDENTIAL' ? 'Confidential: identity and response content remain physically separated.' : 'Identified: your response is visible only within the stated engagement permissions.'}</p><form key={item.itemId} onSubmit={submit}><fieldset><legend>{item.prompt}</legend><div className="response-scale">{options.map((option) => <label key={String(option)}><input type="radio" name="response" value={String(option)} required /><span>{String(option)}</span></label>)}</div><div className="scale-labels"><small>Strongly disagree</small><small>Strongly agree</small></div></fieldset>{message && <p className="form-error" role="alert">{message}</p>}<button className="primary-button" disabled={pending}>{pending ? 'Submitting securely…' : currentIndex + 1 === assessment.items.length ? 'Submit final response' : 'Save and continue'}</button></form><footer>Link expires {new Date(assessment.closesAt).toLocaleDateString()} · {assessment.items.length - currentIndex} remaining</footer></section></main>;
}
