import 'server-only';

import { createHash } from 'node:crypto';
import { validationError } from '@/lib/errors';
import { dataAccessError } from '@/lib/http/errors';
import { createSupabaseAdminClient } from '@/lib/supabase/admin';
import { isFixtureMode } from '@/lib/supabase/config';
import { getAssessmentWorkflowDefinition, type AssessmentResponseDefinition } from '@/lib/operational-ai/assessment-workflow-definitions';
import { containsControlledContent } from '@/lib/operational-ai/workflow';

export interface ParticipantAssessmentItem {
  itemId: string;
  prompt: string;
  responseType: string;
  section: string;
  guidance: string;
  response: AssessmentResponseDefinition;
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
      ...normalizeResponseDefinition(row.response_type, row.response_options),
    })),
  };
}

export async function getParticipantAssessment(token: string): Promise<ParticipantAssessment | null> {
  if (isFixtureMode() && token.startsWith('fixture-participant-')) {
    const slug = token.slice('fixture-participant-'.length);
    const definition = getAssessmentWorkflowDefinition(slug);
    if (definition) {
      return {
        organizationName: '7th Special Operations Squadron',
        instrumentName: definition.title,
        confidentiality: 'IDENTIFIED',
        closesAt: '2026-12-31T23:59:59.000Z',
        items: definition.items.map((item) => ({
          itemId: `fixture-${item.itemKey.toLowerCase()}`,
          prompt: item.prompt,
          responseType: item.responseType,
          section: item.section,
          guidance: item.guidance,
          response: item.response,
        })),
      };
    }
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
          section: 'Ministry rhythm',
          guidance: 'Choose the response that best reflects the current reality.',
          response: { uiType: 'matrix', rows: [{ key: 'rating', label: 'Rating' }], columns: [{ key: 'value', label: 'Response', type: 'rating' }] },
        },
        {
          itemId: '76100000-0000-4000-8000-000000000002',
          prompt: 'Decision authority is clear at the point where ministry work happens.',
          responseType: 'LIKERT',
          section: 'Decision authority',
          guidance: 'Choose the response that best reflects the current reality.',
          response: { uiType: 'matrix', rows: [{ key: 'rating', label: 'Rating' }], columns: [{ key: 'value', label: 'Response', type: 'rating' }] },
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
  validateAssessmentResponseValue(value);
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

function normalizeResponseDefinition(responseType: string, options: unknown): Pick<ParticipantAssessmentItem, 'section' | 'guidance' | 'response'> {
  if (options && typeof options === 'object' && !Array.isArray(options)) {
    const record = options as Record<string, unknown>;
    if (record.uiType === 'text') return { section: stringOption(record.section, 'Assessment item'), guidance: stringOption(record.guidance, 'Preserve the respondent’s wording.'), response: { uiType: 'text', placeholder: stringOption(record.placeholder, 'Type the confirmed response here…') } };
    if (record.uiType === 'fields' && Array.isArray(record.fields)) return { section: stringOption(record.section, 'Assessment item'), guidance: stringOption(record.guidance, 'Complete the applicable fields.'), response: { uiType: 'fields', fields: record.fields as ParticipantAssessmentItem['response'] extends { uiType: 'fields'; fields: infer T } ? T : never } };
    if (record.uiType === 'multi-select' && Array.isArray(record.options)) return { section: stringOption(record.section, 'Assessment item'), guidance: stringOption(record.guidance, 'Select every applicable option.'), response: { uiType: 'multi-select', options: record.options.filter((item): item is string => typeof item === 'string'), maxSelections: typeof record.maxSelections === 'number' ? record.maxSelections : undefined, allowOther: record.allowOther === true } };
    if (record.uiType === 'matrix' && Array.isArray(record.columns) && (Array.isArray(record.rows) || typeof record.rows === 'number')) return { section: stringOption(record.section, 'Assessment item'), guidance: stringOption(record.guidance, 'Complete the applicable rows.'), response: { uiType: 'matrix', columns: record.columns as ParticipantAssessmentItem['response'] extends { uiType: 'matrix'; columns: infer T } ? T : never, rows: record.rows as ParticipantAssessmentItem['response'] extends { uiType: 'matrix'; rows: infer T } ? T : never } };
  }
  if (responseType === 'LIKERT') return { section: 'Assessment item', guidance: 'Choose one response.', response: { uiType: 'matrix', rows: [{ key: 'rating', label: 'Rating' }], columns: [{ key: 'value', label: 'Response', type: 'rating' }] } };
  return { section: 'Assessment item', guidance: 'Preserve the respondent’s wording.', response: { uiType: 'text', placeholder: 'Type the confirmed response here…' } };
}

function stringOption(value: unknown, fallback: string) {
  return typeof value === 'string' && value.trim() ? value : fallback;
}

export function validateAssessmentResponseValue(value: unknown) {
  if (value === null || value === undefined) throw validationError('A complete assessment response is required.');
  const serialized = JSON.stringify(value);
  if (!serialized || serialized.length > 48_000) throw validationError('The assessment response is too large.');
  const strings: string[] = [];
  collectStrings(value, strings, 0);
  if (!strings.some((item) => item.trim())) throw validationError('A complete assessment response is required.');
  if (strings.some((item) => containsControlledContent(item))) {
    throw validationError('This environment accepts sanitized process-level information only. Remove operational or controlled details.');
  }
}

function collectStrings(value: unknown, output: string[], depth: number) {
  if (depth > 8) throw validationError('The assessment response structure is too deeply nested.');
  if (typeof value === 'string') output.push(value);
  else if (typeof value === 'number' || typeof value === 'boolean') output.push(String(value));
  else if (Array.isArray(value)) value.forEach((item) => collectStrings(item, output, depth + 1));
  else if (value && typeof value === 'object') Object.values(value as Record<string, unknown>).forEach((item) => collectStrings(item, output, depth + 1));
}
