import { describe, expect, it } from 'vitest';
import { assessmentInstruments, assessmentInstrumentUrl, getAssessmentInstrument } from './assessment-instruments';

describe('assessment instruments', () => {
  it('registers the two authoritative mission-product instruments', () => {
    expect(assessmentInstruments.map((instrument) => instrument.slug)).toEqual([
      'mission-product-automation-leadership-assessment',
      'mission-product-workflow-and-automation-assessment',
    ]);
    expect(assessmentInstruments.map((instrument) => instrument.pageCount)).toEqual([10, 15]);
    expect(assessmentInstruments.every((instrument) => instrument.files.docx.endsWith('.docx') && instrument.files.pdf.endsWith('.pdf'))).toBe(true);
  });

  it('resolves protected view and download URLs', () => {
    const instrument = getAssessmentInstrument('mission-product-automation-leadership-assessment');
    expect(instrument?.primaryOutput).toBe('Ranked priorities + success definition');
    expect(assessmentInstrumentUrl(instrument!.slug, 'pdf')).toBe('/api/assessment-instruments/mission-product-automation-leadership-assessment/pdf');
    expect(assessmentInstrumentUrl(instrument!.slug, 'docx', true)).toContain('/docx?download=1');
  });
});
