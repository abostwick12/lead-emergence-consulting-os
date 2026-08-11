begin;
create extension if not exists pgtap with schema extensions;
set local search_path=extensions,public,pg_catalog;
select plan(22);

insert into auth.users(id,email,role,aud,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
('b8100000-0000-4000-8000-000000000001','phase8-consultant@example.test','authenticated','authenticated','{}','{}',now(),now()),
('b8100000-0000-4000-8000-000000000002','phase8-other@example.test','authenticated','authenticated','{}','{}',now(),now());
insert into consulting_os.people(id,auth_user_id,display_name) values
('b8200000-0000-4000-8000-000000000001','b8100000-0000-4000-8000-000000000001','Phase 8 Consultant'),
('b8200000-0000-4000-8000-000000000002','b8100000-0000-4000-8000-000000000002','Other Tenant Owner');
insert into consulting_os.organizations(id,name,slug,created_by) values
('b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','Grounded One','grounded-one','b8200000-0000-4000-8000-000000000001'),
('b8bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','Grounded Two','grounded-two','b8200000-0000-4000-8000-000000000002');
insert into consulting_os.consultant_assignments(id,organization_id,consultant_person_id,status,assignment_reason,created_by) values
('b8500000-0000-4000-8000-000000000001','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8200000-0000-4000-8000-000000000001','ACTIVE','Phase 8 fixture','b8200000-0000-4000-8000-000000000001');
insert into consulting_os.engagements(id,organization_id,name,status,created_by) values
('b8300000-0000-4000-8000-000000000001','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','Grounded engagement','ACTIVE','b8200000-0000-4000-8000-000000000001'),
('b8300000-0000-4000-8000-000000000002','b8bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','Other engagement','ACTIVE','b8200000-0000-4000-8000-000000000002');

insert into consulting_os.domain_objects(id,organization_id,engagement_id,object_type,visibility_scope,origin,created_by) values
('b8400000-0000-4000-8000-000000000001','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','EVIDENCE_SOURCE','ENGAGEMENT_SHARED','IMPORTED','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000002','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','EVIDENCE','ENGAGEMENT_SHARED','HUMAN','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000003','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','EVIDENCE_SOURCE','ORGANIZATION_SHARED','IMPORTED','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000004','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','EVIDENCE','ORGANIZATION_SHARED','HUMAN','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000005','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','EVIDENCE_SOURCE','LEADERSHIP_RESTRICTED','IMPORTED','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000006','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','EVIDENCE','LEADERSHIP_RESTRICTED','HUMAN','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000007','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','EVIDENCE_SOURCE','CONSULTANT_PRIVATE','IMPORTED','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000008','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','EVIDENCE','CONSULTANT_PRIVATE','HUMAN','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000101','b8bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','b8300000-0000-4000-8000-000000000002','EVIDENCE_SOURCE','ORGANIZATION_SHARED','IMPORTED','b8200000-0000-4000-8000-000000000002'),
('b8400000-0000-4000-8000-000000000102','b8bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','b8300000-0000-4000-8000-000000000002','EVIDENCE','ORGANIZATION_SHARED','HUMAN','b8200000-0000-4000-8000-000000000002');
insert into consulting_os.evidence_sources(id,organization_id,source_type,title,captured_at,provenance_context,created_by) values
('b8400000-0000-4000-8000-000000000001','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','INTERVIEW','Interview 04',now(),'Synthetic Phase 8 source','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000003','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','UPLOADED_DOCUMENT','Approval workflow',now(),'Synthetic Phase 8 source','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000005','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','MEETING','Leadership review',now(),'Synthetic Phase 8 contrary source','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000007','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','MEETING','Private coaching note',now(),'Synthetic private source','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000101','b8bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','UPLOADED_DOCUMENT','Other tenant source',now(),'Synthetic cross-tenant source','b8200000-0000-4000-8000-000000000002');
insert into consulting_os.evidence_fragments(id,organization_id,evidence_source_id,locator_kind,locator,content_text,content_sha256,created_by) values
('b8600000-0000-4000-8000-000000000001','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8400000-0000-4000-8000-000000000001','EXCERPT','{"excerpt":12}','Team leads wait for senior approval.',repeat('1',64),'b8200000-0000-4000-8000-000000000001'),
('b8600000-0000-4000-8000-000000000002','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8400000-0000-4000-8000-000000000003','ROW_RANGE','{"rows":[22,41]}','Routine exceptions escalate upward.',repeat('2',64),'b8200000-0000-4000-8000-000000000001'),
('b8600000-0000-4000-8000-000000000003','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8400000-0000-4000-8000-000000000005','NOTE','{"note":3}','Explicit boundaries enabled local decisions.',repeat('3',64),'b8200000-0000-4000-8000-000000000001'),
('b8600000-0000-4000-8000-000000000004','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8400000-0000-4000-8000-000000000007','PRIVATE_NOTE','{"note":1}','Private coaching content.',repeat('4',64),'b8200000-0000-4000-8000-000000000001'),
('b8600000-0000-4000-8000-000000000101','b8bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','b8400000-0000-4000-8000-000000000101','ROW_RANGE','{"rows":[1,2]}','Other tenant evidence.',repeat('5',64),'b8200000-0000-4000-8000-000000000002');
insert into consulting_os.evidence_items(id,organization_id,primary_fragment_id,evidence_type,relevance_note,created_by) values
('b8400000-0000-4000-8000-000000000002','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8600000-0000-4000-8000-000000000001','INTERVIEW_EXCERPT','Supporting source one.','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000004','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8600000-0000-4000-8000-000000000002','WORKFLOW_RECORD','Supporting source two.','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000006','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8600000-0000-4000-8000-000000000003','MEETING_NOTE','Contrary source.','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000008','b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8600000-0000-4000-8000-000000000004','PRIVATE_NOTE','Private source.','b8200000-0000-4000-8000-000000000001'),
('b8400000-0000-4000-8000-000000000102','b8bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','b8600000-0000-4000-8000-000000000101','WORKFLOW_RECORD','Other tenant source.','b8200000-0000-4000-8000-000000000002');

select has_table('consulting_os','ai_generation_runs','AI run audit table exists');
select has_table('consulting_os','ai_run_sources','Exact AI source-set table exists');
select ok(not has_table_privilege('authenticated','consulting_os.ai_generation_runs','INSERT'),'Authenticated users cannot insert AI audit envelopes directly');

set local role authenticated;
select set_config('request.jwt.claim.sub','b8100000-0000-4000-8000-000000000001',true);
select results_eq($$select count(*) from consulting_os.eligible_ai_source_fragments('b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','pattern review')$$,array[3::bigint],'Permission filtering excludes private coaching evidence before retrieval');
select lives_ok($$select consulting_os.request_ai_pattern_suggestion('b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','Pattern review',array['b8400000-0000-4000-8000-000000000002'::uuid,'b8400000-0000-4000-8000-000000000004'::uuid],array['b8400000-0000-4000-8000-000000000006'::uuid],'Routine authority escalates upward.','Active engagement','Two recurring shared sources and one contrary source.','Explicit boundaries enabled local decisions.','Suggestion only; not a diagnosis.')$$,'Authorized grounded pattern request completes');
select results_eq($$select count(*) from consulting_os.ai_generation_runs where organization_id='b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa' and status='COMPLETED' and source_count=3 and permission_filter_applied_at<=completed_at$$,array[1::bigint],'Authorization filter is recorded before completed generation');
select results_eq($$select count(*) from consulting_os.ai_output_review where organization_id='b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa' and current_review_state='SUGGESTED' and jsonb_array_length(sources)=3$$,array[1::bigint],'AI Pattern remains SUGGESTED with the exact source set');
select results_eq($$select count(*) from consulting_os.claim_citations c join consulting_os.domain_objects d on d.id=c.claim_id and d.organization_id=c.organization_id where d.origin='AI' and d.object_type='PATTERN'$$,array[3::bigint],'Every AI Pattern citation resolves to an actual source fragment');
select results_eq($$select count(*) from consulting_os.ai_run_sources where organization_id='b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa' and source_role='SUPPORTING'$$,array[2::bigint],'Pattern exposes supporting evidence');
select results_eq($$select count(*) from consulting_os.ai_run_sources where organization_id='b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa' and source_role='CHALLENGING'$$,array[1::bigint],'Pattern exposes contrary evidence');
select results_eq($$select count(*) from consulting_os.ai_outputs o join consulting_os.domain_objects d on d.id=o.output_domain_object_id where d.visibility_scope='LEADERSHIP_RESTRICTED'$$,array[1::bigint],'AI output inherits the most restrictive eligible source visibility');
select throws_ok($$select consulting_os.request_ai_pattern_suggestion('b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','Cross tenant attempt',array['b8400000-0000-4000-8000-000000000002'::uuid,'b8400000-0000-4000-8000-000000000102'::uuid],array['b8400000-0000-4000-8000-000000000006'::uuid],'Unsafe','Scope','Basis','Contrary','Limit')$$,'42501',null,'Cross-tenant source is rejected before ranking');
select throws_ok($$select consulting_os.request_ai_pattern_suggestion('b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','Private attempt',array['b8400000-0000-4000-8000-000000000002'::uuid,'b8400000-0000-4000-8000-000000000008'::uuid],array['b8400000-0000-4000-8000-000000000006'::uuid],'Unsafe','Scope','Basis','Contrary','Limit')$$,'42501',null,'Private coaching evidence is rejected before ranking');
select lives_ok($$select consulting_os.request_ai_pattern_suggestion('b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','Thin evidence',array['b8400000-0000-4000-8000-000000000002'::uuid],array[]::uuid[],'No output','Scope','Basis','None','Thin')$$,'Insufficient evidence is recorded without fabricated output');
select results_eq($$select count(*) from consulting_os.ai_generation_runs where status='INSUFFICIENT_EVIDENCE' and limitations like 'Insufficient permission-eligible evidence:%'$$,array[1::bigint],'Insufficient evidence is stated explicitly');
reset role;

select throws_ok($$insert into consulting_os.domain_objects(organization_id,engagement_id,object_type,visibility_scope,origin,created_by) values('b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','INSIGHT','ENGAGEMENT_SHARED','AI','b8200000-0000-4000-8000-000000000001')$$,'23514',null,'AI cannot create an Insight');
select throws_ok($$insert into consulting_os.domain_objects(organization_id,engagement_id,object_type,visibility_scope,origin,created_by) values('b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','DECISION','ENGAGEMENT_SHARED','AI','b8200000-0000-4000-8000-000000000001')$$,'23514',null,'AI cannot make a Decision');
select throws_ok($$insert into consulting_os.entity_relationships(organization_id,engagement_id,relationship_type,source_type,source_id,target_type,target_id,origin,review_status,rationale,created_by) values('b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','b8300000-0000-4000-8000-000000000001','CONTRIBUTED_TO','EVIDENCE','b8400000-0000-4000-8000-000000000002','EVIDENCE','b8400000-0000-4000-8000-000000000004','AI','SUGGESTED','Unsafe attribution.','b8200000-0000-4000-8000-000000000001')$$,'23514',null,'AI cannot assert CONTRIBUTED_TO');

set local role authenticated;
select set_config('request.jwt.claim.sub','b8100000-0000-4000-8000-000000000001',true);
select lives_ok($$select consulting_os.reject_ai_suggestion((select id from consulting_os.ai_outputs where organization_id='b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa' order by created_at limit 1),'Contrary evidence narrows the recurrence claim.')$$,'Authorized human may reject an AI suggestion with rationale');
select results_eq($$select count(*) from consulting_os.patterns p join consulting_os.domain_objects d on d.id=p.id where d.origin='AI'$$,array[1::bigint],'Rejected AI Pattern remains preserved in history');
select results_eq($$select count(*) from consulting_os.ai_output_review where organization_id='b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa' and current_review_state='REJECTED' and review_rationale<>''$$,array[1::bigint],'Rejected suggestion remains visibly rejected with human rationale');
select results_eq($$select count(*) from consulting_os.ai_truth_eligible_records where organization_id='b8aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'$$,array[0::bigint],'Rejected and unreviewed AI suggestions never appear as truth');
reset role;

select * from finish();
rollback;
