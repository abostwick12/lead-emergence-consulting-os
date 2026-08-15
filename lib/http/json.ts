const MAX_JSON_BYTES = 64 * 1024;

/**
 * Reads a JSON request body with an upper size bound so a single request cannot
 * push unbounded text into the workspace or exhaust server memory.
 */
export async function readJsonBody(request: Request, maxBytes = MAX_JSON_BYTES): Promise<unknown> {
  const declaredLength = Number(request.headers.get('content-length') ?? Number.NaN);
  if (Number.isFinite(declaredLength) && declaredLength > maxBytes) throw new Error('The request payload is too large.');
  const body = await request.text();
  if (new TextEncoder().encode(body).length > maxBytes) throw new Error('The request payload is too large.');
  try {
    return JSON.parse(body);
  } catch {
    throw new Error('The request body must be valid JSON.');
  }
}
