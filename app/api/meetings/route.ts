import { jsonRoute } from '@/lib/http/json-route';
import { requireApiSession } from '@/lib/http/session';
import { getMeetingCenter, mutateMeeting } from '@/lib/meetings/repository';
import { validateMeetingMutation } from '@/lib/meetings/workflow';

export async function GET() {
  return jsonRoute('Meeting data could not be loaded.', async () => {
    const session = await requireApiSession('Unauthorized');
    return getMeetingCenter(session);
  });
}

export async function POST(request: Request) {
  return jsonRoute('Meeting action could not be completed.', async () => {
    const session = await requireApiSession('Unauthorized');
    return mutateMeeting(session, validateMeetingMutation(await request.json()));
  });
}
