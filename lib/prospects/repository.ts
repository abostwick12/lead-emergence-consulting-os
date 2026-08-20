import 'server-only';
import { addFixtureProspect, fixtureProspectCenter, mutateFixtureProspect } from './fixtures';
import type { ProspectMutation } from './types';

export async function getProspectCenter() { return fixtureProspectCenter(); }
export async function createPublicProspect(input: Parameters<typeof addFixtureProspect>[0]) { return addFixtureProspect(input); }
export async function mutateProspect(_personId: string, mutation: ProspectMutation) { return mutateFixtureProspect(mutation); }