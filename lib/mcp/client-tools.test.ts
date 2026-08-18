import { describe, expect, it } from 'vitest';
import { nextQuestion, normalizeClientRecordKind } from './client-tools';

describe('client MCP guided work helpers', () => {
  it('allows only participant-safe audit and interview records', () => {
    expect(normalizeClientRecordKind('AUDIT')).toBe('AUDIT');
    expect(normalizeClientRecordKind('INTERVIEW')).toBe('INTERVIEW');
    expect(() => normalizeClientRecordKind('PRODUCT')).toThrow('Only guided work assigned to this client is available.');
  });

  it('resumes at the first unanswered authoritative question', () => {
    const questions = ['one', 'two', 'three'].map((id) => ({ id, section: 'Test', prompt: id, guidance: 'Test', placeholder: 'Test' }));
    expect(nextQuestion(questions, [{ questionId: 'one' }, { questionId: 'two' }])?.id).toBe('three');
    expect(nextQuestion(questions, questions.map((question) => ({ questionId: question.id })))).toBeUndefined();
  });
});