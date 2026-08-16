import 'server-only';

import { createHash, randomBytes } from 'node:crypto';
import { dataAccessError, notFoundError } from '@/lib/errors';
import type { PortalSession } from '@/lib/portal/types';
import { createSupabaseAdminClient } from '@/lib/supabase/admin';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { assessmentDefinitionForDatabase, getAssessmentWorkflowDefinition } from './assessment-workflow-definitions';

export interface StartedAssessmentAdministration {
  administrationId: string;
  participantToken: string;
  participantPath: string;
  conversationBrief: string;
}

export async function startAssessmentAdministration(session: PortalSession, slug: string): Promise<StartedAssessmentAdministration> {
  const definition = getAssessmentWorkflowDefinition(slug);
  if (!definition) throw notFoundError('The requested assessment instrument was not found.');

  if (session.fixture) {
    const participantToken = `fixture-participant-${slug}`;
    return started(definition.title, slug, `fixture-administration-${slug}`, participantToken);
  }

  const supabase = await createSupabaseServerClient();
  const { data: administrationId, error } = await supabase.rpc('create_operational_assessment_administration', {
    p_organization_id: session.organization.id,
    p_engagement_id: session.engagement.id,
    p_definition: assessmentDefinitionForDatabase(definition),
    p_audience_description: `${definition.title} · consultant-guided administration`,
    p_confidentiality: 'IDENTIFIED',
  });
  if (error || typeof administrationId !== 'string') {
    throw dataAccessError('operationalAi.startAssessmentAdministration', error ?? new Error('Administration ID was not returned.'), 'The guided assessment could not be started.');
  }

  const participantToken = randomBytes(32).toString('base64url');
  const tokenHash = createHash('sha256').update(participantToken).digest('hex');
  const expiresAt = new Date(Date.now() + 14 * 86_400_000).toISOString();
  const admin = createSupabaseAdminClient();
  const { error: linkError } = await admin.rpc('issue_assessment_participant_link', {
    p_organization_id: session.organization.id,
    p_engagement_id: session.engagement.id,
    p_administration_id: administrationId,
    p_token_hash: tokenHash,
    p_respondent_person_id: session.personId,
    p_recipient_name: session.displayName,
    p_recipient_email: null,
    p_expires_at: expiresAt,
    p_created_by: session.personId,
  });
  if (linkError) {
    throw dataAccessError('operationalAi.issueAssessmentLink', linkError, 'The guided assessment link could not be created.');
  }

  return started(definition.title, slug, administrationId, participantToken);
}

function started(title: string, slug: string, administrationId: string, participantToken: string): StartedAssessmentAdministration {
  return {
    administrationId,
    participantToken,
    participantPath: `/assessment/${participantToken}`,
    conversationBrief: [
      `Administer the authoritative ${title} through the connected Lead Emergence Consulting OS MCP tools.`,
      `Instrument slug: ${slug}`,
      `Administration ID: ${administrationId}`,
      `Participant capability token: ${participantToken}`,
      '',
      'Read the complete versioned instrument before asking anything. Ask one item at a time, preserve all checklists and matrix fields, and retain the respondent’s exact wording. Save a response only after explicit confirmation. Never infer a missing answer, score the instrument, or promote any response into a finding, diagnosis, recommendation, or causal claim. Use sanitized process-level information only; stop if classified, CUI, operationally sensitive, or otherwise restricted material is introduced.',
    ].join('\n'),
  };
}
