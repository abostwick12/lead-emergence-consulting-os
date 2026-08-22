import type { User } from '@supabase/supabase-js';

const ENTRY_SSO_MODE_COOKIE_PREFIX = 'le_entry_sso_mode_';
export type EntrySsoMode = 'sign_in' | 'link_existing';

const CALLBACK_SEGMENTS: Record<EntrySsoMode, string> = {
  sign_in: 'sign-in',
  link_existing: 'link-existing',
};

export function entrySsoCallbackPath(mode: EntrySsoMode) {
  return `/auth/callback/${CALLBACK_SEGMENTS[mode]}`;
}

export function entrySsoModeFromCallback(value: string | null | undefined): EntrySsoMode | null {
  return value === CALLBACK_SEGMENTS.sign_in
    ? 'sign_in'
    : value === CALLBACK_SEGMENTS.link_existing
      ? 'link_existing'
      : null;
}

export function entrySsoModeCookieName(mode: EntrySsoMode) {
  return `${ENTRY_SSO_MODE_COOKIE_PREFIX}${CALLBACK_SEGMENTS[mode]}`;
}

export function entrySsoModeCookieOptions(mode: EntrySsoMode) {
  return {
    httpOnly: true,
    sameSite: 'lax' as const,
    secure: process.env.NODE_ENV === 'production',
    path: entrySsoCallbackPath(mode),
    maxAge: 600,
  };
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function requireEntryProviderIdentifier(value = process.env.ENTRY_OIDC_PROVIDER) {
  if (!value || !/^custom:[a-z0-9][a-z0-9:-]{1,49}$/.test(value)) {
    throw new Error('Entry identity provider is not configured');
  }
  return value;
}

export function extractEntryProviderIdentity(user: User, providerIdentifier: string) {
  const matches = (user.identities ?? []).filter((identity) => identity.provider === providerIdentifier);
  if (matches.length !== 1) throw new Error('A single verified Entry provider identity is required');

  const identity = matches[0];
  const identityData = identity.identity_data as Record<string, unknown>;
  const subject = identityData.sub;
  if (typeof subject !== 'string' || !UUID.test(subject)) throw new Error('Entry provider subject is invalid');
  if (!UUID.test(identity.identity_id)) throw new Error('Provider identity identifier is invalid');
  if (identity.id !== subject) throw new Error('Provider identity subject does not match');

  const displayName = [identityData.name, identityData.full_name, identityData.preferred_username]
    .find((value): value is string => typeof value === 'string' && value.trim().length > 0)
    ?.trim()
    .slice(0, 200) ?? 'Lead Emergence member';

  return {
    authUserId: user.id,
    canonicalUserId: subject,
    providerIdentifier,
    providerIdentityId: identity.identity_id,
    displayName,
  };
}

export function isEntrySsoMode(value: string | undefined): value is EntrySsoMode {
  return value === 'sign_in' || value === 'link_existing';
}
