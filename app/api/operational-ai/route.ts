import { jsonRoute } from '@/lib/http/json-route';
import { requirePortalRole } from '@/lib/portal/context';
import { mutateOperationalEngagement } from '@/lib/operational-ai/repository';
import { validateOperationalMutation } from '@/lib/operational-ai/workflow';

export async function POST(request: Request) {
  return jsonRoute('The workspace could not be updated.', async () => {
    const session = await requirePortalRole('consultant');
    return mutateOperationalEngagement(session, validateOperationalMutation(await request.json()));
  });
}
