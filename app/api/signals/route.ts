import { jsonRoute } from '@/lib/http/json-route';
import { requireApiConsultant } from '@/lib/http/session';
import { mutateSignalsWorkspace } from '@/lib/signals/repository';
import { validateSignalsMutation } from '@/lib/signals/workflow';

export async function POST(request: Request) {
  return jsonRoute('The Signals action could not be completed.', async () => {
    const session = await requireApiConsultant('Assigned consultant authorization is required.');
    return mutateSignalsWorkspace(session, validateSignalsMutation(await request.json()));
  });
}
