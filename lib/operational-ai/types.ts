import type { Visibility } from '@/lib/portal/types';

export type OperationalSection = 'overview' | 'products' | 'audits' | 'interviews' | 'workflows' | 'evidence' | 'findings' | 'opportunities' | 'prototypes' | 'validation' | 'recommendations' | 'documents' | 'actions';
export type WorkStatus = 'NOT_STARTED' | 'IN_PROGRESS' | 'SUBMITTED' | 'REVIEWED' | 'COMPLETE';
export type GuidedRecordKind = 'PRODUCT' | 'AUDIT' | 'INTERVIEW';

export interface GuidedResponse {
  questionId: string;
  answer: string;
  updatedAt: string;
}

export interface EngagementProduct { id: string; name: string; description: string; ownerLabel: string; status: 'ACTIVE' | 'ON_HOLD' | 'COMPLETE'; handlingLabel: string; responses: GuidedResponse[] }
export interface AuditAssignment { id: string; productId: string; title: string; respondentLabel: string; dueOn: string; status: WorkStatus; completedResponses: number; totalPrompts: number; responses: GuidedResponse[] }
export interface InterviewPlan { id: string; productId: string; participantLabel: string; interviewType: string; objective: string; scheduledFor: string; status: 'PLANNED' | 'IN_PROGRESS' | 'COMPLETED'; notesCount: number; responses: GuidedResponse[] }
export interface WorkflowStepAnalysis { id: string; sequence: number; name: string; ownerLabel: string; systemTool: string; inputs: string; outputs: string; durationMinutes: number; waitMinutes: number; reworkRisk: 'LOW' | 'MEDIUM' | 'HIGH'; judgmentRequired: string; verificationRequired: string; aiSuitability: 'NOT_ASSESSED' | 'ASSISTIVE_CANDIDATE' | 'HUMAN_ONLY' }
export interface WorkflowMap { id: string; productId: string; name: string; purpose: string; status: 'DRAFT' | 'IN_REVIEW' | 'APPROVED'; steps: WorkflowStepAnalysis[] }
export interface EvidenceItem { id: string; productId?: string; title: string; sourceType: 'DOCUMENT' | 'INTERVIEW' | 'AUDIT' | 'WORKFLOW' | 'OBSERVATION'; observation: string; sourceLocator: string; visibility: Visibility; status: 'CAPTURED' | 'READY_FOR_REVIEW' | 'REVIEWED' }
export interface ArtifactRequest { id: string; productId?: string; title: string; requestedFrom: string; requestedOn: string; dueOn: string; status: 'REQUESTED' | 'RECEIVED' | 'DECLINED' | 'NOT_AVAILABLE'; handlingNote: string }
export interface EngagementAction { id: string; title: string; ownerLabel: string; dueOn: string; status: 'OPEN' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED'; visibility: Visibility }

export interface OperationalEngagementData {
  organizationId: string; engagementId: string; organizationName: string; engagementName: string;
  engagementType: 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION'; objective: string; scopeStatement: string; ownerLabel: string;
  handlingLabel: 'Internal — Sanitized Only'; handlingNotice: string; currentStage: 'SEE REALITY'; targetCompletion: string;
  products: EngagementProduct[]; audits: AuditAssignment[]; interviews: InterviewPlan[]; workflows: WorkflowMap[];
  evidence: EvidenceItem[]; requests: ArtifactRequest[]; actions: EngagementAction[];
}

export const operationalSections: Array<{ key: OperationalSection; label: string; phase: 'P0' | 'P1' | 'P2' }> = [
  { key: 'overview', label: 'Overview', phase: 'P0' }, { key: 'products', label: 'Products', phase: 'P0' },
  { key: 'audits', label: 'Audits', phase: 'P0' }, { key: 'interviews', label: 'Interviews', phase: 'P0' },
  { key: 'workflows', label: 'Workflows', phase: 'P0' }, { key: 'evidence', label: 'Evidence', phase: 'P0' },
  { key: 'findings', label: 'Findings', phase: 'P1' }, { key: 'opportunities', label: 'Opportunities', phase: 'P1' },
  { key: 'prototypes', label: 'Prototypes', phase: 'P2' }, { key: 'validation', label: 'Validation', phase: 'P2' },
  { key: 'recommendations', label: 'Recommendations', phase: 'P2' }, { key: 'documents', label: 'Documents', phase: 'P0' },
  { key: 'actions', label: 'Actions', phase: 'P0' },
];

export function isOperationalSection(value: string): value is OperationalSection { return operationalSections.some((section) => section.key === value) }
