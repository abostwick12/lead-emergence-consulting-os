import type { PortalSession } from '@/lib/portal/types';
import { createFixtureStore } from '../fixtures/store';
import { generateGroundedPattern, rejectSuggestion } from './workflow';
import type { MeridianAiData, MeridianMutation, MeridianSource, MeridianSuggestion } from './types';

interface MeridianFixtureStore { generated: MeridianSuggestion[]; rejected: MeridianSuggestion[] }
const fixtures = createFixtureStore<MeridianFixtureStore>('meridian-ai', () => ({ generated: [], rejected: [] }));
const store = fixtures.read;

export const fixtureMeridianSources: MeridianSource[] = [
  { id: 'source-interview-04', fragmentId: 'fragment-interview-04-12', title: 'Interview 04', locator: 'Excerpt 12', excerpt: 'Team leads described waiting for senior approval in routine exception cases.', role: 'SUPPORTING', visibility: 'ENGAGEMENT_SHARED' },
  { id: 'source-workflow-may', fragmentId: 'fragment-workflow-may-22', title: 'Approval workflow', locator: 'Rows 22–41', excerpt: 'Six of eight routine exceptions were escalated beyond the documented role owner.', role: 'SUPPORTING', visibility: 'ORGANIZATION_SHARED' },
  { id: 'source-leadership-review', fragmentId: 'fragment-leadership-review-3', title: 'Leadership review', locator: 'Note 3', excerpt: 'Two teams used explicit boundaries and resolved comparable exceptions without escalation.', role: 'CHALLENGING', visibility: 'LEADERSHIP_RESTRICTED' },
];

const initialSuggestion: MeridianSuggestion = {
  id: 'meridian-pattern-authority', task: 'SUGGEST_PATTERN', title: 'Authority repeatedly escalates upward',
  statement: 'Routine operational decisions are consistently routed to senior leaders across several workflows.',
  scope: 'Active engagement · scheduling, spending, and client exceptions.',
  recurrenceBasis: 'Two supporting sources across distinct contexts; one contrary case retained for review.',
  limitations: 'This may reflect unclear boundaries, risk tolerance, or sample bias. It is not a diagnosis.',
  origin: 'AI', reviewState: 'SUGGESTED', sources: fixtureMeridianSources, generatedLabel: 'Aug 9, 2026',
};

export function fixtureMeridianAi(session: PortalSession): MeridianAiData {
  const fixtureStore = store();
  const rejectedIds = new Set(fixtureStore.rejected.map((item) => item.id));
  return {
    organizationId: session.organization.id, engagementId: session.engagement.id, fixture: true,
    suggestions: [initialSuggestion, ...fixtureStore.generated].filter((item) => !rejectedIds.has(item.id)),
    rejectedSuggestions: fixtureStore.rejected,
    meetingPreparation: {
      meetingId: 'meeting-leadership-review', purpose: 'Prepare the leadership interpretation review without importing private coaching content.',
      summary: 'The shared evidence shows recurring upward escalation, alongside two cases where explicit boundaries enabled local decisions.',
      questions: ['Which decision categories truly require senior review?', 'What contrary evidence would change the current interpretation?', 'Which boundary can be tested without implying a diagnosis?'],
      limitations: 'Prepared only from the three permission-eligible shared sources shown below. No private coaching notes were searched or summarized.',
      sources: fixtureMeridianSources,
    },
    availableSourceCount: fixtureMeridianSources.length,
    guardrails: ['Permission filtering occurs before relevance ranking.', 'Every claim cites an exact source fragment.', 'Suggestions remain SUGGESTED until a human review.', 'Meridian cannot validate an Insight or Diagnosis or make a Decision.'],
  };
}

export function mutateFixtureMeridianAi(session: PortalSession, mutation: MeridianMutation): MeridianAiData {
  const fixtureStore = store();
  if (mutation.action === 'GENERATE_PATTERN') {
    const result = generateGroundedPattern(fixtureMeridianSources, new Set(mutation.sourceIds), `meridian-pattern-${fixtureStore.generated.length + 1}`);
    if (result.status === 'INSUFFICIENT_EVIDENCE') throw new Error(result.limitation);
    if (result.suggestion) fixtureStore.generated = [...fixtureStore.generated, result.suggestion];
  } else {
    const current = fixtureMeridianAi(session).suggestions.find((item) => item.id === mutation.suggestionId);
    if (!current) throw new Error('The suggestion is not active in the current permission context.');
    fixtureStore.rejected = [...fixtureStore.rejected, rejectSuggestion(current, mutation.rationale)];
  }
  return fixtureMeridianAi(session);
}

export function resetMeridianAiFixtures() { fixtures.reset(); }
