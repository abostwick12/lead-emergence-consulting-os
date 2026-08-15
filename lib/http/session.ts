import 'server-only';

import { getPortalSession } from '@/lib/portal/context';
import { HttpError } from './json-route';

/** Any authenticated portal session, or a 401 for API callers. */
export async function requireApiSession(message: string) {
  const session = await getPortalSession();
  if (!session || session.role === 'outsider') throw new HttpError(message, 401);
  return session;
}

/** The assigned consultant session, or a 401 for API callers. */
export async function requireApiConsultant(message: string) {
  const session = await requireApiSession(message);
  if (session.role !== 'consultant') throw new HttpError(message, 401);
  return session;
}
