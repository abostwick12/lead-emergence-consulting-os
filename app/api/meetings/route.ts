import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { getPortalSession } from '@/lib/portal/context';
import { getMeetingCenter, mutateMeeting } from '@/lib/meetings/repository';
import { validateMeetingMutation } from '@/lib/meetings/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function GET() {
  const session = await getPortalSession();
  if (!session || session.role === 'outsider') return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  try {
    return NextResponse.json(await getMeetingCenter(session));
  } catch (error) {
    return apiErrorResponse('api.meetings.get', error, 'Meeting data could not be loaded.');
  }
}

export async function POST(request: Request) {
  const session = await getPortalSession();
  if (!session || session.role === 'outsider') return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  try {
    const mutation = validateMeetingMutation(await readJsonBody(request));
    return NextResponse.json(await mutateMeeting(session, mutation));
  } catch (error) {
    return apiErrorResponse('api.meetings.post', error, 'Meeting action could not be completed.');
  }
}
