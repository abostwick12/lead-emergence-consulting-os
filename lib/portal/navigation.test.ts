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
  ])('maps %s to %s', (input, expected) => {
    expect(safeReturnPath(input)).toBe(expected);
  });
});
