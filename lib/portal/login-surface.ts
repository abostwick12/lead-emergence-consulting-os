export type LoginSurface = 'entry-redirect' | 'entry-error' | 'legacy' | 'fixture';

export function resolveLoginSurface({
  fixture,
  hasError,
  legacy,
}: {
  fixture: boolean;
  hasError: boolean;
  legacy: boolean;
}): LoginSurface {
  if (fixture) return 'fixture';
  if (legacy) return 'legacy';
  if (hasError) return 'entry-error';
  return 'entry-redirect';
}
