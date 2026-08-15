import 'server-only';

import { unstable_checkRateLimit as checkRateLimit } from '@vercel/firewall';
import { logError, rateLimitedError } from '@/lib/errors';

export const ASSESSMENT_RESPONSE_RATE_LIMIT_ID = 'assessment-response';

/**
 * Applies the distributed Vercel Firewall limit only in deployed production
 * builds. Local development and test runs remain unrestricted. If the
 * firewall check itself is unavailable, the request is allowed through and
 * the failure is recorded so a security dependency cannot lock out a valid
 * participant.
 */
export async function enforceAssessmentResponseRateLimit(request: Request) {
  if (process.env.NODE_ENV !== 'production') return;

  let rateLimited = false;
  try {
    ({ rateLimited } = await checkRateLimit(ASSESSMENT_RESPONSE_RATE_LIMIT_ID, { request }));
  } catch (error) {
    logError('http.rateLimit.assessmentResponse', error);
    return;
  }

  if (rateLimited) {
    throw rateLimitedError('Too many assessment submissions. Please wait briefly and try again.');
  }
}
