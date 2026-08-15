import { jsonRoute } from '@/lib/http/json-route';
import { requireApiSession } from '@/lib/http/session';
import { mutateAlignmentCapability } from '@/lib/alignment/repository';
import { validateAlignmentMutation } from '@/lib/alignment/workflow';

export async function POST(request: Request) {
  return jsonRoute('The change could not be saved.', async () => {
    const session = await requireApiSession('Authentication is required.');
    return mutateAlignmentCapability(session, validateAlignmentMutation(await request.json()));
  });
}
