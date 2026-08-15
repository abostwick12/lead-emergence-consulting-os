import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { validationError } from '@/lib/errors';
import { readJsonBody } from '@/lib/http/json';
import { enforceAssessmentResponseRateLimit } from '@/lib/http/rate-limit';
import { submitParticipantAssessment } from '@/lib/access/assessment';

export async function POST(request: Request) {
  try {
    await enforceAssessmentResponseRateLimit(request);
    const body = await readJsonBody(request);
    const input = (body && typeof body === 'object' && !Array.isArray(body) ? body : {}) as Record<string, unknown>;
    if (typeof input.token !== 'string' || typeof input.itemId !== 'string' || (typeof input.value !== 'string' && typeof input.value !== 'number')) {
      throw validationError('A complete assessment response is required.');
    }
    return NextResponse.json(await submitParticipantAssessment(input.token, input.itemId, input.value), { status: 201 });
  } catch (error) {
    return apiErrorResponse('api.assessmentResponse', error, 'Response could not be submitted.');
  }
}
