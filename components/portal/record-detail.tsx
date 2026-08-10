import Link from 'next/link';
import type { PortalRecord } from '@/lib/portal/types';
import { StateBadge } from './state-badge';

export function RecordDetail({ record, backHref }: { record: PortalRecord; backHref: string }) {
  return (
    <article className="record-detail">
      <Link className="back-link" href={backHref}>← Back to workspace</Link>
      <header>
        <div className="record-meta"><StateBadge state={record.state} /><span>{record.objectType.replaceAll('_', ' ')}</span>{record.visibility === 'CONSULTANT_PRIVATE' && <span className="private-badge">CONSULTANT PRIVATE</span>}</div>
        <h1>{record.title}</h1><p className="record-statement">{record.statement}</p>
      </header>
      <div className="detail-grid">
        <section><p className="eyebrow">Rationale</p><h2>Why this is recorded</h2><p>{record.rationale}</p></section>
        <section><p className="eyebrow">Governance</p><h2>Record boundary</h2><dl><div><dt>Origin</dt><dd>{record.origin}</dd></div><div><dt>Visibility</dt><dd>{record.visibility.replaceAll('_', ' ')}</dd></div><div><dt>State</dt><dd>{record.state}</dd></div></dl></section>
      </div>
      <section className="sources"><p className="eyebrow">Provenance</p><h2>Inspectable sources</h2>{record.sourceLabels.length ? <ul>{record.sourceLabels.map((source) => <li key={source}>{source}</li>)}</ul> : <p>No source labels are exposed in this summary. Open the authorized source record for full provenance.</p>}</section>
      <section className="history"><p className="eyebrow">Audit history</p><h2>How this record changed</h2><ol>{record.history.map((item) => <li key={`${item.date}-${item.action}`}><span>{item.date}</span><strong>{item.action}</strong><small>{item.actor}</small></li>)}</ol></section>
    </article>
  );
}
