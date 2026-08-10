begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(27);

insert into auth.users (id, email, role, aud, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
  ('51000000-0000-4000-8000-000000000001', 'reviewer@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('51000000-0000-4000-8000-000000000002', 'member@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('51000000-0000-4000-8000-000000000003', 'other@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now());

insert into consulting_os.people (id, auth_user_id, display_name)
values
  ('52000000-0000-4000-8000-000000000001', '51000000-0000-4000-8000-000000000001', 'Authorized Reviewer'),
  ('52000000-0000-4000-8000-000000000002', '51000000-0000-4000-8000-000000000002', 'Client Member'),
  ('52000000-0000-4000-8000-000000000003', '51000000-0000-4000-8000-000000000003', 'Other Org Admin');

insert into consulting_os.organizations (id, name, slug, created_by)
values
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Meridian Partners', 'meridian-a', '52000000-0000-4000-8000-000000000001'),
  ('cbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'Meridian Partners', 'meridian-b', '52000000-0000-4000-8000-000000000003');

insert into consulting_os.organization_memberships
  (id, organization_id, person_id, platform_role, status, created_by)
values
  ('53000000-0000-4000-8000-000000000001', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '52000000-0000-4000-8000-000000000001', 'CLIENT_ADMIN', 'ACTIVE', '52000000-0000-4000-8000-000000000001'),
  ('53000000-0000-4000-8000-000000000002', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '52000000-0000-4000-8000-000000000002', 'CLIENT_MEMBER', 'ACTIVE', '52000000-0000-4000-8000-000000000001'),
  ('53000000-0000-4000-8000-000000000003', 'cbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '52000000-0000-4000-8000-000000000003', 'CLIENT_ADMIN', 'ACTIVE', '52000000-0000-4000-8000-000000000003');

insert into consulting_os.domain_objects
  (id, organization_id, object_type, visibility_scope, origin, created_by)
values
  ('54000000-0000-4000-8000-000000000001', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'EVIDENCE_SOURCE', 'ORGANIZATION_SHARED', 'IMPORTED', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000002', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'EVIDENCE', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000003', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'OBSERVATION', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000004', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'PATTERN', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000005', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'ASSUMPTION', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000006', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'HYPOTHESIS', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000007', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'INTERPRETATION', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000008', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'INTERPRETATION', 'ORGANIZATION_SHARED', 'AI', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000009', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'INSIGHT', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000010', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'DECISION', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000011', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'RECORD_REVIEW', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000012', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'RECORD_REVIEW', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000013', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'INSIGHT', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000014', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'PATTERN', 'ORGANIZATION_SHARED', 'AI', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000015', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'RECORD_REVIEW', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000001'),
  ('54b00000-0000-4000-8000-000000000001', 'cbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'EVIDENCE_SOURCE', 'ORGANIZATION_SHARED', 'IMPORTED', '52000000-0000-4000-8000-000000000003'),
  ('54b00000-0000-4000-8000-000000000002', 'cbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'EVIDENCE', 'ORGANIZATION_SHARED', 'HUMAN', '52000000-0000-4000-8000-000000000003');

insert into consulting_os.evidence_sources
  (id, organization_id, source_type, title, captured_at, provenance_context, created_by)
values
  ('54000000-0000-4000-8000-000000000001', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'UPLOADED_DOCUMENT', 'Approval workflow', '2020-01-01', 'Synthetic workflow export', '52000000-0000-4000-8000-000000000001'),
  ('54b00000-0000-4000-8000-000000000001', 'cbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'UPLOADED_DOCUMENT', 'Other tenant workflow', '2020-01-01', 'Synthetic other-tenant source', '52000000-0000-4000-8000-000000000003');

insert into consulting_os.evidence_fragments
  (id, organization_id, evidence_source_id, locator_kind, locator, content_text, content_sha256, created_by)
values
  ('55000000-0000-4000-8000-000000000001', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '54000000-0000-4000-8000-000000000001', 'ROW_RANGE', '{"rows":[1,12]}', 'Routine decisions required senior approval.', repeat('a', 64), '52000000-0000-4000-8000-000000000001'),
  ('55b00000-0000-4000-8000-000000000001', 'cbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '54b00000-0000-4000-8000-000000000001', 'ROW_RANGE', '{"rows":[1,2]}', 'Other tenant evidence.', repeat('b', 64), '52000000-0000-4000-8000-000000000003');

insert into consulting_os.evidence_items
  (id, organization_id, primary_fragment_id, evidence_type, relevance_note, created_by)
values
  ('54000000-0000-4000-8000-000000000002', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '55000000-0000-4000-8000-000000000001', 'WORKFLOW_RECORD', 'Documents approval routing.', '52000000-0000-4000-8000-000000000001'),
  ('54b00000-0000-4000-8000-000000000002', 'cbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '55b00000-0000-4000-8000-000000000001', 'WORKFLOW_RECORD', 'Other tenant evidence.', '52000000-0000-4000-8000-000000000003');

insert into consulting_os.observations
  (id, organization_id, statement, observation_type, observed_at, context, primary_evidence_id, created_by)
values
  ('54000000-0000-4000-8000-000000000003', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Routine decisions required senior approval.', 'DIRECT_MEASUREMENT', '2020-01-02', 'Approval workflow sample', '54000000-0000-4000-8000-000000000002', '52000000-0000-4000-8000-000000000001');

insert into consulting_os.patterns
  (id, organization_id, statement, scope, recurrence_basis, initial_review_state, created_by)
values
  ('54000000-0000-4000-8000-000000000004', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Decision authority repeatedly escalates upward.', 'Organization', 'Repeated across twelve workflow records.', 'ACCEPTED', '52000000-0000-4000-8000-000000000001');

insert into consulting_os.assumptions
  (id, organization_id, logical_id, version_number, statement, holder_scope, assumption_status, initial_review_state, confidence_level, review_trigger, effective_from, created_by)
values
  ('54000000-0000-4000-8000-000000000005', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '56000000-0000-4000-8000-000000000001', 1, 'Senior approval protects decision quality.', 'Leadership', 'SUPPORTED', 'ACCEPTED', 'MODERATE', 'Revisit when delegated decisions have outcome evidence.', '2020-01-01', '52000000-0000-4000-8000-000000000001');

insert into consulting_os.hypotheses
  (id, organization_id, statement, test_criteria, strengthening_evidence, weakening_evidence, initial_review_state, created_by)
values
  ('54000000-0000-4000-8000-000000000006', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Oversight may be equated with quality.', 'Compare delegation trials.', 'Lower latency without quality loss.', 'Quality declines after delegation.', 'UNDER_REVIEW', '52000000-0000-4000-8000-000000000001');

insert into consulting_os.interpretations
  (id, organization_id, statement, scope, limitations, initial_review_state, created_by)
values
  ('54000000-0000-4000-8000-000000000007', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Authority architecture may be the primary constraint.', 'Decision workflows', 'Capability evidence is incomplete.', 'UNDER_REVIEW', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000008', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Employees may lack initiative.', 'Decision workflows', 'AI candidate conflicts with direct reports.', 'SUGGESTED', '52000000-0000-4000-8000-000000000001');

insert into consulting_os.insights
  (id, organization_id, statement, rationale, limitations, initial_review_state, created_by)
values
  ('54000000-0000-4000-8000-000000000009', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Selected routine decisions can move downward with explicit boundaries.', 'Evidence and reviewed interpretation support a bounded trial.', 'Only selected decision categories were reviewed.', 'UNDER_REVIEW', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000013', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Unvalidated candidate insight.', 'Candidate only.', 'Not reviewed.', 'DRAFT', '52000000-0000-4000-8000-000000000001');

insert into consulting_os.decisions
  (id, organization_id, statement, authority_person_id, rationale, intended_effect, review_trigger, decision_status, decided_at, created_by)
values
  ('54000000-0000-4000-8000-000000000010', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Delegate defined routine decisions to team leads.', '52000000-0000-4000-8000-000000000001', 'Validated insight and operative assumption support a bounded trial.', 'Reduce decision latency without degrading quality.', 'Reconsider if quality or rework worsens.', 'APPROVED', '2021-01-01', '52000000-0000-4000-8000-000000000001');

insert into consulting_os.record_reviews
  (id, organization_id, subject_id, review_action, reviewer_person_id, rationale, evidence_considered, contrary_evidence, limitations, reviewed_at, created_by)
values
  ('54000000-0000-4000-8000-000000000011', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '54000000-0000-4000-8000-000000000009', 'VALIDATED', '52000000-0000-4000-8000-000000000001', 'Sufficient for bounded action.', 'Workflow evidence, observation, pattern, and interpretation.', 'Some teams may require different limits.', 'Applies only to selected routine decisions.', '2020-12-15', '52000000-0000-4000-8000-000000000001'),
  ('54000000-0000-4000-8000-000000000012', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '54000000-0000-4000-8000-000000000008', 'REJECTED', '52000000-0000-4000-8000-000000000001', 'Source record does not support lack of initiative.', null, null, null, '2020-12-15', '52000000-0000-4000-8000-000000000001');

insert into consulting_os.claim_citations
  (organization_id, claim_id, evidence_fragment_id, citation_role, citation_note, created_by)
values
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '54000000-0000-4000-8000-000000000003', '55000000-0000-4000-8000-000000000001', 'SUPPORTING', 'Direct workflow record.', '52000000-0000-4000-8000-000000000001'),
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '54000000-0000-4000-8000-000000000009', '55000000-0000-4000-8000-000000000001', 'SUPPORTING', 'Traceable source for reviewed insight.', '52000000-0000-4000-8000-000000000001');

insert into consulting_os.entity_relationships
  (organization_id, relationship_type, source_type, source_id, target_type, target_id, origin, review_status, rationale, created_by)
values
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'SUPPORTED_BY', 'OBSERVATION', '54000000-0000-4000-8000-000000000003', 'EVIDENCE', '54000000-0000-4000-8000-000000000002', 'HUMAN', 'ACCEPTED', 'Observation cites evidence.', '52000000-0000-4000-8000-000000000001'),
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'CONTRIBUTES_TO', 'OBSERVATION', '54000000-0000-4000-8000-000000000003', 'PATTERN', '54000000-0000-4000-8000-000000000004', 'HUMAN', 'ACCEPTED', 'Observation contributes to recurrence.', '52000000-0000-4000-8000-000000000001'),
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'SUGGESTS', 'PATTERN', '54000000-0000-4000-8000-000000000004', 'HYPOTHESIS', '54000000-0000-4000-8000-000000000006', 'HUMAN', 'ACCEPTED', 'Pattern suggests testable explanation.', '52000000-0000-4000-8000-000000000001'),
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'SUGGESTS', 'PATTERN', '54000000-0000-4000-8000-000000000004', 'INTERPRETATION', '54000000-0000-4000-8000-000000000007', 'HUMAN', 'ACCEPTED', 'Pattern suggests interpretation.', '52000000-0000-4000-8000-000000000001'),
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'DERIVED_FROM', 'INTERPRETATION', '54000000-0000-4000-8000-000000000007', 'ASSUMPTION', '54000000-0000-4000-8000-000000000005', 'HUMAN', 'ACCEPTED', 'Interpretation considers operative assumption.', '52000000-0000-4000-8000-000000000001'),
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'EXPLAINS', 'INTERPRETATION', '54000000-0000-4000-8000-000000000007', 'PATTERN', '54000000-0000-4000-8000-000000000004', 'HUMAN', 'ACCEPTED', 'Interpretation proposes meaning for pattern.', '52000000-0000-4000-8000-000000000001'),
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'DERIVED_FROM', 'INSIGHT', '54000000-0000-4000-8000-000000000009', 'INTERPRETATION', '54000000-0000-4000-8000-000000000007', 'HUMAN', 'ACCEPTED', 'Insight derives from reviewed interpretation.', '52000000-0000-4000-8000-000000000001'),
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'VALIDATES', 'RECORD_REVIEW', '54000000-0000-4000-8000-000000000011', 'INSIGHT', '54000000-0000-4000-8000-000000000009', 'HUMAN', 'ACCEPTED', 'Authorized review validates insight.', '52000000-0000-4000-8000-000000000001'),
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'INFORMS', 'INSIGHT', '54000000-0000-4000-8000-000000000009', 'DECISION', '54000000-0000-4000-8000-000000000010', 'HUMAN', 'ACCEPTED', 'Validated insight informs decision.', '52000000-0000-4000-8000-000000000001'),
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'INFORMS', 'ASSUMPTION', '54000000-0000-4000-8000-000000000005', 'DECISION', '54000000-0000-4000-8000-000000000010', 'HUMAN', 'ACCEPTED', 'Operative assumption informs decision.', '52000000-0000-4000-8000-000000000001'),
  ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'REJECTS', 'RECORD_REVIEW', '54000000-0000-4000-8000-000000000012', 'INTERPRETATION', '54000000-0000-4000-8000-000000000008', 'HUMAN', 'ACCEPTED', 'Human review rejects AI interpretation.', '52000000-0000-4000-8000-000000000001');

select results_eq(
  $$select count(*) from consulting_os.entity_relationships
    where organization_id = 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'
      and relationship_type in ('SUPPORTED_BY','CONTRIBUTES_TO','SUGGESTS','DERIVED_FROM','EXPLAINS','VALIDATES','INFORMS')$$,
  array[10::bigint],
  'Complete Evidence-to-Decision reasoning relationships persist'
);
select results_eq(
  $$select count(*) from consulting_os.claim_citations c
    join consulting_os.evidence_fragments f on f.id = c.evidence_fragment_id
    join consulting_os.evidence_sources s on s.id = f.evidence_source_id
    where c.claim_id = '54000000-0000-4000-8000-000000000009'$$,
  array[1::bigint],
  'Insight traces backward to an exact source fragment'
);
select results_eq(
  $$select count(*) from consulting_os.interpretations
    where organization_id = 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'$$,
  array[2::bigint],
  'Competing interpretations coexist without overwrite'
);
select results_eq(
  $$select count(*) from consulting_os.interpretations
    where id = '54000000-0000-4000-8000-000000000008'$$,
  array[1::bigint],
  'Rejected AI interpretation remains in historical storage'
);
select results_eq(
  $$select count(*) from consulting_os.operative_epistemic_records
    where id = '54000000-0000-4000-8000-000000000008'$$,
  array[0::bigint],
  'Rejected AI interpretation is excluded from operative retrieval'
);
select results_eq(
  $$select count(*) from consulting_os.validated_insights
    where id = '54000000-0000-4000-8000-000000000009'$$,
  array[1::bigint],
  'Human validation creates an explicitly validated Insight projection'
);
select results_eq(
  $$select count(*) from consulting_os.entity_relationships
    where target_id = '54000000-0000-4000-8000-000000000010'
      and relationship_type = 'INFORMS'$$,
  array[2::bigint],
  'Decision preserves both Insight and Assumption rationale inputs'
);
select throws_ok(
  $$insert into consulting_os.entity_relationships
    (organization_id, relationship_type, source_type, source_id, target_type, target_id, rationale, created_by)
    values ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'ASSOCIATED_WITH', 'OBSERVATION',
      '54000000-0000-4000-8000-000000000003', 'EVIDENCE',
      '54b00000-0000-4000-8000-000000000002', 'Cross-tenant attempt',
      '52000000-0000-4000-8000-000000000001')$$,
  null, null, 'Cross-tenant relationship remains structurally impossible'
);
select throws_ok(
  $$insert into consulting_os.entity_relationships
    (organization_id, relationship_type, source_type, source_id, target_type, target_id, rationale, created_by)
    values ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'INFORMS', 'OBSERVATION',
      '54000000-0000-4000-8000-000000000003', 'DECISION',
      '54000000-0000-4000-8000-000000000010', 'Invalid ontology edge',
      '52000000-0000-4000-8000-000000000001')$$,
  null, null, 'Relationship matrix rejects invalid source and target types'
);
select throws_ok(
  $$insert into consulting_os.entity_relationships
    (organization_id, relationship_type, source_type, source_id, target_type, target_id, rationale, created_by)
    values ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'INFORMS', 'INSIGHT',
      '54000000-0000-4000-8000-000000000013', 'DECISION',
      '54000000-0000-4000-8000-000000000010', 'Premature insight',
      '52000000-0000-4000-8000-000000000001')$$,
  null, null, 'Unvalidated Insight cannot inform a Decision'
);
select throws_ok(
  $$insert into consulting_os.patterns
    (id, organization_id, statement, scope, recurrence_basis, initial_review_state, created_by)
    values ('54000000-0000-4000-8000-000000000014', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      'AI candidate pattern', 'Organization', 'Candidate cluster', 'DRAFT',
      '52000000-0000-4000-8000-000000000001')$$,
  null, null, 'AI inferential records must begin SUGGESTED'
);
select throws_ok(
  $$update consulting_os.evidence_fragments set content_text = 'rewritten'
    where id = '55000000-0000-4000-8000-000000000001'$$,
  null, null, 'Evidence fragments are append-only'
);
select throws_ok(
  $$update consulting_os.observations set statement = 'rewritten'
    where id = '54000000-0000-4000-8000-000000000003'$$,
  null, null, 'Observations are append-only'
);
select throws_ok(
  $$update consulting_os.domain_objects set object_type = 'PATTERN'
    where id = '54000000-0000-4000-8000-000000000003'$$,
  null, null, 'Domain object type and provenance are immutable'
);
select throws_ok(
  $$insert into consulting_os.record_reviews
    (id, organization_id, subject_id, review_action, reviewer_person_id, rationale, reviewed_at, created_by)
    values ('54000000-0000-4000-8000-000000000015', 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      '54000000-0000-4000-8000-000000000013', 'VALIDATED',
      '52000000-0000-4000-8000-000000000001', 'Too little detail', now(),
      '52000000-0000-4000-8000-000000000001')$$,
  null, null, 'Validation requires evidence, contrary evidence, and limitations'
);
select throws_ok(
  $$insert into consulting_os.claim_citations
    (organization_id, claim_id, evidence_fragment_id, citation_role, citation_note, created_by)
    values ('caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      '54000000-0000-4000-8000-000000000009',
      '55b00000-0000-4000-8000-000000000001', 'SUPPORTING',
      'Cross-tenant citation', '52000000-0000-4000-8000-000000000001')$$,
  null, null, 'Citation cannot cross the tenant boundary'
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '51000000-0000-4000-8000-000000000001', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select lives_ok(
  $$select consulting_os.supersede_assumption(
    '54000000-0000-4000-8000-000000000005',
    'Decision quality is protected by explicit capability and boundaries.',
    '2024-01-01'::timestamptz,
    'UNTESTED',
    'LOW',
    'New version requires outcome evidence.',
    'Review after the delegation trial.'
  )$$,
  'Authorized user can supersede an Assumption through the controlled function'
);
select results_eq(
  $$select version_number from consulting_os.assumptions_at(
    'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '2022-01-01')$$,
  array[1],
  'Historical query returns the version operative in 2022'
);
select results_eq(
  $$select version_number from consulting_os.assumptions_at(
    'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '2025-01-01')$$,
  array[2],
  'Current-era query returns the superseding version'
);
select results_eq(
  $$select count(*) from consulting_os.current_assumptions
    where logical_id = '56000000-0000-4000-8000-000000000001'$$,
  array[1::bigint],
  'Exactly one current Assumption version is operative'
);
select results_eq(
  $$select count(*) from consulting_os.entity_relationships
    where source_id = '54000000-0000-4000-8000-000000000005'
      and target_id = '54000000-0000-4000-8000-000000000010'
      and relationship_type = 'INFORMS'$$,
  array[1::bigint],
  'Historical Decision remains linked to the Assumption version used then'
);
select results_eq(
  $$select count(*) from consulting_os.evidence_sources
    where organization_id = 'cbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'$$,
  array[0::bigint],
  'RLS excludes a high-similarity cross-tenant source before retrieval'
);
select results_eq(
  $$select count(*) from consulting_os.operative_epistemic_records
    where organization_id = 'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'$$,
  array[7::bigint],
  'Operative retrieval remains permission-filtered and review-aware'
);

select set_config('request.jwt.claim.sub', '51000000-0000-4000-8000-000000000002', true);
select throws_ok(
  $$insert into consulting_os.record_reviews
    (id, organization_id, subject_id, review_action, reviewer_person_id, rationale,
      evidence_considered, contrary_evidence, limitations, reviewed_at, created_by)
    values ('57000000-0000-4000-8000-000000000001',
      'caaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      '54000000-0000-4000-8000-000000000013', 'VALIDATED',
      '52000000-0000-4000-8000-000000000002', 'Unauthorized review',
      'None', 'None', 'None', now(), '52000000-0000-4000-8000-000000000002')$$,
  null, null, 'Ordinary member cannot validate an organizational claim'
);

reset role;
select cmp_ok(
  (select count(*) from consulting_os.audit_events where event_type like 'RECORD_REVIEWS_%'),
  '>=', 2::bigint,
  'Human review acts are recorded in the append-only audit log'
);
select results_eq(
  $$select count(*) from consulting_os.entity_relationships
    where relationship_type = 'SUPERSEDES'
      and source_type = 'ASSUMPTION'
      and target_id = '54000000-0000-4000-8000-000000000005'$$,
  array[1::bigint],
  'Assumption supersession creates an explicit historical relationship'
);
select results_eq(
  $$select count(*) from consulting_os.record_reviews
    where subject_id = '54000000-0000-4000-8000-000000000008'
      and review_action = 'REJECTED'$$,
  array[1::bigint],
  'Rejected suggestion and human reasoning remain reconstructable'
);

select * from finish();
rollback;
