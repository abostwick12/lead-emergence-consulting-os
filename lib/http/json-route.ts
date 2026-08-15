import { NextResponse } from 'next/server';

export class HttpError extends Error {
  readonly status: number;

  constructor(message: string, status = 400) {
    super(message);
    this.name = 'HttpError';
    this.status = status;
  }
}

/**
 * Runs an API handler and serializes its result, turning any thrown error into a
 * JSON error body. `HttpError` carries its own status; everything else is 400.
 * Handlers may also return a `NextResponse` when they need to set cookies.
 */
export async function jsonRoute<T>(
  fallback: string,
  handler: () => Promise<T>,
  status?: number,
) {
  try {
    const result = await handler();
    return result instanceof NextResponse ? result : NextResponse.json(result, { status });
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : fallback },
      { status: error instanceof HttpError ? error.status : 400 },
    );
  }
}
