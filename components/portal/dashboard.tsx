import Link from 'next/link';
import type { AttentionItem, PortalDashboard, PortalRecord } from '@/lib/portal/types';
import { Roadmap } from './roadmap';
import { StateBadge, StateLegend } from './state-badge';

export function PageIntro({ eyebrow, title, description }: { eyebrow: string; title: string; description: string }) {
  return (
    <header className="page-intro">
      <p className="eyebrow">{eyebrow}</p>
      <h1>{title}</h1>
      <p>{description}</p>
    </header>
  );
}

export function DashboardView({ dashboard, role }: { dashboard: PortalDashboard; role: 'consultant' | 'client' }) {
  return (
    <>
      <PageIntro
        eyebrow={role === 'consultant' ? 'Consultant home' : 'Your organization'}
        title={role === 'consultant' ? `Good morning. ${dashboard.organization.name} is in focus.` : 'What needs your attention'}
        description={role === 'consultant'
          ? 'Move from evidence to accountable decisions without losing source, review state, or history.'
          : 'A focused view of your active reviews, commitments, and upcoming work.'}
      />
      <AttentionList items={dashboard.attention} emptyText="Nothing needs immediate attention." />
      <Roadmap stages={dashboard.roadmap} />
      <section className="workspace-grid" aria-labelledby="workspace-heading">
        <div className="section-heading full-span"><div><p className="eyebrow">Workspace</p><h2 id="workspace-heading">Work in context</h2></div></div>
        {dashboard.workspaces.map((workspace) => (
          <Link className="workspace-card" href={workspace.href} key={workspace.key}>
            <span className="workspace-metric">{workspace.metric}</span>
            <h3>{workspace.label}</h3>
            <p>{workspace.description}</p>
            <small>{workspace.metricLabel}</small>
          </Link>
        ))}
      </section>
      <CurrentReality dashboard={dashboard} />
      <StateLegend />
      <RecordList records={dashboard.records} role={role} title={role === 'consultant' ? 'Recent reasoning records' : 'Validated conclusions and decisions'} />
    </>
  );
}

export function AttentionList({ items, emptyText }: { items: AttentionItem[]; emptyText: string }) {
  return (
    <section className="attention-section" aria-labelledby="attention-heading">
      <div className="section-heading"><div><p className="eyebrow">Attention</p><h2 id="attention-heading">Now and next</h2></div><span className="count-pill">{items.length}</span></div>
      {items.length ? <div className="attention-list">{items.map((item) => (
        <Link href={item.href} key={item.id} className="attention-item">
          <span className={`attention-kind kind-${item.kind.toLowerCase()}`}>{item.kind}</span>
          <div><strong>{item.title}</strong><p>{item.description}</p></div>
          <span className="due-label">{item.dueLabel}</span>
        </Link>
      ))}</div> : <div className="empty-state"><strong>All clear</strong><p>{emptyText}</p></div>}
    </section>
  );
}

export function RecordList({ records, role, title = 'Records' }: { records: PortalRecord[]; role: 'consultant' | 'client'; title?: string }) {
  return (
    <section className="records-section" aria-labelledby="records-heading">
      <div className="section-heading"><div><p className="eyebrow">Traceable knowledge</p><h2 id="records-heading">{title}</h2></div></div>
      {records.length ? <div className="record-list">{records.map((record) => (
        <Link className="record-card" href={`/${role}/records/${record.id}`} key={record.id}>
          <div className="record-meta"><StateBadge state={record.state} /><span>{record.objectType.replaceAll('_', ' ')}</span>{record.visibility === 'CONSULTANT_PRIVATE' && <span className="private-badge">PRIVATE</span>}</div>
          <h3>{record.title}</h3><p>{record.statement}</p><small>{record.updatedLabel}</small>
        </Link>
      ))}</div> : <div className="empty-state"><strong>No records yet</strong><p>This workspace will populate as authorized work is recorded.</p></div>}
    </section>
  );
}

function CurrentReality({ dashboard }: { dashboard: PortalDashboard }) {
  return (
    <section className="current-reality" aria-labelledby="current-reality-heading">
      <p className="eyebrow">Current effective state</p><h2 id="current-reality-heading">What is true now</h2>
      <p className="reality-statement">{dashboard.currentNarrative}</p>
      <details><summary>View historical state</summary>{dashboard.historicalNarratives.length
        ? dashboard.historicalNarratives.map((item) => <div className="history-item" key={item.effectiveOn}><strong>{item.effectiveOn}</strong><p>{item.narrative}</p></div>)
        : <p>No superseded narrative is available.</p>}</details>
    </section>
  );
}
