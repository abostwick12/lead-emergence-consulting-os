'use client';

import { useState, type FormEvent } from 'react';
import { AlertTriangle, BookOpenCheck, BrainCircuit, CheckCircle2, LockKeyhole, Quote, ShieldCheck, Sparkles, XCircle } from 'lucide-react';
import type { MeridianAiData, MeridianMutation, MeridianSource, MeridianSuggestion } from '@/lib/meridian-ai/types';

export function GroundedAssistance({ initialData }: { initialData: MeridianAiData }) {
  const [data, setData] = useState(initialData);
  const [pending, setPending] = useState(false);
  const [message, setMessage] = useState('');

  async function mutate(mutation: MeridianMutation) {
    setPending(true); setMessage('');
    try {
      const response = await fetch('/api/meridian-ai', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(mutation) });
      const body = await response.json();
      if (!response.ok) throw new Error(body.error ?? 'Meridian could not complete the grounded request.');
      setData(body);
      setMessage(mutation.action === 'REJECT_SUGGESTION' ? 'Rejected suggestion preserved in review history and removed from active retrieval.' : 'Grounded suggestion created with its exact permission-eligible source set.');
    } catch (error) { setMessage(error instanceof Error ? error.message : 'Meridian could not complete the grounded request.'); }
    finally { setPending(false); }
  }

  return <section className="meridian-grounded" aria-labelledby="meridian-grounded-title">
    <header className="meridian-grounded-header">
      <div><p className="eyebrow"><BrainCircuit aria-hidden="true" />Meridian · grounded assistance</p><h2 id="meridian-grounded-title">Evidence in view. Judgment stays human.</h2><p>Meridian works inside this engagement context; it is not a generic chatbot and cannot turn a suggestion into organizational truth.</p></div>
      <button className="primary-button" type="button" disabled={pending} onClick={() => mutate({ action: 'GENERATE_PATTERN', sourceIds: data.meetingPreparation.sources.map((source) => source.id) })}><Sparkles aria-hidden="true" />{pending ? 'Grounding…' : 'Suggest a pattern'}</button>
    </header>
    {message && <p className={message.startsWith('Insufficient') ? 'meridian-message warning' : 'meridian-message'} role="status">{message}</p>}
    <div className="meridian-guardrails">{data.guardrails.map((guardrail) => <span key={guardrail}><ShieldCheck aria-hidden="true" />{guardrail}</span>)}</div>
    <div className="meridian-layout">
      <div className="meridian-suggestions">
        <div className="section-heading"><div><p className="eyebrow">Review queue</p><h3>Suggestions with provenance</h3></div><p className="section-note">{data.suggestions.length} active · {data.rejectedSuggestions.length} rejected and preserved</p></div>
        {data.suggestions.map((suggestion) => <SuggestionCard suggestion={suggestion} pending={pending} onReject={(rationale) => mutate({ action: 'REJECT_SUGGESTION', suggestionId: suggestion.id, rationale })} key={suggestion.id} />)}
        {!data.suggestions.length && <div className="meridian-empty"><CheckCircle2 aria-hidden="true" /><strong>No active suggestions</strong><p>Rejected candidates remain historical records and are not returned as operative truth.</p></div>}
        {!!data.rejectedSuggestions.length && <details className="rejected-archive"><summary><XCircle aria-hidden="true" />Rejected suggestion history</summary>{data.rejectedSuggestions.map((suggestion) => <article key={suggestion.id}><strong>{suggestion.title}</strong><p>{suggestion.reviewRationale}</p><small>AI origin retained · rejected · excluded from active retrieval</small></article>)}</details>}
      </div>
      <MeetingPreparation data={data} />
    </div>
  </section>;
}

function SuggestionCard({ suggestion, pending, onReject }: { suggestion: MeridianSuggestion; pending: boolean; onReject: (rationale: string) => void }) {
  const [reviewing, setReviewing] = useState(false);
  function submit(event: FormEvent<HTMLFormElement>) { event.preventDefault(); const rationale = String(new FormData(event.currentTarget).get('rationale')); onReject(rationale); setReviewing(false); }
  const supporting = suggestion.sources.filter((source) => source.role === 'SUPPORTING');
  const challenging = suggestion.sources.filter((source) => source.role === 'CHALLENGING');
  return <article className="meridian-suggestion-card">
    <header><div className="ai-state"><span><Sparkles aria-hidden="true" />AI ORIGIN</span><span>SUGGESTED</span></div><small>{suggestion.generatedLabel}</small></header>
    <h4>{suggestion.title}</h4><p className="suggestion-statement">{suggestion.statement}</p>
    <dl><div><dt>Scope</dt><dd>{suggestion.scope}</dd></div><div><dt>Recurrence basis</dt><dd>{suggestion.recurrenceBasis}</dd></div></dl>
    <div className="evidence-contrast"><SourceGroup title="Supporting evidence" sources={supporting} /><SourceGroup title="Contrary evidence" sources={challenging} contrary /></div>
    <p className="meridian-limitation"><AlertTriangle aria-hidden="true" /><span><strong>Limitations</strong>{suggestion.limitations}</span></p>
    <footer><span><LockKeyhole aria-hidden="true" />{suggestion.sources.length} authorized source fragments</span><button className="secondary-button" type="button" onClick={() => setReviewing((value) => !value)}>Review suggestion</button></footer>
    {reviewing && <form className="meridian-review-form" onSubmit={submit}><label>Why should this suggestion be rejected?<textarea name="rationale" rows={3} required placeholder="Name the evidence, disagreement, or epistemic boundary…" /></label><button className="danger-button" type="submit" disabled={pending}><XCircle aria-hidden="true" />Reject and preserve history</button></form>}
  </article>;
}

function SourceGroup({ title, sources, contrary }: { title: string; sources: MeridianSource[]; contrary?: boolean }) {
  return <section className={contrary ? 'source-group contrary' : 'source-group'}><h5>{contrary ? <AlertTriangle aria-hidden="true" /> : <BookOpenCheck aria-hidden="true" />}{title}</h5>{sources.length ? sources.map((source) => <article key={`${source.id}-${source.fragmentId}`}><header><strong>{source.title}</strong><span>{source.locator}</span></header><p><Quote aria-hidden="true" />{source.excerpt}</p><small>{source.visibility.replaceAll('_', ' ')}</small></article>) : <p>No permission-eligible contrary source was found; treat the suggestion as insufficient.</p>}</section>;
}

function MeetingPreparation({ data }: { data: MeridianAiData }) {
  const brief = data.meetingPreparation;
  return <aside className="meridian-meeting-prep"><p className="eyebrow">Contextual assistance</p><h3>Leadership review preparation</h3><p>{brief.summary}</p><h4>Questions to carry</h4><ol>{brief.questions.map((question) => <li key={question}>{question}</li>)}</ol><p className="meridian-limitation"><ShieldCheck aria-hidden="true" /><span><strong>Permission boundary</strong>{brief.limitations}</span></p><div className="prep-source-list">{brief.sources.map((source) => <span key={source.fragmentId}>{source.title} · {source.locator}</span>)}</div></aside>;
}
