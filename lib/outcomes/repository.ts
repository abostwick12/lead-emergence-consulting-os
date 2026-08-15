import 'server-only';

import type { PortalSession } from '@/lib/portal/types';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { fixtureOutcomesNewReality, mutateFixtureOutcomes } from './fixtures';
import type { OutcomesMutation, OutcomesNewRealityData } from './types';
import { dataAccessError } from '@/lib/http/errors';

export async function getOutcomesNewReality(session: PortalSession): Promise<OutcomesNewRealityData> {
  if (session.fixture) return fixtureOutcomesNewReality(session);
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.from('value_outcome_pathways').select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).limit(1).maybeSingle();
  if (error) throw dataAccessError(error, 'lib/outcomes/repository.ts');
  if (!data) throw new Error('No visible value pathway is available for this engagement.');
  const { data: evidenceDomains, error: evidenceDomainError } = await supabase.from('domain_objects').select('id').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).eq('object_type', 'EVIDENCE');
  if (evidenceDomainError) throw dataAccessError(evidenceDomainError, 'lib/outcomes/repository.ts');
  const evidenceIds = (evidenceDomains ?? []).map((item) => item.id);
  const [{ data: profiles, error: profileError }, { data: baselines, error: baselineError }, { data: evidence, error: evidenceError }] = await Promise.all([
    supabase.from('current_emergent_organization_profiles').select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).limit(1),
    supabase.from('current_baselines').select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).limit(1),
    evidenceIds.length ? supabase.from('evidence_items').select('id, relevance_note').eq('organization_id', session.organization.id).in('id', evidenceIds).limit(50) : Promise.resolve({ data: [], error: null }),
  ]);
  if (profileError) throw dataAccessError(profileError, 'lib/outcomes/repository.ts');
  if (baselineError) throw dataAccessError(baselineError, 'lib/outcomes/repository.ts');
  if (evidenceError) throw dataAccessError(evidenceError, 'lib/outcomes/repository.ts');
  const profile = profiles?.[0]; const baseline = baselines?.[0];
  return {
    organizationId: session.organization.id, engagementId: session.engagement.id, role: session.role as 'consultant' | 'client', fixture: false,
    goal: { id: data.goal_id, statement: data.goal_statement, baseline: String(data.baseline_value ?? 'Not set'), target: String(data.target_value ?? 'Not set'), owner: 'Authorized owner', status: 'ACTIVE' },
    valueHypothesis: { id: data.value_hypothesis_id, statement: `${data.change_condition} ${data.capability_condition} Expected value: ${data.expected_value}`, createdLabel: 'Established before outcome period', status: 'ACTIVE' },
    indicator: { id: data.indicator_id, name: data.indicator_name, baseline: String(data.baseline_value ?? 'Not set'), target: String(data.target_value ?? 'Not set'), history: data.measurement_id ? [{ value: String(data.measurement_value), period: data.measurement_period_start ? `From ${new Date(data.measurement_period_start).toLocaleDateString()}` : 'Recorded period' }] : [] },
    evidenceOptions: (evidence ?? []).map((item) => ({ id: item.id, label: item.relevance_note })),
    outcome: data.outcome_id ? { id: data.outcome_id, statement: data.outcome_statement, measuredValue: String(data.measurement_value ?? 'Recorded'), association: 'Evaluates the goal and prospective hypothesis', causalStatus: 'No automatic causal claim' } : undefined,
    evaluation: data.value_evaluation_id ? { id: data.value_evaluation_id, harvest: data.harvest_finding, soil: data.soil_finding, dimensions: [
      { name: 'Mission', rating: data.mission_rating, rationale: data.significance },
      { name: 'Human', rating: data.human_rating, rationale: data.significance },
      { name: 'Operational', rating: data.operational_rating, rationale: data.significance },
      { name: 'Economic', rating: data.economic_rating, rationale: data.significance },
      { name: 'Sustainable', rating: data.sustainable_rating, rationale: data.significance },
    ] } : undefined,
    learning: data.learning_id ? { statement: data.learning_statement, reviewState: data.learning_review_state ?? 'SUGGESTED', disposition: data.disposition } : undefined,
    futureState: { statement: 'Future State remains a separate versioned organizational design record.', version: 1 },
    emergentProfile: profile ? { id: profile.id, name: profile.name, actualState: profile.value_state, difference: 'Inspect the linked Emergent Reality Difference records.', status: profile.status } : undefined,
    baseline: baseline ? { id: baseline.id, label: `Baseline · ${new Date(baseline.snapshot_at).toLocaleDateString()}`, memberCount: Array.isArray(baseline.manifest) ? baseline.manifest.length : 0, immutable: true } : undefined,
  };
}

export async function mutateOutcomesNewReality(session: PortalSession, mutation: OutcomesMutation) {
  if (session.fixture) return mutateFixtureOutcomes(session, mutation);
  if (session.role !== 'consultant') throw new Error('Only the assigned consultant may advance this workflow.');
  const current = await getOutcomesNewReality(session);
  const supabase = await createSupabaseServerClient();
  let error: { message: string } | null = null;
  if (mutation.action === 'RECORD_OUTCOME') ({ error } = await supabase.rpc('record_value_outcome', { p_indicator_id: current.indicator.id, p_evidence_id: mutation.evidenceId, p_measured_value: mutation.measuredValue, p_statement: mutation.statement, p_collection_context: mutation.collectionContext, p_limitations: mutation.limitations, p_period_start: mutation.periodStart, p_period_end: mutation.periodEnd }));
  if (mutation.action === 'EVALUATE_VALUE') {
    if (!current.outcome) throw new Error('Record the observed outcome before evaluating value.');
    ({ error } = await supabase.rpc('record_value_evaluation', { p_outcome_id: current.outcome.id, p_harvest: mutation.harvest, p_soil: mutation.soil, p_significance: mutation.significance, p_alternative_explanations: mutation.alternativeExplanations, p_limitations: mutation.limitations }));
  }
  if (mutation.action === 'VALIDATE_LEARNING') {
    if (!current.evaluation) throw new Error('Complete the value evaluation before validating learning.');
    ({ error } = await supabase.rpc('validate_outcome_learning', { p_evaluation_id: current.evaluation.id, p_statement: mutation.statement, p_disposition: mutation.disposition, p_implications: mutation.implications, p_contrary_evidence: mutation.contraryEvidence, p_limitations: mutation.limitations }));
  }
  if (mutation.action === 'ESTABLISH_BASELINE') ({ error } = await supabase.rpc('establish_new_reality', { p_organization_id: session.organization.id, p_engagement_id: session.engagement.id, p_profile_name: mutation.profileName, p_actual_state: mutation.actualState, p_difference: mutation.difference }));
  if (error) throw dataAccessError(error, 'lib/outcomes/repository.ts');
  return getOutcomesNewReality(session);
}
