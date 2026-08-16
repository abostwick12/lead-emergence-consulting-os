'use client';

import { useState, type FormEvent } from 'react';
import { CheckCircle2, LockKeyhole } from 'lucide-react';
import type { ParticipantAssessment as Assessment, ParticipantAssessmentItem } from '@/lib/access/assessment';
import type { AssessmentFieldDefinition, AssessmentMatrixRow, AssessmentResponseDefinition } from '@/lib/operational-ai/assessment-workflow-definitions';

export function ParticipantAssessment({ token, assessment }: { token: string; assessment: Assessment }) {
  const [pending, setPending] = useState(false);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [message, setMessage] = useState('');
  const [skipped, setSkipped] = useState(0);
  const item = assessment.items[currentIndex];
  const complete = currentIndex >= assessment.items.length;
  const legacyLikertAssessment = assessment.items.every((assessmentItem) => assessmentItem.responseType === 'LIKERT');

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!item) return;
    const value = responseValue(item, new FormData(event.currentTarget));
    if (item.response.uiType === 'multi-select' && item.response.maxSelections && selectedCount(value) > item.response.maxSelections) {
      setMessage(`Select no more than ${item.response.maxSelections} options.`);
      return;
    }
    setPending(true);
    setMessage('');
    try {
      const response = await fetch('/api/assessment-response', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ token, itemId: item.itemId, value }),
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
    return <main className="participant-page"><section className="participant-card complete"><CheckCircle2 aria-hidden="true" /><p className="eyebrow">Responses received</p><h1>{legacyLikertAssessment ? 'Thank you.' : 'Administration complete.'}</h1><p>Your confirmed responses have been recorded as evidence for this inquiry. They are not treated as a diagnosis.{skipped ? ` ${skipped} optional item${skipped === 1 ? ' was' : 's were'} skipped in this pass.` : ''}</p></section></main>;
  }

  return <main className="participant-page"><section className="participant-card assessment-administration-card">
    <header><p className="eyebrow">{assessment.organizationName}</p><h1>{assessment.instrumentName}</h1><p>{legacyLikertAssessment ? `Focused organizational inquiry · Question ${currentIndex + 1} of ${assessment.items.length}` : `${item.section} · Item ${currentIndex + 1} of ${assessment.items.length}`}</p></header>
    <p className="participant-privacy"><LockKeyhole aria-hidden="true" />{assessment.confidentiality === 'ANONYMOUS' ? 'Anonymous: this link retains no name, email, or person reference.' : assessment.confidentiality === 'CONFIDENTIAL' ? 'Confidential: identity and response content remain physically separated.' : 'Identified: your response is visible only within the stated engagement permissions.'}</p>
    <form key={item.itemId} onSubmit={submit}>
      <fieldset><legend>{item.prompt}</legend><p className="assessment-item-guidance">{item.guidance}</p><AssessmentResponseControl item={item} /></fieldset>
      {message && <p className="form-error" role="alert">{message}</p>}
      <div className="assessment-submit-row">
        <button className="text-button" type="button" disabled={pending} onClick={() => { setSkipped((value) => value + 1); setCurrentIndex((index) => index + 1); setMessage(''); }}>Skip for now</button>
        <button className="primary-button" disabled={pending}>{pending ? 'Submitting securely…' : currentIndex + 1 === assessment.items.length ? 'Submit final response' : 'Save and continue'}</button>
      </div>
    </form>
    <footer>Link expires {new Date(assessment.closesAt).toLocaleDateString()} · {assessment.items.length - currentIndex} remaining</footer>
  </section></main>;
}

function AssessmentResponseControl({ item }: { item: ParticipantAssessmentItem }) {
  if (item.responseType === 'LIKERT') return <><div className="response-scale">{[1, 2, 3, 4, 5].map((option) => <label key={option}><input type="radio" name="response" value={String(option)} required aria-label={String(option)} /><span>{option}</span></label>)}</div><div className="scale-labels"><small>Strongly disagree</small><small>Strongly agree</small></div></>;
  const response = item.response;
  if (response.uiType === 'text') return <label className="assessment-long-answer"><span>Confirmed response</span><textarea name="response" placeholder={response.placeholder} required /></label>;
  if (response.uiType === 'fields') return <div className="assessment-field-grid">{response.fields.map((field) => <label key={field.key}><span>{field.label}</span><FieldControl name={`field:${field.key}`} field={field} /></label>)}</div>;
  if (response.uiType === 'multi-select') return <div className="assessment-option-grid">{response.options.map((option) => <label key={option}><input type="checkbox" name="selection" value={option} /><span>{option}</span></label>)}{response.allowOther && <label className="assessment-other-option"><span>Other</span><input name="other" placeholder="Describe another applicable response" /></label>}</div>;
  const rows = matrixRows(response.rows);
  return <div className="assessment-matrix-scroll"><table className="assessment-response-matrix"><thead><tr><th scope="col">{Array.isArray(response.rows) ? 'Category' : 'Row'}</th>{response.columns.map((column) => <th scope="col" key={column.key}>{column.label}</th>)}</tr></thead><tbody>{rows.map((row) => <tr key={row.key}><th scope="row">{row.label}</th>{response.columns.map((column) => <td key={column.key}><FieldControl name={`matrix:${row.key}:${column.key}`} field={column} compact /></td>)}</tr>)}</tbody></table></div>;
}

function FieldControl({ name, field, compact = false }: { name: string; field: AssessmentFieldDefinition; compact?: boolean }) {
  if (field.type === 'single-select' || field.type === 'rating') {
    const options = field.type === 'rating' ? ['1', '2', '3', '4', '5'] : field.options ?? [];
    return <select name={name} aria-label={field.label} defaultValue=""><option value="">Select…</option>{options.map((option) => <option key={option} value={option}>{option}</option>)}</select>;
  }
  if (field.type === 'number') return <input name={name} type="number" min="0" aria-label={field.label} />;
  if (field.type === 'date') return <input name={name} type="date" aria-label={field.label} />;
  return compact ? <input name={name} aria-label={field.label} /> : <textarea name={name} aria-label={field.label} />;
}

function matrixRows(rows: number | AssessmentMatrixRow[]): AssessmentMatrixRow[] {
  return typeof rows === 'number'
    ? Array.from({ length: rows }, (_, index) => ({ key: `row_${index + 1}`, label: String(index + 1) }))
    : rows;
}

function responseValue(item: ParticipantAssessmentItem, form: FormData): unknown {
  if (item.responseType === 'LIKERT') return String(form.get('response') ?? '');
  const response: AssessmentResponseDefinition = item.response;
  if (response.uiType === 'text') return String(form.get('response') ?? '').trim();
  if (response.uiType === 'fields') return Object.fromEntries(response.fields.map((field) => [field.key, String(form.get(`field:${field.key}`) ?? '').trim()]).filter(([, value]) => value));
  if (response.uiType === 'multi-select') return { selected: form.getAll('selection').map(String), other: String(form.get('other') ?? '').trim() || undefined };
  const rows = matrixRows(response.rows).map((row) => ({
    rowKey: row.key,
    rowLabel: row.label,
    values: Object.fromEntries(response.columns.map((column) => [column.key, String(form.get(`matrix:${row.key}:${column.key}`) ?? '').trim()]).filter(([, value]) => value)),
  })).filter((row) => Object.keys(row.values).length);
  return { rows };
}

function selectedCount(value: unknown) {
  if (!value || typeof value !== 'object') return 0;
  const selected = (value as { selected?: unknown }).selected;
  return Array.isArray(selected) ? selected.length : 0;
}
