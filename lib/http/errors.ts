const GENERIC_MESSAGE = 'The request could not be completed. Please retry or contact your consultant.';

/**
 * Converts a database or auth-provider error into a client-safe error. The
 * original message is written to the server log only, because provider errors
 * carry schema, policy, and identifier details that must not reach a browser.
 */
export function dataAccessError(error: unknown, context = 'data access'): Error {
  const detail = error instanceof Error
    ? error.message
    : typeof error === 'object' && error !== null && 'message' in error
      ? String((error as { message: unknown }).message)
      : String(error);
  console.error(`[consulting-os] ${context} failed: ${detail}`);
  return new Error(GENERIC_MESSAGE);
}
