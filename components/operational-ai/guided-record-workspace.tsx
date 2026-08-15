'use client';

import { useEffect, useMemo, useRef, useState, type FormEvent } from 'react';
import { ArrowLeft, ArrowRight, Check, Clipboard, ExternalLink, MessageCircle, Pencil, X } from 'lucide-react';
import { getGuidedRecord } from '@/lib/operational-ai/guided-workflows';
import type { GuidedRecordKind, OperationalEngagementData } from '@/lib/operational-ai/types';

type GuidedRecordWorkspaceProps = {
  data: OperationalEngagementData;
  kind: GuidedRecordKind;
  recordId: string;
  pending: boolean;
  onClose: () => void;
  onMutate: (payload: Record<string, unknown>, form?: HTMLFormElement) => void;
};

export function GuidedRecordWorkspace({ data, kind, recordId, pending, onClose, onMutate }: GuidedRecordWorkspaceProps) {
  const snapshot = useMemo(() => getGuidedRecord(data, kind, recordId), [data, kind, recordId]);
  const [mode, setMode] = useState<'guide' | 'record'>('guide');
  const [activeQuestionId, setActiveQuestionId] = useState(snapshot.nextQuestionId ?? snapshot.questions[0].id);
  const [drafts, setDrafts] = useState<Record<string, string>>({});
  const [copied, setCopied] = useState(false);
  const questionPanelRef = useRef<HTMLFormElement>(null);
  const closeHandlerRef = useRef(onClose);
  const activeIndex = Math.max(0, snapshot.questions.findIndex((item) => item.id === activeQuestionId));
  const activeQuestion = snapshot.questions[activeIndex];
  const savedAnswer = snapshot.responses.find((item) => item.questionId === activeQuestion.id)?.answer ?? '';
  const draft = drafts[activeQuestion.id] ?? savedAnswer;
  const progress = Math.round((snapshot.completedCount / snapshot.totalCount) * 100);

  useEffect(() => {
    closeHandlerRef.current = onClose;
  }, [onClose]);

  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') closeHandlerRef.current();
    }
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  function move(delta: number) {
    const next = Math.min(snapshot.questions.length - 1, Math.max(0, activeIndex + delta));
    setActiveQuestionId(snapshot.questions[next].id);
    window.requestAnimationFrame(() => questionPanelRef.current?.scrollIntoView({ block: 'start' }));
  }

  function saveResponse(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    onMutate({ action: 'SAVE_GUIDED_RESPONSE', recordKind: kind, recordId, questionId: activeQuestion.id, answer: draft });
    if (activeIndex < snapshot.questions.length - 1) move(1);
  }

  async function copyConversationBrief() {
    await navigator.clipboard.writeText(snapshot.conversationBrief);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 2200);
  }

  return <div className="guided-workspace-backdrop" role="presentation" onMouseDown={(event) => { if (event.target === event.currentTarget) onClose(); }}>
    <section className="guided-workspace" role="dialog" aria-modal="true" aria-labelledby="guided-record-title">
      <header className="guided-workspace-header">
        <div>
          <p className="eyebrow">{kind} · GUIDED WORKSPACE</p>
          <h2 id="guided-record-title">{snapshot.title}</h2>
          <p>{snapshot.context}</p>
        </div>
        <button className="guided-icon-button" type="button" onClick={onClose} aria-label="Close guided workspace"><X aria-hidden="true" /></button>
      </header>

      <section className="conversation-handoff" aria-label="ChatGPT conversation workflow">
        <MessageCircle aria-hidden="true" />
        <div><strong>Conversation-first workflow</strong><span>Use ChatGPT to ask these questions naturally. The MCP-ready contract reads this record and saves only answers you explicitly confirm.</span></div>
        <button type="button" onClick={copyConversationBrief}>{copied ? <Check aria-hidden="true" /> : <Clipboard aria-hidden="true" />}{copied ? 'Copied' : 'Copy ChatGPT brief'}</button>
        <a href="https://chatgpt.com/" target="_blank" rel="noreferrer">Open ChatGPT <ExternalLink aria-hidden="true" /></a>
      </section>

      <nav className="guided-mode-tabs" aria-label="Guided record views">
        <button className={mode === 'guide' ? 'active' : ''} type="button" onClick={() => setMode('guide')}>Guided questions</button>
        <button className={mode === 'record' ? 'active' : ''} type="button" onClick={() => setMode('record')}>View & edit record</button>
        <span>{snapshot.completedCount} of {snapshot.totalCount} answered</span>
      </nav>
      <progress className="guided-progress" aria-label={`${progress}% complete`} max="100" value={progress}>{progress}%</progress>

      {mode === 'guide' ? <div className="guided-builder">
        <ol className="guided-question-list" aria-label="Guided questions">
          {snapshot.questions.map((item, index) => {
            const answered = snapshot.responses.some((response) => response.questionId === item.id && response.answer.trim());
            return <li key={item.id}><button className={item.id === activeQuestion.id ? 'active' : ''} type="button" onClick={() => setActiveQuestionId(item.id)}><span>{answered ? <Check aria-hidden="true" /> : String(index + 1).padStart(2, '0')}</span><span><small>{item.section}</small>{item.prompt}</span></button></li>;
          })}
        </ol>
        <form className="guided-question-panel" onSubmit={saveResponse} ref={questionPanelRef}>
          <p className="eyebrow">QUESTION {String(activeIndex + 1).padStart(2, '0')} · {activeQuestion.section}</p>
          <h3>{activeQuestion.prompt}</h3>
          <p>{activeQuestion.guidance}</p>
          <label htmlFor="guided-answer">Confirmed response<textarea id="guided-answer" value={draft} onChange={(event) => setDrafts((current) => ({ ...current, [activeQuestion.id]: event.target.value }))} placeholder={activeQuestion.placeholder} required /></label>
          <div className="guided-question-actions">
            <button className="secondary-button compact" type="button" onClick={() => move(-1)} disabled={activeIndex === 0}><ArrowLeft aria-hidden="true" /> Previous</button>
            <button className="text-button" type="button" onClick={() => move(1)} disabled={activeIndex === snapshot.questions.length - 1}>Skip for now</button>
            <button className="primary-button compact" type="submit" disabled={pending || !draft.trim()}>{pending ? 'Saving…' : activeIndex === snapshot.questions.length - 1 ? 'Save response' : 'Save & continue'} <ArrowRight aria-hidden="true" /></button>
          </div>
        </form>
      </div> : <RecordView data={data} snapshot={snapshot} pending={pending} onMutate={onMutate} onEditQuestion={(questionId) => { setActiveQuestionId(questionId); setMode('guide'); }} />}
    </section>
  </div>;
}

function RecordView({ data, snapshot, pending, onMutate, onEditQuestion }: {
  data: OperationalEngagementData;
  snapshot: ReturnType<typeof getGuidedRecord>;
  pending: boolean;
  onMutate: GuidedRecordWorkspaceProps['onMutate'];
  onEditQuestion: (questionId: string) => void;
}) {
  const product = snapshot.kind === 'PRODUCT' ? data.products.find((item) => item.id === snapshot.id) : undefined;
  const audit = snapshot.kind === 'AUDIT' ? data.audits.find((item) => item.id === snapshot.id) : undefined;
  const interview = snapshot.kind === 'INTERVIEW' ? data.interviews.find((item) => item.id === snapshot.id) : undefined;
  return <div className="guided-record-view">
    <section className="guided-summary-card">
      <p className="eyebrow">RECORD DETAILS</p>
      {product && <form onSubmit={(event) => {
        event.preventDefault();
        const form = event.currentTarget;
        onMutate({ action: 'UPDATE_PRODUCT_SUMMARY', id: product.id, ...Object.fromEntries(new FormData(form).entries()) }, form);
      }}>
        <label>Product name<input name="name" defaultValue={product.name} required /></label>
        <label>Product owner<input name="ownerLabel" defaultValue={product.ownerLabel} required /></label>
        <label>Product status<select name="status" defaultValue={product.status}><option>ACTIVE</option><option>ON_HOLD</option><option>COMPLETE</option></select></label>
        <label className="wide">Sanitized purpose and scope<textarea name="description" defaultValue={product.description} required /></label>
        <button className="primary-button compact" disabled={pending}>Save product details</button>
      </form>}
      {audit && <><h3>{audit.title}</h3><dl><div><dt>Respondent</dt><dd>{audit.respondentLabel}</dd></div><div><dt>Due</dt><dd>{audit.dueOn}</dd></div></dl><label>Status<select value={audit.status} disabled={pending} onChange={(event) => onMutate({ action: 'UPDATE_AUDIT_STATUS', id: audit.id, status: event.target.value })}><option>NOT_STARTED</option><option>IN_PROGRESS</option><option>SUBMITTED</option><option>REVIEWED</option></select></label></>}
      {interview && <><h3>{interview.participantLabel}</h3><p>{interview.objective}</p><dl><div><dt>Guide</dt><dd>{interview.interviewType.replaceAll('_', ' ')}</dd></div><div><dt>Scheduled</dt><dd>{new Date(interview.scheduledFor).toLocaleString()}</dd></div></dl><label>Status<select value={interview.status} disabled={pending} onChange={(event) => onMutate({ action: 'UPDATE_INTERVIEW_STATUS', id: interview.id, status: event.target.value })}><option>PLANNED</option><option>IN_PROGRESS</option><option>COMPLETED</option></select></label></>}
    </section>
    <section className="guided-response-register">
      <header><div><p className="eyebrow">CONFIRMED RESPONSES</p><h3>Working record</h3></div><span>{snapshot.completedCount}/{snapshot.totalCount}</span></header>
      {snapshot.questions.map((question) => {
        const response = snapshot.responses.find((item) => item.questionId === question.id);
        return <article key={question.id}><div><small>{question.section}</small><h4>{question.prompt}</h4><p>{response?.answer || 'Not answered yet.'}</p></div><button type="button" onClick={() => onEditQuestion(question.id)}><Pencil aria-hidden="true" /> {response ? 'Edit' : 'Answer'}</button></article>;
      })}
    </section>
  </div>;
}
