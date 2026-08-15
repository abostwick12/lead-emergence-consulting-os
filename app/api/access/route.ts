import { jsonRoute } from '@/lib/http/json-route';
import { requirePortalRole } from '@/lib/portal/context';
import { mutateAccess } from '@/lib/access/repository';
import { validateAccessMutation } from '@/lib/access/workflow';

export async function POST(request: Request) {
  return jsonRoute('Access action failed.', async () => {
    const session = await requirePortalRole('consultant');
    return mutateAccess(session, validateAccessMutation(await request.json()), new URL(request.url).origin);
  });
}
