import type { OperationalEngagementData } from './types';

export const SEVENTH_SOS_ORGANIZATION_ID = '70000000-0000-4000-8000-000000000007';
export const SEVENTH_SOS_ENGAGEMENT_ID = '71000000-0000-4000-8000-000000000007';

const initialData: OperationalEngagementData = {
  organizationId: SEVENTH_SOS_ORGANIZATION_ID, engagementId: SEVENTH_SOS_ENGAGEMENT_ID,
  organizationName: '7th Special Operations Squadron', engagementName: 'Operational Product AI Transformation', engagementType: 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION',
  objective: 'Assess how operational products are created, reviewed, and improved, then identify bounded opportunities for responsible AI assistance.',
  scopeStatement: 'Consulting analysis of sanitized product-development workflows, human judgment, evidence quality, and sustainable operating rhythm. This workspace is not a mission-planning system.',
  ownerLabel: 'Lead Emergence Consulting', handlingLabel: 'Internal — Sanitized Only', currentStage: 'SEE REALITY', targetCompletion: '2026-10-30',
  handlingNotice: 'Enter only information authorized for this environment. Do not enter classified, CUI, SECRET, NOFORN, mission, target, coordinate, frequency, callsign, intelligence, or operational timeline data.',
  products: [
    { id: 'product-1', name: 'Mission Planning and Analysis Toolkit', description: 'Sanitized planning-support product used to structure analysis and human review.', ownerLabel: 'Product owner to confirm', status: 'ACTIVE', handlingLabel: 'Internal — Sanitized Only', responses: [] },
    { id: 'product-2', name: 'Operational Briefing Package', description: 'Sanitized briefing-product workflow, from source collection through quality review.', ownerLabel: 'Product owner to confirm', status: 'ACTIVE', handlingLabel: 'Internal — Sanitized Only', responses: [] },
    { id: 'product-3', name: 'Mission Rehearsal Support Package', description: 'Sanitized support-product workflow assessed only at the process and capability level.', ownerLabel: 'Product owner to confirm', status: 'ACTIVE', handlingLabel: 'Internal — Sanitized Only', responses: [] },
  ],
  audits: [
    { id: 'audit-1', productId: 'product-1', title: 'Product owner written audit', respondentLabel: 'Product owner', dueOn: '2026-08-28', status: 'NOT_STARTED', completedResponses: 0, totalPrompts: 12, responses: [] },
    { id: 'audit-2', productId: 'product-2', title: 'Analyst written audit', respondentLabel: 'Primary analyst', dueOn: '2026-08-28', status: 'NOT_STARTED', completedResponses: 0, totalPrompts: 12, responses: [] },
    { id: 'audit-3', productId: 'product-3', title: 'Reviewer written audit', respondentLabel: 'Quality reviewer', dueOn: '2026-09-02', status: 'NOT_STARTED', completedResponses: 0, totalPrompts: 10, responses: [] },
  ],
  interviews: [
    { id: 'interview-1', productId: 'product-1', participantLabel: 'Product owner', interviewType: 'PRODUCT_OWNER', objective: 'Understand purpose, users, quality criteria, bottlenecks, and required human judgment.', scheduledFor: '2026-09-03T14:00:00-05:00', status: 'PLANNED', notesCount: 0, responses: [] },
    { id: 'interview-2', productId: 'product-2', participantLabel: 'Primary analyst', interviewType: 'ANALYST', objective: 'Map actual work, sources, handoffs, rework, tool use, and verification practice.', scheduledFor: '2026-09-04T14:00:00-05:00', status: 'PLANNED', notesCount: 0, responses: [] },
  ],
  workflows: [{ id: 'workflow-1', productId: 'product-2', name: 'Current-state product preparation', purpose: 'Map the sanitized flow of work from task receipt through authorized release.', status: 'DRAFT', steps: [
    { id: 'step-1', sequence: 1, name: 'Receive task and constraints', ownerLabel: 'Analyst', systemTool: 'Approved work environment', inputs: 'Authorized tasking and sanitized source references', outputs: 'Clarified product intent', durationMinutes: 30, waitMinutes: 0, reworkRisk: 'MEDIUM', judgmentRequired: 'Confirm scope, audience, and missing information.', verificationRequired: 'Human scope check', aiSuitability: 'NOT_ASSESSED' },
    { id: 'step-2', sequence: 2, name: 'Assemble and analyze sources', ownerLabel: 'Analyst', systemTool: 'Approved analysis tools', inputs: 'Authorized sanitized sources', outputs: 'Working analysis and traceable notes', durationMinutes: 180, waitMinutes: 45, reworkRisk: 'HIGH', judgmentRequired: 'Evaluate relevance, reliability, and ambiguity.', verificationRequired: 'Source traceability review', aiSuitability: 'NOT_ASSESSED' },
    { id: 'step-3', sequence: 3, name: 'Review and revise product', ownerLabel: 'Reviewer', systemTool: 'Approved review channel', inputs: 'Draft product and cited source list', outputs: 'Reviewed product and correction record', durationMinutes: 60, waitMinutes: 120, reworkRisk: 'HIGH', judgmentRequired: 'Apply quality criteria and challenge unsupported claims.', verificationRequired: 'Named human approval', aiSuitability: 'HUMAN_ONLY' },
  ]}],
  evidence: [{ id: 'evidence-1', productId: 'product-2', title: 'Initial workflow walkthrough', sourceType: 'OBSERVATION', observation: 'The current process has multiple human judgment and verification points that must remain explicit before any AI opportunity is considered.', sourceLocator: 'Consultant kickoff notes — sanitized process summary', visibility: 'CONSULTANT_PRIVATE', status: 'CAPTURED' }],
  requests: [
    { id: 'request-1', title: 'Current product template', productId: 'product-1', requestedFrom: 'Product owner', requestedOn: '2026-08-14', dueOn: '2026-08-25', status: 'REQUESTED', handlingNote: 'Sanitized structure only; no operational content.' },
    { id: 'request-2', title: 'Quality-review checklist', productId: 'product-2', requestedFrom: 'Quality reviewer', requestedOn: '2026-08-14', dueOn: '2026-08-25', status: 'REQUESTED', handlingNote: 'Authorized, sanitized checklist or summary.' },
  ],
  actions: [
    { id: 'action-1', title: 'Confirm product owners and interview participants', ownerLabel: 'Consultant', dueOn: '2026-08-21', status: 'OPEN', visibility: 'CONSULTANT_PRIVATE' },
    { id: 'action-2', title: 'Confirm approved information-handling process', ownerLabel: 'Client sponsor', dueOn: '2026-08-21', status: 'OPEN', visibility: 'ENGAGEMENT_SHARED' },
  ],
};

declare global { var __leOperationalAiFixture: OperationalEngagementData | undefined }
export function fixtureOperationalEngagement(): OperationalEngagementData { globalThis.__leOperationalAiFixture ??= structuredClone(initialData); return structuredClone(globalThis.__leOperationalAiFixture) }
export function updateFixtureOperationalEngagement(updater: (current: OperationalEngagementData) => OperationalEngagementData) { globalThis.__leOperationalAiFixture = updater(fixtureOperationalEngagement()); return fixtureOperationalEngagement() }
export function resetOperationalFixtures() { globalThis.__leOperationalAiFixture = structuredClone(initialData) }
