import type { NextResponse } from 'next/server';

export const ORGANIZATION_COOKIE = 'le_organization_id';
export const ENGAGEMENT_COOKIE = 'le_engagement_id';
export const FIXTURE_ROLE_COOKIE = 'le_fixture_role';

export function portalCookieOptions() {
  return { httpOnly: true, sameSite: 'lax' as const, path: '/', secure: process.env.NODE_ENV === 'production' };
}

export function setEngagementContextCookies(
  response: NextResponse,
  context: { organizationId: string; engagementId: string },
) {
  const options = portalCookieOptions();
  response.cookies.set(ORGANIZATION_COOKIE, context.organizationId, options);
  response.cookies.set(ENGAGEMENT_COOKIE, context.engagementId, options);
  return response;
}
