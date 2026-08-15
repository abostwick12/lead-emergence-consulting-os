import { objectInput } from '../validation/input';
import type { AccessMutation, ClientPlatformRole } from './types';
const roles: ClientPlatformRole[] = ['CLIENT_ADMIN', 'CLIENT_LEADER', 'CLIENT_MEMBER'];
const emailPattern = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
export function validateAccessMutation(value: unknown): AccessMutation {
  const { raw: input, text } = objectInput(value, 'An access action is required.');
  if (input.action === 'INVITE_CLIENT') { const email = text('email').toLowerCase(); const displayName = text('displayName'); const role = text('role') as ClientPlatformRole; if (!emailPattern.test(email)) throw new Error('Enter a valid client email address.'); if (!displayName) throw new Error('Client name is required.'); if (!roles.includes(role)) throw new Error('Client access role is invalid.'); return { action: input.action, email, displayName, role }; }
  if (input.action === 'CREATE_ASSESSMENT_LINK') { const administrationId = text('administrationId'); if (!/^[0-9a-f-]{36}$/i.test(administrationId)) throw new Error('Assessment administration is invalid.'); const recipientEmail = text('recipientEmail').toLowerCase(); if (recipientEmail && !emailPattern.test(recipientEmail)) throw new Error('Enter a valid participant email address.'); return { action: input.action, administrationId, recipientName: text('recipientName') || undefined, recipientEmail: recipientEmail || undefined }; }
  throw new Error('The access action is not supported.');
}
