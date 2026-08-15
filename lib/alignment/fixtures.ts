import { notFoundError } from '@/lib/errors';
import type { PortalSession } from '@/lib/portal/types';
import type { AlignmentCapabilityData, AlignmentMutation } from './types';

interface AlignmentFixtureStore { revision: number; recordedPractices: string[]; completedActivities: string[] }
declare global { var __leAlignmentFixtures: AlignmentFixtureStore | undefined; }
function store() {
  globalThis.__leAlignmentFixtures ??= { revision: 0, recordedPractices: [], completedActivities: [] };
  return globalThis.__leAlignmentFixtures;
}

export function fixtureAlignmentCapability(session: PortalSession): AlignmentCapabilityData {
  const fixtureStore = store();
  const activities = [
    { id: 'activity-boundary-lab', title: 'Boundary judgment lab', status: fixtureStore.completedActivities.includes('activity-boundary-lab') ? 'COMPLETED' : 'ACTIVE' },
    { id: 'activity-coached-decisions', title: 'Two coached live decisions', status: fixtureStore.completedActivities.includes('activity-coached-decisions') ? 'COMPLETED' : 'ACTIVE' },
  ];
  return {
    organizationId: session.organization.id, engagementId: session.engagement.id,
    role: session.role as 'consultant' | 'client', fixture: true,
    roleArchitectures: [{
      id: 'role-team-lead', name: 'Team Lead',
      purpose: 'Move routine decisions closer to the work while protecting purpose, quality, and escalation judgment.',
      responsibilities: ['Own routine delivery decisions', 'Document exceptions and learning'],
      authorities: ['Approve routine client exceptions within the documented threshold'],
      boundaries: ['Escalate legal, safety, and unbudgeted commitments', 'Do not change organization-wide policy'],
      interfaces: ['Executive sponsor · exception review', 'Operations team · weekly learning loop'],
      support: 'Decision guide, financial context, and monthly coaching.',
      accountability: 'Executive sponsor reviews exceptions and evidence monthly.',
      successMeasures: 'Lower decision latency without increased rework or preventable escalation.',
      decisionLabel: 'Delegate defined routine decisions · Approved Aug 10', status: 'ACTIVE',
    }],
    workflows: [{
      id: 'workflow-bounded-decision', name: 'Bounded operational decision',
      purpose: 'Make purpose-consistent routine decisions at the closest capable level.', ownerRole: 'Team Lead',
      steps: [
        { name: 'Name the decision and boundary', owner: 'Team Lead' },
        { name: 'Check threshold and evidence', owner: 'Team Lead', decisionPoint: true },
        { name: 'Decide or escalate', owner: 'Team Lead', decisionPoint: true },
        { name: 'Document outcome and learning', owner: 'Team Lead' },
      ],
    }],
    initiatives: [{ id: 'initiative-distributed-authority', name: 'Distributed decision authority', owner: 'Executive sponsor', status: 'ACTIVE', intendedCondition: 'Routine authority operates near the work with explicit limits and evidence.' }],
    capabilityPathways: [{
      id: 'pathway-decision-judgment', capabilityName: 'Bounded decision judgment',
      definition: 'Reliably choose, document, and escalate operational decisions under explicit purpose and boundary conditions.',
      requiredBy: 'Team Lead role · Bounded operational decision workflow', requiredLevel: 'RELIABLE', currentLevel: 'DEVELOPING',
      evidence: ['Four observed decisions · two independent', 'Coaching session 3 shared summary', 'Exception log · Aug 1–9'],
      gap: 'Judgment is sound in familiar cases but escalation thresholds are not yet applied reliably under time pressure.',
      developmentPlanId: 'development-plan-decision-judgment', capabilityId: 'capability-decision-judgment',
      developmentPlan: 'Practice six live decisions using the boundary prompt; review exceptions weekly; reassess after four weeks.',
      activities, practices: ['Use the boundary prompt before commitment', ...fixtureStore.recordedPractices.map((item) => `${item} · practice ${fixtureStore.revision}`)],
      resources: ['Decision boundary field guide', 'Exception review template'],
      maturityEvidence: ['Pending: six live decisions and reviewer-confirmed transfer across two contexts'],
    }],
  };
}

export function mutateFixtureAlignment(session: PortalSession, mutation: AlignmentMutation) {
  const fixtureStore = store();
  const current = fixtureAlignmentCapability(session);
  const pathway = current.capabilityPathways.find((item) => item.id === mutation.pathwayId);
  if (!pathway) throw notFoundError('Capability pathway is not available.');
  if (mutation.action === 'ADD_PRACTICE') { fixtureStore.recordedPractices.push(mutation.practice); fixtureStore.revision += 1; }
  else {
    if (!pathway.activities.some((activity) => activity.id === mutation.activityId)) throw notFoundError('Development activity is not available.');
    fixtureStore.completedActivities = mutation.status === 'COMPLETED'
      ? [...new Set([...fixtureStore.completedActivities, mutation.activityId])]
      : fixtureStore.completedActivities.filter((id) => id !== mutation.activityId);
  }
  return fixtureAlignmentCapability(session);
}

export function resetAlignmentFixtures() { globalThis.__leAlignmentFixtures = { revision: 0, recordedPractices: [], completedActivities: [] }; }
