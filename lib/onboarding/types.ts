export interface StartEngagementInput {
  organizationName: string;
  engagementName: string;
  startsOn: string;
  endsOn?: string;
}

export interface StartEngagementResult {
  organizationId: string;
  engagementId: string;
}
