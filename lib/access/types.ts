export type ClientPlatformRole = 'CLIENT_ADMIN' | 'CLIENT_LEADER' | 'CLIENT_MEMBER';
export type AssessmentConfidentiality = 'IDENTIFIED' | 'CONFIDENTIAL' | 'ANONYMOUS';
export interface AccessCenterData { organizationId: string; engagementId: string; invitations: Array<{ id: string; email: string; displayName: string; role: ClientPlatformRole; status: string; expiresAt: string }>; assessments: Array<{ id: string; name: string; audience: string; confidentiality: AssessmentConfidentiality; status: string; closesAt: string }>; }
export type AccessMutation = { action: 'INVITE_CLIENT'; email: string; displayName: string; role: ClientPlatformRole } | { action: 'CREATE_ASSESSMENT_LINK'; administrationId: string; recipientName?: string; recipientEmail?: string };
export interface AccessMutationResult extends AccessCenterData { participantUrl?: string }
