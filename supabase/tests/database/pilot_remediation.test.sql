begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;

select plan(6);

insert into auth.users (id, email, role, aud, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
  ('9a100000-0000-4000-8000-000000000001', 'pilot-consultant@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('9a100000-0000-4000-8000-000000000002', 'pilot-outsider@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now());

insert into consulting_os.people (id, auth_user_id, display_name)
values
  ('9a200000-0000-4000-8000-000000000001', '9a100000-0000-4000-8000-000000000001', 'Pilot Consultant'),
  ('9a200000-0000-4000-8000-000000000002', '9a100000-0000-4000-8000-000000000002', 'Unassigned Person');

insert into consulting_os.organizations (id, name, slug, created_by)
values ('9a300000-0000-4000-8000-000000000001', 'Existing Pilot Client', 'existing-pilot-client', '9a200000-0000-4000-8000-000000000001');

insert into consulting_os.consultant_assignments
  (id, organization_id, consultant_person_id, status, assignment_reason, created_by)
values
  ('9a400000-0000-4000-8000-000000000001', '9a300000-0000-4000-8000-000000000001', '9a200000-0000-4000-8000-000000000001', 'ACTIVE', 'Pilot remediation test', '9a200000-0000-4000-8000-000000000001');

select has_function('consulting_os', 'start_client_engagement', array['text', 'text', 'date', 'date'], 'Client engagement setup command exists');
select has_function('consulting_os', 'capture_discovery_evidence', array['uuid', 'uuid', 'consulting_os.evidence_source_type', 'text', 'text', 'text', 'text', 'text'], 'Evidence intake command exists');

set local role authenticated;
select set_config('request.jwt.claim.sub', '9a100000-0000-4000-8000-000000000001', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select lives_ok(
  $$select * from consulting_os.start_client_engagement('Grace Pilot Church', 'Healthy Rhythm Pilot', '2026-09-01'::date, '2027-02-01'::date)$$,
  'Assigned consultant can atomically create a client and engagement'
);
select results_eq(
  $$select count(*) from consulting_os.organizations where name = 'Grace Pilot Church'$$,
  array[1::bigint],
  'New organization is visible to its assigned consultant'
);
select results_eq(
  $$select count(*) from consulting_os.engagements where name = 'Healthy Rhythm Pilot' and status = 'ACTIVE'$$,
  array[1::bigint],
  'New active engagement is created inside the new tenant'
);

select set_config('request.jwt.claim.sub', '9a100000-0000-4000-8000-000000000002', true);
select throws_ok(
  $$select * from consulting_os.start_client_engagement('Unauthorized Church', 'Unauthorized Engagement', '2026-09-01'::date, null::date)$$,
  null,
  null,
  'Unassigned user cannot create a consulting tenant'
);

select * from finish();
rollback;
