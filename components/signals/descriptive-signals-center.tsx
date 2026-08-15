'use client';

import { useState } from 'react';
import { ArrowRight, BarChart3, CircleHelp, Eye, FileSearch, History, LockKeyhole, RefreshCcw, ShieldCheck } from 'lucide-react';
import type { SignalKind, SignalsMutation, SignalsWorkspaceData } from '@/lib/signals/types';
import { signalKinds } from '@/lib/signals/workflow';
import { postJson } from '@/lib/client/api';

export function DescriptiveSignalsCenter({ initialData }: { initialData: SignalsWorkspaceData }) {
  const [data, setData] = useState(initialData); const [pending, setPending] = useState(false); const [message, setMessage] = useState('');
  async function mutate(mutation: SignalsMutation) {
    setPending(true); setMessage('');
    try {
      setData(await postJson<SignalsWorkspaceData>('/api/signals', mutation, 'The Signals action could not be completed.')); setMessage(mutation.action === 'REENTER_SIGNAL' ? 'Signal re-entered as a new Observation. The original Signal and source path remain intact.' : 'Saved. Longitudinal context and source boundaries remain inspectable.');
    } catch (error) { setMessage(error instanceof Error ? error.message : 'The Signals action could not be completed.'); }
    finally { setPending(false); }
  }
  return <div className="signals-center">
    <section className="signals-principle">
      <div><p className="eyebrow"><Eye aria-hidden="true" />SEE AGAIN</p><h2>Notice change without naming it too soon</h2><p>Signals describe what may deserve attention. They do not establish a recurring Pattern, diagnose drift, or claim cause.</p></div>
      <span className="status-chip gold"><ShieldCheck aria-hidden="true" />Descriptive only</span>
    </section>
    <div className="signals-guardrails" aria-label="Signals guardrails"><span><FileSearch aria-hidden="true" />Evidence remains inspectable</span><span><BarChart3 aria-hidden="true" />Only compatible measures are compared</span><span><LockKeyhole aria-hidden="true" />Private coaching is excluded</span><span><RefreshCcw aria-hidden="true" />Re-entry requires a human action</span></div>
    {message && <p className="signals-message" role="status">{message}</p>}
    {data.baseline && <section className="signals-baseline"><div><p className="eyebrow">Operative baseline</p><h3>{data.baseline.label}</h3><p>{data.baseline.scope}</p></div><div><LockKeyhole aria-hidden="true" /><strong>{data.baseline.establishedLabel}</strong><span>Immutable manifest · {data.baseline.memberCount} records</span></div></section>}
    {data.role === 'consultant' && <AddSignalForm data={data} pending={pending} onMutate={mutate} />}
    <section className="signals-workspace-grid">
      <div className="signals-column">
        <header className="signals-section-heading"><div><p className="eyebrow">New observations</p><h3>Changes worth noticing</h3></div><span className="count-pill">{data.signals.length}</span></header>
        <div className="signal-card-list">{data.signals.map((signal) => <article className="signal-card" key={signal.id}>
          <header><span>{label(signal.kind)}</span><small>{signal.detectedLabel}</small></header><h4>{signal.statement}</h4><p>{signal.context}</p>
          <footer><span><FileSearch aria-hidden="true" />{signal.sourceLabel}</span><span className={`signal-state ${signal.status.toLowerCase()}`}>{signal.status}</span></footer>
          {data.role === 'consultant' && signal.status !== 'REENTERED' && <ReentryForm signalId={signal.id} pending={pending} onMutate={mutate} />}
          {data.reentries.filter((entry) => entry.signalId === signal.id).map((entry) => <div className="reentry-proof" key={entry.observationId}><RefreshCcw aria-hidden="true" /><span><small>{entry.relationship}</small><strong>{entry.statement}</strong></span></div>)}
        </article>)}</div>
      </div>
      <div className="signals-column">
        <header className="signals-section-heading"><div><p className="eyebrow gold">Trends</p><h3>Compatible comparisons</h3></div><span className="count-pill gold">{data.trends.length}</span></header>
        <div className="trend-card-list">{data.trends.map((trend) => <article className="trend-card" key={trend.id}><header><BarChart3 aria-hidden="true" /><div><small>{trend.indicator}</small><strong>{trend.direction}</strong></div></header><div className="trend-values"><span>{trend.baseline}</span><ArrowRight aria-hidden="true" /><span>{trend.current}</span></div><p>{trend.statement}</p><dl><div><dt>Compatibility</dt><dd>{trend.compatibility}</dd></div><div><dt>Limit</dt><dd>{trend.limitations}</dd></div></dl></article>)}</div>
      </div>
    </section>
    <section className="signals-workspace-grid lower">
      <article className="assumption-watch"><header><History aria-hidden="true" /><div><p className="eyebrow">Assumptions to revisit</p><h3>Beliefs with a review trigger</h3></div></header>{data.assumptions.map((assumption) => <section key={assumption.id}><div><span className={`signal-state ${assumption.status.toLowerCase()}`}>{assumption.status}</span><small>{assumption.dueLabel}</small><strong>{assumption.statement}</strong><p>{assumption.trigger}</p></div>{data.role === 'consultant' && assumption.status !== 'COMPLETED' && <AssumptionReviewForm scheduleId={assumption.id} pending={pending} onMutate={mutate} />}</section>)}</article>
      <article className="emerging-questions"><header><CircleHelp aria-hidden="true" /><div><p className="eyebrow gold">Emerging questions</p><h3>Inquiry before conclusion</h3></div></header><ol>{data.questions.map((question) => <li key={question.id}><span>{question.reviewState}</span><strong>{question.question}</strong><small>{question.sourceLabel}</small></li>)}</ol></article>
    </section>
    <p className="signals-boundary-note"><ShieldCheck aria-hidden="true" />This V1 workspace does not perform autonomous drift detection, predictive organizational modeling, or causal diagnosis.</p>
  </div>;
}

function AddSignalForm({ data, pending, onMutate }: { data: SignalsWorkspaceData; pending: boolean; onMutate: (mutation: SignalsMutation) => void }) {
  return <form className="add-signal-form" onSubmit={(event) => { event.preventDefault(); const form = event.currentTarget; const values = new FormData(form); onMutate({ action: 'ADD_SIGNAL', statement: String(values.get('statement')), kind: String(values.get('kind')) as SignalKind, context: String(values.get('context')), evidenceId: String(values.get('evidenceId')) }); form.reset(); }}><header><div><p className="eyebrow">Record a Signal</p><h3>Describe the change, then attach its source</h3></div><span>Signal ≠ Pattern</span></header><div><label>What changed?<textarea name="statement" required placeholder="Describe what was observed or reported." /></label><label>Signal type<select name="kind">{signalKinds.map((kind) => <option key={kind}>{kind}</option>)}</select></label><label>Context<input name="context" required placeholder="Where and when was this noticed?" /></label><label>Primary evidence<select name="evidenceId" required>{data.evidenceSources.map((item) => <option value={item.id} key={item.id}>{item.label}</option>)}</select></label></div><button className="secondary-button" disabled={pending || data.evidenceSources.length === 0}>Record descriptive Signal</button></form>;
}

function ReentryForm({ signalId, pending, onMutate }: { signalId: string; pending: boolean; onMutate: (mutation: SignalsMutation) => void }) {
  return <details className="reentry-control"><summary>Re-enter as a new Observation <ArrowRight aria-hidden="true" /></summary><form onSubmit={(event) => { event.preventDefault(); const values = new FormData(event.currentTarget); onMutate({ action: 'REENTER_SIGNAL', signalId, observationStatement: String(values.get('observationStatement')), context: String(values.get('context')) }); }}><label>Observation statement<textarea name="observationStatement" required placeholder="State what can now be observed without explaining why." /></label><label>Renewed inquiry context<input name="context" required defaultValue="SEE AGAIN review" /></label><button className="secondary-button" disabled={pending}>Create Observation & preserve re-entry</button></form></details>;
}

function AssumptionReviewForm({ scheduleId, pending, onMutate }: { scheduleId: string; pending: boolean; onMutate: (mutation: SignalsMutation) => void }) {
  return <form className="assumption-review-form" onSubmit={(event) => { event.preventDefault(); const values = new FormData(event.currentTarget); onMutate({ action: 'COMPLETE_ASSUMPTION_REVIEW', scheduleId, reviewNote: String(values.get('reviewNote')) }); }}><label>Review note<input name="reviewNote" required placeholder="What did the current evidence show?" /></label><button className="secondary-button" disabled={pending}>Complete review</button></form>;
}

function label(kind: SignalKind) { return kind.toLowerCase().replaceAll('_', ' '); }
