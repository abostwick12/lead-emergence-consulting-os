export const loginErrors = {
  credentials: 'Unable to sign in with those credentials.',
  invitationInvalid: 'Invitation is invalid.',
  invitationNotActivated: 'Invitation could not be activated.',
  invitationNotVerified: 'Invitation could not be verified.',
} as const;

const allowed: readonly string[] = Object.values(loginErrors);

/**
 * Only renders sign-in errors this application produces, so an emailed
 * `?error=` value cannot place attacker-authored text on the login screen.
 */
export function safeLoginError(value: string | undefined): string | null {
  if (!value) return null;
  return allowed.includes(value) ? value : 'Sign-in could not be completed.';
}
