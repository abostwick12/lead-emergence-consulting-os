import type { PortalSession } from '@/lib/portal/types';
import { createFixtureStore } from '../fixtures/store';
import type { SignalItem, SignalsMutation, SignalsWorkspaceData } from './types';

interface SignalsFixtureStore {
  addedSignals: SignalItem[];
  reentries: SignalsWorkspaceData['reentries'];
  completedSchedules: string[];
}
const fixtures = createFixtureStore<SignalsFixtureStore>('signals', () => ({ addedSignals: [], reentries: [], completedSchedules: [] }));
const store = fixtures.read;

const seededSignals: SignalItem[] = [
  {
    id: 'signal-exception-cluster', statement: 'Escalation requests now cluster in two customer-facing workflows.',
    kind: 'OPERATING_CHANGE', detectedLabel: 'Observed 5 days ago', context: 'Weekly operating review',
    sourceLabel: 'Workflow exception log · Aug 2026', visibility: 'ENGAGEMENT_SHARED', status: 'NEW',
  },
  {
    id: 'signal-leader-confidence', statement: 'Leader confidence remains uneven after authority expanded.',
    kind: 'REPORTED_CHANGE', detectedLabel: 'Observed 8 days ago', context: 'Leadership debrief',
    sourceLabel: 'Leadership debrief · Aug 2026', visibility: 'LEADERSHIP_RESTRICTED', status: 'REVIEWED',
  },
];

export function fixtureSignalsWorkspace(session: PortalSession): SignalsWorkspaceData {
  const state = store();
  const signals = [...seededSignals, ...state.addedSignals].map((signal) => state.reentries.some((entry) => entry.signalId === signal.id) ? { ...signal, status: 'REENTERED' as const } : signal);
  return {
    organizationId: session.organization.id,
    engagementId: session.engagement.id,
    role: session.role as 'consultant' | 'client',
    fixture: true,
    signals: session.role === 'client' ? signals.filter((signal) => ['ENGAGEMENT_SHARED', 'ORGANIZATION_SHARED'].includes(signal.visibility)) : signals,
    trends: [{
      id: 'trend-decision-latency', indicator: 'Routine decision latency', direction: 'DECREASED',
      baseline: '6.2 days · Jul 2026', current: '3.4 days · Aug 2026',
      statement: 'Median routine decision latency decreased by 2.8 days between compatible measurement periods.',
      compatibility: 'Same indicator definition · same unit · same scoring rule',
      limitations: 'Two monthly periods are descriptive evidence, not proof of cause or a recurring Pattern.',
    }],
    assumptions: [
      { id: 'schedule-quality-assumption', statement: 'Senior approval protects decision quality.', dueLabel: 'Due now', trigger: 'Revisit after two completed measurement periods.', status: state.completedSchedules.includes('schedule-quality-assumption') ? 'COMPLETED' : 'DUE' },
      { id: 'schedule-boundary-assumption', statement: 'Explicit boundaries are sufficient for routine exception handling.', dueLabel: 'Due in 14 days', trigger: 'Revisit if escalation rate rises.', status: 'UPCOMING' },
    ],
    questions: [
      { id: 'question-exceptions', question: 'What distinguishes the two workflows where exceptions still escalate?', sourceLabel: 'Signal · exception cluster', reviewState: 'DRAFT' },
      { id: 'question-confidence', question: 'What evidence would show that confidence is becoming more consistent?', sourceLabel: 'Assumption · authority growth', reviewState: 'ACCEPTED' },
    ],
    baseline: { id: 'baseline-new-reality', label: 'Distributed Authority · New Reality', scope: 'Authority, capability, decision flow, and observed value', establishedLabel: 'Established Aug 2026', memberCount: 7, immutable: true },
    evidenceSources: [
      { id: 'evidence-workflow-log', label: 'Workflow exception log · Aug 2026' },
      { id: 'evidence-leadership-debrief', label: 'Leadership debrief · Aug 2026' },
    ],
    reentries: state.reentries,
  };
}

export function mutateFixtureSignals(session: PortalSession, mutation: SignalsMutation) {
  if (session.role !== 'consultant') throw new Error('Only the assigned consultant may advance SEE AGAIN.');
  const state = store();
  if (mutation.action === 'ADD_SIGNAL') state.addedSignals.push({
    id: `signal-${state.addedSignals.length + 1}`,
    statement: mutation.statement, kind: mutation.kind, detectedLabel: 'Observed just now', context: mutation.context,
    sourceLabel: fixtureSignalsWorkspace(session).evidenceSources.find((item) => item.id === mutation.evidenceId)?.label ?? 'Selected evidence',
    visibility: 'ENGAGEMENT_SHARED', status: 'NEW',
  });
  if (mutation.action === 'REENTER_SIGNAL') {
    if (state.reentries.some((entry) => entry.signalId === mutation.signalId)) throw new Error('This Signal has already re-entered inquiry.');
    state.reentries.push({ signalId: mutation.signalId, observationId: `observation-${state.reentries.length + 1}`, statement: mutation.observationStatement, relationship: 'REENTERS_AS' });
  }
  if (mutation.action === 'COMPLETE_ASSUMPTION_REVIEW' && !state.completedSchedules.includes(mutation.scheduleId)) state.completedSchedules.push(mutation.scheduleId);
  return fixtureSignalsWorkspace(session);
}

export function resetSignalsFixtures() { fixtures.reset(); }
