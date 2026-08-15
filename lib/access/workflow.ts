import { validationError } from '@/lib/errors';
import type { AccessMutation, ClientPlatformRole } from './types';
const roles: ClientPlatformRole[] = ['CLIENT_ADMIN', 'CLIENT_LEADER', 'CLIENT_MEMBER'];
const emailPattern = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
export function validateAccessMutation(value: unknown): AccessMutation {
  if (!value || typeof value !== 'object') throw validationError('An access action is required.');
  const input = value as Record<string, unknown>; const text = (key: string) => typeof input[key] === 'string' ? input[key].trim() : '';
  if (input.action === 'INVITE_CLIENT') { const email = text('email').toLowerCase(); const displayName = text('displayName'); const role = text('role') as ClientPlatformRole; if (!emailPattern.test(email)) throw validationError('Enter a valid client email address.'); if (!displayName) throw validationError('Client name is required.'); if (!roles.includes(role)) throw validationError('Client access role is invalid.'); return { action: input.action, email, displayName, role }; }
  if (input.action === 'CREATE_ASSESSMENT_LINK') { const administrationId = text('administrationId'); if (!/^[0-9a-f-]{36}$/i.test(administrationId)) throw validationError('Assessment administration is invalid.'); const recipientEmail = text('recipientEmail').toLowerCase(); if (recipientEmail && !emailPattern.test(recipientEmail)) throw validationError('Enter a valid participant email address.'); return { action: input.action, administrationId, recipientName: text('recipientName') || undefined, recipientEmail: recipientEmail || undefined }; }
  throw validationError('The access action is not supported.');
}
