import { describe, expect, it } from 'vitest';
import { readJsonBody } from './json';

function request(body: string, contentLength?: number) {
  return new Request('http://localhost/api/test', {
    method: 'POST',
    headers: contentLength === undefined ? undefined : { 'content-length': String(contentLength) },
    body,
  });
}

describe('readJsonBody', () => {
  it('parses a bounded JSON body', async () => {
    await expect(readJsonBody(request('{"action":"ADD_PRODUCT"}'))).resolves.toEqual({ action: 'ADD_PRODUCT' });
  });

  it('rejects a body above the byte ceiling', async () => {
    await expect(readJsonBody(request(JSON.stringify({ answer: 'x'.repeat(200) }), undefined), 64)).rejects.toThrow('The request payload is too large.');
  });

  it('rejects an oversized declared content length without reading the body', async () => {
    await expect(readJsonBody(request('{}', 1_000_000), 64)).rejects.toThrow('The request payload is too large.');
  });

  it('rejects malformed JSON with a client-safe message', async () => {
    await expect(readJsonBody(request('{'))).rejects.toThrow('The request body must be valid JSON.');
  });
});
