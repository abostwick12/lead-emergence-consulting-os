import { notFound } from 'next/navigation';
import { ArrowLeft, Download, FileText, Printer, ShieldCheck } from 'lucide-react';
import { PageIntro } from '@/components/portal/dashboard';
import { assessmentInstrumentUrl, getAssessmentInstrument } from '@/lib/operational-ai/assessment-instruments';
import { requirePortalRole } from '@/lib/portal/context';

export default async function AssessmentInstrumentPage({ params }: { params: Promise<{ slug: string }> }) {
  const session = await requirePortalRole('consultant');
  const { slug } = await params;
  const instrument = getAssessmentInstrument(slug);
  if (!instrument) notFound();

  return <>
    <PageIntro eyebrow={`${session.organization.name} · assessment instrument`} title={instrument.title} description={instrument.purpose} />
    <section className="assessment-detail">
      <a className="assessment-back-link" href={`/consultant/clients/${session.organization.id}/audits`}><ArrowLeft aria-hidden="true" /> Back to assessments</a>
      <div className="assessment-detail-grid">
        <article className="assessment-detail-card">
          <p className="eyebrow">INSTRUMENT OVERVIEW</p>
          <dl className="operational-meta">
            <div><dt>Audience</dt><dd>{instrument.audience}</dd></div>
            <div><dt>Completion</dt><dd>{instrument.completionTime}</dd></div>
            <div><dt>Output</dt><dd>{instrument.primaryOutput}</dd></div>
            <div><dt>Length</dt><dd>{instrument.pageCount} printable pages</dd></div>
          </dl>
          <div className="assessment-detail-actions">
            <a className="primary-button" href={assessmentInstrumentUrl(instrument.slug, 'pdf')} target="_blank" rel="noreferrer"><Printer aria-hidden="true" /> Open and print PDF</a>
            <a className="secondary-button" href={assessmentInstrumentUrl(instrument.slug, 'pdf', true)}><Download aria-hidden="true" /> Download PDF</a>
            <a className="secondary-button" href={assessmentInstrumentUrl(instrument.slug, 'docx', true)}><FileText aria-hidden="true" /> Download editable Word file</a>
          </div>
          <p className="assessment-print-guidance">The PDF is the print-ready edition. Open it in a new tab, then use the browser’s print control. The Word file preserves the original editable worksheet.</p>
        </article>
        <aside className="assessment-safety-card">
          <ShieldCheck aria-hidden="true" />
          <div><p className="eyebrow">SECURITY AND OPSEC</p><h2>Keep the collection environment inside its authorization.</h2><p>{instrument.securityNotice}</p></div>
        </aside>
      </div>
      <section className="assessment-section-register">
        <header><p className="eyebrow">COMPLETE CONTENT MAP</p><h2>Sections preserved in the instrument</h2><p>The downloadable and printable editions contain the complete tables, checklists, response areas, consultant synthesis fields, and source handling guidance.</p></header>
        <ol>{instrument.sections.map((section, index) => <li key={section}><span>{String(index + 1).padStart(2, '0')}</span>{section}</li>)}</ol>
      </section>
    </section>
  </>;
}
