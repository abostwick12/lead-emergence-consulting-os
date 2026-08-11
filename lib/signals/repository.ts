import 'server-only';

import type { PortalSession } from '@/lib/portal/types';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { fixtureSignalsWorkspace, mutateFixtureSignals } from './fixtures';
import type { SignalKind, SignalsMutation, SignalsWorkspaceData } from './types';

export async function getSignalsWorkspace(session: PortalSession): Promise<SignalsWorkspaceData> {
  if (session.fixture) return fixtureSignalsWorkspace(session);
  const supabase = await createSupabaseServerClient();
  const organizationId = session.organization.id; const engagementId = session.engagement.id;
  const [signalResult, trendResult, assumptionResult, questionResult, baselineResult, evidenceRegistryResult] = await Promise.all([
    supabase.from('signals').select('id,statement,signal_type,detected_at,context,status,primary_evidence_id,domain_objects!inner(visibility_scope)').eq('organization_id', organizationId).eq('engagement_id', engagementId).order('detected_at', { ascending: false }),
    supabase.from('descriptive_trends').select('*').eq('organization_id', organizationId).eq('engagement_id', engagementId).order('created_at', { ascending: false }),
    supabase.from('current_assumptions_due').select('*').eq('organization_id', organizationId).eq('engagement_id', engagementId),
    supabase.from('emerging_questions').select('id,question,initial_review_state,source_signal_id,source_assumption_id').eq('organization_id', organizationId).eq('engagement_id', engagementId).eq('status', 'OPEN'),
    supabase.from('current_baselines').select('*').eq('organization_id', organizationId).or(`engagement_id.eq.${engagementId},next_engagement_id.eq.${engagementId}`).order('snapshot_at', { ascending: false }).limit(1),
    supabase.from('domain_objects').select('id').eq('organization_id', organizationId).eq('engagement_id', engagementId).eq('object_type', 'EVIDENCE'),
  ]);
  for (const result of [signalResult, trendResult, assumptionResult, questionResult, baselineResult, evidenceRegistryResult]) if (result.error) throw new Error(result.error.message);
  const evidenceIds = (evidenceRegistryResult.data ?? []).map((item) => item.id);
  const evidenceResult = evidenceIds.length ? await supabase.from('evidence_items').select('id,relevance_note').in('id', evidenceIds) : { data: [], error: null };
  if (evidenceResult.error) throw new Error(evidenceResult.error.message);
  const baseline = baselineResult.data?.[0];
  return {
    organizationId, engagementId, role: session.role as 'consultant' | 'client', fixture: false,
    signals: (signalResult.data ?? []).map((item) => ({
      id: item.id, statement: item.statement, kind: item.signal_type as SignalKind,
      detectedLabel: new Date(item.detected_at).toLocaleDateString(), context: item.context,
      sourceLabel: `Evidence · ${String(item.primary_evidence_id).slice(0, 8)}`,
      visibility: ((item.domain_objects as unknown as { visibility_scope: SignalItemVisibility }).visibility_scope), status: item.status,
    })),
    trends: (trendResult.data ?? []).map((item) => ({
      id: item.id, indicator: 'Compatible indicator', direction: item.direction,
      baseline: `Measurement · ${String(item.baseline_measurement_id).slice(0, 8)}`,
      current: `Measurement · ${String(item.current_measurement_id).slice(0, 8)}`,
      statement: item.statement, compatibility: item.comparison_basis, limitations: item.limitations,
    })),
    assumptions: (assumptionResult.data ?? []).map((item) => ({ id: item.id, statement: item.statement, dueLabel: item.due_state === 'DUE' ? 'Due now' : new Date(item.scheduled_for).toLocaleDateString(), trigger: item.trigger_context, status: item.due_state })),
    questions: (questionResult.data ?? []).map((item) => ({ id: item.id, question: item.question, sourceLabel: item.source_signal_id ? 'Signal' : 'Assumption', reviewState: item.initial_review_state })),
    baseline: baseline ? { id: baseline.id, label: baseline.source_profile_name, scope: baseline.scope, establishedLabel: new Date(baseline.snapshot_at).toLocaleDateString(), memberCount: Array.isArray(baseline.manifest) ? baseline.manifest.length : 0, immutable: true } : undefined,
    evidenceSources: (evidenceResult.data ?? []).map((item) => ({ id: item.id, label: item.relevance_note })),
    reentries: [],
  };
}

type SignalItemVisibility = 'ENGAGEMENT_SHARED' | 'ORGANIZATION_SHARED' | 'LEADERSHIP_RESTRICTED';

export async function mutateSignalsWorkspace(session: PortalSession, mutation: SignalsMutation) {
  if (session.fixture) return mutateFixtureSignals(session, mutation);
  if (session.role !== 'consultant') throw new Error('Assigned consultant authorization is required.');
  const supabase = await createSupabaseServerClient();
  let result;
  if (mutation.action === 'ADD_SIGNAL') result = await supabase.rpc('create_signal', {
    p_organization_id: session.organization.id, p_engagement_id: session.engagement.id,
    p_primary_evidence_id: mutation.evidenceId, p_statement: mutation.statement,
    p_signal_type: mutation.kind, p_context: mutation.context,
  });
  if (mutation.action === 'REENTER_SIGNAL') result = await supabase.rpc('reenter_signal_as_observation', {
    p_signal_id: mutation.signalId, p_observation_statement: mutation.observationStatement, p_context: mutation.context,
  });
  if (mutation.action === 'COMPLETE_ASSUMPTION_REVIEW') result = await supabase.rpc('complete_assumption_review', {
    p_schedule_id: mutation.scheduleId, p_review_note: mutation.reviewNote,
  });
  if (!result || result.error) throw new Error(result?.error?.message ?? 'The Signals action could not be completed.');
  return getSignalsWorkspace(session);
}
