'use client';

import { useState } from 'react';
import { Check, Clipboard, ExternalLink, MessageCircle, Play } from 'lucide-react';
import { logError } from '@/lib/errors';
import type { StartedAssessmentAdministration } from '@/lib/operational-ai/assessment-administration';

export function AssessmentStartActions({ slug }: { slug: string }) {
  const [started, setStarted] = useState<StartedAssessmentAdministration | null>(null);
  const [pending, setPending] = useState(false);
  const [message, setMessage] = useState('');
  const [copied, setCopied] = useState(false);

  async function prepare() {
    setPending(true);
    setMessage('');
    try {
      const response = await fetch(`/api/assessment-instruments/${slug}/start`, { method: 'POST' });
      const body = await response.json();
      if (!response.ok) throw new Error(body.error);
      setStarted(body as StartedAssessmentAdministration);
    } catch (error) {
      logError('assessment.prepareAdministration', error);
      setMessage(error instanceof Error ? error.message : 'The guided administration could not be prepared.');
    } finally {
      setPending(false);
    }
  }

  async function copyBrief() {
    if (!started) return;
    try {
      await navigator.clipboard.writeText(started.conversationBrief);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 2200);
    } catch (error) {
      logError('assessment.copyConversationBrief', error);
      setMessage('The ChatGPT brief could not be copied. Use the in-platform administration instead.');
    }
  }

  if (!started) return <div className="assessment-start-actions"><button className="primary-button" type="button" disabled={pending} onClick={() => void prepare()}><Play aria-hidden="true" />{pending ? 'Preparing…' : 'Prepare guided administration'}</button>{message && <p className="form-error" role="alert">{message}</p>}</div>;

  return <section className="assessment-start-ready" aria-live="polite">
    <div><p className="eyebrow">ADMINISTRATION READY</p><h3>Choose the facilitation experience.</h3><p>The same complete, versioned instrument is used in either path. Confirmed answers are retained as evidence—not diagnosis.</p></div>
    <div className="assessment-start-choices">
      <a className="primary-button" href={started.participantPath}><Play aria-hidden="true" /> Open guided assessment</a>
      <button className="secondary-button" type="button" onClick={() => void copyBrief()}>{copied ? <Check aria-hidden="true" /> : <Clipboard aria-hidden="true" />}{copied ? 'Brief copied' : 'Copy ChatGPT MCP brief'}</button>
      <a className="text-button" href="https://chatgpt.com/" target="_blank" rel="noreferrer"><MessageCircle aria-hidden="true" /> Open ChatGPT <ExternalLink aria-hidden="true" /></a>
    </div>
    <p className="assessment-mcp-note">The ChatGPT path requires the Lead Emergence Consulting OS MCP connection. The brief instructs ChatGPT to ask one item at a time and save only explicitly confirmed responses.</p>
    {message && <p className="form-error" role="alert">{message}</p>}
  </section>;
}
