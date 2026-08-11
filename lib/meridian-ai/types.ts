export type MeridianTask = 'SUGGEST_PATTERN' | 'SUGGEST_INTERPRETATION' | 'MEETING_PREPARATION';
export type MeridianReviewState = 'SUGGESTED' | 'REJECTED';
export type MeridianSourceRole = 'SUPPORTING' | 'CHALLENGING' | 'CONTEXT';

export interface MeridianSource {
  id: string;
  fragmentId: string;
  title: string;
  locator: string;
  excerpt: string;
  role: MeridianSourceRole;
  visibility: 'LEADERSHIP_RESTRICTED' | 'ENGAGEMENT_SHARED' | 'ORGANIZATION_SHARED';
}

export interface MeridianSuggestion {
  id: string;
  task: Exclude<MeridianTask, 'MEETING_PREPARATION'>;
  title: string;
  statement: string;
  scope: string;
  recurrenceBasis: string;
  limitations: string;
  origin: 'AI';
  reviewState: MeridianReviewState;
  sources: MeridianSource[];
  generatedLabel: string;
  reviewRationale?: string;
}

export interface MeetingPreparationBrief {
  meetingId: string;
  purpose: string;
  summary: string;
  questions: string[];
  limitations: string;
  sources: MeridianSource[];
}

export interface MeridianAiData {
  organizationId: string;
  engagementId: string;
  fixture: boolean;
  suggestions: MeridianSuggestion[];
  rejectedSuggestions: MeridianSuggestion[];
  meetingPreparation: MeetingPreparationBrief;
  availableSourceCount: number;
  guardrails: string[];
}

export type MeridianMutation =
  | { action: 'GENERATE_PATTERN'; sourceIds: string[] }
  | { action: 'REJECT_SUGGESTION'; suggestionId: string; rationale: string };

export interface GroundedGenerationResult {
  status: 'COMPLETED' | 'INSUFFICIENT_EVIDENCE';
  suggestion?: MeridianSuggestion;
  limitation?: string;
}
