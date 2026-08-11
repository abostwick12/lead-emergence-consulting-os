import { describe, expect, it } from 'vitest';
import { assertPermittedTask, filterAuthorizedSources, generateGroundedPattern, rejectSuggestion } from './workflow';
import type { MeridianSource, MeridianSuggestion } from './types';

const sources: MeridianSource[] = [
  { id: 'a', fragmentId: 'fa', title: 'A', locator: '1', excerpt: 'A', role: 'SUPPORTING', visibility: 'ENGAGEMENT_SHARED' },
  { id: 'b', fragmentId: 'fb', title: 'B', locator: '2', excerpt: 'B', role: 'SUPPORTING', visibility: 'ORGANIZATION_SHARED' },
  { id: 'c', fragmentId: 'fc', title: 'C', locator: '3', excerpt: 'C', role: 'CHALLENGING', visibility: 'LEADERSHIP_RESTRICTED' },
  { id: 'private', fragmentId: 'fp', title: 'Private', locator: '4', excerpt: 'Private', role: 'SUPPORTING', visibility: 'CONSULTANT_PRIVATE' as never },
];

describe('Meridian grounded assistance', () => {
  it('filters authorization and privacy before synthesis', () => {
    expect(filterAuthorizedSources(sources, new Set(['a', 'b', 'c', 'private']))).toHaveLength(3);
    expect(filterAuthorizedSources(sources, new Set(['a', 'c'])).map((source) => source.id)).toEqual(['a', 'c']);
  });
  it('states insufficient evidence instead of inventing a substitute', () => expect(generateGroundedPattern(sources, new Set(['a', 'c']))).toEqual(expect.objectContaining({ status: 'INSUFFICIENT_EVIDENCE' })));
  it('preserves supporting and contrary citations on a suggestion', () => {
    const result = generateGroundedPattern(sources, new Set(['a', 'b', 'c']));
    expect(result.suggestion).toEqual(expect.objectContaining({ origin: 'AI', reviewState: 'SUGGESTED' }));
    expect(result.suggestion?.sources.map((source) => source.role)).toEqual(['SUPPORTING', 'SUPPORTING', 'CHALLENGING']);
  });
  it('rejects authoritative AI tasks', () => expect(() => assertPermittedTask('MAKE_DECISION')).toThrow(/cannot validate.*make a Decision/i));
  it('preserves a rejected suggestion with rationale', () => {
    const suggestion = generateGroundedPattern(sources, new Set(['a', 'b', 'c'])).suggestion as MeridianSuggestion;
    expect(rejectSuggestion(suggestion, 'Contrary source changes the recurrence claim.')).toEqual(expect.objectContaining({ reviewState: 'REJECTED', reviewRationale: expect.stringContaining('Contrary') }));
  });
});
