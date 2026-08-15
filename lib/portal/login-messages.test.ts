import { describe, expect, it } from 'vitest';
import { loginErrors, safeLoginError } from './login-messages';

describe('safeLoginError', () => {
  it('renders application-produced messages', () => {
    expect(safeLoginError(loginErrors.credentials)).toBe(loginErrors.credentials);
  });

  it('replaces attacker-authored text with a fixed message', () => {
    expect(safeLoginError('Call 555-0100 to verify your account')).toBe('Sign-in could not be completed.');
  });

  it('renders nothing when no error is present', () => {
    expect(safeLoginError(undefined)).toBeNull();
  });
});
