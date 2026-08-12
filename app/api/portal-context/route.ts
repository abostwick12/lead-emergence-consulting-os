import { NextResponse, type NextRequest } from 'next/server';
import { requirePortalRole } from '@/lib/portal/context';
import { safeReturnPath } from '@/lib/portal/navigation';

export async function GET(request: NextRequest) {
  const session = await requirePortalRole('consultant');
  const organizationId = request.nextUrl.searchParams.get('organizationId');
  if (!organizationId || !session.organizations.some((item) => item.id === organizationId)) return new NextResponse('Organization not available', { status: 404 });
  const engagementId = request.nextUrl.searchParams.get('engagementId') ?? session.engagements.find((item) => item.organizationId === organizationId)?.id;
  if (!engagementId || !session.engagements.some((item) => item.id === engagementId && item.organizationId === organizationId)) return new NextResponse('Engagement not available', { status: 404 });
  const returnTo = safeReturnPath(request.nextUrl.searchParams.get('returnTo'));
  const response = NextResponse.redirect(new URL(returnTo === '/' ? `/consultant/clients/${organizationId}/overview` : returnTo, request.url));
  const options = { httpOnly: true, sameSite: 'lax' as const, path: '/', secure: process.env.NODE_ENV === 'production' };
  response.cookies.set('le_organization_id', organizationId, options);
  response.cookies.set('le_engagement_id', engagementId, options);
  return response;
}
