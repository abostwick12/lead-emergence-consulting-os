import { unavailableError } from '@/lib/errors';

/** Resolve an application-controlled origin for links that may be emailed. */
export function resolveTrustedOrigin(requestOrigin?: string): string {
  const configured = process.env.APP_ORIGIN;
  if (configured) {
    try {
      const parsed = new URL(configured);
      if (parsed.protocol === 'https:' || (process.env.NODE_ENV !== 'production' && parsed.protocol === 'http:')) return parsed.origin;
    } catch {
      // The safe configuration failure below deliberately hides the invalid value.
    }
    throw unavailableError('Secure invitation links are temporarily unavailable because the application origin is invalid.');
  }

  if (process.env.NODE_ENV !== 'production' && requestOrigin) {
    const parsed = new URL(requestOrigin);
    if (parsed.hostname === 'localhost' || parsed.hostname === '127.0.0.1') return parsed.origin;
  }
  throw unavailableError('Secure invitation links are temporarily unavailable because the application origin is not configured.');
}
