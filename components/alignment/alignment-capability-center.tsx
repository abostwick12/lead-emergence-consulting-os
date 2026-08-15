'use client';

import { useState, type FormEvent } from 'react';
import { ArrowRight, Check, CircleGauge, Gavel, GitBranch, ShieldCheck, Sparkles, Target, UsersRound } from 'lucide-react';
import type { AlignmentCapabilityData, AlignmentMutation, CapabilityPathwayView } from '@/lib/alignment/types';
import { postJson } from '@/lib/client/api';

export function AlignmentCapabilityCenter({ initialData, mode }: { initialData: AlignmentCapabilityData; mode: 'alignment' | 'development' }) {
  const [data, setData] = useState(initialData);
  const [pending, setPending] = useState(false);
  const [message, setMessage] = useState('');

  async function mutate(mutation: AlignmentMutation) {
    setPending(true); setMessage('');
    try {
      setData(await postJson<AlignmentCapabilityData>('/api/alignment', mutation, 'The change could not be saved.')); setMessage('Saved. The development record remains linked to its requirement, evidence, and plan.');
    } catch (error) { setMessage(error instanceof Error ? error.message : 'The change could not be saved.'); }
    finally { setPending(false); }
  }

  return <div className="alignment-center">
    {message && <p className="alignment-message" role="status">{message}</p>}
    {mode === 'alignment'
      ? <AlignmentView data={data} />
      : <DevelopmentView data={data} pending={pending} onMutate={mutate} />}
  </div>;
}

function AlignmentView({ data }: { data: AlignmentCapabilityData }) {
  return <>
    <section className="reasoning-chain" aria-labelledby="design-chain-heading">
      <div><p className="eyebrow">Traceable design</p><h2 id="design-chain-heading">Insight becomes accountable structure</h2></div>
      <ol><li><span>Validated insight</span><strong>Authority can expand with explicit capability and boundaries</strong></li><ArrowRight aria-hidden="true" /><li><span>Decision</span><strong>Delegate defined routine decisions</strong></li><ArrowRight aria-hidden="true" /><li><span>Design</span><strong>Role · authority · boundary · workflow</strong></li></ol>
    </section>
    <section className="architecture-section" aria-labelledby="role-architecture-heading">
      <div className="section-heading"><div><p className="eyebrow">Alignment architecture</p><h2 id="role-architecture-heading">Roles are more than titles</h2></div><p className="section-note">Each active role keeps its full operating contract inspectable.</p></div>
      {data.roleArchitectures.map((role) => <article className="role-architecture-card" key={role.id}>
        <header><div><span className="status-chip">{role.status}</span><h3>{role.name}</h3><p>{role.purpose}</p></div><div className="decision-trace"><Gavel aria-hidden="true" /><span>Created by decision</span><strong>{role.decisionLabel}</strong></div></header>
        <div className="role-contract-grid">
          <ContractPart title="Responsibilities" items={role.responsibilities} />
          <ContractPart title="Authority" items={role.authorities} accent="gold" />
          <ContractPart title="Boundaries" items={role.boundaries} />
          <ContractPart title="Interfaces" items={role.interfaces} />
          <ContractPart title="Support" items={[role.support]} />
          <ContractPart title="Accountability" items={[role.accountability]} />
          <ContractPart title="Success measures" items={[role.successMeasures]} wide />
        </div>
      </article>)}
    </section>
    <section className="workflow-initiative-grid">
      <div><p className="eyebrow">Workflow</p><h2>Decision flow</h2>{data.workflows.map((workflow) => <article className="workflow-card" key={workflow.id}><header><GitBranch aria-hidden="true" /><div><h3>{workflow.name}</h3><p>{workflow.purpose}</p><small>Owner · {workflow.ownerRole}</small></div></header><ol>{workflow.steps.map((step, index) => <li key={step.name}><span>{index + 1}</span><div><strong>{step.name}</strong><small>{step.owner}{step.decisionPoint ? ' · decision point' : ''}</small></div></li>)}</ol></article>)}</div>
      <div><p className="eyebrow">Reinvention initiative</p><h2>Change in motion</h2>{data.initiatives.map((initiative) => <article className="initiative-card" key={initiative.id}><span className="status-chip gold">{initiative.status}</span><h3>{initiative.name}</h3><p>{initiative.intendedCondition}</p><small>Owner · {initiative.owner}</small></article>)}</div>
    </section>
  </>;
}

function ContractPart({ title, items, accent, wide }: { title: string; items: string[]; accent?: 'gold'; wide?: boolean }) {
  return <section className={`${wide ? 'wide ' : ''}${accent === 'gold' ? 'gold' : ''}`}><p>{title}</p><ul>{items.map((item) => <li key={item}>{item}</li>)}</ul></section>;
}

function DevelopmentView({ data, pending, onMutate }: { data: AlignmentCapabilityData; pending: boolean; onMutate: (mutation: AlignmentMutation) => void }) {
  return <section className="capability-section" aria-labelledby="capability-heading">
    <div className="section-heading"><div><p className="eyebrow">Build capability</p><h2 id="capability-heading">From requirement to reliable practice</h2></div><p className="section-note">Activity is not maturity. Evidence of reliable and transferable performance closes the pathway.</p></div>
    <p className="privacy-invariant"><ShieldCheck aria-hidden="true" />Private coaching content is never organizational telemetry. Only explicitly shared, permission-eligible evidence may appear here.</p>
    {data.capabilityPathways.map((pathway) => <CapabilityPathway pathway={pathway} canRecord={data.fixture || data.role === 'consultant'} pending={pending} onMutate={onMutate} key={pathway.id} />)}
  </section>;
}

function CapabilityPathway({ pathway, canRecord, pending, onMutate }: { pathway: CapabilityPathwayView; canRecord: boolean; pending: boolean; onMutate: (mutation: AlignmentMutation) => void }) {
  function addPractice(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const values = new FormData(form);
    onMutate({
      action: 'ADD_PRACTICE',
      pathwayId: pathway.id,
      practice: String(values.get('practice')),
      conditions: String(values.get('conditions')),
      repetitionTarget: String(values.get('repetitionTarget')),
      feedbackMethod: String(values.get('feedbackMethod')),
    });
    form.reset();
  }
  return <article className="capability-pathway">
    <header><div><span className="status-chip"><Sparkles aria-hidden="true" />REQUIRED CAPABILITY</span><h3>{pathway.capabilityName}</h3><p>{pathway.definition}</p></div><div className="level-comparison"><span><small>Current evidence</small>{levelLabel(pathway.currentLevel)}</span><ArrowRight aria-hidden="true" /><span><small>Required</small>{levelLabel(pathway.requiredLevel)}</span></div></header>
    <p className="required-by"><Target aria-hidden="true" /><span>Required by</span><strong>{pathway.requiredBy}</strong></p>
    <div className="capability-flow">
      <PathwayPart icon={<CircleGauge aria-hidden="true" />} label="Current evidence" content={pathway.evidence} />
      <PathwayPart icon={<ShieldCheck aria-hidden="true" />} label="Capability gap" content={[pathway.gap]} tone="gold" />
      <PathwayPart icon={<UsersRound aria-hidden="true" />} label="Development plan" content={[pathway.developmentPlan]} />
      <PathwayPart icon={<GitBranch aria-hidden="true" />} label="Practice" content={pathway.practices} />
      <PathwayPart icon={<Check aria-hidden="true" />} label="Maturity evidence" content={pathway.maturityEvidence} tone="gold" />
    </div>
    <div className="development-actions">
      <section><p className="eyebrow">Activities</p>{pathway.activities.map((activity) => <button className="activity-row" disabled={pending} type="button" key={activity.id} onClick={() => onMutate({ action: 'UPDATE_ACTIVITY', pathwayId: pathway.id, activityId: activity.id, status: activity.status === 'COMPLETED' ? 'ACTIVE' : 'COMPLETED' })}><span className={activity.status === 'COMPLETED' ? 'activity-check complete' : 'activity-check'}>{activity.status === 'COMPLETED' && <Check aria-hidden="true" />}</span><strong>{activity.title}</strong><small>{activity.status}</small></button>)}</section>
      <section><p className="eyebrow">Resources</p><ul>{pathway.resources.map((resource) => <li key={resource}>{resource}</li>)}</ul></section>
    </div>
    {canRecord && <form className="practice-form" onSubmit={addPractice}>
      <label>Record completed practice<input name="practice" required placeholder="Boundary review during a live decision" /></label>
      <label>Conditions<input name="conditions" required placeholder="Real decision, normal time pressure" /></label>
      <label>Repetition target<input name="repetitionTarget" required placeholder="Six decisions across two contexts" /></label>
      <label>Feedback method<input name="feedbackMethod" required placeholder="Weekly exception review with coach" /></label>
      <button className="secondary-button" disabled={pending} type="submit">Save practice</button>
    </form>}
  </article>;
}

function PathwayPart({ icon, label, content, tone }: { icon: React.ReactNode; label: string; content: string[]; tone?: 'gold' }) {
  return <section className={tone === 'gold' ? 'gold' : ''}><header>{icon}<span>{label}</span></header><ul>{content.map((item) => <li key={item}>{item}</li>)}</ul></section>;
}

function levelLabel(level: string) { return level.toLowerCase().replaceAll('_', ' ').replace(/(^|\s)\w/g, (letter) => letter.toUpperCase()); }
