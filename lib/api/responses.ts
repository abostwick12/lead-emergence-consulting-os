import { unstable_rethrow } from 'next/navigation';
import { NextResponse } from 'next/server';
import { clientMessage, isAppError, logError } from '@/lib/errors';

/**
 * Converts a thrown value into a JSON response.
 *
 * Next.js control-flow signals (`redirect`, `notFound`) are rethrown so an
 * unauthenticated or unauthorized request still redirects or 404s instead of
 * being reported as a failed action. Errors that are not AppError instances are
 * unexpected: they are logged with their cause and reported as a 500 without
 * exposing internal detail.
 */
export function apiErrorResponse(scope: string, error: unknown, fallbackMessage: string) {
  unstable_rethrow(error);
  if (!isAppError(error) || error.status >= 500) logError(scope, error);
  const status = isAppError(error) ? error.status : 500;
  return NextResponse.json({ error: clientMessage(error, fallbackMessage) }, { status });
}
