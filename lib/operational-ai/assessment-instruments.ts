export type AssessmentInstrumentFormat = 'docx' | 'pdf';

export interface AssessmentInstrument {
  slug: string;
  title: string;
  label: string;
  purpose: string;
  audience: string;
  completionTime: string;
  primaryOutput: string;
  pageCount: number;
  sections: string[];
  securityNotice: string;
  files: Record<AssessmentInstrumentFormat, string>;
}

export const assessmentInstruments: AssessmentInstrument[] = [
  {
    slug: 'mission-product-automation-leadership-assessment',
    title: 'Mission Product Automation Leadership Assessment',
    label: 'Leadership alignment instrument',
    purpose: 'Clarifies mission priorities, intended outcomes, non-negotiable guardrails, and the evidence leadership will accept as success.',
    audience: 'Commander / director, deputies, mission owners',
    completionTime: '30–45 minutes',
    primaryOutput: 'Ranked priorities + success definition',
    pageCount: 10,
    sections: [
      'Mission Context and Decision Environment',
      'Priority Mission Products',
      'What Success Must Look Like',
      'Human Decision Authority and Guardrails',
      'Constraints, Readiness, and Dependencies',
      'Ownership, Adoption, and Operating Model',
      'Leadership Commitment and Final Priorities',
      'Consultant Synthesis',
    ],
    securityNotice: 'Complete this instrument only at the classification level of the system being used. Use category-level descriptions here; move operational details, sources, vulnerabilities, and sensitive examples to an approved environment.',
    files: {
      docx: 'assets/assessments/mission-product-automation-leadership-assessment.docx',
      pdf: 'assets/assessments/mission-product-automation-leadership-assessment.pdf',
    },
  },
  {
    slug: 'mission-product-workflow-and-automation-assessment',
    title: 'Mission Product Workflow and Automation Assessment',
    label: 'Workflow discovery instrument',
    purpose: 'Captures how a real product is created today: inputs, decisions, handoffs, waiting, rework, constraints, and the work that consumes the most time.',
    audience: 'Analysts, planners, briefers, product creators',
    completionTime: '45–60 minutes per product',
    primaryOutput: 'Current-state workflow + pilot candidate',
    pageCount: 15,
    sections: [
      'Product Purpose and Definition of Done',
      'Trigger, Inputs, and Source Authority',
      'Current-State Workflow: What Actually Happens',
      'Time, Waiting, Handoffs, and Rework',
      'Friction and Failure Modes',
      'Quality, Review, and Release',
      'Human Judgment, Tacit Knowledge, and Boundaries',
      'Technology, Access, and Working Conditions',
      'Desired Future State and Pilot Candidate',
      'Evidence Package and Creator Summary',
      'Consultant Synthesis',
    ],
    securityNotice: 'Complete this instrument only at the classification level of the system being used. Do not paste operational details, intelligence, PII, vulnerabilities, or sensitive source material into an unapproved environment. Use categories or sanitized examples when required.',
    files: {
      docx: 'assets/assessments/mission-product-workflow-and-automation-assessment.docx',
      pdf: 'assets/assessments/mission-product-workflow-and-automation-assessment.pdf',
    },
  },
];

export function getAssessmentInstrument(slug: string) {
  return assessmentInstruments.find((instrument) => instrument.slug === slug);
}

export function assessmentInstrumentUrl(slug: string, format: AssessmentInstrumentFormat, download = false) {
  return `/api/assessment-instruments/${slug}/${format}${download ? '?download=1' : ''}`;
}
