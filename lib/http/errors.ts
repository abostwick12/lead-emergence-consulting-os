import { dataAccessError as appDataAccessError } from '@/lib/errors';

const GENERIC_MESSAGE = 'The request could not be completed. Please retry or contact your consultant.';

/**
 * Converts a database or auth-provider error into a client-safe error. The
 * original message is written to the server log only, because provider errors
 * carry schema, policy, and identifier details that must not reach a browser.
 */
export function dataAccessError(error: unknown, context = 'data access') {
  return appDataAccessError(context, error, GENERIC_MESSAGE);
}
