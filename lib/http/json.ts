import { payloadTooLargeError, validationError } from '@/lib/errors';

export const MAX_JSON_BYTES = 64 * 1024;

/** Read and decode a JSON body without buffering beyond the configured limit. */
export async function readJsonBody(request: Request, maxBytes = MAX_JSON_BYTES): Promise<unknown> {
  const declared = request.headers.get('content-length');
  if (declared && /^\d+$/.test(declared) && Number(declared) > maxBytes) throw payloadTooLargeError();
  if (!request.body) throw validationError('The request body must be valid JSON.');

  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let total = 0;
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    total += value.byteLength;
    if (total > maxBytes) throw payloadTooLargeError();
    chunks.push(value);
  }

  const bytes = new Uint8Array(total);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.byteLength;
  }

  let text: string;
  try {
    text = new TextDecoder('utf-8', { fatal: true }).decode(bytes);
  } catch (cause) {
    throw validationError('The request body must contain valid UTF-8 JSON.', { cause });
  }
  try {
    return JSON.parse(text);
  } catch (cause) {
    throw validationError('The request body must be valid JSON.', { cause });
  }
}
