import { describe, expect, it } from 'vitest';
import { resolveLoginSurface } from './login-surface';

describe('resolveLoginSurface', () => {
  it('sends the normal Consulting login route directly to Entry', () => {
    expect(resolveLoginSurface({ fixture: false, hasError: false, legacy: false })).toBe('entry-redirect');
  });

  it('renders a neutral interruption view instead of a second login after an Entry error', () => {
    expect(resolveLoginSurface({ fixture: false, hasError: true, legacy: false })).toBe('entry-error');
  });

  it('renders password access only when the rollback route is requested explicitly', () => {
    expect(resolveLoginSurface({ fixture: false, hasError: false, legacy: true })).toBe('legacy');
  });

  it('keeps local fixture access independent from hosted authentication', () => {
    expect(resolveLoginSurface({ fixture: true, hasError: false, legacy: false })).toBe('fixture');
  });
});
