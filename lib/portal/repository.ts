import 'server-only';

import { cache } from 'react';
import { FIXTURE_ORGANIZATION_ID, fixtureDashboard, fixtureRecord } from './fixtures';
import {
  roadmapStages,
  workspaceDefinitions,
  type PortalDashboard,
  type PortalRecord,
  type PortalSession,
  type ReviewState,
  type Visibility,
} from './types';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { assertSucceeded, unwrap } from '@/lib/supabase/errors';

export const getPortalDashboard = cache(async (session: PortalSession): Promise<PortalDashboard> => {
  if (session.fixture) {
    const dashboard = fixtureDashboard(session.role === 'consultant' ? 'consultant' : 'client');
    if (session.organization.id === FIXTURE_ORGANIZATION_ID) return dashboard;
    return {
      ...dashboard,
      organization: session.organization,
      engagement: session.engagement,
      attention: [],
      records: [],
      workspaces: workspaceDefinitions.map((workspace) => ({ ...workspace, metric: '0', metricLabel: 'available records', href: `/consultant/clients/${session.organization.id}/${workspace.key}` })),
      currentNarrative: 'Discovery has not yet established a validated current organizational narrative.',
      historicalNarratives: [],
    };
  }
  const supabase = await createSupabaseServerClient();
  const records: PortalRecord[] = [];

  if (session.role === 'client') {
    const conclusions = unwrap('portal.dashboard.clientConclusions', await supabase
      .from('client_visible_validated_conclusions')
      .select('id, organization_id, object_type, statement, rationale, limitations, reviewed_at')
      .eq('organization_id', session.organization.id)
      .order('reviewed_at', { ascending: false })
      .limit(20));
    for (const row of conclusions ?? []) {
      records.push({
        id: row.id,
        organizationId: row.organization_id,
        engagementId: session.engagement.id,
        objectType: row.object_type,
        title: titleFromStatement(row.statement),
        statement: row.statement,
        rationale: row.rationale,
        state: row.object_type === 'INSIGHT' ? 'VALIDATED INSIGHT' : 'VALIDATED DIAGNOSIS',
        origin: 'HUMAN',
        visibility: 'ORGANIZATION_SHARED',
        sourceLabels: [],
        history: [{ date: formatDate(row.reviewed_at), action: 'Validated', actor: 'Authorized reviewer' }],
        updatedLabel: `Validated ${formatDate(row.reviewed_at)}`,
      });
    }
  } else {
    const [statesResult, decisionsResult] = await Promise.all([
      supabase
        .from('epistemic_record_states')
        .select('id, organization_id, object_type, origin, current_review_state, created_at')
        .eq('organization_id', session.organization.id)
        .order('created_at', { ascending: false })
        .limit(20),
      supabase
        .from('decisions')
        .select('id, organization_id, object_type, statement, rationale, created_at')
        .eq('organization_id', session.organization.id)
        .order('created_at', { ascending: false })
        .limit(20),
    ]);
    assertSucceeded('portal.dashboard.records', statesResult, decisionsResult);
    const states = statesResult.data;
    const decisions = decisionsResult.data;
    const domainIds = [...(states ?? []).map((row) => row.id), ...(decisions ?? []).map((row) => row.id)];
    const domains = domainIds.length
      ? unwrap('portal.dashboard.domainObjects', await supabase
          .from('domain_objects')
          .select('id, engagement_id, visibility_scope')
          .eq('organization_id', session.organization.id)
          .in('id', domainIds))
      : [];
    const domainMap = new Map((domains ?? []).map((row) => [row.id, row]));
    const typedTables = [
      'observations', 'patterns', 'assumptions', 'hypotheses', 'interpretations',
      'insights', 'risks', 'strengths', 'unrealized_potentials', 'diagnoses',
    ] as const;
    const typedResults = domainIds.length
      ? await Promise.all(typedTables.map((table) =>
          supabase.from(table).select('*').eq('organization_id', session.organization.id).in('id', domainIds),
        ))
      : [];
    assertSucceeded('portal.dashboard.typedRecords', ...typedResults);
    const contentMap = new Map<string, Record<string, unknown>>();
    for (const result of typedResults) {
      for (const row of result.data ?? []) contentMap.set(row.id, row as Record<string, unknown>);
    }
    for (const row of states ?? []) {
      const domain = domainMap.get(row.id);
      const content = contentMap.get(row.id);
      const statement = stringValue(content?.statement, `${titleCase(row.object_type)} record`);
      records.push({
        id: row.id,
        organizationId: row.organization_id,
        engagementId: domain?.engagement_id ?? session.engagement.id,
        objectType: row.object_type,
        title: titleFromStatement(statement),
        statement,
        rationale: firstString(content, ['rationale', 'context', 'recurrence_basis', 'test_criteria', 'confidence_rationale', 'protection_rationale', 'constraint_summary', 'scope'])
          ?? 'Review the typed source record and its cited relationships for full context.',
        state: mapReviewState(row.object_type, row.origin, row.current_review_state),
        origin: row.origin === 'AI' ? 'AI' : 'HUMAN',
        visibility: (domain?.visibility_scope ?? 'ENGAGEMENT_SHARED') as Visibility,
        sourceLabels: [],
        history: [{ date: formatDate(row.created_at), action: 'Created', actor: row.origin === 'AI' ? 'Meridian' : 'Authorized human' }],
        updatedLabel: formatDate(row.created_at),
      });
    }
    for (const row of decisions ?? []) {
      const domain = domainMap.get(row.id);
      records.push({
        id: row.id,
        organizationId: row.organization_id,
        engagementId: domain?.engagement_id ?? session.engagement.id,
        objectType: 'DECISION',
        title: titleFromStatement(row.statement),
        statement: row.statement,
        rationale: row.rationale,
        state: 'DECISION',
        origin: 'HUMAN',
        visibility: (domain?.visibility_scope ?? 'ENGAGEMENT_SHARED') as Visibility,
        sourceLabels: [],
        history: [{ date: formatDate(row.created_at), action: 'Decision recorded', actor: 'Authorized human' }],
        updatedLabel: formatDate(row.created_at),
      });
    }
  }

  return {
    organization: session.organization,
    engagement: session.engagement,
    roadmap: roadmapStages,
    attention: [],
    records,
    workspaces: workspaceDefinitions.map((workspace) => ({
      ...workspace,
      metric: String(records.filter((record) => workspaceFilter(workspace.key, record)).length),
      metricLabel: 'available records',
      href: session.role === 'consultant'
        ? `/consultant/clients/${session.organization.id}/${workspace.key}`
        : clientHref(workspace.key),
    })),
    currentNarrative: records.find((record) => record.state === 'VALIDATED INSIGHT')?.statement
      ?? 'No currently effective organizational narrative has been validated yet.',
    historicalNarratives: [],
  };
});

export async function getPortalRecord(session: PortalSession, recordId: string) {
  if (session.fixture) return fixtureRecord(session.role === 'consultant' ? 'consultant' : 'client', recordId);
  const dashboard = await getPortalDashboard(session);
  return dashboard.records.find((record) => record.id === recordId) ?? null;
}

export function recordsForWorkspace(dashboard: PortalDashboard, workspace: string) {
  return dashboard.records.filter((record) => workspaceFilter(workspace, record));
}

function workspaceFilter(workspace: string, record: PortalRecord) {
  if (workspace === 'overview') return true;
  if (workspace === 'discovery') return ['EVIDENCE', 'OBSERVATION', 'PATTERN', 'ASSUMPTION', 'HYPOTHESIS'].includes(record.objectType);
  if (workspace === 'strategy') return ['INTERPRETATION', 'INSIGHT', 'DIAGNOSIS', 'DECISION'].includes(record.objectType);
  if (workspace === 'development') return ['CAPABILITY', 'DEVELOPMENT_PLAN', 'COMMITMENT'].includes(record.objectType);
  if (workspace === 'outcomes') return ['GOAL', 'INDICATOR', 'MEASUREMENT', 'OUTCOME', 'LEARNING'].includes(record.objectType);
  if (workspace === 'signals') return ['OBSERVATION', 'PATTERN', 'SIGNAL'].includes(record.objectType);
  return true;
}

function mapReviewState(objectType: string, origin: string, reviewState: string): ReviewState {
  if (objectType === 'DECISION') return 'DECISION';
  if (objectType === 'INSIGHT' && reviewState === 'VALIDATED') return 'VALIDATED INSIGHT';
  if (origin === 'AI' && reviewState === 'SUGGESTED') return 'AI SUGGESTION';
  return 'INTERPRETATION';
}

function titleFromStatement(statement: string) {
  return statement.length > 72 ? `${statement.slice(0, 69)}…` : statement;
}

function titleCase(value: string) {
  return value.toLowerCase().replaceAll('_', ' ').replace(/(^|\s)\w/g, (letter) => letter.toUpperCase());
}

function formatDate(value: string) {
  return new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric', year: 'numeric' }).format(new Date(value));
}
function stringValue(value: unknown, fallback: string) {
  return typeof value === 'string' && value.trim() ? value : fallback;
}

function firstString(record: Record<string, unknown> | undefined, keys: string[]) {
  if (!record) return null;
  for (const key of keys) {
    const value = record[key];
    if (typeof value === 'string' && value.trim()) return value;
  }
  return null;
}


function clientHref(workspace: string) {
  if (workspace === 'development') return '/client/my-development';
  if (workspace === 'outcomes' || workspace === 'signals') return '/client/progress';
  if (workspace === 'overview') return '/client';
  return '/client/our-organization';
}
