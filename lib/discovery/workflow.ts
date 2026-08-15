import { validationError } from '@/lib/errors';
import type { AssessmentConfidentiality, DiscoveryMutation, EvidenceSourceType } from './types';

const evidenceTypes: EvidenceSourceType[] = ['UPLOADED_DOCUMENT', 'METRIC_SYSTEM', 'CONSULTANT_OBSERVATION', 'CLIENT_STATEMENT', 'OTHER'];
const confidentialityValues: AssessmentConfidentiality[] = ['IDENTIFIED', 'CONFIDENTIAL', 'ANONYMOUS'];

export function validateDiscoveryMutation(value: unknown): DiscoveryMutation {
  if (!value || typeof value !== 'object') throw validationError('A discovery intake action is required.');
  const input = value as Record<string, unknown>;
  const required = (key: string) => { const field = input[key]; if (typeof field !== 'string' || !field.trim()) throw validationError(`${key} is required.`); return field.trim(); };
  if (input.action === 'CAPTURE_EVIDENCE') {
    const sourceType = required('sourceType') as EvidenceSourceType; if (!evidenceTypes.includes(sourceType)) throw validationError('Evidence source type is invalid.');
    return { action: input.action, sourceType, title: required('title'), provenanceContext: required('provenanceContext'), content: required('content'), relevanceNote: required('relevanceNote'), limitations: typeof input.limitations === 'string' ? input.limitations.trim() : '' };
  }
  if (input.action === 'RECORD_INTERVIEW') return { action: input.action, participantLabel: required('participantLabel'), guideName: required('guideName'), question: required('question'), response: required('response'), consentRecorded: input.consentRecorded === true };
  if (input.action === 'CREATE_ASSESSMENT') {
    const confidentiality = required('confidentiality') as AssessmentConfidentiality; if (!confidentialityValues.includes(confidentiality)) throw validationError('Assessment confidentiality is invalid.');
    return { action: input.action, name: required('name'), dimension: required('dimension'), prompt: required('prompt'), audience: required('audience'), opensAt: required('opensAt'), closesAt: required('closesAt'), confidentiality };
  }
  throw validationError('The discovery intake action is not supported.');
}
