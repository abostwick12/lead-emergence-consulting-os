import { jsonRoute } from '@/lib/http/json-route';
import { requireApiConsultant } from '@/lib/http/session';
import { mutateOutcomesNewReality } from '@/lib/outcomes/repository';
import { validateOutcomesMutation } from '@/lib/outcomes/workflow';

export async function POST(request: Request) {
  return jsonRoute('The outcome workflow could not be advanced.', async () => {
    const session = await requireApiConsultant('Assigned consultant authorization is required.');
    return mutateOutcomesNewReality(session, validateOutcomesMutation(await request.json()));
  });
}
