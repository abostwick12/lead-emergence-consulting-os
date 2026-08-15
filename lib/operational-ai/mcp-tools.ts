import 'server-only';
import { authorizationError, validationError } from '@/lib/errors';
import type { PortalSession } from '@/lib/portal/types';
import { getGuidedRecord } from './guided-workflows';
import { getOperationalEngagement, mutateOperationalEngagement } from './repository';
import type { GuidedRecordKind } from './types';
import { validateOperationalMutation } from './workflow';

export const operationalMcpTools = [
  {
    name: 'list_engagement_records',
    title: 'List Consulting OS engagement records',
    description: 'Lists sanitized product, written-audit, or interview records for the consultant’s active engagement.',
    readOnly: true,
  },
  {
    name: 'get_guided_record',
    title: 'Read a guided Consulting OS record',
    description: 'Returns the record context, guided questions, saved responses, progress, and next unanswered question.',
    readOnly: true,
  },
  {
    name: 'save_guided_response',
    title: 'Save one confirmed guided response',
    description: 'Saves one sanitized response after the user explicitly confirms the exact answer. Never use this tool to infer or silently summarize an answer.',
    readOnly: false,
    destructive: false,
  },
] as const;

export async function executeOperationalMcpTool(session: PortalSession, name: string, input: Record<string, unknown>) {
  if (session.role !== 'consultant') throw authorizationError('Consultant access is required.');
  const data = await getOperationalEngagement(session);
  if (name === 'list_engagement_records') {
    const kind = recordKind(input.recordKind);
    if (kind === 'PRODUCT') return data.products.map((item) => ({ id: item.id, title: item.name, status: item.status, completedResponses: item.responses.length }));
    if (kind === 'AUDIT') return data.audits.map((item) => ({ id: item.id, title: item.title, status: item.status, completedResponses: item.responses.length, totalPrompts: item.totalPrompts }));
    return data.interviews.map((item) => ({ id: item.id, title: item.participantLabel, status: item.status, completedResponses: item.responses.length }));
  }
  if (name === 'get_guided_record') return getGuidedRecord(data, recordKind(input.recordKind), requiredText(input.recordId, 'recordId'));
  if (name === 'save_guided_response') {
    if (input.confirmed !== true) throw validationError('Explicit user confirmation is required before saving a guided response.');
    return mutateOperationalEngagement(session, validateOperationalMutation({
      action: 'SAVE_GUIDED_RESPONSE',
      recordKind: recordKind(input.recordKind),
      recordId: requiredText(input.recordId, 'recordId'),
      questionId: requiredText(input.questionId, 'questionId'),
      answer: requiredText(input.answer, 'answer'),
    }));
  }
  throw validationError('Unsupported Consulting OS MCP tool.');
}

function recordKind(value: unknown): GuidedRecordKind {
  if (value !== 'PRODUCT' && value !== 'AUDIT' && value !== 'INTERVIEW') throw validationError('recordKind must be PRODUCT, AUDIT, or INTERVIEW.');
  return value;
}

function requiredText(value: unknown, name: string) {
  if (typeof value !== 'string' || !value.trim()) throw validationError(`${name} is required.`);
  return value.trim();
}
