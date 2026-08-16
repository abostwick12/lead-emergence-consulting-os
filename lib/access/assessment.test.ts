import { describe, expect, it } from 'vitest';
import { normalizeParticipantAssessmentRows } from './assessment';

describe('participant assessment projection', () => {
  it('keeps every unanswered item in instrument order', () => {
    const assessment = normalizeParticipantAssessmentRows([
      {
        organization_name: 'Northstar Community Church',
        instrument_name: 'Ministry Rhythm Discovery',
        item_id: 'item-1',
        prompt: 'First question',
        response_type: 'LIKERT',
        response_options: [1, 2, 3, 4, 5],
        confidentiality: 'CONFIDENTIAL',
        closes_at: '2026-09-12T22:00:00.000Z',
      },
      {
        organization_name: 'Northstar Community Church',
        instrument_name: 'Ministry Rhythm Discovery',
        item_id: 'item-2',
        prompt: 'Second question',
        response_type: 'LIKERT',
        response_options: [1, 2, 3, 4, 5],
        confidentiality: 'CONFIDENTIAL',
        closes_at: '2026-09-12T22:00:00.000Z',
      },
    ]);

    expect(assessment?.items.map((item) => item.itemId)).toEqual(['item-1', 'item-2']);
  });

  it('returns no participant assessment when no unanswered items remain', () => {
    expect(normalizeParticipantAssessmentRows([])).toBeNull();
  });
});
