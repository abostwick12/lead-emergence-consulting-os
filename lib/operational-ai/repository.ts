import 'server-only';
import type { PortalSession } from '@/lib/portal/types';
import { fixtureOperationalEngagement, updateFixtureOperationalEngagement } from './fixtures';
import type { OperationalEngagementData } from './types';
import type { OperationalMutation } from './workflow';

function id(prefix: string) { return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 7)}` }

export async function getOperationalEngagement(session: PortalSession): Promise<OperationalEngagementData> {
  if (session.fixture) return fixtureOperationalEngagement();
  throw new Error('Hosted Operational Product AI provisioning remains disabled until the approved infrastructure checkpoint.');
}

export async function mutateOperationalEngagement(session: PortalSession, mutation: OperationalMutation) {
  if (session.role !== 'consultant') throw new Error('Consultant access is required.');
  if (!session.fixture) throw new Error('Hosted Operational Product AI mutations remain disabled until the approved infrastructure checkpoint.');
  return updateFixtureOperationalEngagement((current) => {
    if (mutation.action === 'ADD_PRODUCT') current.products.push({ id: id('product'), name: mutation.name, description: mutation.description, ownerLabel: mutation.ownerLabel, status: 'ACTIVE', handlingLabel: current.handlingLabel });
    if (mutation.action === 'UPDATE_AUDIT_STATUS') current.audits = current.audits.map((item) => item.id === mutation.id ? { ...item, status: mutation.status } : item);
    if (mutation.action === 'ADD_INTERVIEW') current.interviews.push({ id: id('interview'), productId: mutation.productId, participantLabel: mutation.participantLabel, interviewType: mutation.interviewType, objective: mutation.objective, scheduledFor: mutation.scheduledFor, status: 'PLANNED', notesCount: 0 });
    if (mutation.action === 'ADD_EVIDENCE') current.evidence.push({ id: id('evidence'), productId: mutation.productId, title: mutation.title, sourceType: mutation.sourceType, observation: mutation.observation, sourceLocator: mutation.sourceLocator, visibility: mutation.visibility, status: 'CAPTURED' });
    if (mutation.action === 'ADD_REQUEST') current.requests.push({ id: id('request'), productId: mutation.productId, title: mutation.title, requestedFrom: mutation.requestedFrom, requestedOn: new Date().toISOString().slice(0, 10), dueOn: mutation.dueOn, status: 'REQUESTED', handlingNote: 'Sanitized material only; no operational content.' });
    if (mutation.action === 'ADD_ACTION') current.actions.push({ id: id('action'), title: mutation.title, ownerLabel: mutation.ownerLabel, dueOn: mutation.dueOn, status: 'OPEN', visibility: mutation.visibility });
    if (mutation.action === 'UPDATE_ACTION_STATUS') current.actions = current.actions.map((item) => item.id === mutation.id ? { ...item, status: mutation.status } : item);
    if (mutation.action === 'UPDATE_STEP_SUITABILITY') current.workflows = current.workflows.map((workflow) => ({ ...workflow, steps: workflow.steps.map((step) => step.id === mutation.id ? { ...step, aiSuitability: mutation.aiSuitability } : step) }));
    return current;
  });
}
