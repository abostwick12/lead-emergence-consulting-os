import { objectInput, type InputReader } from '../validation/input';
import { guidedQuestions } from './guided-workflows';

export type OperationalMutation =
  | { action: 'ADD_PRODUCT'; name: string; description: string; ownerLabel: string }
  | { action: 'UPDATE_PRODUCT_SUMMARY'; id: string; name: string; description: string; ownerLabel: string; status: 'ACTIVE' | 'ON_HOLD' | 'COMPLETE' }
  | { action: 'UPDATE_AUDIT_STATUS'; id: string; status: 'NOT_STARTED' | 'IN_PROGRESS' | 'SUBMITTED' | 'REVIEWED' }
  | { action: 'ADD_INTERVIEW'; productId: string; participantLabel: string; interviewType: string; objective: string; scheduledFor: string }
  | { action: 'UPDATE_INTERVIEW_STATUS'; id: string; status: 'PLANNED' | 'IN_PROGRESS' | 'COMPLETED' }
  | { action: 'SAVE_GUIDED_RESPONSE'; recordKind: 'PRODUCT' | 'AUDIT' | 'INTERVIEW'; recordId: string; questionId: string; answer: string }
  | { action: 'ADD_EVIDENCE'; productId?: string; title: string; sourceType: 'DOCUMENT' | 'INTERVIEW' | 'AUDIT' | 'WORKFLOW' | 'OBSERVATION'; observation: string; sourceLocator: string; visibility: 'CONSULTANT_PRIVATE' | 'ENGAGEMENT_SHARED' }
  | { action: 'ADD_REQUEST'; productId?: string; title: string; requestedFrom: string; dueOn: string }
  | { action: 'ADD_ACTION'; title: string; ownerLabel: string; dueOn: string; visibility: 'CONSULTANT_PRIVATE' | 'ENGAGEMENT_SHARED' }
  | { action: 'UPDATE_ACTION_STATUS'; id: string; status: 'OPEN' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED' }
  | { action: 'UPDATE_STEP_SUITABILITY'; id: string; aiSuitability: 'NOT_ASSESSED' | 'ASSISTIVE_CANDIDATE' | 'HUMAN_ONLY' };

const forbidden = /\b(classified|secret|no-forn|noforn|cui|coordinates?|frequency|frequencies|callsign|target(?:ing)?|intelligence|mission timeline)\b/i;
function sanitized(reader: InputReader, key: string) { const clean = reader.required(key); if (forbidden.test(clean)) throw new Error('This workspace accepts sanitized consulting content only. Remove operational or controlled details.'); return clean }

export function validateOperationalMutation(value: unknown): OperationalMutation {
  const reader = objectInput(value, 'A workspace action is required.');
  const input = reader.raw;
  const text = (key: string) => sanitized(reader, key);
  const action = text('action');
  if (action === 'ADD_PRODUCT') return { action, name: text('name'), description: text('description'), ownerLabel: text('ownerLabel') };
  if (action === 'UPDATE_PRODUCT_SUMMARY') return { action, id: text('id'), name: text('name'), description: text('description'), ownerLabel: text('ownerLabel'), status: reader.oneOf('status', ['ACTIVE', 'ON_HOLD', 'COMPLETE'] as const) };
  if (action === 'UPDATE_AUDIT_STATUS') return { action, id: text('id'), status: reader.oneOf('status', ['NOT_STARTED', 'IN_PROGRESS', 'SUBMITTED', 'REVIEWED'] as const) };
  if (action === 'ADD_INTERVIEW') return { action, productId: text('productId'), participantLabel: text('participantLabel'), interviewType: text('interviewType'), objective: text('objective'), scheduledFor: text('scheduledFor') };
  if (action === 'UPDATE_INTERVIEW_STATUS') return { action, id: text('id'), status: reader.oneOf('status', ['PLANNED', 'IN_PROGRESS', 'COMPLETED'] as const) };
  if (action === 'SAVE_GUIDED_RESPONSE') {
    const recordKind = reader.oneOf('recordKind', ['PRODUCT', 'AUDIT', 'INTERVIEW'] as const);
    const questionId = text('questionId');
    if (!guidedQuestions[recordKind].some((question) => question.id === questionId)) throw new Error('questionId is not valid for this guided record type.');
    return { action, recordKind, recordId: text('recordId'), questionId, answer: text('answer') };
  }
  if (action === 'ADD_EVIDENCE') return { action, productId: typeof input.productId === 'string' && input.productId ? input.productId : undefined, title: text('title'), sourceType: reader.oneOf('sourceType', ['DOCUMENT', 'INTERVIEW', 'AUDIT', 'WORKFLOW', 'OBSERVATION'] as const), observation: text('observation'), sourceLocator: text('sourceLocator'), visibility: reader.oneOf('visibility', ['CONSULTANT_PRIVATE', 'ENGAGEMENT_SHARED'] as const) };
  if (action === 'ADD_REQUEST') return { action, productId: typeof input.productId === 'string' && input.productId ? input.productId : undefined, title: text('title'), requestedFrom: text('requestedFrom'), dueOn: text('dueOn') };
  if (action === 'ADD_ACTION') return { action, title: text('title'), ownerLabel: text('ownerLabel'), dueOn: text('dueOn'), visibility: reader.oneOf('visibility', ['CONSULTANT_PRIVATE', 'ENGAGEMENT_SHARED'] as const) };
  if (action === 'UPDATE_ACTION_STATUS') return { action, id: text('id'), status: reader.oneOf('status', ['OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'] as const) };
  if (action === 'UPDATE_STEP_SUITABILITY') return { action, id: text('id'), aiSuitability: reader.oneOf('aiSuitability', ['NOT_ASSESSED', 'ASSISTIVE_CANDIDATE', 'HUMAN_ONLY'] as const) };
  throw new Error('Unsupported workspace action.');
}
