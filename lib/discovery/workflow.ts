import { objectInput } from '../validation/input';
import type { AssessmentConfidentiality, DiscoveryMutation, EvidenceSourceType } from './types';

const evidenceTypes: EvidenceSourceType[] = ['UPLOADED_DOCUMENT', 'METRIC_SYSTEM', 'CONSULTANT_OBSERVATION', 'CLIENT_STATEMENT', 'OTHER'];
const confidentialityValues: AssessmentConfidentiality[] = ['IDENTIFIED', 'CONFIDENTIAL', 'ANONYMOUS'];

export function validateDiscoveryMutation(value: unknown): DiscoveryMutation {
  const { raw: input, text, required, oneOf } = objectInput(value, 'A discovery intake action is required.');
  if (input.action === 'CAPTURE_EVIDENCE') {
    const sourceType = oneOf('sourceType', evidenceTypes, 'Evidence source type is invalid.');
    return { action: input.action, sourceType, title: required('title'), provenanceContext: required('provenanceContext'), content: required('content'), relevanceNote: required('relevanceNote'), limitations: text('limitations') };
  }
  if (input.action === 'RECORD_INTERVIEW') return { action: input.action, participantLabel: required('participantLabel'), guideName: required('guideName'), question: required('question'), response: required('response'), consentRecorded: input.consentRecorded === true };
  if (input.action === 'CREATE_ASSESSMENT') {
    const confidentiality = oneOf('confidentiality', confidentialityValues, 'Assessment confidentiality is invalid.');
    return { action: input.action, name: required('name'), dimension: required('dimension'), prompt: required('prompt'), audience: required('audience'), opensAt: required('opensAt'), closesAt: required('closesAt'), confidentiality };
  }
  throw new Error('The discovery intake action is not supported.');
}
