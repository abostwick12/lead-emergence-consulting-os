import { jsonRoute } from '@/lib/http/json-route';
import { submitParticipantAssessment } from '@/lib/access/assessment';

export async function POST(request: Request) {
  return jsonRoute('Response could not be submitted.', async () => {
    const input = await request.json();
    if (typeof input.token !== 'string' || typeof input.itemId !== 'string' || (typeof input.value !== 'string' && typeof input.value !== 'number')) throw new Error('A complete assessment response is required.');
    return submitParticipantAssessment(input.token, input.itemId, input.value);
  }, 201);
}
