import { describe, expect, it } from 'vitest';
import { fixtureOperationalEngagement } from './fixtures';
import { getGuidedRecord } from './guided-workflows';

describe('guided engagement workflows', () => {
  it('opens a product at the first unanswered question with an MCP conversation brief', () => {
    const snapshot = getGuidedRecord(fixtureOperationalEngagement(), 'PRODUCT', 'product-1');
    expect(snapshot.nextQuestionId).toBe('product-purpose');
    expect(snapshot.totalCount).toBe(12);
    expect(snapshot.conversationBrief).toContain('Ask one guided question at a time');
    expect(snapshot.conversationBrief).toContain('save an answer only after I explicitly confirm it');
  });

  it('preserves product, audit, and interview as distinct guided records', () => {
    const data = fixtureOperationalEngagement();
    expect(getGuidedRecord(data, 'PRODUCT', 'product-1').questions[0].id).toBe('product-purpose');
    expect(getGuidedRecord(data, 'AUDIT', 'audit-1').questions[0].id).toBe('audit-context');
    expect(getGuidedRecord(data, 'INTERVIEW', 'interview-1').questions[0].id).toBe('interview-role');
  });
});
