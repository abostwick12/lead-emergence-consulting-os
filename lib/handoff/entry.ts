import 'server-only';

import { createRemoteJWKSet, jwtVerify } from 'jose';
import { z } from 'zod';

export const entryHandoffClaims = z.object({
  iss: z.string().url(),
  sub: z.string().uuid(),
  aud: z.literal('CONSULTING'),
  iat: z.number().int(),
  exp: z.number().int(),
  jti: z.string().uuid(),
}).strict();

export type EntryHandoffResult =
  | { status: 'LINKED'; canonicalUserId: string; consultingPersonId: string }
  | { status: 'NO_WORKSPACE'; canonicalUserId: string };

function entryIssuer() {
  const issuer = process.env.ENTRY_ISSUER;
  if (!issuer) throw new Error('ENTRY_ISSUER is not configured');
  return issuer;
}

function entryJwks() {
  const url = process.env.ENTRY_JWKS_URL;
  if (!url) throw new Error('ENTRY_JWKS_URL is not configured');
  return createRemoteJWKSet(new URL(url));
}

export async function verifyEntryHandoff(token: string) {
  const result = await jwtVerify(token, entryJwks(), {
    issuer: entryIssuer(),
    audience: 'CONSULTING',
    algorithms: ['RS256'],
    clockTolerance: 5,
  });
  return entryHandoffClaims.parse(result.payload);
}