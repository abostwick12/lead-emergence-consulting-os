import { describe, expect, it } from 'vitest';
import { validateDiscoveryMutation } from './workflow';

describe('discovery intake boundaries', () => {
  it('keeps evidence source and provenance explicit', () => {
    expect(validateDiscoveryMutation({ action: 'CAPTURE_EVIDENCE', sourceType: 'CONSULTANT_OBSERVATION', title: 'Staff rhythm', provenanceContext: 'Observed during staff meeting', content: 'Three urgent changes were added.', relevanceNote: 'Shows planning volatility', limitations: 'One meeting' })).toMatchObject({ sourceType: 'CONSULTANT_OBSERVATION' });
  });
  it('does not accept a completed interview without explicit consent', () => {
    expect(validateDiscoveryMutation({ action: 'RECORD_INTERVIEW', participantLabel: 'Pastor', guideName: 'Discovery', question: 'What is sustainable?', response: 'Not this pace.', consentRecorded: false })).toMatchObject({ consentRecorded: false });
  });
});
