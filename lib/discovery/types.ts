export type EvidenceSourceType = 'UPLOADED_DOCUMENT' | 'METRIC_SYSTEM' | 'CONSULTANT_OBSERVATION' | 'CLIENT_STATEMENT' | 'OTHER';
export type AssessmentConfidentiality = 'IDENTIFIED' | 'CONFIDENTIAL' | 'ANONYMOUS';

export interface DiscoveryIntakeData {
  organizationId: string;
  engagementId: string;
  role: 'consultant' | 'client';
  evidenceCount: number;
  interviewCount: number;
  assessmentCount: number;
  recentItems: Array<{ id: string; kind: string; title: string; detail: string }>;
}

export type DiscoveryMutation =
  | { action: 'CAPTURE_EVIDENCE'; sourceType: EvidenceSourceType; title: string; provenanceContext: string; content: string; relevanceNote: string; limitations: string }
  | { action: 'RECORD_INTERVIEW'; participantLabel: string; guideName: string; question: string; response: string; consentRecorded: boolean }
  | { action: 'CREATE_ASSESSMENT'; name: string; dimension: string; prompt: string; audience: string; opensAt: string; closesAt: string; confidentiality: AssessmentConfidentiality };
