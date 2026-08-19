import { describe, expect, it } from 'vitest';
import { safeReturnPath } from './navigation';

describe('safe return paths', () => {
  it.each([
    [null, '/'],
    ['', '/'],
    ['https://attacker.example', '/'],
    ['//attacker.example', '/'],
    ['/\\attacker.example', '/'],
    ['/client\nheader:value', '/'],
    ['/client?focus=review', '/client?focus=review'],
    ['/consultant/clients/org-1', '/consultant/clients/org-1'],
    ['/oauth/consent?authorization_id=opaque%2Bvalue%3D%3D&provider=github', '/oauth/consent?authorization_id=opaque%2Bvalue%3D%3D&provider=github'],
    ['/oauth/consent?authorization_id=opaque&returnTo=https%3A%2F%2Fattacker.example', '/oauth/consent?authorization_id=opaque&returnTo=https%3A%2F%2Fattacker.example'],
  ])('maps %s to %s', (input, expected) => {
    expect(safeReturnPath(input)).toBe(expected);
  });
});
