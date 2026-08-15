import { beforeEach, describe, expect, it } from 'vitest';
import { fixtureSession } from '../portal/fixtures';
import { fixtureMeridianAi, fixtureMeridianSources, mutateFixtureMeridianAi, resetMeridianAiFixtures } from './fixtures';

const consultant = () => fixtureSession('consultant')!;

describe('meridian AI fixture projections', () => {
  beforeEach(() => {
    resetMeridianAiFixtures();
  });

  it('presents the seeded suggestion as reviewable rather than validated', () => {
    const data = fixtureMeridianAi(consultant());
    expect(data.suggestions).toHaveLength(1);
    expect(data.suggestions[0].reviewState).toBe('SUGGESTED');
    expect(data.suggestions[0].origin).toBe('AI');
    expect(data.rejectedSuggestions).toHaveLength(0);
    expect(data.availableSourceCount).toBe(fixtureMeridianSources.length);
  });

  it('grounds the meeting preparation brief in shared sources only', () => {
    const preparation = fixtureMeridianAi(consultant()).meetingPreparation;
    expect(preparation.sources).toHaveLength(fixtureMeridianSources.length);
    expect(preparation.limitations).toContain('No private coaching notes');
    expect(preparation.questions.length).toBeGreaterThan(0);
  });

  it('generates a grounded pattern from supporting and contrary sources', () => {
    const data = mutateFixtureMeridianAi(consultant(), {
      action: 'GENERATE_PATTERN',
      sourceIds: fixtureMeridianSources.map((source) => source.id),
    });
    expect(data.suggestions).toHaveLength(2);
    const generated = data.suggestions[1];
    expect(generated.reviewState).toBe('SUGGESTED');
    expect(generated.recurrenceBasis).toContain('2 supporting sources');
    expect(generated.sources.some((source) => source.role === 'CHALLENGING')).toBe(true);
  });

  it('refuses to generate a pattern without a contrary source', () => {
    expect(() => mutateFixtureMeridianAi(consultant(), {
      action: 'GENERATE_PATTERN',
      sourceIds: fixtureMeridianSources.filter((source) => source.role === 'SUPPORTING').map((source) => source.id),
    })).toThrow('Insufficient permission-eligible evidence');
  });

  it('moves a rejected suggestion into the review history with its rationale', () => {
    const suggestionId = fixtureMeridianAi(consultant()).suggestions[0].id;
    const data = mutateFixtureMeridianAi(consultant(), {
      action: 'REJECT_SUGGESTION', suggestionId, rationale: 'The scope conflates two distinct workflows.',
    });
    expect(data.suggestions).toHaveLength(0);
    expect(data.rejectedSuggestions[0].reviewState).toBe('REJECTED');
    expect(data.rejectedSuggestions[0].reviewRationale).toBe('The scope conflates two distinct workflows.');
  });

  it('rejects a review action against an inactive suggestion', () => {
    expect(() => mutateFixtureMeridianAi(consultant(), {
      action: 'REJECT_SUGGESTION', suggestionId: 'meridian-pattern-missing', rationale: 'Not applicable.',
    })).toThrow('The suggestion is not active in the current permission context.');
  });

  it('restores the seeded suggestion on reset', () => {
    mutateFixtureMeridianAi(consultant(), {
      action: 'REJECT_SUGGESTION', suggestionId: 'meridian-pattern-authority', rationale: 'Temporary rejection.',
    });
    resetMeridianAiFixtures();
    expect(fixtureMeridianAi(consultant()).suggestions).toHaveLength(1);
  });
});
