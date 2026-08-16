import 'server-only';

import { createHash } from 'node:crypto';
import { validationError } from '@/lib/errors';
import { dataAccessError } from '@/lib/http/errors';
import { createSupabaseAdminClient } from '@/lib/supabase/admin';
import { isFixtureMode } from '@/lib/supabase/config';

export interface ParticipantAssessmentItem {
  itemId: string;
  prompt: string;
  responseType: string;
  responseOptions: unknown;
}

export interface ParticipantAssessment {
  organizationName: string;
  instrumentName: string;
  items: ParticipantAssessmentItem[];
  confidentiality: string;
  closesAt: string;
}

interface ParticipantAssessmentRow {
  organization_name: string;
  instrument_name: string;
  item_id: string;
  prompt: string;
  response_type: string;
  response_options: unknown;
  confidentiality: string;
  closes_at: string;
}

const tokenHash = (token: string) => createHash('sha256').update(token).digest('hex');

export function normalizeParticipantAssessmentRows(rows: ParticipantAssessmentRow[]): ParticipantAssessment | null {
  const first = rows[0];
  if (!first) return null;
  return {
    organizationName: first.organization_name,
    instrumentName: first.instrument_name,
    confidentiality: first.confidentiality,
    closesAt: first.closes_at,
    items: rows.map((row) => ({
      itemId: row.item_id,
      prompt: row.prompt,
      responseType: row.response_type,
      responseOptions: row.response_options,
    })),
  };
}

export async function getParticipantAssessment(token: string): Promise<ParticipantAssessment | null> {
  if (isFixtureMode() && token.startsWith('fixture-participant-')) {
    return {
      organizationName: 'Northstar Community Church',
      instrumentName: 'Ministry Rhythm Discovery',
      confidentiality: 'CONFIDENTIAL',
      closesAt: '2026-09-12T22:00:00.000Z',
      items: [
        {
          itemId: '76100000-0000-4000-8000-000000000001',
          prompt: 'Our current ministry rhythm is sustainable for staff and volunteers.',
          responseType: 'LIKERT',
          responseOptions: [1, 2, 3, 4, 5],
        },
        {
          itemId: '76100000-0000-4000-8000-000000000002',
          prompt: 'Decision authority is clear at the point where ministry work happens.',
          responseType: 'LIKERT',
          responseOptions: [1, 2, 3, 4, 5],
        },
      ],
    };
  }
  if (token.length < 32) return null;
  const admin = createSupabaseAdminClient();
  const { data, error } = await admin.rpc('resolve_assessment_participant_link', { p_token_hash: tokenHash(token) });
  if (error) throw dataAccessError(error, 'lib/access/assessment.ts');
  return normalizeParticipantAssessmentRows((Array.isArray(data) ? data : data ? [data] : []) as ParticipantAssessmentRow[]);
}

export async function submitParticipantAssessment(token: string, itemId: string, value: unknown) {
  if (isFixtureMode() && token.startsWith('fixture-participant-')) return { responseId: `fixture-response-${itemId}` };
  if (token.length < 32 || !/^[0-9a-f-]{36}$/i.test(itemId)) throw validationError('Assessment link is invalid.');
  const admin = createSupabaseAdminClient();
  const { data, error } = await admin.rpc('submit_assessment_participant_response', {
    p_token_hash: tokenHash(token),
    p_item_id: itemId,
    p_response: { value },
  });
  if (error) throw dataAccessError(error, 'lib/access/assessment.ts');
  return { responseId: data };
}
