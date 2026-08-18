import 'server-only';

import { authorizationError, dataAccessError, notFoundError, validationError } from '@/lib/errors';
import { guidedQuestions, type GuidedQuestion } from '@/lib/operational-ai/guided-workflows';
import type { GuidedRecordKind } from '@/lib/operational-ai/types';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import type { ClientMcpContext, ClientMcpEngagement, ClientMcpResolution } from './session';

interface GuidedRecordRow {
  record_kind: string;
  record_id: string;
  title: string;
  record_context: string;
  record_status: string;
  question_id: string | null;
  answer: string | null;
  updated_at: string | null;
}

export async function getClientWorkspace(resolution: ClientMcpResolution) {
  if (resolution.status !== 'ready') return workspaceStatus(resolution);
  const currentWork = await findCurrentWork(resolution.context);
  return {
    status: currentWork ? 'ready' : 'work_complete',
    identity: { personId: resolution.context.personId, displayName: resolution.context.displayName },
    organization: { id: resolution.context.organization.id, name: resolution.context.organization.name },
    engagement: {
      id: resolution.context.engagement.id,
      name: resolution.context.engagement.name,
      type: resolution.context.engagement.engagementType,
      status: resolution.context.engagement.status,
      currentStage: resolution.context.engagement.currentPhase,
    },
    membership: { platformRole: resolution.context.platformRole },
    currentWork: currentWork ? {
      type: currentWork.recordKind,
      id: currentWork.recordId,
      title: currentWork.title,
      status: currentWork.status,
    } : undefined,
    progress: currentWork ? {
      completed: currentWork.completedResponseCount,
      total: guidedQuestions[currentWork.recordKind].length,
      summary: `${currentWork.completedResponseCount} of ${guidedQuestions[currentWork.recordKind].length} questions confirmed.`,
    } : undefined,
    nextAction: currentWork ? {
      type: 'GUIDED_RECORD',
      label: `Continue ${currentWork.title}`,
      targetId: currentWork.recordId,
    } : null,
    counts: { unanswered: currentWork ? Math.max(guidedQuestions[currentWork.recordKind].length - currentWork.completedResponseCount, 0) : 0 },
    agent: { label: 'Lead Emergence Consulting Advisor', posture: ['Evidence before interpretation', 'Human judgment remains authoritative'] },
  };
}

export async function listMyGuidedRecords(context: ClientMcpContext) {
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.rpc('list_my_guided_records', {
    p_organization_id: context.organization.id,
    p_engagement_id: context.engagement.id,
  });
  if (error) throw dataAccessError('mcp.client.listGuidedRecords', error, 'The assigned consulting work could not be loaded.');
  return normalizeRecords(data);
}

export async function getMyGuidedRecord(context: ClientMcpContext, input: { recordKind: GuidedRecordKind; recordId: string }) {
  const rows = await getRecordRows(context, input);
  const first = rows[0];
  if (!first) throw notFoundError('The requested guided work is unavailable.');
  const questions = guidedQuestions[input.recordKind];
  const responses = rows.flatMap((row) => row.question_id && row.answer && row.updated_at ? [{ questionId: row.question_id, answer: row.answer, updatedAt: row.updated_at }] : []);
  const answered = new Set(responses.map((item) => item.questionId));
  const nextQuestion = questions.find((item) => !answered.has(item.id));
  return {
    kind: input.recordKind,
    id: input.recordId,
    title: first.title,
    context: first.record_context,
    status: first.record_status,
    questions,
    responses,
    completedCount: answered.size,
    totalCount: questions.length,
    nextQuestionId: nextQuestion?.id,
    nextQuestion,
  };
}

export async function saveMyConfirmedGuidedResponse(context: ClientMcpContext, input: { recordKind: GuidedRecordKind; recordId: string; questionId: string; answer: string }) {
  if (!guidedQuestions[input.recordKind].some((question) => question.id === input.questionId)) {
    throw validationError('The question is not part of the assigned guided work.');
  }
  await getRecordRows(context, input);
  const supabase = await createSupabaseServerClient();
  const { error } = await supabase.from('guided_record_responses').upsert({
    organization_id: context.organization.id,
    engagement_id: context.engagement.id,
    record_kind: input.recordKind,
    record_id: input.recordId,
    question_id: input.questionId,
    answer: input.answer.trim(),
    confirmed_by: context.personId,
    confirmed_at: new Date().toISOString(),
  }, { onConflict: 'organization_id,engagement_id,record_kind,record_id,question_id' });
  if (error) throw dataAccessError('mcp.client.saveGuidedResponse', error, 'The confirmed response could not be saved.');
  return getMyGuidedRecord(context, input);
}

export function normalizeClientRecordKind(value: unknown): GuidedRecordKind {
  if (value !== 'AUDIT' && value !== 'INTERVIEW') throw authorizationError('Only guided work assigned to this client is available.');
  return value;
}

function workspaceStatus(resolution: Exclude<ClientMcpResolution, { status: 'ready' }>) {
  if (resolution.status === 'no_assignment') {
    return { status: 'no_assignment', identity: { personId: resolution.personId, displayName: resolution.displayName }, message: 'No active Lead Emergence consulting engagement is assigned to this account.' };
  }
  return {
    status: 'selection_required',
    identity: { personId: resolution.personId, displayName: resolution.displayName },
    engagements: resolution.engagements.map(selectionSummary),
  };
}

function selectionSummary(item: ClientMcpEngagement) {
  return {
    id: item.id,
    organizationId: item.organizationId,
    organizationName: item.organization.name,
    name: item.name,
    status: item.status,
    currentStage: item.currentPhase,
    platformRole: item.platformRole,
  };
}

async function findCurrentWork(context: ClientMcpContext) {
  const records = await listMyGuidedRecords(context);
  const incomplete = records.filter((record) => record.completedResponseCount < guidedQuestions[record.recordKind].length);
  if (incomplete.length === 1) return incomplete[0];
  return undefined;
}

async function getRecordRows(context: ClientMcpContext, input: { recordKind: GuidedRecordKind; recordId: string }) {
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.rpc('get_my_guided_record', {
    p_organization_id: context.organization.id,
    p_engagement_id: context.engagement.id,
    p_record_kind: input.recordKind,
    p_record_id: input.recordId,
  });
  if (error) throw dataAccessError('mcp.client.getGuidedRecord', error, 'The requested guided work is unavailable.');
  const rows = (Array.isArray(data) ? data : data ? [data] : []) as GuidedRecordRow[];
  if (!rows.length) throw notFoundError('The requested guided work is unavailable.');
  return rows;
}

function normalizeRecords(data: unknown) {
  const rows = (Array.isArray(data) ? data : []) as Array<{
    record_kind: string;
    record_id: string;
    title: string;
    record_status: string;
    scheduled_at: string | null;
    completed_response_count: number | string;
  }>;
  return rows.flatMap((row) => {
    if (row.record_kind !== 'AUDIT' && row.record_kind !== 'INTERVIEW') return [];
    return [{
      recordKind: row.record_kind as GuidedRecordKind,
      recordId: row.record_id,
      title: row.title,
      status: row.record_status,
      scheduledAt: row.scheduled_at ?? undefined,
      completedResponseCount: Number(row.completed_response_count),
    }];
  });
}

export function nextQuestion(questions: GuidedQuestion[], answers: Array<{ questionId: string }>) {
  const answered = new Set(answers.map((answer) => answer.questionId));
  return questions.find((question) => !answered.has(question.id));
}