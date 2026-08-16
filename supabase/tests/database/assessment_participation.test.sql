begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(12);

insert into auth.users (id, email, role, aud, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values ('ad100000-0000-4000-8000-000000000001', 'assessment-owner@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now());

insert into consulting_os.people (id, auth_user_id, display_name)
values ('ad200000-0000-4000-8000-000000000001', 'ad100000-0000-4000-8000-000000000001', 'Assessment Owner');

insert into consulting_os.organizations (id, name, slug, created_by)
values ('ad300000-0000-4000-8000-000000000001', 'Assessment Test Organization', 'assessment-test-organization', 'ad200000-0000-4000-8000-000000000001');

insert into consulting_os.engagements (id, organization_id, name, status, starts_on, created_by)
values ('ad400000-0000-4000-8000-000000000001', 'ad300000-0000-4000-8000-000000000001', 'Assessment Test Engagement', 'ACTIVE', current_date, 'ad200000-0000-4000-8000-000000000001');

insert into consulting_os.domain_objects (id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by)
values
  ('ad500000-0000-4000-8000-000000000001', 'ad300000-0000-4000-8000-000000000001', null, 'ASSESSMENT_INSTRUMENT', 'ORGANIZATION_SHARED', 'HUMAN', 'ad200000-0000-4000-8000-000000000001'),
  ('ad500000-0000-4000-8000-000000000002', 'ad300000-0000-4000-8000-000000000001', 'ad400000-0000-4000-8000-000000000001', 'EVIDENCE_SOURCE', 'LEADERSHIP_RESTRICTED', 'HUMAN', 'ad200000-0000-4000-8000-000000000001'),
  ('ad500000-0000-4000-8000-000000000003', 'ad300000-0000-4000-8000-000000000001', 'ad400000-0000-4000-8000-000000000001', 'ASSESSMENT_ADMINISTRATION', 'LEADERSHIP_RESTRICTED', 'HUMAN', 'ad200000-0000-4000-8000-000000000001');

insert into consulting_os.evidence_sources (id, organization_id, source_type, title, captured_at, provenance_context, created_by)
values ('ad500000-0000-4000-8000-000000000002', 'ad300000-0000-4000-8000-000000000001', 'ASSESSMENT', 'Confidential assessment source', now(), 'Participant assessment workflow test.', 'ad200000-0000-4000-8000-000000000001');

insert into consulting_os.assessment_instruments (id, organization_id, name, framework_name, instrument_status, validation_claim_status, created_by)
values ('ad500000-0000-4000-8000-000000000001', 'ad300000-0000-4000-8000-000000000001', 'Two Item Inquiry', 'Test fixture', 'ACTIVE', 'NOT_VALIDATED', 'ad200000-0000-4000-8000-000000000001');

insert into consulting_os.assessment_instrument_versions (id, organization_id, instrument_id, version_number, version_label, dimensions, scoring_rules, compatibility_key, created_by)
values ('ad600000-0000-4000-8000-000000000001', 'ad300000-0000-4000-8000-000000000001', 'ad500000-0000-4000-8000-000000000001', 1, '1.0', '["RHYTHM"]', '{"method":"descriptive"}', 'rhythm-v1', 'ad200000-0000-4000-8000-000000000001');

insert into consulting_os.assessment_items (id, organization_id, instrument_version_id, item_key, prompt, dimension_key, response_type, response_options, ordinal, created_by)
values
  ('ad700000-0000-4000-8000-000000000001', 'ad300000-0000-4000-8000-000000000001', 'ad600000-0000-4000-8000-000000000001', 'Q1', 'First question', 'RHYTHM', 'LIKERT', '[1,2,3,4,5]', 1, 'ad200000-0000-4000-8000-000000000001'),
  ('ad700000-0000-4000-8000-000000000002', 'ad300000-0000-4000-8000-000000000001', 'ad600000-0000-4000-8000-000000000001', 'Q2', 'Second question', 'RHYTHM', 'LIKERT', '[1,2,3,4,5]', 2, 'ad200000-0000-4000-8000-000000000001');

insert into consulting_os.assessment_administrations (id, organization_id, engagement_id, instrument_version_id, evidence_source_id, audience_description, opens_at, closes_at, confidentiality, minimum_reporting_cohort, administration_status, created_by)
values ('ad500000-0000-4000-8000-000000000003', 'ad300000-0000-4000-8000-000000000001', 'ad400000-0000-4000-8000-000000000001', 'ad600000-0000-4000-8000-000000000001', 'ad500000-0000-4000-8000-000000000002', 'Test participants', now() - interval '1 hour', now() + interval '1 day', 'CONFIDENTIAL', 1, 'DRAFT', 'ad200000-0000-4000-8000-000000000001');

select has_table('consulting_private', 'assessment_participant_item_submissions', 'Private per-item completion ledger exists');
select results_eq(
  $$select relrowsecurity from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'consulting_private' and c.relname = 'assessment_participant_item_submissions'$$,
  array[true],
  'Completion ledger has RLS enabled'
);

set local role service_role;
select set_config('request.jwt.claim.role', 'service_role', true);

select lives_ok(
  $$select consulting_os.issue_assessment_participant_link('ad300000-0000-4000-8000-000000000001', 'ad400000-0000-4000-8000-000000000001', 'ad500000-0000-4000-8000-000000000003', repeat('a', 64), null, 'Private Participant', 'private@example.test', now() + interval '1 day', 'ad200000-0000-4000-8000-000000000001')$$,
  'A confidential participant capability can be issued without putting identity on response rows'
);
select results_eq(
  $$select count(*) from consulting_os.resolve_assessment_participant_link(repeat('a', 64))$$,
  array[2::bigint],
  'Both unanswered items resolve from one active capability'
);
select lives_ok(
  $$select consulting_os.submit_assessment_participant_response(repeat('a', 64), 'ad700000-0000-4000-8000-000000000001', '{"value":4}')$$,
  'The first item can be submitted'
);
select results_eq(
  $$select link_status from consulting_private.assessment_participant_links where token_hash = repeat('a', 64)$$,
  array['ACTIVE'::consulting_os.participant_link_status],
  'The capability remains active while an item is unanswered'
);
select results_eq(
  $$select item_id from consulting_os.resolve_assessment_participant_link(repeat('a', 64))$$,
  array['ad700000-0000-4000-8000-000000000002'::uuid],
  'Only the unanswered item resolves after partial completion'
);
select throws_ok(
  $$select consulting_os.submit_assessment_participant_response(repeat('a', 64), 'ad700000-0000-4000-8000-000000000001', '{"value":5}')$$,
  '23505',
  'assessment item has already been answered',
  'Duplicate submission of the same item is rejected'
);
select lives_ok(
  $$select consulting_os.submit_assessment_participant_response(repeat('a', 64), 'ad700000-0000-4000-8000-000000000002', '{"value":5}')$$,
  'The final item can be submitted'
);
select results_eq(
  $$select link_status from consulting_private.assessment_participant_links where token_hash = repeat('a', 64)$$,
  array['USED'::consulting_os.participant_link_status],
  'The capability becomes used only after the final item'
);
select results_eq(
  $$select count(*) from consulting_private.assessment_responses where participant_token_hash = repeat('a', 64) and respondent_person_id is null$$,
  array[2::bigint],
  'Confidential response rows contain no respondent identity'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub', 'ad100000-0000-4000-8000-000000000001', true);
select set_config('request.jwt.claim.role', 'authenticated', true);
select throws_ok(
  $$select count(*) from consulting_private.assessment_participant_item_submissions$$,
  null,
  null,
  'Ordinary portal roles cannot query the private identity-to-response completion ledger'
);

select * from finish();
rollback;
