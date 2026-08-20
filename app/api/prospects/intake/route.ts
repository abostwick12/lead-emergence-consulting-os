import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { readJsonBody } from '@/lib/http/json';
import { createPublicProspect } from '@/lib/prospects/repository';
import { validatePublicIntake } from '@/lib/prospects/workflow';

export async function POST(request: Request) {
  try {
    const intake = validatePublicIntake(await readJsonBody(request));
    const prospect = await createPublicProspect({ ...intake, responses: intake.responses });
    return NextResponse.json({ id: prospect.id }, { status: 201 });
  } catch (error) {
    return apiErrorResponse('api.prospects.intake', error, 'Your intake could not be saved. Please try again.');
  }
}