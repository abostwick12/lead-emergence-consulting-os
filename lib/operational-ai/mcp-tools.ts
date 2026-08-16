import 'server-only';
import { authorizationError, validationError } from '@/lib/errors';
import type { PortalSession } from '@/lib/portal/types';
import { getGuidedRecord } from './guided-workflows';
import { getOperationalEngagement, mutateOperationalEngagement } from './repository';
import type { GuidedRecordKind } from './types';
import { validateOperationalMutation } from './workflow';
import { assessmentWorkflowDefinitions, getAssessmentWorkflowDefinition } from './assessment-workflow-definitions';
import { startAssessmentAdministration } from './assessment-administration';
import { submitParticipantAssessment } from '@/lib/access/assessment';

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
  {
    name: 'list_assessment_instruments',
    title: 'List authoritative assessment instruments',
    description: 'Lists the complete versioned Mission Product assessment instruments available to the active engagement.',
    readOnly: true,
  },
  {
    name: 'get_assessment_instrument',
    title: 'Read an authoritative assessment instrument',
    description: 'Returns every section, item, checklist option, matrix column, and response contract for one immutable instrument version.',
    readOnly: true,
  },
  {
    name: 'start_assessment_administration',
    title: 'Start a guided assessment administration',
    description: 'Creates a tenant-scoped administration of the exact authoritative instrument and returns the participant capability needed for the conversation.',
    readOnly: false,
    destructive: false,
  },
  {
    name: 'save_assessment_response',
    title: 'Save one confirmed assessment response',
    description: 'Saves one structured response after explicit confirmation. Never infer omitted fields, score the instrument, or convert a response into diagnosis.',
    readOnly: false,
    destructive: false,
  },
] as const;

export async function executeOperationalMcpTool(session: PortalSession, name: string, input: Record<string, unknown>) {
  if (session.role !== 'consultant') throw authorizationError('Consultant access is required.');
  if (name === 'list_assessment_instruments') return assessmentWorkflowDefinitions.map((definition) => ({ slug: definition.slug, title: definition.title, version: definition.version, sections: definition.sections.length, items: definition.items.length }));
  if (name === 'get_assessment_instrument') {
    const definition = getAssessmentWorkflowDefinition(requiredText(input.slug, 'slug'));
    if (!definition) throw validationError('The assessment instrument was not found.');
    return definition;
  }
  if (name === 'start_assessment_administration') return startAssessmentAdministration(session, requiredText(input.slug, 'slug'));
  if (name === 'save_assessment_response') {
    if (input.confirmed !== true) throw validationError('Explicit user confirmation is required before saving an assessment response.');
    return submitParticipantAssessment(requiredText(input.participantToken, 'participantToken'), requiredText(input.itemId, 'itemId'), input.response);
  }

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
