import { describe, expect, it } from 'vitest';
import { normalizeParticipantAssessmentRows, validateAssessmentResponseValue } from './assessment';

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

  it('projects structured matrix response contracts without flattening them', () => {
    const assessment = normalizeParticipantAssessmentRows([{
      organization_name: '7th Special Operations Squadron',
      instrument_name: 'Mission Product Workflow and Automation Assessment',
      item_id: 'item-1',
      prompt: 'A. Production steps',
      response_type: 'TEXT',
      response_options: {
        section: '3. Current-State Workflow: What Actually Happens',
        guidance: 'Map the trace case.',
        uiType: 'matrix',
        columns: [{ key: 'action', label: 'Action or decision' }],
        rows: 12,
      },
      confidentiality: 'IDENTIFIED',
      closes_at: '2026-09-12T22:00:00.000Z',
    }]);

    expect(assessment?.items[0].section).toContain('Current-State Workflow');
    expect(assessment?.items[0].response).toMatchObject({ uiType: 'matrix', rows: 12 });
  });

  it('accepts sanitized structured evidence and rejects restricted detail indicators', () => {
    expect(() => validateAssessmentResponseValue({ rows: [{ values: { action: 'Human reviewer checks source traceability.' } }] })).not.toThrow();
    expect(() => validateAssessmentResponseValue({ rows: [{ values: { action: 'Enter the classified mission timeline.' } }] })).toThrow(/sanitized process-level information/i);
  });
});
