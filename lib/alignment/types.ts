export type CapabilityLevel = 'NOT_DEMONSTRATED' | 'FOUNDATIONAL' | 'DEVELOPING' | 'RELIABLE' | 'TRANSFERABLE';

export interface RoleArchitectureView {
  id: string; name: string; purpose: string; responsibilities: string[]; authorities: string[];
  boundaries: string[]; interfaces: string[]; support: string; accountability: string;
  successMeasures: string; decisionLabel: string; status: string;
}

export interface WorkflowView {
  id: string; name: string; purpose: string; ownerRole: string;
  steps: Array<{ name: string; owner: string; decisionPoint?: boolean }>;
}

export interface CapabilityPathwayView {
  id: string; capabilityName: string; definition: string; requiredBy: string;
  requiredLevel: CapabilityLevel; currentLevel: CapabilityLevel; evidence: string[]; gap: string;
  developmentPlanId: string; capabilityId: string; developmentPlan: string;
  activities: Array<{ id: string; title: string; status: string }>;
  practices: string[]; resources: string[]; maturityEvidence: string[];
}

export interface AlignmentCapabilityData {
  organizationId: string; engagementId: string; role: 'consultant' | 'client'; fixture: boolean;
  roleArchitectures: RoleArchitectureView[]; workflows: WorkflowView[];
  initiatives: Array<{ id: string; name: string; owner: string; status: string; intendedCondition: string }>;
  capabilityPathways: CapabilityPathwayView[];
}

export type AlignmentMutation =
  | {
      action: 'ADD_PRACTICE'; pathwayId: string; practice: string; conditions: string;
      repetitionTarget: string; feedbackMethod: string;
    }
  | { action: 'UPDATE_ACTIVITY'; pathwayId: string; activityId: string; status: 'ACTIVE' | 'COMPLETED' };
