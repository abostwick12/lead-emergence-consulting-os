export type AssessmentCellType = 'text' | 'number' | 'date' | 'rating' | 'single-select';

export interface AssessmentFieldDefinition {
  key: string;
  label: string;
  type?: AssessmentCellType;
  options?: string[];
}

export interface AssessmentMatrixRow {
  key: string;
  label: string;
}

export type AssessmentResponseDefinition =
  | { uiType: 'text'; placeholder: string }
  | { uiType: 'fields'; fields: AssessmentFieldDefinition[] }
  | { uiType: 'multi-select'; options: string[]; maxSelections?: number; allowOther?: boolean }
  | { uiType: 'matrix'; columns: AssessmentFieldDefinition[]; rows: number | AssessmentMatrixRow[] };

export interface AssessmentWorkflowItem {
  itemKey: string;
  sectionKey: string;
  section: string;
  prompt: string;
  guidance: string;
  responseType: 'TEXT' | 'MULTI_SELECT';
  response: AssessmentResponseDefinition;
}

export interface AssessmentWorkflowDefinition {
  slug: string;
  title: string;
  version: number;
  sourceDocument: string;
  sections: Array<{ key: string; label: string }>;
  items: AssessmentWorkflowItem[];
}

const text = (itemKey: string, sectionKey: string, section: string, prompt: string, guidance = 'Preserve the respondent’s wording. Use sanitized, process-level information only.'): AssessmentWorkflowItem => ({
  itemKey, sectionKey, section, prompt, guidance, responseType: 'TEXT',
  response: { uiType: 'text', placeholder: 'Type the confirmed response here…' },
});

const fields = (itemKey: string, sectionKey: string, section: string, prompt: string, fieldDefinitions: AssessmentFieldDefinition[], guidance = 'Complete the applicable fields. Do not enter restricted operational detail.'): AssessmentWorkflowItem => ({
  itemKey, sectionKey, section, prompt, guidance, responseType: 'TEXT',
  response: { uiType: 'fields', fields: fieldDefinitions },
});

const select = (itemKey: string, sectionKey: string, section: string, prompt: string, options: string[], maxSelections?: number, allowOther = false, guidance = 'Select every applicable option, then confirm the response before it is saved.'): AssessmentWorkflowItem => ({
  itemKey, sectionKey, section, prompt, guidance, responseType: 'MULTI_SELECT',
  response: { uiType: 'multi-select', options, maxSelections, allowOther },
});

const matrix = (itemKey: string, sectionKey: string, section: string, prompt: string, columns: AssessmentFieldDefinition[], rows: number | AssessmentMatrixRow[], guidance = 'Complete as many rows as the evidence supports. Leave unknown fields blank rather than guessing.'): AssessmentWorkflowItem => ({
  itemKey, sectionKey, section, prompt, guidance, responseType: 'TEXT',
  response: { uiType: 'matrix', columns, rows },
});

const leadershipSections = [
  ['RESPONDENT_INFORMATION', 'Respondent information'],
  ['MISSION_CONTEXT', '1. Mission Context and Decision Environment'],
  ['PRIORITY_PRODUCTS', '2. Priority Mission Products'],
  ['SUCCESS', '3. What Success Must Look Like'],
  ['AUTHORITY_GUARDRAILS', '4. Human Decision Authority and Guardrails'],
  ['CONSTRAINTS', '5. Constraints, Readiness, and Dependencies'],
  ['OWNERSHIP', '6. Ownership, Adoption, and Operating Model'],
  ['COMMITMENT', '7. Leadership Commitment and Final Priorities'],
  ['CONSULTANT_SYNTHESIS', '8. Consultant Synthesis'],
] as const;

const leadershipItems: AssessmentWorkflowItem[] = [
  fields('LEAD_INFO', 'RESPONDENT_INFORMATION', 'Respondent information', 'Respondent information', [
    { key: 'unit_organization', label: 'Unit / organization' },
    { key: 'name_role', label: 'Name and role' },
    { key: 'date', label: 'Date', type: 'date' },
    { key: 'interviewed_by', label: 'Interviewed by' },
  ]),
  text('LEAD_SCOPE', 'RESPONDENT_INFORMATION', 'Respondent information', 'A  Which mission area, staff function, or operational problem is in scope for this engagement?'),
  text('LEAD_1_1', 'MISSION_CONTEXT', '1. Mission Context and Decision Environment', '1.1  What mission outcome(s) do these products support? What becomes possible when the products are timely and trusted?'),
  text('LEAD_1_2', 'MISSION_CONTEXT', '1. Mission Context and Decision Environment', '1.2  Who consumes the products, and what decisions or actions do they enable?'),
  text('LEAD_1_3', 'MISSION_CONTEXT', '1. Mission Context and Decision Environment', '1.3  What is the operational tempo: routine cycle, surge conditions, short-notice tasking, and peak demand?'),
  text('LEAD_1_4', 'MISSION_CONTEXT', '1. Mission Context and Decision Environment', '1.4  What are the consequences of a late, incomplete, inconsistent, or incorrect product?'),
  text('LEAD_1_5', 'MISSION_CONTEXT', '1. Mission Context and Decision Environment', '1.5  What should never be optimized away in pursuit of speed (for example: commander intent, judgment, nuance, accountability, security, or relationship)?'),
  matrix('LEAD_PRODUCT_PORTFOLIO', 'PRIORITY_PRODUCTS', '2. Priority Mission Products', 'Identify the product portfolio.', [
    { key: 'product', label: 'Product / recurring deliverable' },
    { key: 'consumer', label: 'Primary consumer' },
    { key: 'decision', label: 'Decision or action enabled' },
    { key: 'frequency', label: 'Typical frequency' },
  ], 6),
  matrix('LEAD_PRIORITY_RATINGS', 'PRIORITY_PRODUCTS', '2. Priority Mission Products', 'Leadership priority rating — rate each named product from 1 (low) to 5 (high). Readiness reflects the availability of authoritative inputs, repeatable rules, access, and an accountable owner.', [
    { key: 'product', label: 'Product' },
    { key: 'mission_impact', label: 'Mission impact', type: 'rating' },
    { key: 'current_burden', label: 'Current burden', type: 'rating' },
    { key: 'time_sensitivity', label: 'Time sensitivity', type: 'rating' },
    { key: 'readiness', label: 'Readiness', type: 'rating' },
    { key: 'leader_priority', label: 'Leader priority', type: 'rating' },
  ], 6),
  text('LEAD_2_1', 'PRIORITY_PRODUCTS', '2. Priority Mission Products', '2.1  Which three products should be examined first, and why are they more important than the others?'),
  select('LEAD_PRIMARY_OUTCOMES', 'SUCCESS', '3. What Success Must Look Like', 'Select no more than four primary outcomes. A successful pilot should improve these outcomes without violating the guardrails in Section 4.', [
    'Shorter end-to-end cycle time', 'Less hands-on production time',
    'Fewer corrections or revision rounds', 'Higher accuracy or completeness',
    'More consistent format and content', 'Faster response to changing conditions',
    'Greater surge capacity', 'Better continuity across personnel turnover',
    'Stronger source traceability / auditability', 'Reduced duplicate entry and handoffs',
    'More time for analysis and mission judgment', 'Improved user confidence and adoption',
  ], 4),
  matrix('LEAD_OUTCOME_TARGETS', 'SUCCESS', '3. What Success Must Look Like', 'Define observable change, a baseline, a target, and a responsible evidence owner. Avoid promising causation or ROI before a pilot is measured.', [
    { key: 'outcome', label: 'Outcome' }, { key: 'baseline', label: 'Current baseline' },
    { key: 'target', label: 'Target / threshold' }, { key: 'by_when', label: 'By when', type: 'date' },
    { key: 'evidence_owner', label: 'Evidence source + owner' },
  ], 4),
  text('LEAD_3_1', 'SUCCESS', '3. What Success Must Look Like', '3.1  At 90 days, what must be measurably true for leadership to continue, expand, modify, or stop the effort?'),
  text('LEAD_3_2', 'SUCCESS', '3. What Success Must Look Like', '3.2  If personnel regain time, where should that time be reinvested to produce mission value?'),
  text('LEAD_3_3', 'SUCCESS', '3. What Success Must Look Like', '3.3  What result would look impressive but would not actually count as mission success?'),
  matrix('LEAD_AUTHORITY_MATRIX', 'AUTHORITY_GUARDRAILS', '4. Human Decision Authority and Guardrails', 'Set boundaries before selecting a tool. The system may assist; accountable people retain material mission decisions.', [
    { key: 'disposition', label: 'Disposition', type: 'single-select', options: ['Allowed', 'Case-by-case', 'Prohibited'] },
    { key: 'approver_condition', label: 'Approver / condition' },
  ], [
    { key: 'retrieve_sources', label: 'Find or retrieve approved source material' },
    { key: 'summarize_compare', label: 'Extract, summarize, or compare content' },
    { key: 'assemble_draft', label: 'Assemble a first draft from approved inputs' },
    { key: 'phrasing_structure_visuals', label: 'Suggest phrasing, structure, or visuals' },
    { key: 'check_quality', label: 'Check format, completeness, and consistency' },
    { key: 'reconcile_sources', label: 'Reconcile conflicting sources' },
    { key: 'recommend_decision', label: 'Make or recommend an operational decision' },
    { key: 'release_without_review', label: 'Publish, release, transmit, or brief without review' },
  ]),
  text('LEAD_4_1', 'AUTHORITY_GUARDRAILS', '4. Human Decision Authority and Guardrails', '4.1  Which judgments must remain distinctly human, and who is accountable for them?'),
  text('LEAD_4_2', 'AUTHORITY_GUARDRAILS', '4. Human Decision Authority and Guardrails', '4.2  What failures are unacceptable even once? Which errors are tolerable only if detected before release?'),
  text('LEAD_4_3', 'AUTHORITY_GUARDRAILS', '4. Human Decision Authority and Guardrails', '4.3  What source traceability, citations, confidence indicators, or review evidence must accompany generated content?'),
  text('LEAD_4_4', 'AUTHORITY_GUARDRAILS', '4. Human Decision Authority and Guardrails', '4.4  Who has authority to approve the pilot, authorize production use, pause it, and retire it?'),
  select('LEAD_CONSTRAINTS', 'CONSTRAINTS', '5. Constraints, Readiness, and Dependencies', 'Check every constraint that could materially affect scope, schedule, data access, or acceptable design.', [
    'Classification / compartmentation', 'Approved network or hosting environment',
    'Data access or releasability', 'Authoritative-source availability',
    'Cybersecurity approval', 'Records retention / discoverability',
    'Identity, role, and permission controls', 'Integration with existing systems',
    'Procurement or licensing', 'Staff availability for discovery and testing',
    'Template / SOP inconsistency', 'Trust, adoption, or workforce concern',
    'Training and support capacity', 'External policy or legal constraint',
  ]),
  text('LEAD_5_1', 'CONSTRAINTS', '5. Constraints, Readiness, and Dependencies', '5.1  Which systems, repositories, templates, and data sources are approved and authoritative?'),
  text('LEAD_5_2', 'CONSTRAINTS', '5. Constraints, Readiness, and Dependencies', '5.2  What must be true before real mission data can be used in discovery, testing, or evaluation?'),
  text('LEAD_5_3', 'CONSTRAINTS', '5. Constraints, Readiness, and Dependencies', '5.3  Where is the unit ready to experiment, and where is it not ready?'),
  text('LEAD_5_4', 'CONSTRAINTS', '5. Constraints, Readiness, and Dependencies', '5.4  What other initiatives, dependencies, or competing priorities could help or hinder this work?'),
  matrix('LEAD_OPERATING_ROLES', 'OWNERSHIP', '6. Ownership, Adoption, and Operating Model', 'Identify the coalition that will sponsor, govern, test, and sustain the capability.', [
    { key: 'named_person_office', label: 'Named person / office' },
    { key: 'authority_contribution', label: 'Authority or contribution' },
    { key: 'availability_cadence', label: 'Availability / decision cadence' },
  ], [
    { key: 'executive_sponsor', label: 'Executive sponsor' },
    { key: 'mission_product_owner', label: 'Mission / product owner' },
    { key: 'creators_smes', label: 'Product creators / SMEs' },
    { key: 'security_data', label: 'Cyber / security / data authority' },
    { key: 'technical_owner', label: 'Technical / integration owner' },
    { key: 'change_lead', label: 'Training / change lead' },
    { key: 'evidence_owner', label: 'Evaluation / evidence owner' },
  ]),
  text('LEAD_6_1', 'OWNERSHIP', '6. Ownership, Adoption, and Operating Model', '6.1  What concerns are people likely to have about quality, control, workload, roles, or workforce impact?'),
  text('LEAD_6_2', 'OWNERSHIP', '6. Ownership, Adoption, and Operating Model', '6.2  How will leadership communicate the purpose of the effort and invite honest feedback without pressuring people to report success?'),
  text('LEAD_6_3', 'OWNERSHIP', '6. Ownership, Adoption, and Operating Model', '6.3  Who will own the capability after the consulting engagement ends?'),
  matrix('LEAD_FINAL_PRIORITIES', 'COMMITMENT', '7. Leadership Commitment and Final Priorities', 'Rank the final leadership priorities.', [
    { key: 'product_use_case', label: 'Product / use case' }, { key: 'mission_outcome', label: 'Mission outcome' },
    { key: 'why_now', label: 'Why now' }, { key: 'decision_owner', label: 'Pilot decision owner' },
  ], [{ key: 'rank_1', label: '1' }, { key: 'rank_2', label: '2' }, { key: 'rank_3', label: '3' }]),
  text('LEAD_7_1', 'COMMITMENT', '7. Leadership Commitment and Final Priorities', '7.1  Complete this sentence: This engagement will be successful if, by [date], the unit can ______ while preserving ______, as demonstrated by ______.'),
  text('LEAD_7_2', 'COMMITMENT', '7. Leadership Commitment and Final Priorities', '7.2  What access, personnel time, sample artifacts, and decisions will leadership commit to make available?'),
  text('LEAD_7_3', 'COMMITMENT', '7. Leadership Commitment and Final Priorities', '7.3  What is explicitly out of scope for this engagement?'),
  matrix('LEAD_CONFIRMATION', 'COMMITMENT', '7. Leadership Commitment and Final Priorities', 'Leadership confirmation', [
    { key: 'name_role', label: 'Name / role' },
    { key: 'decision', label: 'Decision', type: 'single-select', options: ['Proceed', 'Revise', 'Hold'] },
    { key: 'signature_concurrence', label: 'Signature or concurrence' },
    { key: 'date', label: 'Date', type: 'date' },
  ], 3),
  matrix('LEAD_SYNTHESIS', 'CONSULTANT_SYNTHESIS', '8. Consultant Synthesis', 'Complete after comparing leadership responses with workflow evidence. Record observations, interpretations, decisions, and unresolved assumptions separately.', [
    { key: 'synthesis', label: 'Synthesis' },
  ], [
    { key: 'direct_evidence', label: 'Direct observations / evidence' },
    { key: 'patterns_tensions', label: 'Patterns or tensions to investigate' },
    { key: 'interpretation', label: 'Current interpretation (not yet fact)' },
    { key: 'decisions_boundaries', label: 'Agreed decisions and boundaries' },
    { key: 'open_assumptions', label: 'Open assumptions / evidence needed' },
  ]),
  matrix('LEAD_USE_CASE_SCREEN', 'CONSULTANT_SYNTHESIS', '8. Consultant Synthesis', 'Initial use-case screen', [
    { key: 'candidate', label: 'Candidate' },
    { key: 'mission_value', label: 'Mission value', type: 'single-select', options: ['Low', 'Medium', 'High'] },
    { key: 'feasibility', label: 'Feasibility', type: 'single-select', options: ['Low', 'Medium', 'High'] },
    { key: 'risk_guardrail', label: 'Risk / guardrail load', type: 'single-select', options: ['Low', 'Medium', 'High'] },
    { key: 'evidence_readiness', label: 'Evidence readiness', type: 'single-select', options: ['Low', 'Medium', 'High'] },
    { key: 'recommendation', label: 'Recommendation', type: 'single-select', options: ['Explore', 'Defer', 'Decline'] },
  ], 5),
];

const workflowSections = [
  ['RESPONDENT_INFORMATION', 'Respondent and product information'],
  ['PURPOSE', '1. Product Purpose and Definition of Done'],
  ['INPUTS', '2. Trigger, Inputs, and Source Authority'],
  ['CURRENT_WORKFLOW', '3. Current-State Workflow: What Actually Happens'],
  ['TIME_FRICTION', '4. Time, Waiting, Handoffs, and Rework'],
  ['FAILURE_MODES', '5. Friction and Failure Modes'],
  ['QUALITY', '6. Quality, Review, and Release'],
  ['HUMAN_JUDGMENT', '7. Human Judgment, Tacit Knowledge, and Boundaries'],
  ['TECHNOLOGY', '8. Technology, Access, and Working Conditions'],
  ['FUTURE_STATE', '9. Desired Future State and Pilot Candidate'],
  ['EVIDENCE_PACKAGE', '10. Evidence Package and Creator Summary'],
  ['CONSULTANT_SYNTHESIS', '11. Consultant Synthesis'],
] as const;

const workflowItems: AssessmentWorkflowItem[] = [
  fields('WORKFLOW_INFO', 'RESPONDENT_INFORMATION', 'Respondent and product information', 'Respondent and product information', [
    { key: 'unit_team', label: 'Unit / team' }, { key: 'name_role', label: 'Name or role' },
    { key: 'product_name', label: 'Product name' }, { key: 'trace_case_date', label: 'Date completed / trace case', type: 'date' },
    { key: 'typical_suspense', label: 'Typical suspense' }, { key: 'typical_frequency', label: 'Typical frequency' },
    { key: 'primary_consumer', label: 'Primary consumer' }, { key: 'interviewed_by', label: 'Interviewed by' },
  ]),
  text('WORKFLOW_1_1', 'PURPOSE', '1. Product Purpose and Definition of Done', '1.1  What decision, action, coordination, or shared understanding is this product supposed to enable?'),
  text('WORKFLOW_1_2', 'PURPOSE', '1. Product Purpose and Definition of Done', '1.2  Who uses it? What does each audience member need from it?'),
  text('WORKFLOW_1_3', 'PURPOSE', '1. Product Purpose and Definition of Done', "1.3  What makes the product 'done' and acceptable for release? Who decides?"),
  text('WORKFLOW_1_4', 'PURPOSE', '1. Product Purpose and Definition of Done', '1.4  What changes between routine and surge production?'),
  text('WORKFLOW_1_5', 'PURPOSE', '1. Product Purpose and Definition of Done', '1.5  Which parts are standard or reusable, and which must be newly reasoned or tailored every cycle?'),
  text('WORKFLOW_2_1', 'INPUTS', '2. Trigger, Inputs, and Source Authority', '2.1  What triggers production: battle rhythm, tasking, new information, request, event, or commander / director direction?'),
  matrix('WORKFLOW_INPUTS', 'INPUTS', '2. Trigger, Inputs, and Source Authority', 'Identify which inputs can be trusted, accessed, and traced.', [
    { key: 'source_category', label: 'Input or source category' },
    { key: 'authoritative', label: 'Authoritative?', type: 'single-select', options: ['Yes', 'No', 'Conditional'] },
    { key: 'format', label: 'Format' }, { key: 'where_accessed', label: 'Where accessed' },
    { key: 'sensitivity_access', label: 'Sensitivity / access' }, { key: 'quality_issue', label: 'Common quality issue' },
  ], 8),
  text('WORKFLOW_2_2', 'INPUTS', '2. Trigger, Inputs, and Source Authority', '2.2  Which inputs arrive late, incomplete, contradictory, duplicated, or in a format that is hard to use?'),
  text('WORKFLOW_2_3', 'INPUTS', '2. Trigger, Inputs, and Source Authority', '2.3  How do you decide which source wins when sources disagree?'),
  text('WORKFLOW_2_4', 'INPUTS', '2. Trigger, Inputs, and Source Authority', '2.4  What material is unavailable to some contributors because of permissions, systems, location, or classification?'),
  matrix('WORKFLOW_STEPS', 'CURRENT_WORKFLOW', '3. Current-State Workflow: What Actually Happens', 'A. Production steps — map the trace case from trigger to release. Include unofficial steps, shadow tools, and backtracking.', [
    { key: 'action_decision', label: 'Action or decision' }, { key: 'role', label: 'Role' },
    { key: 'input_source', label: 'Input / source' }, { key: 'system_tool', label: 'System or tool' },
  ], Array.from({ length: 12 }, (_, index) => ({ key: `step_${index + 1}`, label: String(index + 1) }))),
  text('WORKFLOW_3_1', 'CURRENT_WORKFLOW', '3. Current-State Workflow: What Actually Happens', '3.1  Where does the actual workflow differ from the SOP, checklist, or published process?'),
  text('WORKFLOW_3_2', 'CURRENT_WORKFLOW', '3. Current-State Workflow: What Actually Happens', "3.2  Which steps depend on one person's memory, relationships, tacit knowledge, or personal files?"),
  matrix('WORKFLOW_STEP_TIME', 'TIME_FRICTION', '4. Time, Waiting, Handoffs, and Rework', 'B. Step-level time and friction — separate hands-on work from elapsed time.', [
    { key: 'hands_on_min', label: 'Hands-on min', type: 'number' }, { key: 'wait_min', label: 'Wait min', type: 'number' },
    { key: 'handoff_approval', label: 'Handoff / approval' }, { key: 'rework_trigger', label: 'Rework or defect trigger' },
    { key: 'frequency', label: 'Frequency' },
  ], Array.from({ length: 12 }, (_, index) => ({ key: `step_${index + 1}`, label: String(index + 1) }))),
  matrix('WORKFLOW_AGGREGATE_TIME', 'TIME_FRICTION', '4. Time, Waiting, Handoffs, and Rework', 'Aggregate time measures', [
    { key: 'routine_cycle', label: 'Routine cycle' }, { key: 'surge', label: 'Surge / short notice' },
    { key: 'measurement_basis', label: 'How measured or estimated' },
  ], [
    { key: 'elapsed_time', label: 'End-to-end elapsed time' },
    { key: 'hands_on_time', label: 'Total hands-on production time' },
    { key: 'wait_time', label: 'Total waiting / queue time' },
    { key: 'revision_rounds', label: 'Typical number of revision rounds' },
    { key: 'people_hours', label: 'People-hours across all contributors' },
  ]),
  text('WORKFLOW_4_1', 'TIME_FRICTION', '4. Time, Waiting, Handoffs, and Rework', '4.1  Which three activities consume the most hands-on time? Estimate minutes or hours for each.'),
  text('WORKFLOW_4_2', 'TIME_FRICTION', '4. Time, Waiting, Handoffs, and Rework', '4.2  Where does work sit idle, and what is usually being waited on?'),
  text('WORKFLOW_4_3', 'TIME_FRICTION', '4. Time, Waiting, Handoffs, and Rework', '4.3  What late-breaking changes create the most rework?'),
  select('WORKFLOW_RECURRING_FRICTION', 'FAILURE_MODES', '5. Friction and Failure Modes', 'Check every recurring friction. Then identify the top three based on time, frequency, and mission consequence—not irritation alone.', [
    'Search across many repositories', 'Copy / paste between systems', 'Re-enter the same data',
    'Convert formats or reformat slides', 'Manually extract facts or tables', 'Reconcile conflicting versions',
    'Check freshness or source authority', 'Chase inputs or approvals', 'Merge contributions from many people',
    'Correct inconsistent terminology', 'Build citations / source traceability', 'Update recurring boilerplate',
    'Repair charts, maps, or visuals', 'Respond to last-minute changes', 'Manage classification / releasability',
    'Recover work during turnover or absence', 'Brief from a product that is already stale', 'Other',
  ], undefined, true),
  matrix('WORKFLOW_TOP_FRICTION', 'FAILURE_MODES', '5. Friction and Failure Modes', 'Rank the top three friction or failure modes.', [
    { key: 'friction', label: 'Friction / failure mode' }, { key: 'frequency', label: 'Frequency' },
    { key: 'time_cost', label: 'Time cost' }, { key: 'consequence', label: 'Mission / quality consequence' },
    { key: 'workaround', label: 'Current workaround' },
  ], [{ key: 'rank_1', label: '1' }, { key: 'rank_2', label: '2' }, { key: 'rank_3', label: '3' }]),
  text('WORKFLOW_5_1', 'FAILURE_MODES', '5. Friction and Failure Modes', '5.1  What errors are easiest to make and hardest to detect?'),
  text('WORKFLOW_5_2', 'FAILURE_MODES', '5. Friction and Failure Modes', "5.2  What 'small' task is repeated so often that its total burden is large?"),
  matrix('WORKFLOW_QUALITY_CONTROL', 'QUALITY', '6. Quality, Review, and Release', 'Make the control system visible: standards, checks, revisions, approvals, and accountability.', [
    { key: 'how_checked', label: 'How checked today' }, { key: 'who_checks', label: 'Who checks' },
    { key: 'common_defect', label: 'Common defect' }, { key: 'release_threshold', label: 'Release threshold' },
  ], [
    { key: 'accuracy', label: 'Accuracy / factual correctness' }, { key: 'completeness', label: 'Completeness' },
    { key: 'timeliness', label: 'Timeliness / freshness' }, { key: 'consistency', label: 'Consistency / terminology' },
    { key: 'traceability', label: 'Source traceability' }, { key: 'security', label: 'Security / releasability' },
    { key: 'usefulness', label: 'Audience usefulness' },
  ]),
  text('WORKFLOW_6_1', 'QUALITY', '6. Quality, Review, and Release', '6.1  Describe the review and approval path from first draft to release. Where do most comments enter?'),
  text('WORKFLOW_6_2', 'QUALITY', '6. Quality, Review, and Release', '6.2  Which checks are rule-based and repeatable? Which require mission judgment?'),
  text('WORKFLOW_6_3', 'QUALITY', '6. Quality, Review, and Release', '6.3  What evidence would help a reviewer trust an AI-assisted draft (for example: source links, change log, confidence, or validation results)?'),
  text('WORKFLOW_6_4', 'QUALITY', '6. Quality, Review, and Release', '6.4  Who can release the product, and who is accountable if it is wrong?'),
  select('WORKFLOW_JUDGMENT_ACTIVITIES', 'HUMAN_JUDGMENT', '7. Human Judgment, Tacit Knowledge, and Boundaries', 'Check the judgment-intensive activities present in this workflow.', [
    'Interpret commander / director intent', 'Resolve ambiguity or conflicting evidence',
    'Assess operational relevance', 'Adapt message to audience and context',
    'Make risk tradeoffs', 'Recognize deception, anomaly, or missing context',
    'Exercise classification / releasability judgment', 'Coordinate through trusted relationships',
    'Choose what not to include', 'Recommend or make a mission decision',
  ]),
  text('WORKFLOW_7_1', 'HUMAN_JUDGMENT', '7. Human Judgment, Tacit Knowledge, and Boundaries', '7.1  What do experienced creators know that is not written in the SOP or template?'),
  text('WORKFLOW_7_2', 'HUMAN_JUDGMENT', '7. Human Judgment, Tacit Knowledge, and Boundaries', '7.2  What contextual clues cause you to change the normal process, interpretation, or product structure?'),
  text('WORKFLOW_7_3', 'HUMAN_JUDGMENT', '7. Human Judgment, Tacit Knowledge, and Boundaries', '7.3  Which parts may be drafted or checked by automation but must always receive human review?'),
  text('WORKFLOW_7_4', 'HUMAN_JUDGMENT', '7. Human Judgment, Tacit Knowledge, and Boundaries', '7.4  Which parts should never be generated, decided, released, or transmitted by automation? Why?'),
  matrix('WORKFLOW_SYSTEMS', 'TECHNOLOGY', '8. Technology, Access, and Working Conditions', 'Capture the environment in which the workflow must operate, including disconnected or constrained conditions.', [
    { key: 'system', label: 'System / tool / repository' }, { key: 'purpose', label: 'Purpose' },
    { key: 'environment', label: 'Approved environment' }, { key: 'access_issue', label: 'Access / permission issue' },
    { key: 'integration_limit', label: 'Integration or export limitation' },
  ], 7),
  text('WORKFLOW_8_1', 'TECHNOLOGY', '8. Technology, Access, and Working Conditions', '8.1  Where must the workflow function: office, operations center, deployed, mobile, disconnected, or low-bandwidth?'),
  text('WORKFLOW_8_2', 'TECHNOLOGY', '8. Technology, Access, and Working Conditions', '8.2  What tools are used unofficially because the approved workflow is too slow or incomplete? Describe the need, not sensitive tool details.'),
  text('WORKFLOW_8_3', 'TECHNOLOGY', '8. Technology, Access, and Working Conditions', '8.3  What logs, permissions, version history, retention, or audit trail would an approved solution need?'),
  text('WORKFLOW_8_4', 'TECHNOLOGY', '8. Technology, Access, and Working Conditions', '8.4  What training, support, or reliability level would be required before you would depend on it?'),
  matrix('WORKFLOW_AUTOMATION_FIT', 'FUTURE_STATE', '9. Desired Future State and Pilot Candidate', 'Describe assistance that improves the work without removing necessary judgment or creating hidden burdens.', [
    { key: 'disposition', label: 'Disposition', type: 'single-select', options: ['Keep human', 'Assist / augment', 'Automate if approved'] },
    { key: 'reason_condition', label: 'Reason / condition' },
  ], [
    { key: 'retrieve', label: 'Find and retrieve inputs' }, { key: 'extract', label: 'Extract and structure data' },
    { key: 'compare', label: 'Compare sources / identify changes' }, { key: 'draft', label: 'Draft recurring sections' },
    { key: 'format', label: 'Create slides / formatting' }, { key: 'check', label: 'Check completeness / consistency' },
    { key: 'route', label: 'Route for review / track status' }, { key: 'decide', label: 'Recommend or decide' },
  ]),
  text('WORKFLOW_9_1', 'FUTURE_STATE', '9. Desired Future State and Pilot Candidate', '9.1  If one burden disappeared next month, which would create the most mission value?'),
  text('WORKFLOW_9_2', 'FUTURE_STATE', '9. Desired Future State and Pilot Candidate', '9.2  What is the smallest safe pilot that could test usefulness with real users and measurable evidence?'),
  text('WORKFLOW_9_3', 'FUTURE_STATE', '9. Desired Future State and Pilot Candidate', '9.3  What representative, sanitized, or approved sample set could be used for testing?'),
  text('WORKFLOW_9_4', 'FUTURE_STATE', '9. Desired Future State and Pilot Candidate', '9.4  What would make you stop using the solution, even if it saved time?'),
  text('WORKFLOW_9_5', 'FUTURE_STATE', '9. Desired Future State and Pilot Candidate', '9.5  What feedback method would make it easy to report errors, surprises, and improvement ideas?'),
  select('WORKFLOW_EVIDENCE_PACKAGE', 'EVIDENCE_PACKAGE', '10. Evidence Package and Creator Summary', 'Identify the artifacts needed to validate the workflow and establish a baseline. Do not transfer any artifact until the collection method and storage location are approved for its classification and sensitivity.', [
    'Current template', 'SOP / checklist', 'One representative completed product',
    'Sanitized source inputs for that product', 'Review comments or revision history',
    'Approval / release checklist', 'Product schedule or battle rhythm',
    'Known defect or correction examples', 'Access / system map', 'Relevant policy or governance document',
  ]),
  matrix('WORKFLOW_CREATOR_SUMMARY', 'EVIDENCE_PACKAGE', '10. Evidence Package and Creator Summary', 'Creator summary', [
    { key: 'response', label: 'Response' },
  ], [
    { key: 'matters', label: 'The product matters because…' }, { key: 'time', label: 'The most time is spent on…' },
    { key: 'delay', label: 'The largest delay is caused by…' }, { key: 'risk', label: 'The most consequential quality risk is…' },
    { key: 'opportunity', label: 'A safe first automation / augmentation opportunity is…' },
    { key: 'judgment', label: 'The human judgment that must be protected is…' },
  ]),
  matrix('WORKFLOW_SYNTHESIS', 'CONSULTANT_SYNTHESIS', '11. Consultant Synthesis', 'Complete after observation, artifact review, and comparison across respondents. Do not treat a single interview as proof of the whole system.', [
    { key: 'finding', label: 'Finding' },
  ], [
    { key: 'observed', label: 'Observed workflow evidence' }, { key: 'reported', label: 'Reported but not yet observed' },
    { key: 'contradictions', label: 'Contradictions / variation across people' },
    { key: 'bottleneck', label: 'Primary bottleneck hypothesis' }, { key: 'risk', label: 'Primary quality / mission risk' },
    { key: 'human_boundary', label: 'Human judgment boundary' },
    { key: 'pilot', label: 'Candidate pilot and expected contribution' },
    { key: 'evidence_needed', label: 'Evidence needed before recommendation' },
  ]),
  matrix('WORKFLOW_BASELINE', 'CONSULTANT_SYNTHESIS', '11. Consultant Synthesis', 'Baseline calculation', [
    { key: 'current', label: 'Current' }, { key: 'pilot_target', label: 'Pilot target' },
    { key: 'measurement_method', label: 'Measurement method' }, { key: 'owner', label: 'Owner' },
  ], [
    { key: 'cycle_time', label: 'End-to-end cycle time' }, { key: 'hands_on', label: 'Hands-on production time' },
    { key: 'wait', label: 'Wait / queue time' }, { key: 'revisions', label: 'Revision rounds / defect rate' },
    { key: 'confidence', label: 'User confidence / usefulness' },
  ]),
];

export const assessmentWorkflowDefinitions: AssessmentWorkflowDefinition[] = [
  {
    slug: 'mission-product-automation-leadership-assessment',
    title: 'Mission Product Automation Leadership Assessment',
    version: 1,
    sourceDocument: 'Mission_Product_Automation_Leadership_Assessment.docx',
    sections: leadershipSections.map(([key, label]) => ({ key, label })),
    items: leadershipItems,
  },
  {
    slug: 'mission-product-workflow-and-automation-assessment',
    title: 'Mission Product Workflow and Automation Assessment',
    version: 1,
    sourceDocument: 'Mission_Product_Workflow_and_Automation_Assessment.docx',
    sections: workflowSections.map(([key, label]) => ({ key, label })),
    items: workflowItems,
  },
];

export function getAssessmentWorkflowDefinition(slug: string) {
  return assessmentWorkflowDefinitions.find((definition) => definition.slug === slug);
}

export function assessmentDefinitionForDatabase(definition: AssessmentWorkflowDefinition) {
  return {
    slug: definition.slug,
    title: definition.title,
    version: definition.version,
    sourceDocument: definition.sourceDocument,
    sections: definition.sections,
    items: definition.items.map((item) => ({
      itemKey: item.itemKey,
      sectionKey: item.sectionKey,
      prompt: item.prompt,
      responseType: item.responseType,
      responseOptions: { section: item.section, guidance: item.guidance, ...item.response },
    })),
  };
}
