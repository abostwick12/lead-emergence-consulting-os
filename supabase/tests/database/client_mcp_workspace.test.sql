begin;
create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(11);

insert into auth.users (id, email, role, aud, raw_app_meta_data, raw_user_meta_data, created_at, updated_at) values
  ('ce100000-0000-4000-8000-000000000001','consultant@example.test','authenticated','authenticated','{}','{}',now(),now()),
  ('ce100000-0000-4000-8000-000000000002','client-a@example.test','authenticated','authenticated','{}','{}',now(),now()),
  ('ce100000-0000-4000-8000-000000000003','client-b@example.test','authenticated','authenticated','{}','{}',now(),now());
insert into consulting_os.people(id,auth_user_id,display_name) values
  ('ce200000-0000-4000-8000-000000000001','ce100000-0000-4000-8000-000000000001','Consultant'),
  ('ce200000-0000-4000-8000-000000000002','ce100000-0000-4000-8000-000000000002','Client A'),
  ('ce200000-0000-4000-8000-000000000003','ce100000-0000-4000-8000-000000000003','Client B');
insert into consulting_os.organizations(id,name,slug,created_by) values
  ('ce300000-0000-4000-8000-000000000001','Client MCP A','client-mcp-a','ce200000-0000-4000-8000-000000000001'),
  ('ce300000-0000-4000-8000-000000000002','Client MCP B','client-mcp-b','ce200000-0000-4000-8000-000000000001');
insert into consulting_os.engagements(id,organization_id,name,status,created_by) values
  ('ce400000-0000-4000-8000-000000000001','ce300000-0000-4000-8000-000000000001','Engagement A','ACTIVE','ce200000-0000-4000-8000-000000000001'),
  ('ce400000-0000-4000-8000-000000000002','ce300000-0000-4000-8000-000000000002','Engagement B','ACTIVE','ce200000-0000-4000-8000-000000000001');
insert into consulting_os.organization_memberships(id,organization_id,person_id,platform_role,status,created_by) values
  ('ce500000-0000-4000-8000-000000000001','ce300000-0000-4000-8000-000000000001','ce200000-0000-4000-8000-000000000002','CLIENT_MEMBER','ACTIVE','ce200000-0000-4000-8000-000000000001'),
  ('ce500000-0000-4000-8000-000000000002','ce300000-0000-4000-8000-000000000002','ce200000-0000-4000-8000-000000000003','CLIENT_ADMIN','ACTIVE','ce200000-0000-4000-8000-000000000001');
insert into consulting_os.engagement_memberships(id,organization_id,engagement_id,organization_membership_id,status,created_by) values
  ('ce600000-0000-4000-8000-000000000001','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','ce500000-0000-4000-8000-000000000001','ACTIVE','ce200000-0000-4000-8000-000000000001'),
  ('ce600000-0000-4000-8000-000000000002','ce300000-0000-4000-8000-000000000002','ce400000-0000-4000-8000-000000000002','ce500000-0000-4000-8000-000000000002','ACTIVE','ce200000-0000-4000-8000-000000000001');
insert into consulting_os.domain_objects(id,organization_id,engagement_id,object_type,visibility_scope,created_by) values
  ('ce700000-0000-4000-8000-000000000001','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','ASSESSMENT_ADMINISTRATION','ENGAGEMENT_SHARED','ce200000-0000-4000-8000-000000000001'),
  ('ce700000-0000-4000-8000-000000000002','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','WRITTEN_AUDIT_ASSIGNMENT','ENGAGEMENT_SHARED','ce200000-0000-4000-8000-000000000001'),
  ('ce700000-0000-4000-8000-000000000003','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','INTERVIEW','ENGAGEMENT_SHARED','ce200000-0000-4000-8000-000000000001'),
  ('ce700000-0000-4000-8000-000000000004','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','INTERVIEW','CONSULTANT_PRIVATE','ce200000-0000-4000-8000-000000000001'),
  ('ce700000-0000-4000-8000-000000000006','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','EVIDENCE_SOURCE','ENGAGEMENT_SHARED','ce200000-0000-4000-8000-000000000001'),
  ('ce700000-0000-4000-8000-000000000007','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','ENGAGEMENT_PRODUCT','ENGAGEMENT_SHARED','ce200000-0000-4000-8000-000000000001'),
  ('ce700000-0000-4000-8000-000000000008','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','EVIDENCE_SOURCE','ENGAGEMENT_SHARED','ce200000-0000-4000-8000-000000000001'),
  ('ce710000-0000-4000-8000-000000000001','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','ASSESSMENT_INSTRUMENT','ENGAGEMENT_SHARED','ce200000-0000-4000-8000-000000000001');
insert into consulting_os.evidence_sources(id,organization_id,source_type,title,captured_at,provenance_context,created_by) values
  ('ce700000-0000-4000-8000-000000000006','ce300000-0000-4000-8000-000000000001','ASSESSMENT','Assessment source',now(),'Test','ce200000-0000-4000-8000-000000000001'),
  ('ce700000-0000-4000-8000-000000000008','ce300000-0000-4000-8000-000000000001','INTERVIEW','Interview source',now(),'Test','ce200000-0000-4000-8000-000000000001');
insert into consulting_os.engagement_products(id,organization_id,engagement_id,name,description,owner_label,created_by) values
  ('ce700000-0000-4000-8000-000000000007','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','Test product','Synthetic test product','Consultant','ce200000-0000-4000-8000-000000000001');
insert into consulting_os.assessment_instruments(id,organization_id,name,framework_name,instrument_status,validation_claim_status,created_by) values
  ('ce710000-0000-4000-8000-000000000001','ce300000-0000-4000-8000-000000000001','Instrument','Test','ACTIVE','NOT_VALIDATED','ce200000-0000-4000-8000-000000000001');
insert into consulting_os.assessment_instrument_versions(id,organization_id,instrument_id,version_number,version_label,dimensions,scoring_rules,compatibility_key,created_by) values
  ('ce720000-0000-4000-8000-000000000001','ce300000-0000-4000-8000-000000000001','ce710000-0000-4000-8000-000000000001',1,'v1','[]','{}','test','ce200000-0000-4000-8000-000000000001');
insert into consulting_os.assessment_administrations(id,organization_id,engagement_id,instrument_version_id,evidence_source_id,audience_description,opens_at,closes_at,confidentiality,administration_status,created_by) values
  ('ce700000-0000-4000-8000-000000000001','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','ce720000-0000-4000-8000-000000000001','ce700000-0000-4000-8000-000000000006','Test',now()-interval '1 hour',now()+interval '1 day','IDENTIFIED','OPEN','ce200000-0000-4000-8000-000000000001');
insert into consulting_os.written_audit_assignments(id,organization_id,engagement_id,product_id,administration_id,respondent_person_id,respondent_label,created_by) values
  ('ce700000-0000-4000-8000-000000000002','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','ce700000-0000-4000-8000-000000000007','ce700000-0000-4000-8000-000000000001','ce200000-0000-4000-8000-000000000002','Client A','ce200000-0000-4000-8000-000000000001');
insert into consulting_os.interviews(id,organization_id,engagement_id,evidence_source_id,participant_person_id,participant_label,interviewer_person_id,guide_name,guide_version,interview_status,created_by) values
  ('ce700000-0000-4000-8000-000000000003','ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','ce700000-0000-4000-8000-000000000008','ce200000-0000-4000-8000-000000000002','Client A','ce200000-0000-4000-8000-000000000001','Guide','1','IN_PROGRESS','ce200000-0000-4000-8000-000000000001');

select ok(consulting_security.is_guided_record_participant('ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','AUDIT','ce700000-0000-4000-8000-000000000002','ce200000-0000-4000-8000-000000000002'),'Assigned client may participate in own audit');
select ok(not consulting_security.is_guided_record_participant('ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','PRODUCT','ce700000-0000-4000-8000-000000000002','ce200000-0000-4000-8000-000000000002'),'Product records are never client guided work');
select ok(not consulting_security.is_guided_record_participant('ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','AUDIT','ce700000-0000-4000-8000-000000000002','ce200000-0000-4000-8000-000000000003'),'Another tenant client cannot use guessed audit ID');
select ok(not consulting_security.is_guided_record_participant('ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','INTERVIEW','ce700000-0000-4000-8000-000000000003','ce200000-0000-4000-8000-000000000003'),'Interview identity without matching engagement membership cannot gain Client MCP access');

set local role authenticated;
select set_config('request.jwt.claim.sub','ce100000-0000-4000-8000-000000000002',true);
select set_config('request.jwt.claim.role','authenticated',true);
select results_eq($$select count(*) from consulting_os.list_my_guided_records('ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001')$$,array[2::bigint],'Client lists only explicitly assigned guided records');
select lives_ok($$insert into consulting_os.guided_record_responses(organization_id,engagement_id,record_kind,record_id,question_id,answer,confirmed_by) values ('ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','AUDIT','ce700000-0000-4000-8000-000000000002','audit-context','Confirmed answer','ce200000-0000-4000-8000-000000000002')$$,'Client can save own assigned confirmed response without organization management');
select results_eq($$select count(*) from consulting_os.guided_record_responses where record_id = 'ce700000-0000-4000-8000-000000000002'$$,array[1::bigint],'Client response persists once');
select results_eq($$select count(*) from consulting_os.domain_objects where id = 'ce700000-0000-4000-8000-000000000004'$$,array[0::bigint],'Client cannot read consultant-private object');

reset role;
update consulting_os.engagement_memberships set status = 'REMOVED' where id = 'ce600000-0000-4000-8000-000000000001';
set local role authenticated;
select set_config('request.jwt.claim.sub','ce100000-0000-4000-8000-000000000002',true);
select results_eq($$select count(*) from consulting_os.list_my_guided_records('ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001')$$,array[0::bigint],'Removed engagement membership loses client guided work immediately');
select throws_ok($$insert into consulting_os.guided_record_responses(organization_id,engagement_id,record_kind,record_id,question_id,answer,confirmed_by) values ('ce300000-0000-4000-8000-000000000001','ce400000-0000-4000-8000-000000000001','AUDIT','ce700000-0000-4000-8000-000000000002','audit-purpose','Denied','ce200000-0000-4000-8000-000000000002')$$,null,null,'Revoked participant cannot save response');

reset role;
select ok((select count(*) from consulting_os.mcp_tool_audit where false) = 0,'MCP audit remains content-free table with no test answer payload');
select * from finish();
rollback;