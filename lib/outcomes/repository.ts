import 'server-only';

import type { PortalSession } from '@/lib/portal/types';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { fixtureOutcomesNewReality, mutateFixtureOutcomes } from './fixtures';
import type { OutcomesMutation, OutcomesNewRealityData } from './types';

export async function getOutcomesNewReality(session: PortalSession): Promise<OutcomesNewRealityData> {
  if (session.fixture) return fixtureOutcomesNewReality(session);
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.from('value_outcome_pathways').select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).limit(1).maybeSingle();
  if (error) throw new Error(error.message);
  if (!data) throw new Error('No visible value pathway is available for this engagement.');
  const [{ data: profiles, error: profileError }, { data: baselines, error: baselineError }] = await Promise.all([
    supabase.from('current_emergent_organization_profiles').select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).limit(1),
    supabase.from('current_baselines').select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).limit(1),
  ]);
  if (profileError) throw new Error(profileError.message);
  if (baselineError) throw new Error(baselineError.message);
  const profile = profiles?.[0]; const baseline = baselines?.[0];
  return {
    organizationId: session.organization.id, engagementId: session.engagement.id, role: session.role as 'consultant' | 'client', fixture: false,
    goal: { id: data.goal_id, statement: data.goal_statement, baseline: String(data.baseline_value ?? 'Not set'), target: String(data.target_value ?? 'Not set'), owner: 'Authorized owner', status: 'ACTIVE' },
    valueHypothesis: { id: data.value_hypothesis_id, statement: `${data.change_condition} ${data.capability_condition} Expected value: ${data.expected_value}`, createdLabel: 'Established before outcome period', status: 'ACTIVE' },
    indicator: { id: data.indicator_id, name: data.indicator_name, baseline: String(data.baseline_value ?? 'Not set'), target: String(data.target_value ?? 'Not set'), history: data.measurement_id ? [{ value: String(data.measurement_value), period: data.measurement_period_start ? `From ${new Date(data.measurement_period_start).toLocaleDateString()}` : 'Recorded period' }] : [] },
    outcome: data.outcome_id ? { id: data.outcome_id, statement: data.outcome_statement, measuredValue: String(data.measurement_value ?? 'Recorded'), association: 'Evaluates the goal and prospective hypothesis', causalStatus: 'No automatic causal claim' } : undefined,
    evaluation: data.value_evaluation_id ? { harvest: data.harvest_finding, soil: data.soil_finding, dimensions: [
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
  throw new Error('Live outcome mutations require the authorized Phase 7 command workflow.');
}
