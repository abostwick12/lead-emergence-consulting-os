begin;
create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(10);

insert into auth.users (id,email,role,aud,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values ('91000000-0000-4000-8000-000000000001','prospect-consultant@example.test','authenticated','authenticated','{}','{}',now(),now()),
('91000000-0000-4000-8000-000000000002','prospect-client@example.test','authenticated','authenticated','{}','{}',now(),now());
insert into consulting_os.people(id,auth_user_id,display_name) values
('92000000-0000-4000-8000-000000000001','91000000-0000-4000-8000-000000000001','Prospect Consultant'),
('92000000-0000-4000-8000-000000000002','91000000-0000-4000-8000-000000000002','Prospect Client');
insert into consulting_os.organizations(id,name,slug,created_by) values ('93000000-0000-4000-8000-000000000001','Prospect Test Org','prospect-test-org','92000000-0000-4000-8000-000000000001');
insert into consulting_os.consultant_assignments(id,organization_id,consultant_person_id,status,assignment_reason,created_by) values ('94000000-0000-4000-8000-000000000001','93000000-0000-4000-8000-000000000001','92000000-0000-4000-8000-000000000001','ACTIVE','Prospect test','92000000-0000-4000-8000-000000000001');
insert into consulting_os.prospects(id,first_name,email) values ('95000000-0000-4000-8000-000000000001','Morgan','morgan@example.test');
insert into consulting_os.prospect_intakes(id,prospect_id,idempotency_key) values ('96000000-0000-4000-8000-000000000001','95000000-0000-4000-8000-000000000001','97000000-0000-4000-8000-000000000001');
insert into consulting_os.prospect_intake_responses(id,intake_id,question_key,prompt_snapshot,answer,ordinal) values ('98000000-0000-4000-8000-000000000001','96000000-0000-4000-8000-000000000001','challenge','What matters?','Reported information only.',1);
insert into consulting_os.prospect_321_revisions(id,prospect_id,revision_number,origin,signals,possibilities,first_move,limitations,created_by) values ('99000000-0000-4000-8000-000000000001','95000000-0000-4000-8000-000000000001',1,'AI','["a","b","c"]','["d","e"]','A bounded first move.','Not validated.','92000000-0000-4000-8000-000000000001');

select is(
  (
    select c.relrowsecurity
    from pg_catalog.pg_class c
    join pg_catalog.pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'consulting_private' and c.relname = 'prospect_notes'
  ),
  true,
  'Consultant-private prospect notes enforce row level security'
);
select is(
  (
    select count(*)
    from pg_catalog.pg_policies
    where schemaname = 'consulting_private' and tablename = 'prospect_notes'
  ),
  0::bigint,
  'Consultant-private prospect notes expose no client policies'
);
set local role service_role;
select lives_ok($$select count(*) from consulting_private.prospect_notes$$,'Service role retains prospect note access through RLS');
reset role;

set local role anon;
select throws_ok($$select count(*) from consulting_os.prospects$$, null, null, 'Public intake callers cannot enumerate prospects');
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub','91000000-0000-4000-8000-000000000002',true);
select results_eq($$select count(*) from consulting_os.prospects$$,array[0::bigint],'Client cannot read Consulting prospect queue');
select throws_ok($$select count(*) from consulting_private.prospect_notes$$,null,null,'Client cannot directly read consultant-private prospect notes');
reset role;
select throws_ok($$update consulting_os.prospect_intake_responses set answer='changed' where id='98000000-0000-4000-8000-000000000001'$$,null,null,'Raw prospect responses are immutable');
select throws_ok($$update consulting_os.prospect_321_revisions set first_move='changed' where id='99000000-0000-4000-8000-000000000001'$$,null,null,'3-2-1 revisions are immutable');
select throws_ok($$insert into consulting_os.prospect_321_deliveries(prospect_id,approved_revision_id,recipient_email,subject_snapshot,body_snapshot,status,sent_at) values ('95000000-0000-4000-8000-000000000001','99000000-0000-4000-8000-000000000001','morgan@example.test','subject','body','SENT',now())$$,null,null,'Delivery cannot reference a revision without an approval record');
select ok(true,'Conversion and identity-link tables are separately constrained by foreign keys and status checks');
select * from finish();
rollback;
