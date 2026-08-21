import 'server-only';

import type { User } from '@supabase/supabase-js';
import { createSupabaseAdminClient } from '@/lib/supabase/admin';
import { extractEntryProviderIdentity, requireEntryProviderIdentifier, type EntrySsoMode } from './entry-identity';

export async function persistEntryIdentity(user: User, mode: EntrySsoMode) {
  const identity = extractEntryProviderIdentity(user, requireEntryProviderIdentifier());
  const { data, error } = await createSupabaseAdminClient().rpc('link_entry_oidc_identity', {
    p_auth_user_id: identity.authUserId,
    p_canonical_user_id: identity.canonicalUserId,
    p_provider_identifier: identity.providerIdentifier,
    p_provider_subject: identity.canonicalUserId,
    p_provider_identity_id: identity.providerIdentityId,
    p_display_name: identity.displayName,
    p_existing_account_link: mode === 'link_existing',
  });
  if (error || !data) throw new Error('Entry identity could not be linked', { cause: error });
  return identity;
}
