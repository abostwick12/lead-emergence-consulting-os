import { validationError } from '@/lib/errors';
import type { GroundedGenerationResult, MeridianMutation, MeridianSource, MeridianSuggestion, MeridianTask } from './types';

const forbiddenTasks = new Set(['VALIDATE_INSIGHT', 'VALIDATE_DIAGNOSIS', 'MAKE_DECISION']);
const permittedVisibility = new Set(['LEADERSHIP_RESTRICTED', 'ENGAGEMENT_SHARED', 'ORGANIZATION_SHARED']);

export function filterAuthorizedSources(candidates: MeridianSource[], authorizedSourceIds: ReadonlySet<string>) {
  return candidates.filter((source) => authorizedSourceIds.has(source.id) && permittedVisibility.has(source.visibility));
}

export function generateGroundedPattern(sources: MeridianSource[], authorizedSourceIds: ReadonlySet<string>, id = 'meridian-pattern-generated'): GroundedGenerationResult {
  // Authorization is deliberately resolved before any relevance ordering or synthesis.
  const eligible = filterAuthorizedSources(sources, authorizedSourceIds);
  const supporting = eligible.filter((source) => source.role === 'SUPPORTING');
  const challenging = eligible.filter((source) => source.role === 'CHALLENGING');
  if (supporting.length < 2 || challenging.length < 1) return {
    status: 'INSUFFICIENT_EVIDENCE',
    limitation: 'Insufficient permission-eligible evidence: a Pattern suggestion needs at least two supporting sources and one contrary source.',
  };
  return { status: 'COMPLETED', suggestion: {
    id, task: 'SUGGEST_PATTERN', title: 'Authority continues to concentrate at escalation points',
    statement: 'Routine decisions appear to move upward when boundary language is ambiguous, even where team capability is present.',
    scope: 'Three permission-eligible workflow and interview sources in the active engagement.',
    recurrenceBasis: `${supporting.length} supporting sources across different evidence contexts; ${challenging.length} contrary source retained.`,
    limitations: 'This is a reviewable Pattern suggestion, not a diagnosis. The sample is bounded to the active engagement.',
    origin: 'AI', reviewState: 'SUGGESTED', sources: [...supporting, ...challenging], generatedLabel: 'Generated now',
  } };
}

export function assertPermittedTask(task: string): asserts task is MeridianTask {
  if (forbiddenTasks.has(task)) throw validationError('Meridian cannot validate an Insight or Diagnosis or make a Decision.');
  if (!['SUGGEST_PATTERN', 'SUGGEST_INTERPRETATION', 'MEETING_PREPARATION'].includes(task)) throw validationError('The Meridian task is not supported.');
}

export function rejectSuggestion(suggestion: MeridianSuggestion, rationale: string): MeridianSuggestion {
  if (!rationale.trim()) throw validationError('A rejection rationale is required so the review history remains reconstructable.');
  return { ...suggestion, reviewState: 'REJECTED', reviewRationale: rationale.trim() };
}

export function validateMeridianMutation(value: unknown): MeridianMutation {
  if (!value || typeof value !== 'object') throw validationError('A Meridian review action is required.');
  const input = value as Record<string, unknown>;
  if (typeof input.action === 'string' && forbiddenTasks.has(input.action)) throw validationError('Meridian cannot validate an Insight or Diagnosis or make a Decision.');
  if (input.action === 'GENERATE_PATTERN') {
    const sourceIds = Array.isArray(input.sourceIds) ? input.sourceIds.filter((item): item is string => typeof item === 'string' && item.length > 0) : [];
    return { action: 'GENERATE_PATTERN', sourceIds };
  }
  if (input.action === 'REJECT_SUGGESTION') return { action: 'REJECT_SUGGESTION', suggestionId: requiredString(input, 'suggestionId'), rationale: requiredString(input, 'rationale') };
  throw validationError('The Meridian review action is not supported.');
}

function requiredString(input: Record<string, unknown>, key: string) {
  const value = input[key];
  if (typeof value !== 'string' || !value.trim()) throw validationError(`${key} is required.`);
  return value.trim();
}
