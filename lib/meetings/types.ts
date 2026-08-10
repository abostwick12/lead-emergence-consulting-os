export const meetingPhases = ['PREPARE', 'MEET', 'CAPTURE', 'DECIDE', 'COMMIT', 'FOLLOW_UP'] as const;
export type MeetingPhase = (typeof meetingPhases)[number];
export type MeetingType = 'CONSULTING' | 'COACHING';
export type MeetingStatus = 'PLANNED' | 'PREPARED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED' | 'ARCHIVED';
export type CommitmentStatus = 'OPEN' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';

export interface MeetingPerson {
  id: string;
  name: string;
  relationship: 'CONSULTANT' | 'CLIENT';
}

export interface MeetingNoteView {
  id: string;
  kind: 'AGENDA' | 'PREPARATION' | 'SHARED_NOTE' | 'FOLLOW_UP' | 'CONSULTANT_NOTE' | 'INDIVIDUAL_REFLECTION';
  content: string;
  authorName: string;
  createdLabel: string;
  privacy: 'SHARED' | 'PRIVATE';
}

export interface MeetingCommitmentView {
  id: string;
  ownerPersonId: string;
  ownerName: string;
  action: string;
  dueOn?: string;
  status: CommitmentStatus;
  sourceMeetingId: string;
}

export interface MeetingDecisionView {
  id: string;
  statement: string;
  rationale: string;
  intendedEffect: string;
  reviewTrigger: string;
  status: 'PROPOSED' | 'APPROVED' | 'ACTIVE' | 'RECONSIDER' | 'SUPERSEDED' | 'RETIRED';
  authorityName: string;
  decidedLabel: string;
}

export interface MeetingView {
  id: string;
  organizationId: string;
  engagementId: string;
  type: MeetingType;
  title: string;
  purpose: string;
  scheduledStart: string;
  scheduledEnd?: string;
  status: MeetingStatus;
  phase: MeetingPhase;
  agenda: string;
  sharedSummary?: string;
  followUp?: string;
  participants: MeetingPerson[];
  notes: MeetingNoteView[];
  decisions: MeetingDecisionView[];
  commitments: MeetingCommitmentView[];
  context: Array<{ id: string; label: string; state: string }>;
  coaching?: {
    relationshipId: string;
    participantName: string;
    coachName: string;
    developmentFocus: string;
    confidentialityStatement: string;
    sessionNumber: number;
  };
}

export interface MeetingCenterData {
  meetings: MeetingView[];
  people: MeetingPerson[];
  currentPersonId: string;
  role: 'consultant' | 'client';
}

export type MeetingMutation =
  | { action: 'CREATE_MEETING'; meetingType: MeetingType; title: string; purpose: string; scheduledStart: string; participantPersonId: string; developmentFocus?: string }
  | { action: 'UPDATE_MEETING'; meetingId: string; title: string; purpose: string; agenda: string; sharedSummary?: string; followUp?: string; phase: MeetingPhase }
  | { action: 'ADD_SHARED_NOTE'; meetingId: string; content: string }
  | { action: 'ADD_PRIVATE_NOTE'; meetingId: string; content: string; kind: 'CONSULTANT_NOTE' | 'INDIVIDUAL_REFLECTION' }
  | { action: 'ADD_DECISION'; meetingId: string; statement: string; rationale: string; intendedEffect: string; reviewTrigger: string }
  | { action: 'ADD_COMMITMENT'; meetingId: string; ownerPersonId: string; actionText: string; dueOn?: string }
  | { action: 'UPDATE_COMMITMENT'; meetingId: string; commitmentId: string; status: CommitmentStatus };
