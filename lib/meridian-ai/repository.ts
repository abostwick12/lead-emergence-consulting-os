import 'server-only';

import type { PortalSession } from '@/lib/portal/types';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { fixtureMeridianAi, mutateFixtureMeridianAi } from './fixtures';
import type { MeridianAiData, MeridianMutation, MeridianSource } from './types';
import { dataAccessError } from '@/lib/http/errors';

export async function getMeridianAi(session: PortalSession): Promise<MeridianAiData> {
  if (session.role !== 'consultant') throw new Error('Grounded Meridian review is available only in the assigned consultant context.');
  if (session.fixture) return fixtureMeridianAi(session);
  const supabase = await createSupabaseServerClient();
  const [runsResult, outputsResult] = await Promise.all([
    supabase.from('ai_generation_runs').select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).order('created_at', { ascending: false }),
    supabase.from('ai_output_review').select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).order('created_at', { ascending: false }),
  ]);
  if (runsResult.error) throw dataAccessError(runsResult.error, 'lib/meridian-ai/repository.ts');
  if (outputsResult.error) throw dataAccessError(outputsResult.error, 'lib/meridian-ai/repository.ts');
  const outputRows = outputsResult.data ?? [];
  const mapSuggestion = (row: Record<string, unknown>) => ({
    id: String(row.id), task: 'SUGGEST_PATTERN' as const, title: String(row.title), statement: String(row.statement),
    scope: String(row.scope), recurrenceBasis: String(row.recurrence_basis), limitations: String(row.limitations),
    origin: 'AI' as const, reviewState: row.current_review_state === 'REJECTED' ? 'REJECTED' as const : 'SUGGESTED' as const,
    sources: normalizeSources(row.sources), generatedLabel: new Date(String(row.created_at)).toLocaleDateString(),
    reviewRationale: row.review_rationale ? String(row.review_rationale) : undefined,
  });
  const suggestions = outputRows.map(mapSuggestion);
  return {
    organizationId: session.organization.id, engagementId: session.engagement.id, fixture: false,
    suggestions: suggestions.filter((item) => item.reviewState === 'SUGGESTED'),
    rejectedSuggestions: suggestions.filter((item) => item.reviewState === 'REJECTED'),
    meetingPreparation: {
      meetingId: 'current', purpose: 'Permission-aware meeting preparation',
      summary: 'No persisted meeting preparation brief is available yet.', questions: [],
      limitations: 'Generate preparation only after the meeting context source set has been explicitly selected.', sources: [],
    },
    availableSourceCount: (runsResult.data ?? []).reduce((count, row) => count + Number(row.source_count ?? 0), 0),
    guardrails: ['Permission filtering occurs before relevance ranking.', 'Every claim cites an exact source fragment.', 'Suggestions remain SUGGESTED until a human review.', 'Meridian cannot validate an Insight or Diagnosis or make a Decision.'],
  };
}

export async function mutateMeridianAi(session: PortalSession, mutation: MeridianMutation) {
  if (session.role !== 'consultant') throw new Error('Only an assigned consultant may request or review Meridian assistance.');
  if (session.fixture) return mutateFixtureMeridianAi(session, mutation);
  const supabase = await createSupabaseServerClient();
  if (mutation.action === 'GENERATE_PATTERN') {
    const { error } = await supabase.rpc('request_ai_pattern_suggestion', {
      p_organization_id: session.organization.id, p_engagement_id: session.engagement.id,
      p_purpose: 'Contextual Discovery pattern review',
      p_supporting_source_ids: mutation.sourceIds.slice(0, -1),
      p_challenging_source_ids: mutation.sourceIds.slice(-1),
      p_statement: 'Routine decisions appear to move upward when boundary language is ambiguous.',
      p_scope: 'Active engagement', p_recurrence_basis: 'Recurring across selected permission-eligible sources.',
      p_contrary_evidence_summary: 'Contrary sources remain visible in the source set.',
      p_limitations: 'Reviewable suggestion only; not a diagnosis.',
    });
    if (error) throw dataAccessError(error, 'lib/meridian-ai/repository.ts');
  } else {
    const { error } = await supabase.rpc('reject_ai_suggestion', { p_output_id: mutation.suggestionId, p_rationale: mutation.rationale });
    if (error) throw dataAccessError(error, 'lib/meridian-ai/repository.ts');
  }
  return getMeridianAi(session);
}

function normalizeSources(value: unknown): MeridianSource[] {
  if (!Array.isArray(value)) return [];
  return value.filter((item): item is Record<string, unknown> => Boolean(item && typeof item === 'object')).map((item) => ({
    id: String(item.id), fragmentId: String(item.fragmentId), title: String(item.title), locator: String(item.locator), excerpt: String(item.excerpt),
    role: String(item.role) as MeridianSource['role'], visibility: String(item.visibility) as MeridianSource['visibility'],
  }));
}
