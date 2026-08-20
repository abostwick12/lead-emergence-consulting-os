import { validationError } from '@/lib/errors';
import { consultingIntakeQuestions, type FollowUpStatus, type IntakeResponse, type ProspectMutation } from './types';

const email = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
const followUps: FollowUpStatus[] = ['NOT_CONTACTED','FOLLOW_UP_DUE','CONTACTED','AWAITING_RESPONSE','MEETING_SCHEDULED','TRIAL_STARTED','CONVERTED','NOT_NOW','CLOSED'];
const text = (value: unknown) => typeof value === 'string' ? value.trim() : '';

export function validatePublicIntake(value: unknown) {
  if (!value || typeof value !== 'object') throw validationError('Please complete the intake before submitting.');
  const input = value as Record<string, unknown>; const firstName = text(input.firstName); const address = text(input.email).toLowerCase();
  if (!firstName || !email.test(address)) throw validationError('Enter your first name and a valid email address.');
  if (!Array.isArray(input.responses) || input.responses.length !== consultingIntakeQuestions.length) throw validationError('Please answer each intake question.');
  const responses: IntakeResponse[] = input.responses.map((value, index) => {
    const row = value as Record<string, unknown>; const question = consultingIntakeQuestions[index];
    if (!row || row.questionKey !== question.key || text(row.answer).length < 8) throw validationError('Please add a little more detail before continuing.');
    return { questionKey: question.key, prompt: question.prompt, answer: text(row.answer) };
  });
  return { firstName, email: address, organizationName: text(input.organizationName) || undefined, roleTitle: text(input.roleTitle) || undefined, newsletterOptIn: input.newsletterOptIn === true, responses };
}

export function validateProspectMutation(value: unknown): ProspectMutation {
  if (!value || typeof value !== 'object') throw validationError('A prospect action is required.');
  const input = value as Record<string, unknown>; const prospectId = text(input.prospectId);
  if (!/^[0-9a-f-]{8,}$/i.test(prospectId)) throw validationError('Prospect context is invalid.');
  if (input.action === 'SAVE_REVISION') {
    const signals = Array.isArray(input.signals) ? input.signals.map(text).filter(Boolean) : []; const possibilities = Array.isArray(input.possibilities) ? input.possibilities.map(text).filter(Boolean) : []; const firstMove = text(input.firstMove);
    if (signals.length !== 3 || possibilities.length !== 2 || !firstMove) throw validationError('A 3-2-1 needs three signals, two possibilities, and one first move.');
    return { action: input.action, prospectId, signals, possibilities, firstMove };
  }
  if (input.action === 'APPROVE') { const revisionId = text(input.revisionId); if (!revisionId) throw validationError('Select a revision to approve.'); return { action: input.action, prospectId, revisionId }; }
  if (input.action === 'PREPARE_DELIVERY' || input.action === 'MARK_SENT') return { action: input.action, prospectId };
  if (input.action === 'ADD_NOTE') { const note = text(input.note); if (!note) throw validationError('A private note is required.'); return { action: input.action, prospectId, note }; }
  if (input.action === 'CREATE_FOLLOW_UP') { const dueAt = text(input.dueAt); const followUpStatus = text(input.followUpStatus) as FollowUpStatus; if (!dueAt || !followUps.includes(followUpStatus)) throw validationError('A valid follow-up date and state are required.'); return { action: input.action, prospectId, dueAt, followUpStatus, note: text(input.note) }; }
  if (input.action === 'CONVERT') { const organizationName = text(input.organizationName); const engagementName = text(input.engagementName); if (!organizationName || !engagementName) throw validationError('Organization and engagement names are required for a controlled conversion.'); return { action: input.action, prospectId, organizationName, engagementName }; }
  throw validationError('This prospect action is not supported.');
}