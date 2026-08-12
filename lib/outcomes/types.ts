export type OutcomeDisposition = 'SUSTAIN' | 'IMPROVE' | 'SCALE' | 'STOP' | 'REINVENT';

export interface OutcomesNewRealityData {
  organizationId: string;
  engagementId: string;
  role: 'consultant' | 'client';
  fixture: boolean;
  goal: { id: string; statement: string; baseline: string; target: string; owner: string; status: string };
  valueHypothesis: { id: string; statement: string; createdLabel: string; status: string };
  indicator: { id: string; name: string; baseline: string; target: string; history: Array<{ value: string; period: string }> };
  evidenceOptions: Array<{ id: string; label: string }>;
  outcome?: { id: string; statement: string; measuredValue: string; association: string; causalStatus: string };
  evaluation?: { id: string; harvest: string; soil: string; dimensions: Array<{ name: string; rating: string; rationale: string }> };
  learning?: { statement: string; reviewState: string; disposition?: OutcomeDisposition };
  futureState: { statement: string; version: number };
  emergentProfile?: { id: string; name: string; actualState: string; difference: string; status: string };
  baseline?: { id: string; label: string; memberCount: number; immutable: boolean };
}

export type OutcomesMutation =
  | { action: 'RECORD_OUTCOME'; measuredValue: string; statement: string; evidenceId: string; collectionContext: string; limitations: string; periodStart: string; periodEnd: string }
  | { action: 'EVALUATE_VALUE'; harvest: string; soil: string; significance: string; alternativeExplanations: string; limitations: string }
  | { action: 'VALIDATE_LEARNING'; statement: string; disposition: OutcomeDisposition; implications: string; contraryEvidence: string; limitations: string }
  | { action: 'ESTABLISH_BASELINE'; profileName: string; actualState: string; difference: string };
