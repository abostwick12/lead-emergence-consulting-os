import {
  roadmapStages,
  workspaceDefinitions,
  type AttentionItem,
  type EngagementOption,
  type OrganizationOption,
  type PortalDashboard,
  type PortalRecord,
  type PortalRole,
  type PortalSession,
} from './types';
import { fixtureOnboardingOptions } from '../onboarding/fixtures';
import { SEVENTH_SOS_ENGAGEMENT_ID, SEVENTH_SOS_ORGANIZATION_ID } from '../operational-ai/fixtures';

export const FIXTURE_ORGANIZATION_ID = '10000000-0000-4000-8000-000000000001';
export const FIXTURE_ENGAGEMENT_ID = '20000000-0000-4000-8000-000000000001';

const organization: OrganizationOption = {
  id: FIXTURE_ORGANIZATION_ID,
  name: 'Northstar Community Works',
  slug: 'northstar-community-works',
};

const engagement: EngagementOption = {
  id: FIXTURE_ENGAGEMENT_ID,
  organizationId: organization.id,
  name: 'Organizational Renewal 2026',
  status: 'ACTIVE',
  startsOn: '2026-06-01',
  endsOn: '2027-02-28',
};

const seventhSosOrganization: OrganizationOption = {
  id: SEVENTH_SOS_ORGANIZATION_ID,
  name: '7th Special Operations Squadron',
  slug: '7th-special-operations-squadron',
};

const seventhSosEngagement: EngagementOption = {
  id: SEVENTH_SOS_ENGAGEMENT_ID,
  organizationId: seventhSosOrganization.id,
  name: 'Operational Product AI Transformation',
  status: 'ACTIVE',
  startsOn: '2026-08-14',
  endsOn: '2026-10-30',
  engagementType: 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION',
  handlingLabel: 'Internal — Sanitized Only',
  currentPhase: 'SEE REALITY',
};

const records: PortalRecord[] = [
  {
    id: '30000000-0000-4000-8000-000000000001',
    organizationId: organization.id,
    engagementId: engagement.id,
    objectType: 'PATTERN',
    title: 'Authority repeatedly escalates upward',
    statement: 'Routine operational decisions are consistently routed to senior leaders across three workflows.',
    rationale: 'The recurrence across scheduling, spending, and client exceptions warrants review as a pattern.',
    state: 'AI SUGGESTION',
    origin: 'AI',
    visibility: 'ENGAGEMENT_SHARED',
    sourceLabels: ['Interview 04 · excerpt 12', 'Approval workflow · May 2026', 'Decision-latency sample'],
    history: [
      { date: 'Aug 8, 2026', action: 'Suggested from cited evidence', actor: 'Meridian' },
      { date: 'Aug 9, 2026', action: 'Queued for consultant review', actor: 'Alex Morgan' },
    ],
    updatedLabel: 'Updated Aug 9',
  },
  {
    id: '30000000-0000-4000-8000-000000000002',
    organizationId: organization.id,
    engagementId: engagement.id,
    objectType: 'INTERPRETATION',
    title: 'The constraint may be authority architecture',
    statement: 'The primary constraint may be unclear authority boundaries rather than a lack of employee initiative.',
    rationale: 'Observed escalation persists even where team leads demonstrate sound operational judgment.',
    state: 'INTERPRETATION',
    origin: 'HUMAN',
    visibility: 'ENGAGEMENT_SHARED',
    sourceLabels: ['Authority pattern', 'Leadership interview synthesis', 'Workflow review'],
    history: [
      { date: 'Aug 9, 2026', action: 'Drafted as a proposed meaning', actor: 'Alex Morgan' },
      { date: 'Aug 10, 2026', action: 'Shared for leadership review', actor: 'Alex Morgan' },
    ],
    updatedLabel: 'Updated today',
  },
  {
    id: '30000000-0000-4000-8000-000000000003',
    organizationId: organization.id,
    engagementId: engagement.id,
    objectType: 'INSIGHT',
    title: 'Authority can expand with explicit capability and boundaries',
    statement: 'Selected routine decisions can move closer to the work when capability expectations and escalation limits are explicit.',
    rationale: 'Leadership validated this conclusion after reviewing workflow evidence and alternative interpretations.',
    state: 'VALIDATED INSIGHT',
    origin: 'HUMAN',
    visibility: 'ORGANIZATION_SHARED',
    sourceLabels: ['Validated interpretation', 'Leadership review · Aug 10', 'Contrary evidence log'],
    history: [
      { date: 'Aug 9, 2026', action: 'Proposed for validation', actor: 'Alex Morgan' },
      { date: 'Aug 10, 2026', action: 'Validated with limitations recorded', actor: 'Leadership review group' },
    ],
    updatedLabel: 'Validated today',
  },
  {
    id: '30000000-0000-4000-8000-000000000004',
    organizationId: organization.id,
    engagementId: engagement.id,
    objectType: 'DECISION',
    title: 'Delegate defined routine decisions',
    statement: 'Team leads will receive authority for defined decision categories within documented thresholds.',
    rationale: 'Authorized leaders selected a bounded delegation approach after considering three alternatives.',
    state: 'DECISION',
    origin: 'HUMAN',
    visibility: 'ORGANIZATION_SHARED',
    sourceLabels: ['Validated insight', 'Decision record · DA-12', 'Alternative analysis'],
    history: [
      { date: 'Aug 10, 2026', action: 'Approved', actor: 'Executive sponsor' },
      { date: 'Aug 10, 2026', action: 'Linked to implementation planning', actor: 'Alex Morgan' },
    ],
    updatedLabel: 'Approved today',
  },
  {
    id: '30000000-0000-4000-8000-000000000005',
    organizationId: organization.id,
    engagementId: engagement.id,
    objectType: 'INTERPRETATION',
    title: 'Private consultant working interpretation',
    statement: 'A private working interpretation that must never appear in the client experience.',
    rationale: 'Unreviewed consultant analysis retained separately pending sufficient evidence.',
    state: 'INTERPRETATION',
    origin: 'HUMAN',
    visibility: 'CONSULTANT_PRIVATE',
    sourceLabels: ['Consultant-private note'],
    history: [{ date: 'Aug 10, 2026', action: 'Created as private analysis', actor: 'Alex Morgan' }],
    updatedLabel: 'Private · today',
  },
];

const consultantAttention: AttentionItem[] = [
  {
    id: 'review-pattern',
    title: 'Review Meridian pattern suggestion',
    description: 'Inspect three cited sources before accepting, modifying, or rejecting it.',
    kind: 'REVIEW',
    dueLabel: 'Due today',
    href: `/consultant/records/${records[0].id}`,
  },
  {
    id: 'leadership-review',
    title: 'Prepare leadership interpretation review',
    description: 'Two competing interpretations are ready for facilitated review.',
    kind: 'MEETING',
    dueLabel: 'Tomorrow · 10:00 AM',
    href: `/consultant/clients/${organization.id}/strategy`,
  },
];

const clientAttention: AttentionItem[] = [
  {
    id: 'client-review',
    title: 'Review the validated authority insight',
    description: 'Confirm the documented limitations before the alignment workshop.',
    kind: 'REVIEW',
    dueLabel: 'Due Friday',
    href: `/client/records/${records[2].id}`,
  },
  {
    id: 'client-commitment',
    title: 'Prepare boundary examples',
    description: 'Bring two routine decisions and one escalation example to the next meeting.',
    kind: 'COMMITMENT',
    dueLabel: 'Before Aug 14 meeting',
    href: '/client/my-development',
  },
  {
    id: 'client-assessment',
    title: 'Assessment opens next week',
    description: 'Your organization will receive a separate invitation when the administration opens.',
    kind: 'ASSESSMENT',
    dueLabel: 'Not yet open',
    href: '/client/our-organization',
  },
];

export function fixtureSession(role: PortalRole, requestedOrganizationId?: string, requestedEngagementId?: string): PortalSession | null {
  if (role === 'outsider') return null;
  const onboarding = fixtureOnboardingOptions();
  const organizations = [organization, seventhSosOrganization, ...onboarding.organizations];
  const engagements = [engagement, seventhSosEngagement, ...onboarding.engagements];
  const selectedOrganization = organizations.find((item) => item.id === requestedOrganizationId) ?? organization;
  const selectedEngagement = engagements.find((item) => item.id === requestedEngagementId && item.organizationId === selectedOrganization.id)
    ?? engagements.find((item) => item.organizationId === selectedOrganization.id)
    ?? engagement;
  return {
    personId: role === 'consultant' ? '40000000-0000-4000-8000-000000000001' : '40000000-0000-4000-8000-000000000002',
    displayName: role === 'consultant' ? 'Alex Morgan' : 'Jordan Lee',
    role,
    organizations,
    organization: selectedOrganization,
    engagements,
    engagement: selectedEngagement,
    fixture: true,
  };
}

export function fixtureDashboard(role: Exclude<PortalRole, 'outsider'>): PortalDashboard {
  const visibleRecords = role === 'consultant'
    ? records
    : records.filter((record) =>
        record.visibility === 'ORGANIZATION_SHARED' &&
        (record.state === 'VALIDATED INSIGHT' || record.state === 'DECISION'),
      );
  const baseHref = role === 'consultant' ? `/consultant/clients/${organization.id}` : '/client';
  return {
    organization,
    engagement,
    roadmap: roadmapStages,
    attention: role === 'consultant' ? consultantAttention : clientAttention,
    records: visibleRecords,
    workspaces: workspaceDefinitions.map((workspace, index) => ({
      ...workspace,
      metric: ['12', '28', '7', '5', '3', '4'][index],
      metricLabel: ['items needing attention', 'evidence-linked records', 'reviewed conclusions', 'active growth items', 'tracked outcomes', 'current signals'][index],
      href: role === 'consultant' ? `${baseHref}/${workspace.key}` : clientHref(workspace.key),
    })),
    currentNarrative: 'Northstar is moving decision authority closer to the work while making capability expectations and escalation boundaries explicit.',
    historicalNarratives: [
      {
        effectiveOn: 'June 1, 2026',
        narrative: 'Northstar relies on senior review to protect consistency while it examines how authority currently operates.',
      },
    ],
  };
}

function clientHref(workspace: string) {
  const mapping: Record<string, string> = {
    overview: '/client',
    discovery: '/client/our-organization',
    strategy: '/client/our-organization',
    development: '/client/my-development',
    outcomes: '/client/progress',
    signals: '/client/progress',
  };
  return mapping[workspace] ?? '/client';
}

export function fixtureRecord(role: Exclude<PortalRole, 'outsider'>, recordId: string) {
  return fixtureDashboard(role).records.find((record) => record.id === recordId) ?? null;
}
