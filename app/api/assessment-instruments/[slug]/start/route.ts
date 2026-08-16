import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requireApiRole } from '@/lib/api/session';
import { startAssessmentAdministration } from '@/lib/operational-ai/assessment-administration';

export async function POST(_request: Request, { params }: { params: Promise<{ slug: string }> }) {
  try {
    const session = await requireApiRole('consultant');
    const { slug } = await params;
    return NextResponse.json(await startAssessmentAdministration(session, slug), { status: 201 });
  } catch (error) {
    return apiErrorResponse('api.assessmentInstruments.start', error, 'The guided assessment could not be started.');
  }
}
