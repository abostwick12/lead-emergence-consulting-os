/**
 * Resolves the origin used inside emailed invitation and assessment links.
 * `APP_ORIGIN` is preferred because a request origin is derived from the
 * client-supplied Host header and can therefore be forged into link targets.
 */
export function resolveTrustedOrigin(requestOrigin: string): string {
  const configured = process.env.APP_ORIGIN;
  if (configured) {
    try {
      const parsed = new URL(configured);
      if (parsed.protocol === 'https:' || parsed.protocol === 'http:') return parsed.origin;
    } catch {
      // Fall through to the request origin when APP_ORIGIN is malformed.
    }
  }
  return requestOrigin;
}
