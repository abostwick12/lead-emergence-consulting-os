import 'server-only';

import type { PortalSession } from '@/lib/portal/types';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { fixtureAlignmentCapability, mutateFixtureAlignment } from './fixtures';
import type { AlignmentCapabilityData, AlignmentMutation, CapabilityLevel } from './types';

export async function getAlignmentCapability(session: PortalSession): Promise<AlignmentCapabilityData> {
  if (session.fixture) return fixtureAlignmentCapability(session);
  const supabase = await createSupabaseServerClient();
  const pathwayView = session.role === 'client' ? 'my_capability_pathways' : 'capability_pathways';
  const [rolesResult, workflowsResult, initiativesResult, pathwaysResult] = await Promise.all([
    supabase.from('role_architecture').select('*').eq('organization_id', session.organization.id),
    supabase.from('current_workflow_versions').select('*').eq('organization_id', session.organization.id),
    supabase.from('reinvention_initiatives').select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id),
    supabase.from(pathwayView).select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id),
  ]);
  for (const result of [rolesResult, workflowsResult, initiativesResult, pathwaysResult]) if (result.error) throw new Error(result.error.message);

  const workflowIds = (workflowsResult.data ?? []).map((row) => row.id);
  const planIds = (pathwaysResult.data ?? []).map((row) => row.development_plan_id).filter(Boolean);
  const [stepsResult, activitiesResult, practicesResult, resourcesResult, maturityResult] = await Promise.all([
    workflowIds.length ? supabase.from('workflow_steps').select('*').eq('organization_id', session.organization.id).in('workflow_version_id', workflowIds).order('sequence_number') : Promise.resolve({ data: [], error: null }),
    planIds.length ? supabase.from('development_activities').select('*').eq('organization_id', session.organization.id).in('development_plan_id', planIds) : Promise.resolve({ data: [], error: null }),
    planIds.length ? supabase.from('practices').select('*').eq('organization_id', session.organization.id).in('development_plan_id', planIds) : Promise.resolve({ data: [], error: null }),
    planIds.length ? supabase.from('resources').select('*').eq('organization_id', session.organization.id).in('development_plan_id', planIds) : Promise.resolve({ data: [], error: null }),
    supabase.from('capability_maturity_assessments').select('*').eq('organization_id', session.organization.id).eq('engagement_id', session.engagement.id).order('assessed_at', { ascending: false }),
  ]);
  for (const result of [stepsResult, activitiesResult, practicesResult, resourcesResult, maturityResult]) if (result.error) throw new Error(result.error.message);

  const roleNames = new Map((rolesResult.data ?? []).map((row) => [row.id, row.name]));
  return {
    organizationId: session.organization.id, engagementId: session.engagement.id,
    role: session.role as 'consultant' | 'client', fixture: false,
    roleArchitectures: (rolesResult.data ?? []).map((row) => ({
      id: row.id, name: row.name, purpose: row.purpose,
      responsibilities: valuesFromJson(row.responsibilities, 'statement'), authorities: valuesFromJson(row.authorities, 'domain'),
      boundaries: valuesFromJson(row.boundaries, 'inside'), interfaces: valuesFromJson(row.interfaces, 'purpose'),
      support: row.support, accountability: row.accountability, successMeasures: row.success_measures,
      decisionLabel: 'Trace through the linked CREATES relationship', status: row.status,
    })),
    workflows: (workflowsResult.data ?? []).map((row) => ({
      id: row.id, name: row.name, purpose: row.purpose, ownerRole: roleNames.get(row.owner_role_id) ?? 'Assigned role',
      steps: (stepsResult.data ?? []).filter((step) => step.workflow_version_id === row.id).map((step) => ({ name: step.name, owner: roleNames.get(step.owner_role_id) ?? 'Assigned role', decisionPoint: step.decision_point })),
    })),
    initiatives: (initiativesResult.data ?? []).map((row) => ({ id: row.id, name: row.name, owner: 'Authorized owner', status: row.status, intendedCondition: row.intended_condition })),
    capabilityPathways: (pathwaysResult.data ?? []).map((row) => ({
      id: row.requirement_id, capabilityName: row.capability_name, definition: 'Reliable performance under named conditions, not training completion.',
      requiredBy: `${row.source_type.replaceAll('_', ' ')} · ${row.source_domain_object_id}`,
      requiredLevel: row.required_level as CapabilityLevel, currentLevel: (row.current_level ?? 'NOT_DEMONSTRATED') as CapabilityLevel,
      evidence: row.evidence_summary ? [row.evidence_summary] : [], gap: row.gap_statement ?? 'Assessment required before a gap is stated.',
      developmentPlan: row.development_plan_title ?? 'No development plan yet.',
      activities: (activitiesResult.data ?? []).filter((item) => item.development_plan_id === row.development_plan_id).map((item) => ({ id: item.id, title: item.title, status: item.status })),
      practices: (practicesResult.data ?? []).filter((item) => item.development_plan_id === row.development_plan_id).map((item) => item.name),
      resources: (resourcesResult.data ?? []).filter((item) => item.development_plan_id === row.development_plan_id).map((item) => item.title),
      maturityEvidence: (maturityResult.data ?? []).filter((item) => item.capability_id === row.capability_id && item.subject_domain_object_id === row.target_subject_id).map((item) => item.evidence_summary),
    })),
  };
}

export async function mutateAlignmentCapability(session: PortalSession, mutation: AlignmentMutation) {
  if (session.fixture) return mutateFixtureAlignment(session, mutation);
  const current = await getAlignmentCapability(session);
  const pathway = current.capabilityPathways.find((item) => item.id === mutation.pathwayId);
  if (!pathway) throw new Error('Capability pathway is not available in your current access context.');
  const supabase = await createSupabaseServerClient();
  if (mutation.action === 'UPDATE_ACTIVITY') {
    if (!pathway.activities.some((item) => item.id === mutation.activityId)) throw new Error('Development activity is not available.');
    const { error } = await supabase.from('development_activities').update({ status: mutation.status, completed_at: mutation.status === 'COMPLETED' ? new Date().toISOString() : null }).eq('id', mutation.activityId).eq('organization_id', session.organization.id);
    if (error) throw new Error(error.message);
  } else {
    throw new Error('New practice records require an authorized development-plan workflow.');
  }
  return getAlignmentCapability(session);
}

function valuesFromJson(value: unknown, key: string) {
  if (!Array.isArray(value)) return [];
  return value.map((item) => typeof item === 'object' && item && typeof (item as Record<string, unknown>)[key] === 'string' ? String((item as Record<string, unknown>)[key]) : '').filter(Boolean);
}
