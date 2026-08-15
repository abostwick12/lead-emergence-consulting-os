export type OperationalMutation =
  | { action: 'ADD_PRODUCT'; name: string; description: string; ownerLabel: string }
  | { action: 'UPDATE_AUDIT_STATUS'; id: string; status: 'NOT_STARTED' | 'IN_PROGRESS' | 'SUBMITTED' | 'REVIEWED' }
  | { action: 'ADD_INTERVIEW'; productId: string; participantLabel: string; interviewType: string; objective: string; scheduledFor: string }
  | { action: 'ADD_EVIDENCE'; productId?: string; title: string; sourceType: 'DOCUMENT' | 'INTERVIEW' | 'AUDIT' | 'WORKFLOW' | 'OBSERVATION'; observation: string; sourceLocator: string; visibility: 'CONSULTANT_PRIVATE' | 'ENGAGEMENT_SHARED' }
  | { action: 'ADD_REQUEST'; productId?: string; title: string; requestedFrom: string; dueOn: string }
  | { action: 'ADD_ACTION'; title: string; ownerLabel: string; dueOn: string; visibility: 'CONSULTANT_PRIVATE' | 'ENGAGEMENT_SHARED' }
  | { action: 'UPDATE_ACTION_STATUS'; id: string; status: 'OPEN' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED' }
  | { action: 'UPDATE_STEP_SUITABILITY'; id: string; aiSuitability: 'NOT_ASSESSED' | 'ASSISTIVE_CANDIDATE' | 'HUMAN_ONLY' };

const forbidden = /\b(classified|secret|no-forn|noforn|cui|coordinates?|frequency|frequencies|callsign|target(?:ing)?|intelligence|mission timeline)\b/i;
function text(input: Record<string, unknown>, key: string) { const value = input[key]; if (typeof value !== 'string' || !value.trim()) throw new Error(`${key} is required.`); const clean = value.trim(); if (forbidden.test(clean)) throw new Error('This workspace accepts sanitized consulting content only. Remove operational or controlled details.'); return clean }
function oneOf<T extends string>(input: Record<string, unknown>, key: string, values: readonly T[]): T { const value = text(input, key); if (!values.includes(value as T)) throw new Error(`${key} is invalid.`); return value as T }

export function validateOperationalMutation(value: unknown): OperationalMutation {
  if (!value || typeof value !== 'object') throw new Error('A workspace action is required.');
  const input = value as Record<string, unknown>; const action = text(input, 'action');
  if (action === 'ADD_PRODUCT') return { action, name: text(input, 'name'), description: text(input, 'description'), ownerLabel: text(input, 'ownerLabel') };
  if (action === 'UPDATE_AUDIT_STATUS') return { action, id: text(input, 'id'), status: oneOf(input, 'status', ['NOT_STARTED', 'IN_PROGRESS', 'SUBMITTED', 'REVIEWED'] as const) };
  if (action === 'ADD_INTERVIEW') return { action, productId: text(input, 'productId'), participantLabel: text(input, 'participantLabel'), interviewType: text(input, 'interviewType'), objective: text(input, 'objective'), scheduledFor: text(input, 'scheduledFor') };
  if (action === 'ADD_EVIDENCE') return { action, productId: typeof input.productId === 'string' && input.productId ? input.productId : undefined, title: text(input, 'title'), sourceType: oneOf(input, 'sourceType', ['DOCUMENT', 'INTERVIEW', 'AUDIT', 'WORKFLOW', 'OBSERVATION'] as const), observation: text(input, 'observation'), sourceLocator: text(input, 'sourceLocator'), visibility: oneOf(input, 'visibility', ['CONSULTANT_PRIVATE', 'ENGAGEMENT_SHARED'] as const) };
  if (action === 'ADD_REQUEST') return { action, productId: typeof input.productId === 'string' && input.productId ? input.productId : undefined, title: text(input, 'title'), requestedFrom: text(input, 'requestedFrom'), dueOn: text(input, 'dueOn') };
  if (action === 'ADD_ACTION') return { action, title: text(input, 'title'), ownerLabel: text(input, 'ownerLabel'), dueOn: text(input, 'dueOn'), visibility: oneOf(input, 'visibility', ['CONSULTANT_PRIVATE', 'ENGAGEMENT_SHARED'] as const) };
  if (action === 'UPDATE_ACTION_STATUS') return { action, id: text(input, 'id'), status: oneOf(input, 'status', ['OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'] as const) };
  if (action === 'UPDATE_STEP_SUITABILITY') return { action, id: text(input, 'id'), aiSuitability: oneOf(input, 'aiSuitability', ['NOT_ASSESSED', 'ASSISTIVE_CANDIDATE', 'HUMAN_ONLY'] as const) };
  throw new Error('Unsupported workspace action.');
}
