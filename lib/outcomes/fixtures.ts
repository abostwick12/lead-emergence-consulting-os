import type { PortalSession } from '@/lib/portal/types';
import type { OutcomeDisposition, OutcomesMutation, OutcomesNewRealityData } from './types';
import { nextOutcomeAction } from './workflow';

interface OutcomeFixtureStore {
  measuredValue?: string; outcomeStatement?: string; harvest?: string; soil?: string;
  learning?: string; disposition?: OutcomeDisposition;
  profileName?: string; actualState?: string; difference?: string; baseline?: boolean;
}
declare global { var __leOutcomeFixtures: OutcomeFixtureStore | undefined; }
function store() { globalThis.__leOutcomeFixtures ??= {}; return globalThis.__leOutcomeFixtures; }

export function fixtureOutcomesNewReality(session: PortalSession): OutcomesNewRealityData {
  const state = store();
  const data: OutcomesNewRealityData = {
    organizationId: session.organization.id, engagementId: session.engagement.id,
    role: session.role as 'consultant' | 'client', fixture: true,
    goal: { id: 'goal-decision-latency', statement: 'Reduce routine decision latency without degrading decision quality.', baseline: '6.2 days', target: '3.0 days', owner: 'Executive sponsor', status: 'ACTIVE' },
    valueHypothesis: { id: 'hypothesis-bounded-authority', statement: 'If authority moves closer to the work while capability and boundaries strengthen, latency should fall without degrading quality.', createdLabel: 'Established before implementation', status: 'ACTIVE' },
    indicator: { id: 'indicator-latency', name: 'Routine decision latency', baseline: '6.2 days', target: '3.0 days', history: [{ value: '6.2 days', period: 'Baseline · Jul 2026' }, ...(state.measuredValue ? [{ value: state.measuredValue, period: 'Current · Aug 2026' }] : [])] },
    evidenceOptions: [{ id: 'evidence-decision-sample', label: 'Decision-latency sample · ten routine decisions' }],
    futureState: { statement: 'Routine decisions are made at the closest capable level within explicit boundaries.', version: 1 },
  };
  if (state.outcomeStatement && state.measuredValue) data.outcome = { id: 'outcome-latency', statement: state.outcomeStatement, measuredValue: state.measuredValue, association: 'Evaluates the initiative and goal', causalStatus: 'No causal claim' };
  if (state.harvest && state.soil) data.evaluation = { id: 'evaluation-harvest-soil', harvest: state.harvest, soil: state.soil, dimensions: [
    { name: 'Organizational', rating: 'STRONG', rationale: 'Decision flow is measurably faster.' },
    { name: 'People', rating: 'DEVELOPING', rationale: 'Confidence is growing unevenly.' },
    { name: 'Capability', rating: 'STRONG', rationale: 'Boundary judgment is becoming reliable.' },
    { name: 'Relationship', rating: 'STABLE', rationale: 'Escalation conversations remain healthy.' },
    { name: 'Purpose', rating: 'STRONG', rationale: 'Decisions remain aligned with purpose.' },
  ] };
  if (state.learning) data.learning = { statement: state.learning, reviewState: 'VALIDATED', disposition: state.disposition };
  if (state.profileName && state.actualState && state.difference) data.emergentProfile = { id: 'profile-new-reality', name: state.profileName, actualState: state.actualState, difference: state.difference, status: 'APPROVED' };
  if (state.baseline) data.baseline = { id: 'baseline-new-reality', label: 'New Reality baseline · Aug 2026', memberCount: 7, immutable: true };
  return data;
}

export function mutateFixtureOutcomes(session: PortalSession, mutation: OutcomesMutation) {
  if (session.role !== 'consultant') throw new Error('Only the assigned consultant may advance this workflow.');
  const state = store();
  const current = fixtureOutcomesNewReality(session);
  if (mutation.action !== nextOutcomeAction(current)) throw new Error('Complete the preceding outcome step first.');
  if (mutation.action === 'RECORD_OUTCOME') { state.measuredValue = mutation.measuredValue; state.outcomeStatement = mutation.statement; }
  if (mutation.action === 'EVALUATE_VALUE') { state.harvest = mutation.harvest; state.soil = mutation.soil; }
  if (mutation.action === 'VALIDATE_LEARNING') { state.learning = mutation.statement; state.disposition = mutation.disposition; }
  if (mutation.action === 'ESTABLISH_BASELINE') { state.profileName = mutation.profileName; state.actualState = mutation.actualState; state.difference = mutation.difference; state.baseline = true; }
  return fixtureOutcomesNewReality(session);
}

export function resetOutcomeFixtures() { globalThis.__leOutcomeFixtures = {}; }
