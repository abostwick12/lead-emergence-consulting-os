export const consultingIntakeQuestions = [
  { key: 'context', prompt: 'What kind of organization or leadership context are you working in right now?' },
  { key: 'challenge', prompt: 'What leadership challenge is asking for attention?' },
  { key: 'friction', prompt: 'Where are people, systems, or decisions creating the most friction?' },
  { key: 'outcome', prompt: 'What would meaningfully improve in the next 90 days?' },
  { key: 'attempts', prompt: 'What have you already tried?' },
  { key: 'authority', prompt: 'Who needs to participate in or authorize meaningful change?' },
] as const;

export type ProspectStatus = 'NEW' | 'AI_DRAFT_READY' | 'IN_REVIEW' | 'NEEDS_FOLLOW_UP' | 'APPROVED' | 'SENT' | 'CONTACTED' | 'CONVERTED' | 'CLOSED';
export type FollowUpStatus = 'NOT_CONTACTED' | 'FOLLOW_UP_DUE' | 'CONTACTED' | 'AWAITING_RESPONSE' | 'MEETING_SCHEDULED' | 'TRIAL_STARTED' | 'CONVERTED' | 'NOT_NOW' | 'CLOSED';
export type DeliveryStatus = 'PREVIEW_READY' | 'READY_TO_SEND' | 'SENT' | 'FAILED' | 'NOT_SENT';

export interface IntakeResponse { questionKey: string; prompt: string; answer: string; }
export interface ProspectRevision { id: string; number: number; origin: 'AI' | 'CONSULTANT'; signals: string[]; possibilities: string[]; firstMove: string; limitations: string; createdAt: string; }
export interface ProspectEvent { id: string; occurredAt: string; type: string; detail: string; }
export interface ProspectItem {
  id: string; firstName: string; email: string; organizationName?: string; roleTitle?: string;
  status: ProspectStatus; assignedConsultant?: string; nextFollowUpAt?: string; followUpStatus: FollowUpStatus;
  responses: IntakeResponse[]; revisions: ProspectRevision[]; approvedRevisionId?: string; deliveryStatus: DeliveryStatus;
  privateNotes: string[]; events: ProspectEvent[]; conversionStatus: 'NOT_CONVERTED' | 'PENDING' | 'CONVERTED' | 'CANCELLED';
}

export interface ProspectCenterData { prospects: ProspectItem[]; }
export type ProspectMutation =
  | { action: 'SAVE_REVISION'; prospectId: string; signals: string[]; possibilities: string[]; firstMove: string }
  | { action: 'APPROVE'; prospectId: string; revisionId: string }
  | { action: 'PREPARE_DELIVERY'; prospectId: string }
  | { action: 'MARK_SENT'; prospectId: string }
  | { action: 'ADD_NOTE'; prospectId: string; note: string }
  | { action: 'CREATE_FOLLOW_UP'; prospectId: string; dueAt: string; followUpStatus: FollowUpStatus; note: string }
  | { action: 'CONVERT'; prospectId: string; organizationName: string; engagementName: string };