import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requireApiSession } from '@/lib/api/session';
import { getMeetingCenter, mutateMeeting } from '@/lib/meetings/repository';
import { validateMeetingMutation } from '@/lib/meetings/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function GET() {
  try {
    const session = await requireApiSession();
    return NextResponse.json(await getMeetingCenter(session));
  } catch (error) {
    return apiErrorResponse('api.meetings.get', error, 'Meeting data could not be loaded.');
  }
}

export async function POST(request: Request) {
  try {
    const session = await requireApiSession();
    const mutation = validateMeetingMutation(await readJsonBody(request));
    return NextResponse.json(await mutateMeeting(session, mutation));
  } catch (error) {
    return apiErrorResponse('api.meetings.post', error, 'Meeting action could not be completed.');
  }
}
