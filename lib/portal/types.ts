export type PortalRole = 'consultant' | 'client' | 'outsider';
export type WorkspaceKey =
  | 'overview'
  | 'discovery'
  | 'strategy'
  | 'development'
  | 'outcomes'
  | 'signals'
  | 'handoff';

export type ReviewState =
  | 'AI SUGGESTION'
  | 'INTERPRETATION'
  | 'VALIDATED INSIGHT'
  | 'VALIDATED DIAGNOSIS'
  | 'DECISION';

export type Visibility =
  | 'CONSULTANT_PRIVATE'
  | 'INDIVIDUAL_PRIVATE'
  | 'COACHING_SHARED'
  | 'LEADERSHIP_RESTRICTED'
  | 'ENGAGEMENT_SHARED'
  | 'ORGANIZATION_SHARED';

export interface OrganizationOption {
  id: string;
  name: string;
  slug: string;
}

export interface EngagementOption {
  id: string;
  organizationId: string;
  name: string;
  status: string;
  startsOn?: string;
  endsOn?: string;
}

export interface PortalSession {
  personId: string;
  displayName: string;
  role: PortalRole;
  organizations: OrganizationOption[];
  organization: OrganizationOption;
  engagements: EngagementOption[];
  engagement: EngagementOption;
  fixture: boolean;
}

export interface RoadmapStage {
  number: number;
  name: string;
  shortName: string;
  status: 'COMPLETE' | 'CURRENT' | 'UPCOMING';
  description: string;
}

export interface AttentionItem {
  id: string;
  title: string;
  description: string;
  kind: 'REVIEW' | 'COMMITMENT' | 'MEETING' | 'ASSESSMENT';
  dueLabel: string;
  href: string;
}

export interface PortalRecord {
  id: string;
  organizationId: string;
  engagementId: string;
  objectType: string;
  title: string;
  statement: string;
  rationale: string;
  state: ReviewState;
  origin: 'HUMAN' | 'AI';
  visibility: Visibility;
  sourceLabels: string[];
  history: Array<{ date: string; action: string; actor: string }>;
  updatedLabel: string;
}

export interface WorkspaceSummary {
  key: WorkspaceKey;
  label: string;
  description: string;
  metric: string;
  metricLabel: string;
  href: string;
}

export interface PortalDashboard {
  organization: OrganizationOption;
  engagement: EngagementOption;
  roadmap: RoadmapStage[];
  attention: AttentionItem[];
  records: PortalRecord[];
  workspaces: WorkspaceSummary[];
  currentNarrative: string;
  historicalNarratives: Array<{ effectiveOn: string; narrative: string }>;
}

export const roadmapStages: RoadmapStage[] = [
  {
    number: 1,
    name: 'SEE REALITY',
    shortName: 'See',
    status: 'COMPLETE',
    description: 'Observe the organization as it is, with evidence and multiple perspectives.',
  },
  {
    number: 2,
    name: 'REFRAME REALITY',
    shortName: 'Reframe',
    status: 'CURRENT',
    description: 'Test assumptions and develop a grounded account of what the evidence means.',
  },
  {
    number: 3,
    name: 'ALIGN WITH REALITY',
    shortName: 'Align',
    status: 'UPCOMING',
    description: 'Translate validated insight into decisions, roles, boundaries, and workflows.',
  },
  {
    number: 4,
    name: 'BUILD CAPABILITY',
    shortName: 'Build',
    status: 'UPCOMING',
    description: 'Develop the capabilities required to make the intended design real.',
  },
  {
    number: 5,
    name: 'PRODUCE VALUE',
    shortName: 'Value',
    status: 'UPCOMING',
    description: 'Connect goals, indicators, outcomes, evaluation, and learning.',
  },
  {
    number: 6,
    name: 'NEW REALITY',
    shortName: 'New reality',
    status: 'UPCOMING',
    description: 'Record what actually emerged without rewriting the intended future.',
  },
  {
    number: 7,
    name: 'SEE AGAIN',
    shortName: 'See again',
    status: 'UPCOMING',
    description: 'Use the new baseline to renew inquiry and notice meaningful change.',
  },
];

export const workspaceDefinitions: Array<Pick<WorkspaceSummary, 'key' | 'label' | 'description'>> = [
  { key: 'overview', label: 'Overview', description: 'Engagement status and what needs attention.' },
  { key: 'discovery', label: 'Discovery', description: 'Evidence, observations, patterns, and assumptions.' },
  { key: 'strategy', label: 'Strategy', description: 'Interpretations, insights, future state, and decisions.' },
  { key: 'development', label: 'Development', description: 'Capabilities, growth plans, and commitments.' },
  { key: 'outcomes', label: 'Outcomes', description: 'Goals, indicators, outcomes, evaluation, and learning.' },
  { key: 'signals', label: 'Signals', description: 'Current observations and later-stage longitudinal signals.' },
  { key: 'handoff', label: 'Ministry Handoff', description: 'Client access, assessment participation, and consultant-guided Ministry OS setup.' },
];
