import 'server-only';
import { createHash } from 'node:crypto';
import { createSupabaseAdminClient } from '@/lib/supabase/admin';
import { isFixtureMode } from '@/lib/supabase/config';
import { dataAccessError } from '@/lib/http/errors';

export interface ParticipantAssessment { organizationName: string; instrumentName: string; itemId: string; prompt: string; responseType: string; responseOptions: unknown; confidentiality: string; closesAt: string }
const tokenHash = (token: string) => createHash('sha256').update(token).digest('hex');

export async function getParticipantAssessment(token: string): Promise<ParticipantAssessment | null> {
  if (isFixtureMode() && token.startsWith('fixture-participant-')) return { organizationName: 'Northstar Community Church', instrumentName: 'Ministry Rhythm Discovery', itemId: '76100000-0000-4000-8000-000000000001', prompt: 'Our current ministry rhythm is sustainable for staff and volunteers.', responseType: 'LIKERT', responseOptions: [1, 2, 3, 4, 5], confidentiality: 'CONFIDENTIAL', closesAt: '2026-09-12T22:00:00.000Z' };
  if (token.length < 32) return null;
  const admin = createSupabaseAdminClient();
  const { data, error } = await admin.rpc('resolve_assessment_participant_link', { p_token_hash: tokenHash(token) });
  if (error) throw dataAccessError(error, 'lib/access/assessment.ts'); const row = Array.isArray(data) ? data[0] : data; if (!row) return null;
  return { organizationName: row.organization_name, instrumentName: row.instrument_name, itemId: row.item_id, prompt: row.prompt, responseType: row.response_type, responseOptions: row.response_options, confidentiality: row.confidentiality, closesAt: row.closes_at };
}

export async function submitParticipantAssessment(token: string, itemId: string, value: unknown) {
  if (isFixtureMode() && token.startsWith('fixture-participant-')) return { responseId: 'fixture-response' };
  if (token.length < 32 || !/^[0-9a-f-]{36}$/i.test(itemId)) throw new Error('Assessment link is invalid.');
  const admin = createSupabaseAdminClient(); const { data, error } = await admin.rpc('submit_assessment_participant_response', { p_token_hash: tokenHash(token), p_item_id: itemId, p_response: { value } });
  if (error) throw dataAccessError(error, 'lib/access/assessment.ts'); return { responseId: data };
}
