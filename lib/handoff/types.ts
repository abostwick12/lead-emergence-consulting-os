export type MinistryReadiness = 'NOT_ASSESSED' | 'FOUNDATIONAL' | 'PREPARING' | 'READY' | 'OPERATING';
export type MinistryHandoffStatus = 'DRAFT' | 'READY_FOR_REVIEW' | 'READY_FOR_SETUP' | 'COMPLETED';
export interface HandoffChecklistItem { key: string; label: string; complete: boolean; ordinal: number }
export interface MinistryHandoffData { organizationId: string; engagementId: string; churchName: string; authorizedAdminName: string; authorizedAdminEmail: string; ministryAreasAndLeaders: string; priorities: string; meetingAndPlanningRhythm: string; eventsAndWorkflows: string; readiness: MinistryReadiness; status: MinistryHandoffStatus; ministryProductUrl: string; boundaryNote: string; checklist: HandoffChecklistItem[] }
export type SaveMinistryHandoffInput = Omit<MinistryHandoffData, 'organizationId' | 'engagementId' | 'ministryProductUrl' | 'boundaryNote'>;
