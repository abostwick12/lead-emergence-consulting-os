import { notFoundError } from '@/lib/errors';
import type { GuidedRecordKind, GuidedResponse, OperationalEngagementData } from './types';

export interface GuidedQuestion {
  id: string;
  section: string;
  prompt: string;
  guidance: string;
  placeholder: string;
}

export interface GuidedRecordSnapshot {
  kind: GuidedRecordKind;
  id: string;
  title: string;
  context: string;
  status: string;
  questions: GuidedQuestion[];
  responses: GuidedResponse[];
  completedCount: number;
  totalCount: number;
  nextQuestionId?: string;
  conversationBrief: string;
}

const productQuestions: GuidedQuestion[] = [
  question('product-purpose', 'Purpose', 'What purpose does this product serve, and who relies on it?', 'Describe the business or operational need without entering controlled content.', 'Purpose, audience, and the decision or activity it supports…'),
  question('product-owner', 'Ownership', 'Who owns the product and is accountable for its quality?', 'Use a role label when a person has not yet been confirmed.', 'Product owner or accountable role…'),
  question('product-producers', 'People', 'Who produces the product, and what roles contribute?', 'Name roles and teams rather than sensitive operational details.', 'Primary producers and contributors…'),
  question('product-reviewers', 'Governance', 'Who reviews and approves the product before release?', 'Separate reviewers from final approvers where those are different.', 'Reviewers, approvers, and release authority…'),
  question('product-rhythm', 'Operating rhythm', 'How often is it produced, and what turnaround is normally expected?', 'Capture frequency, lead time, and any recurring deadline pressure.', 'Frequency, typical turnaround, and timing constraints…'),
  question('product-sources', 'Inputs', 'What types of authorized source material are normally used?', 'Describe source categories only. Do not paste source content.', 'Source categories and input owners…'),
  question('product-output', 'Output', 'What form does the completed product take?', 'Include format, delivery channel, and any standard or template.', 'Output format, template, and authorized delivery channel…'),
  question('product-tools', 'Tools', 'What approved tools and systems support the work today?', 'Capture tool names and their purpose at a process level.', 'Current tools, systems, and handoffs between them…'),
  question('product-quality', 'Quality', 'What makes the product acceptable, useful, and ready to release?', 'State observable quality criteria and required human checks.', 'Quality criteria, verification, and approval checks…'),
  question('product-friction', 'Friction', 'Where does the work slow down, repeat, or require avoidable effort?', 'Describe bottlenecks, waiting, and common rework causes.', 'Pain points, delays, duplicate work, and rework…'),
  question('product-judgment', 'Human judgment', 'Which decisions require experience, context, or accountable human judgment?', 'Be explicit about work that should remain human-led.', 'Judgment points and why human review matters…'),
  question('product-opportunity', 'Improvement', 'What would a healthier, more sustainable production rhythm make possible?', 'Focus on desired operating conditions before proposing a technology solution.', 'Desired improvement, capacity, quality, and sustainability…'),
];

const auditQuestions: GuidedQuestion[] = [
  question('audit-context', 'Participant context', 'What is your role in creating, reviewing, approving, or using this product?', 'Describe your responsibilities and where you enter the workflow.', 'Role, responsibilities, and relationship to the product…'),
  question('audit-purpose', 'Product purpose', 'What is this product intended to accomplish for its users?', 'Answer from your perspective; differences between perspectives are useful evidence.', 'Purpose, intended users, and expected value…'),
  question('audit-sources', 'Source material', 'What types of authorized inputs do you need before you can begin?', 'Describe categories and readiness, not controlled content.', 'Input types, source owners, and missing-input patterns…'),
  question('audit-workflow', 'Current workflow', 'Walk through the work from request to authorized release.', 'Include handoffs, waiting, review, and correction cycles.', 'Major steps, handoffs, and completion point…'),
  question('audit-time', 'Effort and delay', 'Where is the most active work time spent, and where does work wait?', 'Estimates are acceptable when exact measures are unavailable.', 'Active time, wait time, and deadline pressure…'),
  question('audit-friction', 'Friction', 'What parts of the process create the most difficulty or rework?', 'Name the condition and its effect without assigning blame.', 'Bottlenecks, rework, missing information, or tool friction…'),
  question('audit-judgment', 'Judgment', 'Which steps require the most experience or contextual judgment?', 'Identify decisions that should not be treated as routine automation.', 'Judgment points, uncertainty, and escalation…'),
  question('audit-tools', 'Technology', 'Which tools help today, and where do tools make the work harder?', 'Include manual transfers and duplicate entry between tools.', 'Helpful tools, constraints, and manual workarounds…'),
  question('audit-quality', 'Quality', 'How do you know the product is accurate, useful, and ready?', 'Describe criteria, reviewers, and evidence of quality.', 'Quality checks, review standards, and approval…'),
  question('audit-risk', 'Risk', 'What could go wrong if the work is rushed, incomplete, or poorly supported?', 'Keep the answer at an authorized process and quality level.', 'Quality, trust, workload, or decision-support risks…'),
  question('audit-improvement', 'Improvement', 'What one change would most improve the workflow or result?', 'A process, role, policy, capability, or technology change may be considered.', 'Highest-value improvement and why it matters…'),
  question('audit-followup', 'Follow-up', 'What should the consultant ask next or inspect to understand this work accurately?', 'Identify unanswered questions, people, artifacts, or observations.', 'Recommended follow-up and authorized evidence sources…'),
];

const interviewQuestions: GuidedQuestion[] = [
  question('interview-role', 'Context', 'How does the participant describe their role in this product and workflow?', 'Capture the participant’s account, not the consultant’s interpretation.', 'Participant response and relevant role context…'),
  question('interview-purpose', 'Purpose', 'What outcome is the product meant to support?', 'Ask for examples only at an authorized, sanitized level.', 'Participant response about purpose and users…'),
  question('interview-actual-work', 'Actual work', 'What actually happens from request through release?', 'Follow the real workflow, including workarounds and exceptions.', 'Steps, handoffs, waiting, and review…'),
  question('interview-friction', 'Friction', 'Where does the participant experience the most friction or rework?', 'Probe for conditions and patterns without assigning blame.', 'Pain points, recurring delays, and rework…'),
  question('interview-judgment', 'Judgment', 'Where is human judgment most important?', 'Ask what makes the judgment difficult and how it is verified.', 'Judgment points, uncertainty, and safeguards…'),
  question('interview-quality', 'Quality', 'How does the participant recognize a high-quality result?', 'Capture explicit and tacit criteria separately when possible.', 'Quality criteria and evidence of readiness…'),
  question('interview-tools', 'Tools', 'How do current tools help or constrain the work?', 'Include transfers, duplicate entry, and unofficial workarounds.', 'Tool use, constraints, and handoffs…'),
  question('interview-sustainability', 'Sustainability', 'What makes the current rhythm sustainable or unsustainable?', 'Probe workload, interruption, concentration, and review capacity.', 'Workload, rhythm, resilience, and capacity…'),
  question('interview-opportunity', 'Opportunity', 'Where could responsible assistance create meaningful value?', 'Keep accountable judgment and approval visibly human-led.', 'Candidate assistance and required safeguards…'),
  question('interview-followup', 'Follow-up', 'What should be clarified, observed, or requested after this conversation?', 'Capture unresolved questions and authorized follow-up evidence.', 'Open questions, artifact requests, and next conversations…'),
];

export const guidedQuestions: Record<GuidedRecordKind, GuidedQuestion[]> = {
  PRODUCT: productQuestions,
  AUDIT: auditQuestions,
  INTERVIEW: interviewQuestions,
};

function question(id: string, section: string, prompt: string, guidance: string, placeholder: string): GuidedQuestion {
  return { id, section, prompt, guidance, placeholder };
}

export function getGuidedRecord(data: OperationalEngagementData, kind: GuidedRecordKind, recordId: string): GuidedRecordSnapshot {
  const questions = guidedQuestions[kind];
  const record = findRecord(data, kind, recordId);
  const answered = new Set(record.responses.filter((item) => item.answer.trim()).map((item) => item.questionId));
  const nextQuestion = questions.find((item) => !answered.has(item.id));
  return {
    kind,
    id: recordId,
    title: record.title,
    context: record.context,
    status: record.status,
    questions,
    responses: record.responses,
    completedCount: answered.size,
    totalCount: questions.length,
    nextQuestionId: nextQuestion?.id,
    conversationBrief: buildConversationBrief(data, kind, recordId, record.title, nextQuestion?.prompt),
  };
}

export function buildConversationBrief(data: OperationalEngagementData, kind: GuidedRecordKind, recordId: string, title: string, nextPrompt?: string) {
  return [
    'Help me develop this Lead Emergence Consulting OS record through conversation.',
    `Organization: ${data.organizationName}`,
    `Engagement: ${data.engagementName}`,
    `Record type: ${kind}`,
    `Record ID: ${recordId}`,
    `Record: ${title}`,
    '',
    'Use the connected Consulting OS MCP tools to read the record before asking questions. Ask one guided question at a time, preserve the participant’s wording, and save an answer only after I explicitly confirm it. Never infer missing answers or convert responses into diagnosis. Use sanitized process-level information only.',
    nextPrompt ? `Begin with: ${nextPrompt}` : 'The guided record is complete. Begin by asking what I want to review or revise.',
  ].join('\n');
}

function findRecord(data: OperationalEngagementData, kind: GuidedRecordKind, recordId: string) {
  if (kind === 'PRODUCT') {
    const item = data.products.find((product) => product.id === recordId);
    if (item) return { title: item.name, context: item.description, status: item.status, responses: item.responses };
  }
  if (kind === 'AUDIT') {
    const item = data.audits.find((audit) => audit.id === recordId);
    if (item) return { title: item.title, context: `${item.respondentLabel} · due ${item.dueOn}`, status: item.status, responses: item.responses };
  }
  if (kind === 'INTERVIEW') {
    const item = data.interviews.find((interview) => interview.id === recordId);
    if (item) return { title: item.participantLabel, context: item.objective, status: item.status, responses: item.responses };
  }
  throw notFoundError('The requested guided record was not found.');
}
