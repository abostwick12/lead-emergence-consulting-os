export interface StartEngagementInput {
  organizationName: string;
  engagementName: string;
  startsOn: string;
  endsOn?: string;
  engagementType: 'ORGANIZATIONAL_TRANSFORMATION' | 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION';
  objective?: string;
  scopeStatement?: string;
}

export interface StartEngagementResult {
  organizationId: string;
  engagementId: string;
}
