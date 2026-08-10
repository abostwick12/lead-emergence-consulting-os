BEGIN;
SELECT plan(45);

insert into auth.users (id, email, role, aud, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
  ('71000000-0000-4000-8000-000000000001', 'consultant-phase3@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('71000000-0000-4000-8000-000000000002', 'client-phase3@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('71000000-0000-4000-8000-000000000003', 'outsider-phase3@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now());

insert into consulting_os.people (id, auth_user_id, display_name)
values
  ('72000000-0000-4000-8000-000000000001', '71000000-0000-4000-8000-000000000001', 'Phase 3 Consultant'),
  ('72000000-0000-4000-8000-000000000002', '71000000-0000-4000-8000-000000000002', 'Phase 3 Client Member'),
  ('72000000-0000-4000-8000-000000000003', '71000000-0000-4000-8000-000000000003', 'Other Organization Admin');

insert into consulting_os.organizations (id, name, slug, created_by)
values
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Consulting Core Client', 'consulting-core-a', '72000000-0000-4000-8000-000000000001'),
  ('ebbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'Consulting Core Client', 'consulting-core-b', '72000000-0000-4000-8000-000000000003');

insert into consulting_os.consultant_assignments
  (id, organization_id, consultant_person_id, status, assignment_reason, created_by)
values
  ('72100000-0000-4000-8000-000000000001', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '72000000-0000-4000-8000-000000000001', 'ACTIVE', 'Phase 3 fixture', '72000000-0000-4000-8000-000000000001');

insert into consulting_os.organization_memberships
  (id, organization_id, person_id, platform_role, status, created_by)
values
  ('72200000-0000-4000-8000-000000000001', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '72000000-0000-4000-8000-000000000002', 'CLIENT_MEMBER', 'ACTIVE', '72000000-0000-4000-8000-000000000001'),
  ('72200000-0000-4000-8000-000000000002', 'ebbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '72000000-0000-4000-8000-000000000003', 'CLIENT_ADMIN', 'ACTIVE', '72000000-0000-4000-8000-000000000003');

insert into consulting_os.engagements
  (id, organization_id, name, status, starts_on, created_by)
values
  ('73000000-0000-4000-8000-000000000001', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'SEE REALITY and REFRAME', 'ACTIVE', '2026-01-01', '72000000-0000-4000-8000-000000000001');

insert into consulting_os.domain_objects
  (id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, origin, created_by)
values
  ('74000000-0000-4000-8000-000000000001', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'EVIDENCE_SOURCE', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000002', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'EVIDENCE_SOURCE', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000003', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'EVIDENCE_SOURCE', 'ORGANIZATION_SHARED', null, 'IMPORTED', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000004', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'EVIDENCE', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000005', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'OBSERVATION', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000006', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'PATTERN', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000007', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'ASSUMPTION', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000008', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'RISK', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000009', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'STRENGTH', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000010', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'UNREALIZED_POTENTIAL', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000011', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'DIAGNOSIS', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000012', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'DIAGNOSIS', 'CONSULTANT_PRIVATE', '72000000-0000-4000-8000-000000000001', 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000013', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'INTERVIEW', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000014', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'INTERVIEW_RESPONSE', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000015', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', null, 'ASSESSMENT_INSTRUMENT', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000016', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'ASSESSMENT_ADMINISTRATION', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000017', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'ASSESSMENT_RESPONSE', 'CONSULTANT_PRIVATE', '72000000-0000-4000-8000-000000000001', 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000018', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'ARTIFACT', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000019', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'ARTIFACT', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000020', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', null, 'IDENTITY_ELEMENT', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000021', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', null, 'IDENTITY_ELEMENT', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000022', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', null, 'ORGANIZATIONAL_DNA', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000023', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'FUTURE_STATE_NARRATIVE', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000024', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'FUTURE_STATE_PRINCIPLE', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000025', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'FUTURE_STATE', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000026', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'ORGANIZATIONAL_BLUEPRINT', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000027', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'RECORD_REVIEW', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000028', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'RECORD_REVIEW', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000029', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'RECORD_REVIEW', 'CONSULTANT_PRIVATE', '72000000-0000-4000-8000-000000000001', 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000030', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'RISK', 'CONSULTANT_PRIVATE', '72000000-0000-4000-8000-000000000001', 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000035', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'INSIGHT', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000036', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'RECORD_REVIEW', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74b00000-0000-4000-8000-000000000001', 'ebbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', null, 'RISK', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000003');

insert into consulting_os.evidence_sources
  (id, organization_id, source_type, title, captured_at, provenance_context, created_by)
values
  ('74000000-0000-4000-8000-000000000001', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'INTERVIEW', 'Leadership interview', '2026-01-10', 'Consent-recorded interview', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000002', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'ASSESSMENT', 'Emergence 360 administration', '2026-01-11', 'Organizational inquiry; not a diagnosis', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000003', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'UPLOADED_DOCUMENT', 'Workflow export', '2026-01-09', 'Synthetic workflow source', '72000000-0000-4000-8000-000000000001');

insert into consulting_os.evidence_fragments
  (id, organization_id, evidence_source_id, locator_kind, locator, content_text, content_sha256, created_by)
values
  ('75000000-0000-4000-8000-000000000001', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000001', 'QUESTION_RESPONSE', '{"question":"authority-1"}', 'Routine decisions return to senior leaders.', repeat('a',64), '72000000-0000-4000-8000-000000000001'),
  ('75000000-0000-4000-8000-000000000002', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000002', 'ASSESSMENT_ITEM', '{"item":"authority-1"}', 'Anonymous response value 4.', repeat('b',64), '72000000-0000-4000-8000-000000000001'),
  ('75000000-0000-4000-8000-000000000003', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000003', 'ROW_RANGE', '{"rows":[1,12]}', 'Twelve decisions escalated.', repeat('c',64), '72000000-0000-4000-8000-000000000001');

insert into consulting_os.evidence_items
  (id, organization_id, primary_fragment_id, evidence_type, relevance_note, created_by)
values
  ('74000000-0000-4000-8000-000000000004', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '75000000-0000-4000-8000-000000000003', 'WORKFLOW_RECORD', 'Direct evidence of repeated escalation.', '72000000-0000-4000-8000-000000000001');

insert into consulting_os.observations
  (id, organization_id, statement, observation_type, observed_at, context, primary_evidence_id, initial_review_state, created_by)
values
  ('74000000-0000-4000-8000-000000000005', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Twelve routine decisions escalated.', 'DIRECT_MEASUREMENT', '2026-01-09', 'Workflow sample', '74000000-0000-4000-8000-000000000004', 'ACCEPTED', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.patterns
  (id, organization_id, statement, scope, recurrence_basis, contrary_evidence_summary, initial_review_state, created_by)
values
  ('74000000-0000-4000-8000-000000000006', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Decision authority repeatedly escalates upward.', 'Cross-functional workflows', 'Twelve records plus interview corroboration.', 'Two low-risk categories were delegated.', 'UNDER_REVIEW', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.assumptions
  (id, organization_id, logical_id, version_number, statement, holder_scope, assumption_status, initial_review_state, confidence_level, confidence_rationale, review_trigger, effective_from, created_by)
values
  ('74000000-0000-4000-8000-000000000007', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74100000-0000-4000-8000-000000000001', 1, 'Senior review is required for decision quality.', 'Leadership', 'CHALLENGED', 'UNDER_REVIEW', 'MODERATE', 'Evidence is mixed.', 'Review after delegation trial.', '2026-01-01', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.risks
  (id, organization_id, statement, affected_scope, severity, rationale, initial_review_state, created_by)
values
  ('74000000-0000-4000-8000-000000000008', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Escalation may slow time-sensitive work.', 'Operating model', 'HIGH', 'Repeated delay is present across workflows.', 'ACCEPTED', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000030', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Consultant-only candidate risk.', 'Early analysis', 'MODERATE', 'Not ready for client visibility.', 'UNDER_REVIEW', '72000000-0000-4000-8000-000000000001'),
  ('74b00000-0000-4000-8000-000000000001', 'ebbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'Other-tenant risk.', 'Other tenant', 'LOW', 'Structural isolation fixture.', 'DRAFT', '72000000-0000-4000-8000-000000000003');
insert into consulting_os.strengths
  (id, organization_id, statement, scope, value_produced, protection_rationale, initial_review_state, created_by)
values
  ('74000000-0000-4000-8000-000000000009', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Leaders are highly available.', 'Leadership', 'Rapid exception resolution.', 'Preserve access while reducing routine dependence.', 'ACCEPTED', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.unrealized_potentials
  (id, organization_id, statement, scope, existing_capacity, constraint_summary, initial_review_state, created_by)
values
  ('74000000-0000-4000-8000-000000000010', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Team leads can exercise more routine judgment.', 'Team leads', 'Strong operational knowledge.', 'Decision boundaries are not explicit.', 'ACCEPTED', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.diagnoses
  (id, organization_id, statement, scope, rationale, alternatives_considered, limitations, initial_review_state, created_by)
values
  ('74000000-0000-4000-8000-000000000011', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Authority architecture is the primary present constraint.', 'Decision workflows', 'Evidence converges across records and interviews.', 'Initiative and capability explanations were considered.', 'Applies to selected routine decisions.', 'UNDER_REVIEW', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000012', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Private alternative diagnosis.', 'Consultant analysis', 'Early evidence only.', 'Multiple alternatives remain open.', 'Not ready for client use.', 'UNDER_REVIEW', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.insights
  (id, organization_id, statement, rationale, limitations, initial_review_state, created_by)
values
  ('74000000-0000-4000-8000-000000000035', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Purpose-consistent authority can move closer to the work.', 'Reviewed evidence supports bounded delegation.', 'Requires explicit boundaries.', 'UNDER_REVIEW', '72000000-0000-4000-8000-000000000001');

insert into consulting_os.interviews
  (id, organization_id, engagement_id, evidence_source_id, participant_person_id, participant_label, interviewer_person_id, guide_name, guide_version, interview_status, conducted_at, consent_recorded, created_by)
values
  ('74000000-0000-4000-8000-000000000013', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', '74000000-0000-4000-8000-000000000001', '72000000-0000-4000-8000-000000000002', 'Client stakeholder', '72000000-0000-4000-8000-000000000001', 'SEE REALITY interview', '1.0', 'COMPLETED', '2026-01-10', true, '72000000-0000-4000-8000-000000000001');
insert into consulting_os.interview_responses
  (id, organization_id, interview_id, question_key, question_text, response_text, evidence_fragment_id, source_locator, created_by)
values
  ('74000000-0000-4000-8000-000000000014', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000013', 'authority-1', 'Where do routine decisions go?', 'Routine decisions return to senior leaders.', '75000000-0000-4000-8000-000000000001', 'Question authority-1', '72000000-0000-4000-8000-000000000001');

insert into consulting_os.assessment_instruments
  (id, organization_id, name, framework_name, instrument_status, validation_claim_status, created_by)
values
  ('74000000-0000-4000-8000-000000000015', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Emergence 360 Inquiry', 'Emergence 360', 'ACTIVE', 'NOT_VALIDATED', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.assessment_instrument_versions
  (id, organization_id, instrument_id, version_number, version_label, dimensions, scoring_rules, compatibility_key, published_at, created_by)
values
  ('76000000-0000-4000-8000-000000000001', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000015', 1, '1.0', '["AUTHORITY"]', '{"method":"descriptive"}', 'authority-v1-compatible', '2026-01-01', '72000000-0000-4000-8000-000000000001'),
  ('76000000-0000-4000-8000-000000000002', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000015', 2, '2.0', '["AUTHORITY"]', '{"method":"descriptive"}', 'authority-v1-compatible', '2026-02-01', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.assessment_items
  (id, organization_id, instrument_version_id, item_key, prompt, dimension_key, response_type, ordinal, created_by)
values
  ('76100000-0000-4000-8000-000000000001', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '76000000-0000-4000-8000-000000000001', 'authority-1', 'Decision authority is clear.', 'AUTHORITY', 'LIKERT', 1, '72000000-0000-4000-8000-000000000001'),
  ('76100000-0000-4000-8000-000000000002', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '76000000-0000-4000-8000-000000000002', 'authority-1', 'Decision authority is clear and usable.', 'AUTHORITY', 'LIKERT', 1, '72000000-0000-4000-8000-000000000001');
insert into consulting_os.assessment_administrations
  (id, organization_id, engagement_id, instrument_version_id, evidence_source_id, audience_description, opens_at, closes_at, confidentiality, minimum_reporting_cohort, administration_status, created_by)
values
  ('74000000-0000-4000-8000-000000000016', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', '76000000-0000-4000-8000-000000000001', '74000000-0000-4000-8000-000000000002', 'Cross-functional leaders', '2026-01-10', '2026-01-20', 'ANONYMOUS', 3, 'CLOSED', '72000000-0000-4000-8000-000000000001');
insert into consulting_private.assessment_responses
  (id, organization_id, administration_id, item_id, participant_token_hash, response_value, evidence_fragment_id, submitted_at, created_by)
values
  ('74000000-0000-4000-8000-000000000017', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000016', '76100000-0000-4000-8000-000000000001', repeat('d',64), '{"value":4}', '75000000-0000-4000-8000-000000000002', '2026-01-15', '72000000-0000-4000-8000-000000000001');

insert into consulting_os.identity_elements
  (id, organization_id, logical_id, version_number, element_type, statement, rationale, effective_from, supersedes_id, created_by)
values
  ('74000000-0000-4000-8000-000000000020', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74200000-0000-4000-8000-000000000001', 1, 'PURPOSE', 'We provide dependable service through senior oversight.', 'Historical identity statement.', '2020-01-01', null, '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000021', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74200000-0000-4000-8000-000000000001', 2, 'PURPOSE', 'We cultivate dependable judgment throughout the organization.', 'Reviewed current identity statement.', '2021-01-01', '74000000-0000-4000-8000-000000000020', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.organizational_dna_versions
  (id, organization_id, logical_id, version_number, rationale, effective_from, approved_by, approved_at, created_by)
values
  ('74000000-0000-4000-8000-000000000022', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74300000-0000-4000-8000-000000000001', 1, 'Purpose-consistent judgment is reproducible without conformity.', '2021-01-01', '72000000-0000-4000-8000-000000000001', '2021-01-01', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.organizational_dna_elements
  (organization_id, dna_version_id, identity_element_id, inclusion_rationale, ordinal, created_by)
values
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000022', '74000000-0000-4000-8000-000000000021', 'Current purpose is essential to transferable judgment.', 1, '72000000-0000-4000-8000-000000000001');
insert into consulting_os.future_state_narratives
  (id, organization_id, logical_id, version_number, what_was_true, what_changed, what_is_true_now, what_that_means, what_must_become_true_next, what_could_become_possible, effective_from, approved_by, approved_at, created_by)
values
  ('74000000-0000-4000-8000-000000000023', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74400000-0000-4000-8000-000000000001', 1, 'Senior leaders held most authority.', 'Work became faster and more distributed.', 'Team leads already exercise operational judgment.', 'Authority architecture must reflect demonstrated capability.', 'Boundaries and escalation criteria must become explicit.', 'Purpose-consistent decisions can happen closer to the work.', '2021-01-01', '72000000-0000-4000-8000-000000000001', '2021-01-01', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.future_state_principles
  (id, organization_id, logical_id, version_number, narrative_id, statement, rationale, effective_from, created_by)
values
  ('74000000-0000-4000-8000-000000000024', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74500000-0000-4000-8000-000000000001', 1, '74000000-0000-4000-8000-000000000023', 'Authority should expand alongside demonstrated capability.', 'This preserves quality while reducing dependence.', '2021-01-01', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.future_states
  (id, organization_id, logical_id, version_number, state_domain, current_baseline, desired_condition, horizon_date, effective_from, created_by)
values
  ('74000000-0000-4000-8000-000000000025', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74600000-0000-4000-8000-000000000001', 1, 'AUTHORITY', 'Routine decisions escalate upward.', 'Defined routine decisions occur with team leads inside explicit boundaries.', '2027-01-01', '2021-01-01', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.organizational_blueprints
  (id, organization_id, logical_id, version_number, title, rationale, artifact_status, effective_from, approved_by, approved_at, created_by)
values
  ('74000000-0000-4000-8000-000000000026', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74700000-0000-4000-8000-000000000001', 1, 'Authority Future Blueprint', 'Approved future-state aggregate.', 'APPROVED', '2021-01-01', '72000000-0000-4000-8000-000000000001', '2021-01-01', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.blueprint_members
  (organization_id, blueprint_id, member_type, member_id, domain_key, inclusion_rationale, ordinal, created_by)
values
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000026', 'ORGANIZATIONAL_DNA', '74000000-0000-4000-8000-000000000022', 'IDENTITY', 'DNA constrains the future design.', 1, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000026', 'FUTURE_STATE_NARRATIVE', '74000000-0000-4000-8000-000000000023', 'NARRATIVE', 'Narrative gives meaning to the future design.', 2, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000026', 'FUTURE_STATE_PRINCIPLE', '74000000-0000-4000-8000-000000000024', 'PRINCIPLE', 'Principle constrains downstream alignment.', 3, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000026', 'FUTURE_STATE', '74000000-0000-4000-8000-000000000025', 'AUTHORITY', 'Structured desired condition is approved.', 4, '72000000-0000-4000-8000-000000000001');

insert into consulting_os.artifacts
  (id, organization_id, logical_id, version_number, artifact_type, title, artifact_status, effective_from, approved_by, approved_at, created_by)
values
  ('74000000-0000-4000-8000-000000000018', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74800000-0000-4000-8000-000000000001', 1, 'ORGANIZATIONAL_PORTRAIT', 'Organizational Portrait', 'APPROVED', '2026-01-20', '72000000-0000-4000-8000-000000000001', '2026-01-20', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000019', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74800000-0000-4000-8000-000000000002', 1, 'CURRENT_STATE_REALITY_MAP', 'Current-State Reality Map', 'APPROVED', '2026-01-20', '72000000-0000-4000-8000-000000000001', '2026-01-20', '72000000-0000-4000-8000-000000000001');
insert into consulting_os.artifact_sections
  (id, organization_id, artifact_id, section_key, heading, narrative, ordinal, created_by)
values
  ('77000000-0000-4000-8000-000000000001', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', 'PURPOSE_IDENTITY', 'Purpose and Identity', 'The current purpose centers dependable judgment.', 1, '72000000-0000-4000-8000-000000000001'),
  ('77000000-0000-4000-8000-000000000002', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', 'HISTORY_CONTEXT', 'History and Context', 'Growth increased coordination demand.', 2, '72000000-0000-4000-8000-000000000001'),
  ('77000000-0000-4000-8000-000000000003', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', 'PEOPLE_STAKEHOLDERS', 'People and Stakeholders', 'Leaders and team leads hold different perspectives.', 3, '72000000-0000-4000-8000-000000000001'),
  ('77000000-0000-4000-8000-000000000004', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', 'CULTURE_BEHAVIORS', 'Culture and Behaviors', 'Availability is rewarded while escalation is normalized.', 4, '72000000-0000-4000-8000-000000000001'),
  ('77000000-0000-4000-8000-000000000005', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', 'STRUCTURE_ROLES', 'Structure and Roles', 'Decision rights are concentrated.', 5, '72000000-0000-4000-8000-000000000001'),
  ('77000000-0000-4000-8000-000000000006', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', 'WORKFLOWS', 'Workflows', 'Routine work repeatedly escalates.', 6, '72000000-0000-4000-8000-000000000001'),
  ('77000000-0000-4000-8000-000000000007', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', 'SYSTEMS_TECHNOLOGY', 'Systems and Technology', 'Workflow tooling reflects approval concentration.', 7, '72000000-0000-4000-8000-000000000001'),
  ('77000000-0000-4000-8000-000000000008', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', 'RELATIONSHIPS', 'Relationships', 'Leader availability is a present strength.', 8, '72000000-0000-4000-8000-000000000001'),
  ('77000000-0000-4000-8000-000000000009', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', 'VALUE_OUTCOMES', 'Value and Outcomes', 'Fast exception resolution produces value.', 9, '72000000-0000-4000-8000-000000000001'),
  ('77000000-0000-4000-8000-000000000010', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', 'CURRENT_PRESSURES', 'Current Pressures', 'Growth makes routine escalation unsustainable.', 10, '72000000-0000-4000-8000-000000000001'),
  ('77100000-0000-4000-8000-000000000001', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', 'OBSERVABLE_EVIDENCE', 'Observable Evidence', 'Workflow records demonstrate escalation.', 1, '72000000-0000-4000-8000-000000000001'),
  ('77100000-0000-4000-8000-000000000002', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', 'STAKEHOLDER_PERSPECTIVES', 'Stakeholder Perspectives', 'Stakeholders report concentrated authority.', 2, '72000000-0000-4000-8000-000000000001'),
  ('77100000-0000-4000-8000-000000000003', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', 'WORKFLOWS', 'Workflows', 'Routine work crosses unnecessary approvals.', 3, '72000000-0000-4000-8000-000000000001'),
  ('77100000-0000-4000-8000-000000000004', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', 'SYSTEM_INTERACTIONS', 'System Interactions', 'Approval routing amplifies delay.', 4, '72000000-0000-4000-8000-000000000001'),
  ('77100000-0000-4000-8000-000000000005', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', 'CULTURE_SIGNALS', 'Culture Signals', 'Availability and escalation are both normalized.', 5, '72000000-0000-4000-8000-000000000001'),
  ('77100000-0000-4000-8000-000000000006', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', 'FRICTION_POINTS', 'Friction Points', 'Routine decisions wait for senior review.', 6, '72000000-0000-4000-8000-000000000001'),
  ('77100000-0000-4000-8000-000000000007', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', 'RISKS', 'Risks', 'Delay may compound as the organization grows.', 7, '72000000-0000-4000-8000-000000000001'),
  ('77100000-0000-4000-8000-000000000008', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', 'STRENGTHS', 'Strengths', 'Leaders remain accessible.', 8, '72000000-0000-4000-8000-000000000001'),
  ('77100000-0000-4000-8000-000000000009', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', 'UNREALIZED_POTENTIAL', 'Unrealized Potential', 'Team leads have underused judgment.', 9, '72000000-0000-4000-8000-000000000001'),
  ('77100000-0000-4000-8000-000000000010', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', 'ASSUMPTION_REGISTER', 'Assumption Register', 'The quality assumption remains challenged.', 10, '72000000-0000-4000-8000-000000000001');

insert into consulting_os.artifact_members
  (organization_id, artifact_id, section_id, member_type, member_id, member_note, ordinal, created_by)
values
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', '77000000-0000-4000-8000-000000000001', 'IDENTITY_ELEMENT', '74000000-0000-4000-8000-000000000021', 'Current purpose.', 1, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', '77000000-0000-4000-8000-000000000002', 'EVIDENCE', '74000000-0000-4000-8000-000000000004', 'Historical workflow evidence.', 2, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', '77000000-0000-4000-8000-000000000003', 'OBSERVATION', '74000000-0000-4000-8000-000000000005', 'Stakeholder context.', 3, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', '77000000-0000-4000-8000-000000000004', 'PATTERN', '74000000-0000-4000-8000-000000000006', 'Cultural recurrence.', 4, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', '77000000-0000-4000-8000-000000000005', 'EVIDENCE', '74000000-0000-4000-8000-000000000004', 'Structure evidence.', 5, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', '77000000-0000-4000-8000-000000000006', 'PATTERN', '74000000-0000-4000-8000-000000000006', 'Workflow pattern.', 6, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', '77000000-0000-4000-8000-000000000007', 'RISK', '74000000-0000-4000-8000-000000000008', 'System interaction risk.', 7, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', '77000000-0000-4000-8000-000000000008', 'STRENGTH', '74000000-0000-4000-8000-000000000009', 'Relationship strength.', 8, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', '77000000-0000-4000-8000-000000000009', 'STRENGTH', '74000000-0000-4000-8000-000000000009', 'Value-producing strength.', 9, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000018', '77000000-0000-4000-8000-000000000010', 'UNREALIZED_POTENTIAL', '74000000-0000-4000-8000-000000000010', 'Current pressure and possibility.', 10, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000001', 'EVIDENCE', '74000000-0000-4000-8000-000000000004', 'Observable source.', 1, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000002', 'OBSERVATION', '74000000-0000-4000-8000-000000000005', 'Stakeholder observation.', 2, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000003', 'PATTERN', '74000000-0000-4000-8000-000000000006', 'Workflow pattern.', 3, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000004', 'RISK', '74000000-0000-4000-8000-000000000008', 'System risk.', 4, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000005', 'STRENGTH', '74000000-0000-4000-8000-000000000009', 'Culture strength.', 5, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000006', 'PATTERN', '74000000-0000-4000-8000-000000000006', 'Friction pattern.', 6, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000007', 'RISK', '74000000-0000-4000-8000-000000000008', 'Reviewed risk.', 7, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000008', 'STRENGTH', '74000000-0000-4000-8000-000000000009', 'Protected strength.', 8, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000009', 'UNREALIZED_POTENTIAL', '74000000-0000-4000-8000-000000000010', 'Existing possibility.', 9, '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000010', 'ASSUMPTION', '74000000-0000-4000-8000-000000000007', 'Assumption under review.', 10, '72000000-0000-4000-8000-000000000001');

insert into consulting_os.record_reviews
  (id, organization_id, subject_id, review_action, reviewer_person_id, rationale, evidence_considered, contrary_evidence, limitations, reviewed_at, created_by)
values
  ('74000000-0000-4000-8000-000000000027', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000006', 'ACCEPTED', '72000000-0000-4000-8000-000000000001', 'Recurrence is sufficient for pattern status.', 'Workflow and interview evidence.', 'Two delegated categories.', 'Scoped to sampled workflows.', '2026-01-20', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000028', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000011', 'VALIDATED', '72000000-0000-4000-8000-000000000001', 'Best current explanation for the scoped condition.', 'Workflow, interview, observation, and pattern.', 'Initiative and capability alternatives remain plausible in some areas.', 'Not a permanent or organization-wide truth.', '2026-01-20', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000029', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000012', 'VALIDATED', '72000000-0000-4000-8000-000000000001', 'Private working conclusion only.', 'Early consultant analysis.', 'Several alternatives remain.', 'Not approved for client visibility.', '2026-01-20', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000036', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000035', 'VALIDATED', '72000000-0000-4000-8000-000000000001', 'Sufficient for identity and narrative work.', 'Reviewed evidence chain.', 'Authority remains bounded.', 'Applies to selected decision domains.', '2026-01-20', '72000000-0000-4000-8000-000000000001');

insert into consulting_os.entity_relationships
  (organization_id, engagement_id, relationship_type, source_type, source_id, target_type, target_id, origin, review_status, rationale, created_by)
values
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'SUPPORTED_BY', 'OBSERVATION', '74000000-0000-4000-8000-000000000005', 'EVIDENCE', '74000000-0000-4000-8000-000000000004', 'HUMAN', 'ACCEPTED', 'Observation is source-grounded.', '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'CONTRIBUTES_TO', 'OBSERVATION', '74000000-0000-4000-8000-000000000005', 'PATTERN', '74000000-0000-4000-8000-000000000006', 'HUMAN', 'ACCEPTED', 'Observation contributes to recurrence.', '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'SUPPORTED_BY', 'ASSUMPTION', '74000000-0000-4000-8000-000000000007', 'EVIDENCE', '74000000-0000-4000-8000-000000000004', 'HUMAN', 'ACCEPTED', 'Some evidence supports quality concern.', '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'CHALLENGED_BY', 'ASSUMPTION', '74000000-0000-4000-8000-000000000007', 'OBSERVATION', '74000000-0000-4000-8000-000000000005', 'HUMAN', 'ACCEPTED', 'Observed delay challenges the assumption.', '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'VALIDATES', 'RECORD_REVIEW', '74000000-0000-4000-8000-000000000028', 'DIAGNOSIS', '74000000-0000-4000-8000-000000000011', 'HUMAN', 'ACCEPTED', 'Authorized review validates shared diagnosis.', '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'VALIDATES', 'RECORD_REVIEW', '74000000-0000-4000-8000-000000000029', 'DIAGNOSIS', '74000000-0000-4000-8000-000000000012', 'HUMAN', 'ACCEPTED', 'Authorized review retains private conclusion.', '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'VALIDATES', 'RECORD_REVIEW', '74000000-0000-4000-8000-000000000036', 'INSIGHT', '74000000-0000-4000-8000-000000000035', 'HUMAN', 'ACCEPTED', 'Authorized review validates insight.', '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'DERIVED_FROM', 'IDENTITY_ELEMENT', '74000000-0000-4000-8000-000000000021', 'INSIGHT', '74000000-0000-4000-8000-000000000035', 'HUMAN', 'ACCEPTED', 'Current identity derives from reviewed insight.', '72000000-0000-4000-8000-000000000001'),
  ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', 'DERIVED_FROM', 'FUTURE_STATE_NARRATIVE', '74000000-0000-4000-8000-000000000023', 'INSIGHT', '74000000-0000-4000-8000-000000000035', 'HUMAN', 'ACCEPTED', 'Narrative derives from reviewed insight.', '72000000-0000-4000-8000-000000000001');

select results_eq(
  $$select is_complete from consulting_os.artifact_completion where id = '74000000-0000-4000-8000-000000000018'$$,
  array[true], 'Organizational Portrait is complete as a structured artifact'
);
select results_eq(
  $$select is_complete from consulting_os.artifact_completion where id = '74000000-0000-4000-8000-000000000019'$$,
  array[true], 'Current-State Reality Map is complete as a structured artifact'
);
select results_eq($$select count(*) from consulting_os.artifact_sections where artifact_id = '74000000-0000-4000-8000-000000000018'$$, array[10::bigint], 'Portrait retains ten explicit sections');
select results_eq($$select count(*) from consulting_os.artifact_sections where artifact_id = '74000000-0000-4000-8000-000000000019'$$, array[10::bigint], 'Reality Map retains the ten canonical sections');
select results_eq($$select count(*) from consulting_os.artifact_members where artifact_id = '74000000-0000-4000-8000-000000000019'$$, array[10::bigint], 'Reality Map is composed from typed domain members');
select results_eq(
  $$select count(*) from consulting_os.interview_responses r join consulting_os.evidence_fragments f on f.id = r.evidence_fragment_id join consulting_os.interviews i on i.id = r.interview_id where f.evidence_source_id = i.evidence_source_id$$,
  array[1::bigint], 'Interview response retains exact source-fragment provenance'
);

insert into consulting_os.domain_objects (id, organization_id, object_type, visibility_scope, origin, created_by)
values ('74000000-0000-4000-8000-000000000038', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'INTERVIEW_RESPONSE', 'ORGANIZATION_SHARED', 'HUMAN', '72000000-0000-4000-8000-000000000001');
select throws_ok(
  $$insert into consulting_os.interview_responses (id, organization_id, interview_id, question_key, question_text, response_text, evidence_fragment_id, source_locator, created_by) values ('74000000-0000-4000-8000-000000000038', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000013', 'wrong-source', 'Wrong source?', 'No.', '75000000-0000-4000-8000-000000000003', 'Wrong fragment', '72000000-0000-4000-8000-000000000001')$$,
  null, null, 'Interview response cannot cite a fragment from another source'
);
select results_eq($$select v.version_number from consulting_private.assessment_responses r join consulting_os.assessment_administrations a on a.id = r.administration_id and a.organization_id = r.organization_id join consulting_os.assessment_instrument_versions v on v.id = a.instrument_version_id and v.organization_id = a.organization_id where r.id = '74000000-0000-4000-8000-000000000017'$$, array[1], 'Assessment response remains attached to administered version 1');
select results_eq($$select count(*) from consulting_os.assessment_instrument_versions where instrument_id = '74000000-0000-4000-8000-000000000015'$$, array[2::bigint], 'Assessment revisions create separate versions');
select results_eq($$select count(distinct compatibility_key) from consulting_os.assessment_instrument_versions where instrument_id = '74000000-0000-4000-8000-000000000015'$$, array[1::bigint], 'Compatible assessment versions retain an explicit comparison key');
select throws_ok($$update consulting_os.assessment_instrument_versions set scoring_rules = '{"method":"changed"}' where id = '76000000-0000-4000-8000-000000000001'$$, null, null, 'Administered assessment version is immutable');

insert into consulting_os.domain_objects (id, organization_id, object_type, visibility_scope, owner_person_id, origin, created_by)
values
  ('74000000-0000-4000-8000-000000000032', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'ASSESSMENT_RESPONSE', 'CONSULTANT_PRIVATE', '72000000-0000-4000-8000-000000000001', 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000033', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'ASSESSMENT_RESPONSE', 'CONSULTANT_PRIVATE', '72000000-0000-4000-8000-000000000001', 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000034', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'ASSESSMENT_ADMINISTRATION', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001'),
  ('74000000-0000-4000-8000-000000000031', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'ASSESSMENT_INSTRUMENT', 'ORGANIZATION_SHARED', null, 'HUMAN', '72000000-0000-4000-8000-000000000001');
select throws_ok(
  $$insert into consulting_private.assessment_responses (id, organization_id, administration_id, item_id, participant_token_hash, response_value, evidence_fragment_id, submitted_at, created_by) values ('74000000-0000-4000-8000-000000000032', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000016', '76100000-0000-4000-8000-000000000002', repeat('e',64), '{"value":3}', '75000000-0000-4000-8000-000000000002', now(), '72000000-0000-4000-8000-000000000001')$$,
  null, null, 'Response cannot use an item from a different instrument version'
);
select throws_ok(
  $$insert into consulting_private.assessment_responses (id, organization_id, administration_id, item_id, respondent_person_id, participant_token_hash, response_value, evidence_fragment_id, submitted_at, created_by) values ('74000000-0000-4000-8000-000000000033', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000016', '76100000-0000-4000-8000-000000000001', '72000000-0000-4000-8000-000000000002', repeat('f',64), '{"value":3}', '75000000-0000-4000-8000-000000000002', now(), '72000000-0000-4000-8000-000000000001')$$,
  null, null, 'Anonymous response cannot retain respondent identity'
);
select throws_ok(
  $$insert into consulting_os.assessment_administrations (id, organization_id, engagement_id, instrument_version_id, evidence_source_id, audience_description, opens_at, closes_at, confidentiality, minimum_reporting_cohort, administration_status, created_by) values ('74000000-0000-4000-8000-000000000034', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '73000000-0000-4000-8000-000000000001', '76000000-0000-4000-8000-000000000002', '74000000-0000-4000-8000-000000000002', 'Too-small cohort', now(), now() + interval '1 day', 'ANONYMOUS', 2, 'DRAFT', '72000000-0000-4000-8000-000000000001')$$,
  null, null, 'Anonymous administration requires a minimum reporting cohort'
);
select throws_ok(
  $$insert into consulting_os.assessment_instruments (id, organization_id, name, framework_name, instrument_status, validation_claim_status, created_by) values ('74000000-0000-4000-8000-000000000031', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Unsupported validation claim', 'Emergence 360', 'DRAFT', 'VALIDATED', '72000000-0000-4000-8000-000000000001')$$,
  null, null, 'Instrument cannot imply validation without a documented basis'
);
select results_eq($$select count(*) from consulting_os.entity_relationships where source_id = '74000000-0000-4000-8000-000000000005' and relationship_type = 'SUPPORTED_BY'$$, array[1::bigint], 'Observation is source-grounded');
select results_eq($$select current_review_state from consulting_os.epistemic_record_states where id = '74000000-0000-4000-8000-000000000006'$$, array['ACCEPTED'::consulting_os.epistemic_review_state], 'Pattern review is explicit');
select results_eq($$select supporting_links from consulting_os.assumption_register where id = '74000000-0000-4000-8000-000000000007'$$, array[1::bigint], 'Assumption Register counts evidence for');
select results_eq($$select challenging_links from consulting_os.assumption_register where id = '74000000-0000-4000-8000-000000000007'$$, array[1::bigint], 'Assumption Register counts evidence against');
select results_eq($$select count(*) from consulting_os.operative_epistemic_records where id in ('74000000-0000-4000-8000-000000000008','74000000-0000-4000-8000-000000000009','74000000-0000-4000-8000-000000000010')$$, array[3::bigint], 'Risk, Strength, and Unrealized Potential remain distinct operative types');
select results_eq($$select current_review_state from consulting_os.epistemic_record_states where id = '74000000-0000-4000-8000-000000000011'$$, array['VALIDATED'::consulting_os.epistemic_review_state], 'Diagnosis requires and retains human validation');
select results_eq($$select count(*) from consulting_os.client_visible_validated_conclusions where id in ('74000000-0000-4000-8000-000000000011','74000000-0000-4000-8000-000000000035')$$, array[2::bigint], 'Validated shared Insight and Diagnosis become client-visible conclusions');
select results_eq($$select count(*) from consulting_os.client_visible_validated_conclusions where id = '74000000-0000-4000-8000-000000000012'$$, array[0::bigint], 'Validated consultant-private Diagnosis is never promoted by the shared view');
select results_eq(
  $$select (what_was_true <> '' and what_changed <> '' and what_is_true_now <> '' and what_that_means <> '' and what_must_become_true_next <> '' and what_could_become_possible <> '') from consulting_os.future_state_narratives where id = '74000000-0000-4000-8000-000000000023'$$,
  array[true], 'Future-State Narrative preserves all six canonical fields'
);
select results_eq($$select count(*) from consulting_os.organizational_dna_elements where dna_version_id = '74000000-0000-4000-8000-000000000022'$$, array[1::bigint], 'Organizational DNA is a curated identity composition');
select results_eq($$select id from consulting_os.current_identity_elements where logical_id = '74200000-0000-4000-8000-000000000001'$$, array['74000000-0000-4000-8000-000000000021'::uuid], 'Current identity projection returns version 2');
select results_eq($$select count(*) from consulting_os.identity_elements where logical_id = '74200000-0000-4000-8000-000000000001'$$, array[2::bigint], 'Historical identity version remains queryable');
select results_eq($$select id from consulting_os.current_future_states where logical_id = '74600000-0000-4000-8000-000000000001'$$, array['74000000-0000-4000-8000-000000000025'::uuid], 'Current Future State remains a structured desired condition');
select results_eq($$select count(*) from consulting_os.blueprint_members where blueprint_id = '74000000-0000-4000-8000-000000000026'$$, array[4::bigint], 'Blueprint materializes approved identity and future-state members');
select results_eq($$select count(*) from consulting_os.current_organizational_blueprints where id = '74000000-0000-4000-8000-000000000026'$$, array[1::bigint], 'Approved Blueprint is available through current-state projection');
select throws_ok($$update consulting_os.identity_elements set statement = 'Overwrite history' where id = '74000000-0000-4000-8000-000000000021'$$, null, null, 'Meaning-changing identity edits require a new version');

insert into consulting_os.domain_objects (id, organization_id, object_type, visibility_scope, origin, created_by)
values ('74000000-0000-4000-8000-000000000037', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'IDENTITY_ELEMENT', 'ORGANIZATION_SHARED', 'HUMAN', '72000000-0000-4000-8000-000000000001');
select throws_ok(
  $$insert into consulting_os.identity_elements (id, organization_id, logical_id, version_number, element_type, statement, rationale, effective_from, supersedes_id, created_by) values ('74000000-0000-4000-8000-000000000037', 'eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74200000-0000-4000-8000-000000000099', 2, 'PURPOSE', 'Wrong chain.', 'Must fail.', '2022-01-01', '74000000-0000-4000-8000-000000000021', '72000000-0000-4000-8000-000000000001')$$,
  null, null, 'Version chain cannot switch logical identity'
);
select throws_ok(
  $$insert into consulting_os.artifact_sections (organization_id, artifact_id, section_key, heading, narrative, ordinal, created_by) values ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', 'EXECUTIVE_SUMMARY', 'Invalid', 'Invalid section.', 11, '72000000-0000-4000-8000-000000000001')$$,
  null, null, 'Reality Map rejects ungoverned report sections'
);
select throws_ok(
  $$insert into consulting_os.artifact_members (organization_id, artifact_id, section_id, member_type, member_id, member_note, ordinal, created_by) values ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000007', 'IDENTITY_ELEMENT', '74000000-0000-4000-8000-000000000021', 'Wrong type.', 11, '72000000-0000-4000-8000-000000000001')$$,
  null, null, 'Reality Map section enforces typed member vocabulary'
);
select throws_ok(
  $$insert into consulting_os.artifact_members (organization_id, artifact_id, section_id, member_type, member_id, member_note, ordinal, created_by) values ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000007', 'RISK', '74000000-0000-4000-8000-000000000030', 'Private candidate.', 11, '72000000-0000-4000-8000-000000000001')$$,
  null, null, 'Client-visible artifact cannot broaden consultant-private analysis'
);
select results_eq(
  $$select consulting_security.visibility_can_contain('COACHING_SHARED', 'CONSULTANT_PRIVATE')$$,
  array[false], 'Coaching-shared scope cannot broaden consultant-private analysis'
);
select throws_ok(
  $$insert into consulting_os.artifact_members (organization_id, artifact_id, section_id, member_type, member_id, member_note, ordinal, created_by) values ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000007', 'RISK', '74b00000-0000-4000-8000-000000000001', 'Cross tenant.', 11, '72000000-0000-4000-8000-000000000001')$$,
  null, null, 'Artifact composition cannot cross organization boundary'
);
select results_eq($$select count(*) from consulting_os.entity_relationships where source_id in ('74000000-0000-4000-8000-000000000021','74000000-0000-4000-8000-000000000023') and relationship_type = 'DERIVED_FROM' and target_id = '74000000-0000-4000-8000-000000000035'$$, array[2::bigint], 'Identity and Future-State Narrative retain reviewed Insight provenance');

set local role authenticated;
select set_config('request.jwt.claim.sub', '71000000-0000-4000-8000-000000000002', true);
select set_config('request.jwt.claim.role', 'authenticated', true);
select results_eq($$select count(*) from consulting_os.artifacts where id = '74000000-0000-4000-8000-000000000019'$$, array[1::bigint], 'Client member can read shared Reality Map');
select results_eq($$select count(*) from consulting_os.risks where id = '74000000-0000-4000-8000-000000000030'$$, array[0::bigint], 'Client member cannot read consultant-private risk analysis');
select results_eq($$select count(*) from consulting_os.diagnoses where id = '74000000-0000-4000-8000-000000000012'$$, array[0::bigint], 'Client member cannot read consultant-private Diagnosis');
select throws_ok($$select count(*) from consulting_private.interview_responses$$, null, null, 'Client has no direct access to physically partitioned interview responses');
select throws_ok(
  $$insert into consulting_os.artifact_members (organization_id, artifact_id, section_id, member_type, member_id, member_note, ordinal, created_by) values ('eaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '74000000-0000-4000-8000-000000000019', '77100000-0000-4000-8000-000000000001', 'EVIDENCE', '74000000-0000-4000-8000-000000000004', 'Unauthorized change.', 12, '72000000-0000-4000-8000-000000000002')$$,
  null, null, 'Client member cannot modify consultant-owned Reality Map composition'
);
select set_config('request.jwt.claim.sub', '71000000-0000-4000-8000-000000000001', true);
select results_eq($$select count(*) from consulting_os.risks where id = '74000000-0000-4000-8000-000000000030'$$, array[1::bigint], 'Assigned consultant can read their private analysis');
select set_config('request.jwt.claim.sub', '71000000-0000-4000-8000-000000000003', true);
select results_eq($$select count(*) from consulting_os.artifacts where id = '74000000-0000-4000-8000-000000000019'$$, array[0::bigint], 'Other organization cannot read the Reality Map');

reset role;

SELECT * FROM finish();
ROLLBACK;
