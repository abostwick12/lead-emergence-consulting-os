begin;
create extension if not exists pgtap with schema extensions;
set local search_path=extensions,public,pg_catalog;
select plan(22);

select has_table('consulting_os','signals','Signal is first-class');
select has_table('consulting_os','descriptive_trends','Compatible descriptive trends are governed');
select has_table('consulting_os','assumption_review_schedules','Assumption review timing is explicit');
select has_view('consulting_os','current_signal_set','SEE AGAIN has a permission-aware derived view');
select has_function('consulting_os','reenter_signal_as_observation',array['uuid','text','text','timestamp with time zone'],'Signal re-entry is controlled');
select enum_has_labels('consulting_os','signal_status',array['NEW','REVIEWED','REENTERED','ARCHIVED'],'Signal lifecycle is controlled');
select results_eq($$select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='consulting_os' and c.relname in ('signals','descriptive_trends','assumption_review_schedules','emerging_questions') and c.relrowsecurity$$,array[4::bigint],'Every Phase 9 table enforces RLS');

insert into auth.users(id,email,role,aud,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
('c9100000-0000-4000-8000-000000000001','phase9-consultant@example.test','authenticated','authenticated','{}','{}',now(),now()),
('c9100000-0000-4000-8000-000000000002','phase9-other@example.test','authenticated','authenticated','{}','{}',now(),now());
insert into consulting_os.people(id,auth_user_id,display_name) values
('c9200000-0000-4000-8000-000000000001','c9100000-0000-4000-8000-000000000001','Phase 9 Consultant'),
('c9200000-0000-4000-8000-000000000002','c9100000-0000-4000-8000-000000000002','Other Tenant Owner');
insert into consulting_os.organizations(id,name,slug,created_by) values
('c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','See Again One','see-again-one','c9200000-0000-4000-8000-000000000001'),
('c9bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','See Again Two','see-again-two','c9200000-0000-4000-8000-000000000002');
insert into consulting_os.consultant_assignments(organization_id,consultant_person_id,status,effective_from,assignment_reason,created_by) values
('c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9200000-0000-4000-8000-000000000001','ACTIVE',now()-interval '1 day','Phase 9 fixture','c9200000-0000-4000-8000-000000000001');
insert into consulting_os.engagements(id,organization_id,name,status,starts_on,created_by) values
('c9300000-0000-4000-8000-000000000001','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','Renewed inquiry','ACTIVE',current_date,'c9200000-0000-4000-8000-000000000001'),
('c9300000-0000-4000-8000-000000000002','c9bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','Other inquiry','ACTIVE',current_date,'c9200000-0000-4000-8000-000000000002');

insert into consulting_os.domain_objects(id,organization_id,engagement_id,object_type,visibility_scope,origin,created_by) values
('c9400000-0000-4000-8000-000000000001','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','ROLE','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000002','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',null,'FUTURE_STATE','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000003','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','EMERGENT_ORGANIZATION_PROFILE','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000004','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','BASELINE_SNAPSHOT','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000005','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','EVIDENCE_SOURCE','ENGAGEMENT_SHARED','IMPORTED','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000006','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','EVIDENCE','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000007','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','EVIDENCE_SOURCE','CONSULTANT_PRIVATE','IMPORTED','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000008','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','EVIDENCE','CONSULTANT_PRIVATE','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000009','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','GOAL','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000010','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',null,'INDICATOR','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000011','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','MEASUREMENT','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000012','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','MEASUREMENT','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000013','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',null,'INDICATOR','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000014','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','MEASUREMENT','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000015','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','ASSUMPTION','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000016','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','EMERGING_QUESTION','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000101','c9bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','c9300000-0000-4000-8000-000000000002','EVIDENCE_SOURCE','ENGAGEMENT_SHARED','IMPORTED','c9200000-0000-4000-8000-000000000002'),
('c9400000-0000-4000-8000-000000000102','c9bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','c9300000-0000-4000-8000-000000000002','EVIDENCE','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000002');

insert into consulting_os.future_states(id,organization_id,logical_id,version_number,state_domain,current_baseline,desired_condition,horizon_date,effective_from,created_by) values
('c9400000-0000-4000-8000-000000000002','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9500000-0000-4000-8000-000000000002',1,'AUTHORITY','Senior approval','Bounded authority near work',current_date+90,now()-interval '60 days','c9200000-0000-4000-8000-000000000001');
insert into consulting_os.emergent_organization_profiles(id,organization_id,engagement_id,logical_id,version_number,intended_future_state_id,name,identity_state,purpose_state,culture_state,people_state,structure_state,systems_state,technology_state,relationships_state,value_state,stories_state,assumptions_state,status,effective_from,created_by) values
('c9400000-0000-4000-8000-000000000003','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9500000-0000-4000-8000-000000000003',1,'c9400000-0000-4000-8000-000000000002','Distributed Authority Reality','Purpose-led','Purpose held','More trust','Team leads decide','Authority distributed','Exception review','Workflow evidence','Healthy escalation','Latency improved','Delegation story','Oversight is not approval','APPROVED',now()-interval '30 days','c9200000-0000-4000-8000-000000000001');
insert into consulting_os.baseline_snapshots(id,organization_id,engagement_id,source_profile_id,snapshot_at,scope,rationale,created_by) values
('c9400000-0000-4000-8000-000000000004','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9400000-0000-4000-8000-000000000003',now()-interval '20 days','Authority and decision flow','Approved New Reality baseline.','c9200000-0000-4000-8000-000000000001');

insert into consulting_os.evidence_sources(id,organization_id,source_type,title,captured_at,provenance_context,created_by) values
('c9400000-0000-4000-8000-000000000005','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','METRIC_SYSTEM','Workflow log',now(),'Synthetic shared source','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000007','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','MEETING','Private coaching note',now(),'Synthetic private source','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000101','c9bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','METRIC_SYSTEM','Other tenant log',now(),'Synthetic other source','c9200000-0000-4000-8000-000000000002');
insert into consulting_os.evidence_fragments(id,organization_id,evidence_source_id,locator_kind,locator,content_text,content_sha256,created_by) values
('c9600000-0000-4000-8000-000000000001','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9400000-0000-4000-8000-000000000005','ROW_RANGE','{"rows":[1,10]}','Escalations cluster in two workflows.',repeat('1',64),'c9200000-0000-4000-8000-000000000001'),
('c9600000-0000-4000-8000-000000000002','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9400000-0000-4000-8000-000000000007','PRIVATE_NOTE','{"note":1}','Private coaching content.',repeat('2',64),'c9200000-0000-4000-8000-000000000001'),
('c9600000-0000-4000-8000-000000000101','c9bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','c9400000-0000-4000-8000-000000000101','ROW_RANGE','{"rows":[1,2]}','Other tenant evidence.',repeat('3',64),'c9200000-0000-4000-8000-000000000002');
insert into consulting_os.evidence_items(id,organization_id,primary_fragment_id,evidence_type,relevance_note,created_by) values
('c9400000-0000-4000-8000-000000000006','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9600000-0000-4000-8000-000000000001','SYSTEM_RECORD','Shared operational evidence.','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000008','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9600000-0000-4000-8000-000000000002','PRIVATE_NOTE','Private coaching evidence.','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000102','c9bbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','c9600000-0000-4000-8000-000000000101','SYSTEM_RECORD','Other tenant evidence.','c9200000-0000-4000-8000-000000000002');

insert into consulting_os.goals(id,organization_id,engagement_id,logical_id,version_number,statement,owner_domain_object_id,baseline_value,baseline_at,target_value,target_at,horizon,status,effective_from,created_by) values
('c9400000-0000-4000-8000-000000000009','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9500000-0000-4000-8000-000000000009',1,'Reduce latency without quality loss.','c9400000-0000-4000-8000-000000000001','6.2 days',now()-interval '60 days','3.0 days',now()+interval '30 days','90 days','ACTIVE',now()-interval '60 days','c9200000-0000-4000-8000-000000000001');
insert into consulting_os.indicators(id,organization_id,logical_id,version_number,goal_id,name,definition,direction,cadence,source_description,unit,status,effective_from,created_by) values
('c9400000-0000-4000-8000-000000000010','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9500000-0000-4000-8000-000000000010',1,'c9400000-0000-4000-8000-000000000009','Decision latency','Median routine decision latency.','DECREASE','Monthly','Workflow timestamps','days','ACTIVE',now()-interval '60 days','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000013','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9500000-0000-4000-8000-000000000013',1,'c9400000-0000-4000-8000-000000000009','Escalation count','Count of escalations.','DECREASE','Monthly','Workflow timestamps','count','ACTIVE',now()-interval '60 days','c9200000-0000-4000-8000-000000000001');
insert into consulting_os.measurements(id,organization_id,engagement_id,indicator_id,primary_evidence_id,measured_at,period_start,period_end,value_payload,display_value,collection_context,limitations,created_by) values
('c9400000-0000-4000-8000-000000000011','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9400000-0000-4000-8000-000000000010','c9400000-0000-4000-8000-000000000006',now()-interval '30 days',now()-interval '60 days',now()-interval '31 days','6.2','6.2 days','Baseline sample.','Small sample.','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000012','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9400000-0000-4000-8000-000000000010','c9400000-0000-4000-8000-000000000006',now(),now()-interval '29 days',now()-interval '1 day','3.4','3.4 days','Current sample.','Two periods only.','c9200000-0000-4000-8000-000000000001'),
('c9400000-0000-4000-8000-000000000014','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9400000-0000-4000-8000-000000000013','c9400000-0000-4000-8000-000000000006',now(),now()-interval '29 days',now()-interval '1 day','4','4 escalations','Current sample.','Different indicator.','c9200000-0000-4000-8000-000000000001');

insert into consulting_os.assumptions(id,organization_id,logical_id,version_number,statement,holder_scope,assumption_status,initial_review_state,review_trigger,effective_from,created_by) values
('c9400000-0000-4000-8000-000000000015','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9500000-0000-4000-8000-000000000015',1,'Senior approval protects decision quality.','Leadership','UNTESTED','DRAFT','Review after two measurement periods.',now()-interval '60 days','c9200000-0000-4000-8000-000000000001');
insert into consulting_os.assumption_review_schedules(id,organization_id,engagement_id,assumption_id,scheduled_for,trigger_context,status,created_by) values
('c9700000-0000-4000-8000-000000000001','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9400000-0000-4000-8000-000000000015',current_date,'Two compatible periods are available.','DUE','c9200000-0000-4000-8000-000000000001');
insert into consulting_os.emerging_questions(id,organization_id,engagement_id,question,source_assumption_id,initial_review_state,status,created_by) values
('c9400000-0000-4000-8000-000000000016','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','What evidence would show that confidence is becoming more consistent?','c9400000-0000-4000-8000-000000000015','DRAFT','OPEN','c9200000-0000-4000-8000-000000000001');

insert into consulting_os.descriptive_trends(organization_id,engagement_id,baseline_measurement_id,current_measurement_id,direction,statement,comparison_basis,limitations,visibility_scope,created_by) values
('c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9400000-0000-4000-8000-000000000011','c9400000-0000-4000-8000-000000000012','DECREASED','Median decision latency decreased between the two periods.','Same indicator definition, direction, and unit.','Two periods do not establish recurrence or cause.','ENGAGEMENT_SHARED','c9200000-0000-4000-8000-000000000001');
select results_eq($$select count(*) from consulting_os.descriptive_trends where direction='DECREASED'$$,array[1::bigint],'Compatible measurements produce a descriptive trend');
select throws_ok($$insert into consulting_os.descriptive_trends(organization_id,engagement_id,baseline_measurement_id,current_measurement_id,direction,statement,comparison_basis,limitations,visibility_scope,created_by) values('c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9400000-0000-4000-8000-000000000011','c9400000-0000-4000-8000-000000000014','MIXED','Measures differ.','Attempted comparison.','Incompatible.','ENGAGEMENT_SHARED','c9200000-0000-4000-8000-000000000001')$$,'23514',null,'Incompatible indicator identities cannot become a trend');
select throws_ok($$insert into consulting_os.descriptive_trends(organization_id,engagement_id,baseline_measurement_id,current_measurement_id,direction,statement,comparison_basis,limitations,visibility_scope,created_by) values('c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9400000-0000-4000-8000-000000000011','c9400000-0000-4000-8000-000000000012','MIXED','Drift detected in authority.','Same measure.','None.','ENGAGEMENT_SHARED','c9200000-0000-4000-8000-000000000001')$$,'23514',null,'Diagnostic language cannot be stored as a descriptive trend');
select results_eq($$select count(*) from consulting_os.current_assumptions_due where assumption_id='c9400000-0000-4000-8000-000000000015' and due_state='DUE'$$,array[1::bigint],'Assumptions due for review are surfaced');
select results_eq($$select count(*) from consulting_os.current_signal_set where item_type in ('TREND','ASSUMPTION_TO_REVISIT','EMERGING_QUESTION','BASELINE')$$,array[4::bigint],'Current Signal Set composes the four established longitudinal areas');

set local role authenticated;
select set_config('request.jwt.claim.sub','c9100000-0000-4000-8000-000000000001',true);
select lives_ok($$select consulting_os.create_signal('c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9400000-0000-4000-8000-000000000006','Escalations now cluster in two workflows.','OPERATING_CHANGE','Weekly operating review',now(),'c9400000-0000-4000-8000-000000000004','ENGAGEMENT_SHARED')$$,'Authorized human can record a source-grounded descriptive Signal');
select results_eq($$select count(*) from consulting_os.current_signal_set where item_type='NEW_OBSERVATION' and detail='Escalations now cluster in two workflows.'$$,array[1::bigint],'New Signal appears without becoming a Pattern');
select throws_ok($$select consulting_os.create_signal('c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','c9400000-0000-4000-8000-000000000008','Private coaching indicates drift.','REPORTED_CHANGE','Private source attempt',now(),null,'ENGAGEMENT_SHARED')$$,'42501',null,'Private coaching evidence cannot become organizational telemetry');
select lives_ok($$select consulting_os.reenter_signal_as_observation((select id from consulting_os.signals where statement='Escalations now cluster in two workflows.'),'Exceptions were recorded in three consecutive operating reviews.','Renewed SEE REALITY inquiry',now())$$,'Authorized human can re-enter a Signal as an Observation');
select results_eq($$select count(*) from consulting_os.entity_relationships where relationship_type='REENTERS_AS' and source_type='SIGNAL' and target_type='OBSERVATION' and review_status='ACCEPTED'$$,array[1::bigint],'Re-entry preserves the typed relationship');
select results_eq($$select count(*) from consulting_os.signals where statement='Escalations now cluster in two workflows.' and status='REENTERED'$$,array[1::bigint],'Original Signal remains preserved with re-entry status');
select lives_ok($$select consulting_os.complete_assumption_review('c9700000-0000-4000-8000-000000000001','Quality remained stable across the reviewed periods.')$$,'Authorized human can complete a due assumption review');
select results_eq($$select count(*) from consulting_os.current_assumptions_due where assumption_id='c9400000-0000-4000-8000-000000000015'$$,array[0::bigint],'Completed assumption review leaves the due queue');
reset role;

insert into consulting_os.domain_objects(id,organization_id,engagement_id,object_type,visibility_scope,origin,created_by) values
('c9400000-0000-4000-8000-000000000017','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','SIGNAL','ENGAGEMENT_SHARED','HUMAN','c9200000-0000-4000-8000-000000000001');
select throws_ok($$insert into consulting_os.signals(id,organization_id,engagement_id,statement,signal_type,detected_at,context,primary_evidence_id,created_by) values('c9400000-0000-4000-8000-000000000017','c9aaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','c9300000-0000-4000-8000-000000000001','Unsafe cross-tenant Signal.','CONTEXT_CHANGE',now(),'Invalid source','c9400000-0000-4000-8000-000000000102','c9200000-0000-4000-8000-000000000001')$$,'42501',null,'Signal Evidence cannot cross the organization boundary');
select ok(not has_table_privilege('authenticated','consulting_os.signals','INSERT'),'Authenticated users cannot bypass controlled Signal creation');

select * from finish();
rollback;
