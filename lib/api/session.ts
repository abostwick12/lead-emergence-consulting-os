import 'server-only';

import { authenticationError, authorizationError } from '@/lib/errors';
import { getPortalSession } from '@/lib/portal/context';
import type { PortalRole } from '@/lib/portal/types';

export async function requireApiSession(message = 'Authentication is required.') {
  const session = await getPortalSession();
  if (!session || session.role === 'outsider') throw authenticationError(message);
  return session;
}

export async function requireApiRole(role: Exclude<PortalRole, 'outsider'>, message?: string) {
  const session = await requireApiSession();
  if (session.role !== role) throw authorizationError(message ?? `${role === 'consultant' ? 'Consultant' : 'Client'} authorization is required.`);
  return session;
}
