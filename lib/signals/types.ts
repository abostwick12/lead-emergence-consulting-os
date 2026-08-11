export type SignalKind = 'REPORTED_CHANGE' | 'MEASURED_CHANGE' | 'OPERATING_CHANGE' | 'RELATIONSHIP_CHANGE' | 'CONTEXT_CHANGE';
export type TrendDirection = 'INCREASED' | 'DECREASED' | 'STABLE' | 'MIXED';

export interface SignalItem {
  id: string;
  statement: string;
  kind: SignalKind;
  detectedLabel: string;
  context: string;
  sourceLabel: string;
  visibility: 'ENGAGEMENT_SHARED' | 'ORGANIZATION_SHARED' | 'LEADERSHIP_RESTRICTED';
  status: 'NEW' | 'REVIEWED' | 'REENTERED';
}

export interface SignalsWorkspaceData {
  organizationId: string;
  engagementId: string;
  role: 'consultant' | 'client';
  fixture: boolean;
  signals: SignalItem[];
  trends: Array<{
    id: string;
    indicator: string;
    direction: TrendDirection;
    baseline: string;
    current: string;
    statement: string;
    compatibility: string;
    limitations: string;
  }>;
  assumptions: Array<{
    id: string;
    statement: string;
    dueLabel: string;
    trigger: string;
    status: 'DUE' | 'UPCOMING' | 'COMPLETED';
  }>;
  questions: Array<{ id: string; question: string; sourceLabel: string; reviewState: 'DRAFT' | 'SUGGESTED' | 'ACCEPTED' }>;
  baseline?: { id: string; label: string; scope: string; establishedLabel: string; memberCount: number; immutable: true };
  evidenceSources: Array<{ id: string; label: string }>;
  reentries: Array<{ signalId: string; observationId: string; statement: string; relationship: 'REENTERS_AS' }>;
}

export type SignalsMutation =
  | { action: 'ADD_SIGNAL'; statement: string; kind: SignalKind; context: string; evidenceId: string }
  | { action: 'REENTER_SIGNAL'; signalId: string; observationStatement: string; context: string }
  | { action: 'COMPLETE_ASSUMPTION_REVIEW'; scheduleId: string; reviewNote: string };
