import { jsonRoute } from '@/lib/http/json-route';
import { requirePortalRole } from '@/lib/portal/context';
import { mutateDiscoveryIntake } from '@/lib/discovery/repository';
import { validateDiscoveryMutation } from '@/lib/discovery/workflow';

export async function POST(request: Request) {
  return jsonRoute('Discovery intake could not be saved.', async () => {
    const session = await requirePortalRole('consultant');
    return mutateDiscoveryIntake(session, validateDiscoveryMutation(await request.json()));
  });
}
