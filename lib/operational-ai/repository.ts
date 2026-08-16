import 'server-only';
import type { PortalSession } from '@/lib/portal/types';
import { fixtureOperationalEngagement, updateFixtureOperationalEngagement } from './fixtures';
import type { OperationalEngagementData } from './types';
import type { OperationalMutation } from './workflow';
import { authorizationError, dataAccessError, notFoundError, unavailableError } from '@/lib/errors';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { assertSucceeded } from '@/lib/supabase/errors';
import { guidedQuestions } from './guided-workflows';

export const operationalProvisioningGateNotice = 'Hosted Operational Product AI storage is not provisioned yet.';

export function isOperationalWorkspaceProvisioned(session: PortalSession) {
  return session.fixture;
}

function id(prefix: string) { return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 7)}` }

export async function getOperationalEngagement(session: PortalSession): Promise<OperationalEngagementData> {
  if (session.fixture) return fixtureOperationalEngagement();
  const supabase = await createSupabaseServerClient();
  const [engagementResult, productsResult, auditsResult, interviewsResult, linksResult, responsesResult, requestsResult, actionsResult] = await Promise.all([
    supabase.from('engagements').select('id, organization_id, name, engagement_type, objective, scope_statement, handling_label, handling_notice, current_phase, ends_on').eq('id', session.engagement.id).eq('organization_id', session.organization.id).maybeSingle(),
    supabase.from('engagement_products').select('id, name, description, owner_label, product_status, handling_label').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).order('created_at'),
    supabase.from('written_audit_assignments').select('id, product_id, respondent_label, due_on, audit_status').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).order('created_at'),
    supabase.from('interviews').select('id, participant_label, interview_status, scheduled_at, guide_name, objective, interview_type').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).neq('interview_status', 'CANCELLED').order('scheduled_at'),
    supabase.from('interview_product_links').select('interview_id, product_id').eq('organization_id', session.organization.id),
    supabase.from('guided_record_responses').select('record_kind, record_id, question_id, answer, updated_at').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).order('updated_at'),
    supabase.from('artifact_requests').select('id, product_id, title, requested_from, requested_on, due_on, request_status, handling_note').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).order('created_at'),
    supabase.from('engagement_actions').select('id, title, owner_label, due_on, action_status').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).order('created_at'),
  ]);
  assertSucceeded('operationalAi.load', engagementResult, productsResult, auditsResult, interviewsResult, linksResult, responsesResult, requestsResult, actionsResult);
  const engagement = engagementResult.data;
  if (!engagement || engagement.engagement_type !== 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION') throw unavailableError(operationalProvisioningGateNotice);

  const responses = new Map<string, Array<{ questionId: string; answer: string; updatedAt: string }>>();
  for (const row of responsesResult.data ?? []) {
    const key = `${row.record_kind}:${row.record_id}`;
    const current = responses.get(key) ?? [];
    current.push({ questionId: row.question_id, answer: row.answer, updatedAt: row.updated_at });
    responses.set(key, current);
  }
  const products = (productsResult.data ?? []).map((row) => ({
    id: row.id,
    name: row.name,
    description: row.description,
    ownerLabel: row.owner_label,
    status: row.product_status as 'ACTIVE' | 'ON_HOLD' | 'COMPLETE',
    handlingLabel: row.handling_label,
    responses: responses.get(`PRODUCT:${row.id}`) ?? [],
  }));
  const productNames = new Map(products.map((product) => [product.id, product.name]));
  const interviewProducts = new Map((linksResult.data ?? []).map((row) => [row.interview_id, row.product_id]));
  return {
    organizationId: session.organization.id,
    engagementId: session.engagement.id,
    organizationName: session.organization.name,
    engagementName: engagement.name,
    engagementType: 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION',
    objective: engagement.objective ?? '',
    scopeStatement: engagement.scope_statement ?? '',
    ownerLabel: session.displayName,
    handlingLabel: 'Internal — Sanitized Only',
    handlingNotice: engagement.handling_notice ?? 'Use sanitized, authorized process-level information only.',
    currentStage: 'SEE REALITY',
    targetCompletion: engagement.ends_on ?? '',
    products,
    audits: (auditsResult.data ?? []).map((row) => {
      const saved = responses.get(`AUDIT:${row.id}`) ?? [];
      return {
        id: row.id,
        productId: row.product_id,
        title: `${productNames.get(row.product_id) ?? 'Product'} · written audit`,
        respondentLabel: row.respondent_label,
        dueOn: row.due_on ?? '',
        status: row.audit_status as 'NOT_STARTED' | 'IN_PROGRESS' | 'SUBMITTED' | 'REVIEWED',
        completedResponses: saved.length,
        totalPrompts: guidedQuestions.AUDIT.length,
        responses: saved,
      };
    }),
    interviews: (interviewsResult.data ?? []).map((row) => ({
      id: row.id,
      productId: interviewProducts.get(row.id) ?? '',
      participantLabel: row.participant_label,
      interviewType: row.interview_type ?? row.guide_name,
      objective: row.objective ?? row.guide_name,
      scheduledFor: row.scheduled_at ?? '',
      status: row.interview_status as 'PLANNED' | 'IN_PROGRESS' | 'COMPLETED',
      notesCount: (responses.get(`INTERVIEW:${row.id}`) ?? []).length,
      responses: responses.get(`INTERVIEW:${row.id}`) ?? [],
    })),
    workflows: [],
    evidence: [],
    requests: (requestsResult.data ?? []).map((row) => ({ id: row.id, productId: row.product_id ?? undefined, title: row.title, requestedFrom: row.requested_from, requestedOn: row.requested_on, dueOn: row.due_on ?? '', status: row.request_status as 'REQUESTED' | 'RECEIVED' | 'DECLINED' | 'NOT_AVAILABLE', handlingNote: row.handling_note })),
    actions: (actionsResult.data ?? []).map((row) => ({ id: row.id, title: row.title, ownerLabel: row.owner_label, dueOn: row.due_on ?? '', status: row.action_status as 'OPEN' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED', visibility: 'ENGAGEMENT_SHARED' })),
  };
}

export async function mutateOperationalEngagement(session: PortalSession, mutation: OperationalMutation) {
  if (session.role !== 'consultant') throw authorizationError('Consultant access is required.');
  if (!session.fixture) {
    if (mutation.action !== 'SAVE_GUIDED_RESPONSE') throw unavailableError(operationalProvisioningGateNotice);
    const supabase = await createSupabaseServerClient();
    const { error } = await supabase.from('guided_record_responses').upsert({
      organization_id: session.organization.id,
      engagement_id: session.engagement.id,
      record_kind: mutation.recordKind,
      record_id: mutation.recordId,
      question_id: mutation.questionId,
      answer: mutation.answer,
      confirmed_by: session.personId,
      confirmed_at: new Date().toISOString(),
    }, { onConflict: 'organization_id,engagement_id,record_kind,record_id,question_id' });
    if (error) throw dataAccessError('operationalAi.saveGuidedResponse', error, 'The confirmed response could not be saved.');
    return getOperationalEngagement(session);
  }
  return updateFixtureOperationalEngagement((current) => {
    if (mutation.action === 'ADD_PRODUCT') current.products.push({ id: id('product'), name: mutation.name, description: mutation.description, ownerLabel: mutation.ownerLabel, status: 'ACTIVE', handlingLabel: current.handlingLabel, responses: [] });
    if (mutation.action === 'UPDATE_PRODUCT_SUMMARY') current.products = current.products.map((item) => item.id === mutation.id ? { ...item, name: mutation.name, description: mutation.description, ownerLabel: mutation.ownerLabel, status: mutation.status } : item);
    if (mutation.action === 'UPDATE_AUDIT_STATUS') current.audits = current.audits.map((item) => item.id === mutation.id ? { ...item, status: mutation.status } : item);
    if (mutation.action === 'ADD_INTERVIEW') current.interviews.push({ id: id('interview'), productId: mutation.productId, participantLabel: mutation.participantLabel, interviewType: mutation.interviewType, objective: mutation.objective, scheduledFor: mutation.scheduledFor, status: 'PLANNED', notesCount: 0, responses: [] });
    if (mutation.action === 'UPDATE_INTERVIEW_STATUS') current.interviews = current.interviews.map((item) => item.id === mutation.id ? { ...item, status: mutation.status } : item);
    if (mutation.action === 'SAVE_GUIDED_RESPONSE') {
      const response = { questionId: mutation.questionId, answer: mutation.answer, updatedAt: new Date().toISOString() };
      const save = (responses: typeof current.products[number]['responses']) => [...responses.filter((item) => item.questionId !== mutation.questionId), response];
      let found = false;
      if (mutation.recordKind === 'PRODUCT') current.products = current.products.map((item) => {
        if (item.id !== mutation.recordId) return item;
        found = true;
        return { ...item, responses: save(item.responses) };
      });
      if (mutation.recordKind === 'AUDIT') current.audits = current.audits.map((item) => {
        if (item.id !== mutation.recordId) return item;
        found = true;
        const responses = save(item.responses);
        return { ...item, responses, completedResponses: responses.length, status: item.status === 'NOT_STARTED' ? 'IN_PROGRESS' : item.status };
      });
      if (mutation.recordKind === 'INTERVIEW') current.interviews = current.interviews.map((item) => {
        if (item.id !== mutation.recordId) return item;
        found = true;
        const responses = save(item.responses);
        return { ...item, responses, notesCount: responses.length, status: item.status === 'PLANNED' ? 'IN_PROGRESS' : item.status };
      });
      if (!found) throw notFoundError('The requested guided record was not found.');
    }
    if (mutation.action === 'ADD_EVIDENCE') current.evidence.push({ id: id('evidence'), productId: mutation.productId, title: mutation.title, sourceType: mutation.sourceType, observation: mutation.observation, sourceLocator: mutation.sourceLocator, visibility: mutation.visibility, status: 'CAPTURED' });
    if (mutation.action === 'ADD_REQUEST') current.requests.push({ id: id('request'), productId: mutation.productId, title: mutation.title, requestedFrom: mutation.requestedFrom, requestedOn: new Date().toISOString().slice(0, 10), dueOn: mutation.dueOn, status: 'REQUESTED', handlingNote: 'Sanitized material only; no operational content.' });
    if (mutation.action === 'ADD_ACTION') current.actions.push({ id: id('action'), title: mutation.title, ownerLabel: mutation.ownerLabel, dueOn: mutation.dueOn, status: 'OPEN', visibility: mutation.visibility });
    if (mutation.action === 'UPDATE_ACTION_STATUS') current.actions = current.actions.map((item) => item.id === mutation.id ? { ...item, status: mutation.status } : item);
    if (mutation.action === 'UPDATE_STEP_SUITABILITY') current.workflows = current.workflows.map((workflow) => ({ ...workflow, steps: workflow.steps.map((step) => step.id === mutation.id ? { ...step, aiSuitability: mutation.aiSuitability } : step) }));
    return current;
  });
}
