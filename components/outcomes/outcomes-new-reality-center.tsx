'use client';

import { useState } from 'react';
import { ArrowRight, CheckCircle2, Compass, GitCompareArrows, LockKeyhole, Sprout, Target } from 'lucide-react';
import type { OutcomeDisposition, OutcomesMutation, OutcomesNewRealityData } from '@/lib/outcomes/types';
import { nextOutcomeAction, outcomeDispositions } from '@/lib/outcomes/workflow';

export function OutcomesNewRealityCenter({ initialData }: { initialData: OutcomesNewRealityData }) {
  const [data, setData] = useState(initialData); const [pending, setPending] = useState(false); const [message, setMessage] = useState('');
  const next = nextOutcomeAction(data);
  async function mutate(mutation: OutcomesMutation) {
    setPending(true); setMessage('');
    try { const response = await fetch('/api/outcomes', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(mutation) }); const body = await response.json(); if (!response.ok) throw new Error(body.error); setData(body); setMessage('Saved. The reasoning path and historical state remain inspectable.'); }
    catch (error) { setMessage(error instanceof Error ? error.message : 'The outcome workflow could not be advanced.'); }
    finally { setPending(false); }
  }
  return <div className="outcomes-center">
    {message && <p className="outcomes-message" role="status">{message}</p>}
    <section className="value-contract">
      <header><div><p className="eyebrow">Produce value</p><h2>Expectation before evidence</h2></div><span className="status-chip">{data.valueHypothesis.status}</span></header>
      <div className="value-chain"><article><small>Value hypothesis</small><strong>{data.valueHypothesis.statement}</strong><span>{data.valueHypothesis.createdLabel}</span></article><ArrowRight aria-hidden="true" /><article><small>Goal</small><strong>{data.goal.statement}</strong><span>{data.goal.owner}</span></article><ArrowRight aria-hidden="true" /><article><small>Indicator</small><strong>{data.indicator.name}</strong><span>{data.indicator.baseline} → {data.indicator.target}</span></article></div>
    </section>
    <section className="outcome-grid">
      <article className="outcome-panel"><header><Target aria-hidden="true" /><div><p className="eyebrow">Measurement history</p><h3>{data.indicator.name}</h3></div></header><ol>{data.indicator.history.map((item) => <li key={item.period}><span>{item.period}</span><strong>{item.value}</strong></li>)}</ol>{data.outcome ? <div className="recorded-outcome"><small>Observed outcome</small><strong>{data.outcome.statement}</strong><p>{data.outcome.association} · <em>{data.outcome.causalStatus}</em></p></div> : data.role === 'consultant' && next === 'RECORD_OUTCOME' ? <OutcomeForm pending={pending} onMutate={mutate} /> : <PendingCopy text="An outcome has not been recorded." />}</article>
      <article className="outcome-panel"><header><Sprout aria-hidden="true" /><div><p className="eyebrow">Harvest & Soil</p><h3>Value in two horizons</h3></div></header>{data.evaluation ? <><div className="harvest-soil"><section><small>Harvest</small><p>{data.evaluation.harvest}</p></section><section><small>Soil</small><p>{data.evaluation.soil}</p></section></div><div className="dimension-list">{data.evaluation.dimensions.map((item) => <div key={item.name}><span>{item.name}</span><strong>{item.rating}</strong><small>{item.rationale}</small></div>)}</div></> : data.role === 'consultant' && next === 'EVALUATE_VALUE' ? <EvaluationForm pending={pending} onMutate={mutate} /> : <PendingCopy text="Harvest and Soil evaluation follows a recorded outcome." />}</article>
    </section>
    <section className="learning-panel"><div><p className="eyebrow">Human-reviewed learning</p><h2>{data.learning?.statement ?? 'Decide what the evidence teaches'}</h2>{data.learning && <span className="status-chip gold">{data.learning.reviewState} · {data.learning.disposition}</span>}</div>{data.role === 'consultant' && next === 'VALIDATE_LEARNING' ? <LearningForm pending={pending} onMutate={mutate} /> : !data.learning && <PendingCopy text="Learning remains unvalidated until Harvest and Soil are reviewed." />}</section>
    <section className="reality-comparison">
      <header><div><p className="eyebrow">New Reality</p><h2>Intent is preserved beside what emerged</h2></div><GitCompareArrows aria-hidden="true" /></header>
      <div className="reality-columns"><article><small>Future State · version {data.futureState.version}</small><p>{data.futureState.statement}</p><span>Preserved · not overwritten</span></article><article><small>Emergent Organization Profile</small>{data.emergentProfile ? <><h3>{data.emergentProfile.name}</h3><p>{data.emergentProfile.actualState}</p><span>{data.emergentProfile.difference}</span></> : <p>What actually became true has not yet been established.</p>}</article><article><small>Next baseline</small>{data.baseline ? <><h3>{data.baseline.label}</h3><p><LockKeyhole aria-hidden="true" /> Immutable manifest · {data.baseline.memberCount} records</p><span>Ready to SEE AGAIN</span></> : <p>The approved New Reality has not yet become the next baseline.</p>}</article></div>
      {data.role === 'consultant' && next === 'ESTABLISH_BASELINE' && <BaselineForm pending={pending} onMutate={mutate} />}
      {next === 'COMPLETE' && <p className="baseline-complete"><CheckCircle2 aria-hidden="true" />New Reality is preserved and ready to re-enter inquiry.</p>}
    </section>
  </div>;
}

function PendingCopy({ text }: { text: string }) { return <p className="outcome-pending"><Compass aria-hidden="true" />{text}</p>; }
function formValue(form: HTMLFormElement, name: string) { return String(new FormData(form).get(name)); }
function OutcomeForm({ pending, onMutate }: ActionProps) { return <form className="outcome-form" onSubmit={(event) => { event.preventDefault(); onMutate({ action: 'RECORD_OUTCOME', measuredValue: formValue(event.currentTarget, 'measuredValue'), statement: formValue(event.currentTarget, 'statement') }); }}><label>Current measurement<input name="measuredValue" required placeholder="3.4 days" /></label><label>What occurred<textarea name="statement" required placeholder="Describe the observed result without claiming cause." /></label><button className="secondary-button" disabled={pending}>Record outcome</button></form>; }
function EvaluationForm({ pending, onMutate }: ActionProps) { return <form className="outcome-form" onSubmit={(event) => { event.preventDefault(); onMutate({ action: 'EVALUATE_VALUE', harvest: formValue(event.currentTarget, 'harvest'), soil: formValue(event.currentTarget, 'soil') }); }}><label>Harvest<textarea name="harvest" required placeholder="Immediate value realized" /></label><label>Soil<textarea name="soil" required placeholder="Capacity strengthened for future value" /></label><button className="secondary-button" disabled={pending}>Evaluate value</button></form>; }
function LearningForm({ pending, onMutate }: ActionProps) { return <form className="learning-form" onSubmit={(event) => { event.preventDefault(); onMutate({ action: 'VALIDATE_LEARNING', statement: formValue(event.currentTarget, 'statement'), disposition: formValue(event.currentTarget, 'disposition') as OutcomeDisposition }); }}><label>Validated learning<textarea name="statement" required placeholder="What did the organization learn?" /></label><label>Decision<select name="disposition">{outcomeDispositions.map((item) => <option key={item}>{item}</option>)}</select></label><button className="secondary-button" disabled={pending}>Validate learning</button></form>; }
function BaselineForm({ pending, onMutate }: ActionProps) { return <form className="baseline-form" onSubmit={(event) => { event.preventDefault(); onMutate({ action: 'ESTABLISH_BASELINE', profileName: formValue(event.currentTarget, 'profileName'), actualState: formValue(event.currentTarget, 'actualState'), difference: formValue(event.currentTarget, 'difference') }); }}><label>Profile name<input name="profileName" required defaultValue="Distributed Authority · New Reality" /></label><label>What actually became true<textarea name="actualState" required /></label><label>Difference from intent<textarea name="difference" required /></label><button className="primary-button" disabled={pending}>Approve profile & establish baseline</button></form>; }
type ActionProps = { pending: boolean; onMutate: (mutation: OutcomesMutation) => void };
