import 'server-only';
import type { PortalSession } from '@/lib/portal/types';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { fixtureDiscoveryIntake, mutateFixtureDiscovery } from './fixtures';
import type { DiscoveryIntakeData, DiscoveryMutation } from './types';
import { dataAccessError } from '@/lib/http/errors';

export async function getDiscoveryIntake(session: PortalSession): Promise<DiscoveryIntakeData> {
  if (session.fixture) return fixtureDiscoveryIntake(session);
  const supabase = await createSupabaseServerClient();
  const { data: evidenceDomains, error: domainError } = await supabase.from('domain_objects').select('id').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).eq('object_type', 'EVIDENCE');
  if (domainError) throw dataAccessError(domainError, 'lib/discovery/repository.ts');
  const evidenceIds = (evidenceDomains ?? []).map((item) => item.id);
  const [evidence, interviews, assessments] = await Promise.all([
    evidenceIds.length ? supabase.from('evidence_items').select('id, relevance_note, created_at').eq('organization_id', session.organization.id).in('id', evidenceIds).order('created_at', { ascending: false }).limit(20) : Promise.resolve({ data: [], error: null }),
    supabase.from('interviews').select('id, participant_label, guide_name, created_at').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).order('created_at', { ascending: false }).limit(20),
    supabase.from('assessment_administrations').select('id, audience_description, confidentiality, created_at').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).order('created_at', { ascending: false }).limit(20),
  ]);
  for (const result of [evidence, interviews, assessments]) if (result.error) throw dataAccessError(result.error, 'lib/discovery/repository.ts');
  const recentItems = [
    ...(evidence.data ?? []).map((item) => ({ id: item.id, kind: 'EVIDENCE', title: item.relevance_note, detail: 'Traceable evidence item', createdAt: item.created_at })),
    ...(interviews.data ?? []).map((item) => ({ id: item.id, kind: 'INTERVIEW', title: item.participant_label, detail: item.guide_name, createdAt: item.created_at })),
    ...(assessments.data ?? []).map((item) => ({ id: item.id, kind: 'ASSESSMENT', title: 'Assessment administration', detail: `${item.audience_description} · ${item.confidentiality}`, createdAt: item.created_at })),
  ].sort((a, b) => String(b.createdAt).localeCompare(String(a.createdAt))).slice(0, 8).map((item) => ({ id: item.id, kind: item.kind, title: item.title, detail: item.detail }));
  return { organizationId: session.organization.id, engagementId: session.engagement.id, role: session.role as 'consultant' | 'client', evidenceCount: evidence.data?.length ?? 0, interviewCount: interviews.data?.length ?? 0, assessmentCount: assessments.data?.length ?? 0, recentItems };
}

export async function mutateDiscoveryIntake(session: PortalSession, mutation: DiscoveryMutation) {
  if (session.role !== 'consultant') throw new Error('Only an assigned consultant may record discovery material.');
  if (session.fixture) return mutateFixtureDiscovery(session, mutation);
  const supabase = await createSupabaseServerClient(); let error: { message: string } | null = null;
  if (mutation.action === 'CAPTURE_EVIDENCE') ({ error } = await supabase.rpc('capture_discovery_evidence', { p_organization_id: session.organization.id, p_engagement_id: session.engagement.id, p_source_type: mutation.sourceType, p_title: mutation.title, p_provenance_context: mutation.provenanceContext, p_content: mutation.content, p_relevance_note: mutation.relevanceNote, p_limitations: mutation.limitations || null }));
  if (mutation.action === 'RECORD_INTERVIEW') ({ error } = await supabase.rpc('record_discovery_interview', { p_organization_id: session.organization.id, p_engagement_id: session.engagement.id, p_participant_label: mutation.participantLabel, p_guide_name: mutation.guideName, p_question: mutation.question, p_response: mutation.response, p_consent_recorded: mutation.consentRecorded }));
  if (mutation.action === 'CREATE_ASSESSMENT') ({ error } = await supabase.rpc('create_discovery_assessment', { p_organization_id: session.organization.id, p_engagement_id: session.engagement.id, p_name: mutation.name, p_dimension: mutation.dimension, p_prompt: mutation.prompt, p_audience: mutation.audience, p_opens_at: mutation.opensAt, p_closes_at: mutation.closesAt, p_confidentiality: mutation.confidentiality }));
  if (error) throw dataAccessError(error, 'lib/discovery/repository.ts');
  return getDiscoveryIntake(session);
}
