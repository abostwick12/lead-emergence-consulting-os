import { jsonRoute } from '@/lib/http/json-route';
import { requirePortalRole } from '@/lib/portal/context';
import { saveMinistryHandoff } from '@/lib/handoff/repository';
import { validateMinistryHandoff } from '@/lib/handoff/workflow';

export async function POST(request: Request) {
  return jsonRoute('Ministry handoff could not be saved.', async () => {
    const session = await requirePortalRole('consultant');
    return saveMinistryHandoff(session, validateMinistryHandoff(await request.json()));
  });
}
