import { Download, ExternalLink, FileCheck2, Printer, ShieldCheck } from 'lucide-react';
import { assessmentInstruments, assessmentInstrumentUrl } from '@/lib/operational-ai/assessment-instruments';

export function AssessmentInstrumentLibrary() {
  return <section className="assessment-library" aria-labelledby="assessment-library-title">
    <header className="operational-section-header assessment-library-header">
      <span><FileCheck2 aria-hidden="true" /></span>
      <div>
        <p className="eyebrow">AUTHORITATIVE INSTRUMENTS</p>
        <h2 id="assessment-library-title">Mission product assessments</h2>
        <p>Use the complete instruments for guided conversations, individual completion, or facilitated workshops. Record confirmed responses in the engagement workspace; do not treat a response as diagnosis.</p>
      </div>
    </header>
    <div className="assessment-instrument-grid">
      {assessmentInstruments.map((instrument) => <article className="assessment-instrument-card" key={instrument.slug}>
        <div className="assessment-instrument-card-heading">
          <p className="eyebrow">{instrument.label}</p>
          <span>{instrument.pageCount} pages</span>
        </div>
        <h3>{instrument.title}</h3>
        <p>{instrument.purpose}</p>
        <dl className="operational-meta">
          <div><dt>Audience</dt><dd>{instrument.audience}</dd></div>
          <div><dt>Time</dt><dd>{instrument.completionTime}</dd></div>
          <div><dt>Output</dt><dd>{instrument.primaryOutput}</dd></div>
        </dl>
        <div className="assessment-security-note"><ShieldCheck aria-hidden="true" /><span>Sanitized process-level use in this environment. Full handling guidance is preserved inside the instrument.</span></div>
        <div className="assessment-instrument-actions">
          <a className="primary-button compact" href={`/consultant/assessments/${instrument.slug}`}>Open assessment <ExternalLink aria-hidden="true" /></a>
          <a className="secondary-button compact" href={assessmentInstrumentUrl(instrument.slug, 'pdf')} target="_blank" rel="noreferrer"><Printer aria-hidden="true" /> Print PDF</a>
          <a className="text-button assessment-download" href={assessmentInstrumentUrl(instrument.slug, 'docx', true)}><Download aria-hidden="true" /> Word</a>
        </div>
      </article>)}
    </div>
  </section>;
}
