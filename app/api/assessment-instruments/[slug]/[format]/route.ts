import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requireApiRole } from '@/lib/api/session';
import { getAssessmentInstrument, type AssessmentInstrumentFormat } from '@/lib/operational-ai/assessment-instruments';
import { notFoundError } from '@/lib/errors';

const contentTypes: Record<AssessmentInstrumentFormat, string> = {
  docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  pdf: 'application/pdf',
};

export async function GET(request: Request, context: RouteContext<'/api/assessment-instruments/[slug]/[format]'>) {
  try {
    await requireApiRole('consultant');
    const { slug, format: rawFormat } = await context.params;
    if (rawFormat !== 'docx' && rawFormat !== 'pdf') throw notFoundError('Assessment format was not found.');
    const format: AssessmentInstrumentFormat = rawFormat;
    const instrument = getAssessmentInstrument(slug);
    if (!instrument) throw notFoundError('Assessment instrument was not found.');

    const filename = instrument.files[format].split('/').at(-1);
    if (!filename) throw notFoundError('Assessment file was not found.');
    const file = await readFile(join(process.cwd(), 'assets', 'assessments', filename));
    const download = format === 'docx' || new URL(request.url).searchParams.get('download') === '1';
    const downloadFilename = `${instrument.slug}.${format}`;
    return new NextResponse(file, {
      headers: {
        'Cache-Control': 'private, no-store, max-age=0',
        'Content-Disposition': `${download ? 'attachment' : 'inline'}; filename="${downloadFilename}"`,
        'Content-Length': String(file.byteLength),
        'Content-Type': contentTypes[format],
        'X-Content-Type-Options': 'nosniff',
      },
    });
  } catch (error) {
    return apiErrorResponse('api.assessmentInstruments', error, 'The assessment instrument could not be opened.');
  }
}
