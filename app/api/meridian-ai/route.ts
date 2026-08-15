import { jsonRoute } from '@/lib/http/json-route';
import { requireApiConsultant } from '@/lib/http/session';
import { mutateMeridianAi } from '@/lib/meridian-ai/repository';
import { validateMeridianMutation } from '@/lib/meridian-ai/workflow';

export async function POST(request: Request) {
  return jsonRoute('Meridian could not complete the grounded request.', async () => {
    const session = await requireApiConsultant('An assigned consultant session is required.');
    return mutateMeridianAi(session, validateMeridianMutation(await request.json()));
  });
}
