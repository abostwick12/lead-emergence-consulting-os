import { describe, expect, it } from 'vitest';
import { consultingIntakeQuestions } from './types';
import { validateProspectMutation, validatePublicIntake } from './workflow';

const responses = consultingIntakeQuestions.map((question) => ({ questionKey: question.key, prompt: question.prompt, answer: 'A sufficiently specific response for the consultant to review.' }));

describe('Consulting prospect workflow', () => {
  it('accepts a complete public intake without creating an account', () => {
    expect(validatePublicIntake({ firstName: ' Morgan ', email: 'Morgan@Example.com ', newsletterOptIn: true, responses })).toMatchObject({ firstName: 'Morgan', email: 'morgan@example.com', newsletterOptIn: true });
  });
  it('requires every configured intake response', () => {
    expect(() => validatePublicIntake({ firstName: 'Morgan', email: 'morgan@example.com', responses: responses.slice(1) })).toThrow(/answer each/i);
  });
  it('requires an explicit complete 3-2-1 before saving a revision', () => {
    expect(() => validateProspectMutation({ action: 'SAVE_REVISION', prospectId: '11111111-1111-4111-8111-111111111111', signals: ['one'], possibilities: [], firstMove: '' })).toThrow(/3-2-1/i);
  });
  it('does not permit delivery mutation without the specific workflow action', () => {
    expect(validateProspectMutation({ action: 'PREPARE_DELIVERY', prospectId: '11111111-1111-4111-8111-111111111111' })).toEqual({ action: 'PREPARE_DELIVERY', prospectId: '11111111-1111-4111-8111-111111111111' });
  });
});