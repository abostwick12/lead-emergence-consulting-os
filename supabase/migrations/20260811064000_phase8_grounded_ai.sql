-- Lead Emergence Consulting OS — Phase 8 grounded AI.
-- Additive migration for disposable/local verification only unless a hosted target is separately approved.

create type consulting_os.ai_task_type as enum (
  'EXTRACT_OBSERVATIONS', 'SUMMARIZE_SOURCES', 'SUGGEST_PATTERN',
  'SUGGEST_TENSION', 'SUGGEST_HYPOTHESIS', 'SUGGEST_INTERPRETATION',
  'MEETING_PREPARATION', 'COMPARE_OUTCOMES'
);
create type consulting_os.ai_run_status as enum ('PENDING', 'COMPLETED', 'INSUFFICIENT_EVIDENCE', 'FAILED');
create type consulting_os.ai_output_kind as enum ('PATTERN', 'INTERPRETATION', 'MEETING_BRIEF', 'SOURCE_SUMMARY');
create type consulting_os.ai_source_role as enum ('SUPPORTING', 'CHALLENGING', 'CONTEXT');

create table consulting_os.ai_generation_runs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  engagement_id uuid not null,
  requested_by uuid not null references consulting_os.people(id) on delete restrict,
  task_type consulting_os.ai_task_type not null,
  purpose text not null check (length(btrim(purpose)) > 0),
  status consulting_os.ai_run_status not null default 'PENDING',
  provider text not null default 'DETERMINISTIC_FIXTURE',
  model_identifier text not null default 'NO_HOSTED_MODEL',
  permission_filter_applied_at timestamptz not null default now(),
  source_count integer not null default 0 check (source_count >= 0),
  limitations text,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check ((status = 'PENDING' and completed_at is null) or (status <> 'PENDING' and completed_at is not null))
);

create table consulting_os.ai_run_sources (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  run_id uuid not null,
  source_domain_object_id uuid not null,
  evidence_fragment_id uuid not null,
  source_role consulting_os.ai_source_role not null,
  rank_after_authorization integer not null check (rank_after_authorization > 0),
  source_title_snapshot text not null check (length(btrim(source_title_snapshot)) > 0),
  locator_snapshot jsonb not null check (jsonb_typeof(locator_snapshot) = 'object'),
  content_sha256_snapshot text not null check (content_sha256_snapshot ~ '^[0-9a-f]{64}$'),
  visibility_snapshot consulting_os.visibility_scope not null,
  created_at timestamptz not null default now(),
  foreign key (run_id, organization_id) references consulting_os.ai_generation_runs(id, organization_id) on delete restrict,
  foreign key (source_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (evidence_fragment_id, organization_id) references consulting_os.evidence_fragments(id, organization_id) on delete restrict,
  unique (run_id, source_domain_object_id, source_role),
  unique (id, organization_id),
  check (visibility_snapshot not in ('CONSULTANT_PRIVATE', 'INDIVIDUAL_PRIVATE', 'COACHING_SHARED', 'TEAM_SHARED', 'PLATFORM_RESTRICTED'))
);

create table consulting_os.ai_outputs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  engagement_id uuid not null,
  run_id uuid not null,
  output_kind consulting_os.ai_output_kind not null,
  output_domain_object_id uuid,
  title text not null check (length(btrim(title)) > 0),
  statement text not null check (length(btrim(statement)) > 0),
  scope text not null check (length(btrim(scope)) > 0),
  recurrence_basis text not null check (length(btrim(recurrence_basis)) > 0),
  limitations text not null check (length(btrim(limitations)) > 0),
  created_at timestamptz not null default now(),
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (run_id, organization_id) references consulting_os.ai_generation_runs(id, organization_id) on delete restrict,
  foreign key (output_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (run_id, output_domain_object_id),
  check ((output_kind in ('PATTERN','INTERPRETATION') and output_domain_object_id is not null) or (output_kind in ('MEETING_BRIEF','SOURCE_SUMMARY')))
);

create table consulting_os.ai_output_citations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  output_id uuid not null,
  run_source_id uuid not null,
  citation_note text not null check (length(btrim(citation_note)) > 0),
  created_at timestamptz not null default now(),
  foreign key (output_id, organization_id) references consulting_os.ai_outputs(id, organization_id) on delete restrict,
  foreign key (run_source_id, organization_id) references consulting_os.ai_run_sources(id, organization_id) on delete restrict,
  unique (output_id, run_source_id)
);

create index ai_runs_org_engagement_time_idx on consulting_os.ai_generation_runs(organization_id, engagement_id, created_at desc);
create index ai_run_sources_run_role_idx on consulting_os.ai_run_sources(organization_id, run_id, source_role, rank_after_authorization);
create index ai_outputs_org_engagement_time_idx on consulting_os.ai_outputs(organization_id, engagement_id, created_at desc);
create index ai_output_citations_output_idx on consulting_os.ai_output_citations(organization_id, output_id);

create or replace function consulting_security.enforce_ai_authority_boundary()
returns trigger language plpgsql security invoker set search_path = '' as $$
begin
  if new.origin = 'AI' and new.object_type in ('INSIGHT','DIAGNOSIS','DECISION','RECORD_REVIEW','OUTCOME_DECISION','VALUE_EVALUATION') then
    raise exception 'AI cannot create or validate authoritative % records', new.object_type using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.enforce_ai_attribution_boundary()
returns trigger language plpgsql security invoker set search_path = '' as $$
begin
  if new.origin = 'AI' and new.relationship_type in ('CAUSES','CONTRIBUTED_TO') then
    raise exception 'AI cannot assert % relationships', new.relationship_type using errcode = '23514';
  end if;
  return new;
end
$$;

create trigger domain_objects_ai_authority_boundary before insert or update on consulting_os.domain_objects
for each row execute function consulting_security.enforce_ai_authority_boundary();
create trigger aa_relationships_ai_attribution_boundary before insert or update on consulting_os.entity_relationships
for each row execute function consulting_security.enforce_ai_attribution_boundary();

create or replace function consulting_security.assert_ai_source_eligible(p_organization_id uuid, p_source_domain_object_id uuid)
returns void language plpgsql stable security definer set search_path = '' as $$
declare v_object consulting_os.domain_objects%rowtype;
begin
  select * into v_object from consulting_os.domain_objects d
  where d.id = p_source_domain_object_id and d.organization_id = p_organization_id and d.archived_at is null;
  if v_object.id is null
    or not consulting_security.can_read_domain_object(p_source_domain_object_id, p_organization_id)
    or v_object.visibility_scope in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE','COACHING_SHARED','TEAM_SHARED','PLATFORM_RESTRICTED')
    or v_object.object_type <> 'EVIDENCE'
  then
    raise exception 'requested AI source is not permission-eligible evidence in this tenant' using errcode = '42501';
  end if;
end
$$;

create or replace function consulting_os.eligible_ai_source_fragments(p_organization_id uuid, p_engagement_id uuid, p_purpose text)
returns table (
  source_domain_object_id uuid, evidence_fragment_id uuid, title text, locator jsonb,
  content_text text, content_sha256 text, visibility_scope consulting_os.visibility_scope
)
language sql stable security invoker set search_path = '' as $$
  select e.id, f.id, s.title, f.locator, f.content_text, f.content_sha256, d.visibility_scope
  from consulting_os.evidence_items e
  join consulting_os.domain_objects d on d.id = e.id and d.organization_id = e.organization_id
  join consulting_os.evidence_fragments f on f.id = e.primary_fragment_id and f.organization_id = e.organization_id
  join consulting_os.evidence_sources s on s.id = f.evidence_source_id and s.organization_id = f.organization_id
  where e.organization_id = p_organization_id
    and nullif(btrim(p_purpose), '') is not null
    and (d.engagement_id is null or d.engagement_id = p_engagement_id)
    and d.archived_at is null
    and d.visibility_scope not in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE','COACHING_SHARED','TEAM_SHARED','PLATFORM_RESTRICTED')
$$;

create or replace function consulting_os.request_ai_pattern_suggestion(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_purpose text,
  p_supporting_source_ids uuid[],
  p_challenging_source_ids uuid[],
  p_statement text,
  p_scope text,
  p_recurrence_basis text,
  p_contrary_evidence_summary text,
  p_limitations text
)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_actor uuid := consulting_security.current_person_id();
  v_run_id uuid := gen_random_uuid();
  v_pattern_id uuid := gen_random_uuid();
  v_output_id uuid;
  v_source_id uuid;
  v_rank integer := 0;
  v_source record;
  v_run_source_id uuid;
  v_visibility consulting_os.visibility_scope := 'ORGANIZATION_SHARED';
  v_source_count integer := coalesce(cardinality(p_supporting_source_ids), 0) + coalesce(cardinality(p_challenging_source_ids), 0);
begin
  if v_actor is null or not consulting_security.has_active_consultant_assignment(p_organization_id) then
    raise exception 'only an assigned consultant may request grounded AI assistance' using errcode = '42501';
  end if;
  if not exists (select 1 from consulting_os.engagements e where e.id = p_engagement_id and e.organization_id = p_organization_id) then
    raise exception 'engagement is outside the organization boundary' using errcode = '23503';
  end if;
  if length(btrim(coalesce(p_purpose,''))) = 0 then raise exception 'AI purpose is required' using errcode = '23514'; end if;

  insert into consulting_os.ai_generation_runs(id, organization_id, engagement_id, requested_by, task_type, purpose)
  values (v_run_id, p_organization_id, p_engagement_id, v_actor, 'SUGGEST_PATTERN', p_purpose);

  foreach v_source_id in array coalesce(p_supporting_source_ids, array[]::uuid[]) loop
    perform consulting_security.assert_ai_source_eligible(p_organization_id, v_source_id);
  end loop;
  foreach v_source_id in array coalesce(p_challenging_source_ids, array[]::uuid[]) loop
    perform consulting_security.assert_ai_source_eligible(p_organization_id, v_source_id);
  end loop;
  update consulting_os.ai_generation_runs set permission_filter_applied_at=now() where id=v_run_id;

  if coalesce(cardinality(p_supporting_source_ids), 0) < 2 or coalesce(cardinality(p_challenging_source_ids), 0) < 1 then
    update consulting_os.ai_generation_runs set status='INSUFFICIENT_EVIDENCE', source_count=v_source_count,
      limitations='Insufficient permission-eligible evidence: two supporting and one contrary source are required.', completed_at=now()
    where id=v_run_id;
    insert into consulting_os.audit_events(organization_id,actor_person_id,event_type,target_table,target_id,operation,reason,metadata)
    values(p_organization_id,v_actor,'AI_INSUFFICIENT_EVIDENCE','consulting_os.ai_generation_runs',v_run_id,'INSERT','Grounded request stopped before generation',jsonb_build_object('source_count',v_source_count));
    return v_run_id;
  end if;

  foreach v_source_id in array p_supporting_source_ids loop
    v_rank := v_rank + 1;
    select e.id source_id, f.id fragment_id, s.title, f.locator, f.content_sha256, d.visibility_scope into strict v_source
    from consulting_os.evidence_items e join consulting_os.domain_objects d on d.id=e.id and d.organization_id=e.organization_id
    join consulting_os.evidence_fragments f on f.id=e.primary_fragment_id and f.organization_id=e.organization_id
    join consulting_os.evidence_sources s on s.id=f.evidence_source_id and s.organization_id=f.organization_id
    where e.id=v_source_id and e.organization_id=p_organization_id;
    if v_source.visibility_scope='LEADERSHIP_RESTRICTED' then v_visibility:='LEADERSHIP_RESTRICTED';
    elsif v_source.visibility_scope='ENGAGEMENT_SHARED' and v_visibility='ORGANIZATION_SHARED' then v_visibility:='ENGAGEMENT_SHARED'; end if;
    insert into consulting_os.ai_run_sources(organization_id,run_id,source_domain_object_id,evidence_fragment_id,source_role,rank_after_authorization,source_title_snapshot,locator_snapshot,content_sha256_snapshot,visibility_snapshot)
    values(p_organization_id,v_run_id,v_source.source_id,v_source.fragment_id,'SUPPORTING',v_rank,v_source.title,v_source.locator,v_source.content_sha256,v_source.visibility_scope);
  end loop;
  foreach v_source_id in array p_challenging_source_ids loop
    v_rank := v_rank + 1;
    select e.id source_id, f.id fragment_id, s.title, f.locator, f.content_sha256, d.visibility_scope into strict v_source
    from consulting_os.evidence_items e join consulting_os.domain_objects d on d.id=e.id and d.organization_id=e.organization_id
    join consulting_os.evidence_fragments f on f.id=e.primary_fragment_id and f.organization_id=e.organization_id
    join consulting_os.evidence_sources s on s.id=f.evidence_source_id and s.organization_id=f.organization_id
    where e.id=v_source_id and e.organization_id=p_organization_id;
    if v_source.visibility_scope='LEADERSHIP_RESTRICTED' then v_visibility:='LEADERSHIP_RESTRICTED';
    elsif v_source.visibility_scope='ENGAGEMENT_SHARED' and v_visibility='ORGANIZATION_SHARED' then v_visibility:='ENGAGEMENT_SHARED'; end if;
    insert into consulting_os.ai_run_sources(organization_id,run_id,source_domain_object_id,evidence_fragment_id,source_role,rank_after_authorization,source_title_snapshot,locator_snapshot,content_sha256_snapshot,visibility_snapshot)
    values(p_organization_id,v_run_id,v_source.source_id,v_source.fragment_id,'CHALLENGING',v_rank,v_source.title,v_source.locator,v_source.content_sha256,v_source.visibility_scope);
  end loop;

  insert into consulting_os.domain_objects(id,organization_id,engagement_id,object_type,visibility_scope,origin,created_by)
  values(v_pattern_id,p_organization_id,p_engagement_id,'PATTERN',v_visibility,'AI',v_actor);
  insert into consulting_os.patterns(id,organization_id,statement,scope,recurrence_basis,contrary_evidence_summary,initial_review_state,created_by)
  values(v_pattern_id,p_organization_id,p_statement,p_scope,p_recurrence_basis,p_contrary_evidence_summary,'SUGGESTED',v_actor);
  insert into consulting_os.ai_outputs(organization_id,engagement_id,run_id,output_kind,output_domain_object_id,title,statement,scope,recurrence_basis,limitations)
  values(p_organization_id,p_engagement_id,v_run_id,'PATTERN',v_pattern_id,'Meridian Pattern suggestion',p_statement,p_scope,p_recurrence_basis,p_limitations)
  returning id into v_output_id;

  for v_source in select * from consulting_os.ai_run_sources where run_id=v_run_id order by rank_after_authorization loop
    insert into consulting_os.claim_citations(organization_id,claim_id,evidence_fragment_id,citation_role,citation_note,created_by)
    values(p_organization_id,v_pattern_id,v_source.evidence_fragment_id,v_source.source_role::text::consulting_os.citation_role,'Exact source fragment preserved by the grounded AI run.',v_actor);
    insert into consulting_os.ai_output_citations(organization_id,output_id,run_source_id,citation_note)
    values(p_organization_id,v_output_id,v_source.id,'Citation to the authorization-filtered source snapshot.');
  end loop;
  update consulting_os.ai_generation_runs set status='COMPLETED',source_count=v_source_count,limitations=p_limitations,completed_at=now() where id=v_run_id;
  insert into consulting_os.audit_events(organization_id,actor_person_id,event_type,target_table,target_id,operation,reason,metadata)
  values(p_organization_id,v_actor,'AI_SUGGESTION_CREATED','consulting_os.ai_outputs',v_output_id,'INSERT',p_purpose,jsonb_build_object('run_id',v_run_id,'source_count',v_source_count,'review_state','SUGGESTED'));
  return v_output_id;
end
$$;

create or replace function consulting_os.reject_ai_suggestion(p_output_id uuid, p_rationale text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare v_actor uuid:=consulting_security.current_person_id(); v_output record; v_review_id uuid:=gen_random_uuid(); v_visibility consulting_os.visibility_scope;
begin
  select o.*, d.visibility_scope into v_output from consulting_os.ai_outputs o
  join consulting_os.domain_objects d on d.id=o.output_domain_object_id and d.organization_id=o.organization_id
  where o.id=p_output_id;
  if v_output.id is null or v_actor is null or not consulting_security.has_active_consultant_assignment(v_output.organization_id)
    or not consulting_security.can_manage_domain_object(v_output.output_domain_object_id,v_output.organization_id) then
    raise exception 'AI suggestion is not reviewable in the current context' using errcode='42501';
  end if;
  if length(btrim(coalesce(p_rationale,'')))=0 then raise exception 'rejection rationale is required' using errcode='23514'; end if;
  if exists(select 1 from consulting_os.latest_record_reviews r where r.subject_id=v_output.output_domain_object_id and r.organization_id=v_output.organization_id and r.review_action='REJECTED') then
    raise exception 'AI suggestion is already rejected' using errcode='23514';
  end if;
  v_visibility:=v_output.visibility_scope;
  insert into consulting_os.domain_objects(id,organization_id,engagement_id,object_type,visibility_scope,origin,created_by)
  values(v_review_id,v_output.organization_id,v_output.engagement_id,'RECORD_REVIEW',v_visibility,'HUMAN',v_actor);
  insert into consulting_os.record_reviews(id,organization_id,subject_id,review_action,reviewer_person_id,rationale,reviewed_at,created_by)
  values(v_review_id,v_output.organization_id,v_output.output_domain_object_id,'REJECTED',v_actor,p_rationale,now(),v_actor);
  insert into consulting_os.audit_events(organization_id,actor_person_id,event_type,target_table,target_id,operation,reason,metadata)
  values(v_output.organization_id,v_actor,'AI_SUGGESTION_REJECTED','consulting_os.record_reviews',v_review_id,'INSERT',p_rationale,jsonb_build_object('output_id',p_output_id,'subject_id',v_output.output_domain_object_id));
  return v_review_id;
end
$$;

alter table consulting_os.ai_generation_runs enable row level security;
alter table consulting_os.ai_run_sources enable row level security;
alter table consulting_os.ai_outputs enable row level security;
alter table consulting_os.ai_output_citations enable row level security;
create policy ai_runs_select_assigned on consulting_os.ai_generation_runs for select to authenticated using (consulting_security.has_active_consultant_assignment(organization_id));
create policy ai_sources_select_visible on consulting_os.ai_run_sources for select to authenticated using (consulting_security.has_active_consultant_assignment(organization_id) and consulting_security.can_read_domain_object(source_domain_object_id,organization_id));
create policy ai_outputs_select_visible on consulting_os.ai_outputs for select to authenticated using (consulting_security.can_read_domain_object(output_domain_object_id,organization_id));
create policy ai_output_citations_select_visible on consulting_os.ai_output_citations for select to authenticated using (exists(select 1 from consulting_os.ai_outputs o where o.id=ai_output_citations.output_id and o.organization_id=ai_output_citations.organization_id and consulting_security.can_read_domain_object(o.output_domain_object_id,o.organization_id)));

create or replace view consulting_os.ai_output_review with (security_invoker=true) as
select o.id,o.organization_id,o.engagement_id,o.output_kind,o.output_domain_object_id,o.title,o.statement,o.scope,o.recurrence_basis,o.limitations,o.created_at,
  coalesce(es.current_review_state,'SUGGESTED'::consulting_os.epistemic_review_state) current_review_state,
  rr.rationale review_rationale,
  coalesce(jsonb_agg(jsonb_build_object('id',rs.source_domain_object_id,'fragmentId',rs.evidence_fragment_id,'title',rs.source_title_snapshot,'locator',rs.locator_snapshot::text,'excerpt',f.content_text,'role',rs.source_role,'visibility',rs.visibility_snapshot) order by rs.rank_after_authorization) filter(where rs.id is not null),'[]'::jsonb) sources
from consulting_os.ai_outputs o
left join consulting_os.epistemic_record_states es on es.id=o.output_domain_object_id and es.organization_id=o.organization_id
left join consulting_os.latest_record_reviews rr on rr.subject_id=o.output_domain_object_id and rr.organization_id=o.organization_id
left join consulting_os.ai_output_citations oc on oc.output_id=o.id and oc.organization_id=o.organization_id
left join consulting_os.ai_run_sources rs on rs.id=oc.run_source_id and rs.organization_id=oc.organization_id
left join consulting_os.evidence_fragments f on f.id=rs.evidence_fragment_id and f.organization_id=rs.organization_id
group by o.id,es.current_review_state,rr.rationale;

create or replace view consulting_os.ai_truth_eligible_records with (security_invoker=true) as
select es.* from consulting_os.epistemic_record_states es
where es.origin='HUMAN' and es.current_review_state in ('ACCEPTED','VALIDATED');

revoke all on consulting_os.ai_generation_runs,consulting_os.ai_run_sources,consulting_os.ai_outputs,consulting_os.ai_output_citations from public,anon,authenticated;
grant select on consulting_os.ai_generation_runs,consulting_os.ai_run_sources,consulting_os.ai_outputs,consulting_os.ai_output_citations to authenticated;
grant all on consulting_os.ai_generation_runs,consulting_os.ai_run_sources,consulting_os.ai_outputs,consulting_os.ai_output_citations to service_role;
grant select on consulting_os.ai_output_review,consulting_os.ai_truth_eligible_records to authenticated,service_role;
revoke all on function consulting_security.assert_ai_source_eligible(uuid,uuid),consulting_security.enforce_ai_authority_boundary(),consulting_security.enforce_ai_attribution_boundary() from public,anon,authenticated;
revoke all on function consulting_os.eligible_ai_source_fragments(uuid,uuid,text),consulting_os.request_ai_pattern_suggestion(uuid,uuid,text,uuid[],uuid[],text,text,text,text,text),consulting_os.reject_ai_suggestion(uuid,text) from public,anon;
grant execute on function consulting_os.eligible_ai_source_fragments(uuid,uuid,text),consulting_os.request_ai_pattern_suggestion(uuid,uuid,text,uuid[],uuid[],text,text,text,text,text),consulting_os.reject_ai_suggestion(uuid,text) to authenticated,service_role;

comment on table consulting_os.ai_generation_runs is 'Auditable AI request envelope; permission filtering timestamp precedes source ranking and generation.';
comment on table consulting_os.ai_run_sources is 'Exact authorization-filtered source set with immutable provenance snapshots. Private coaching sources are prohibited.';
comment on view consulting_os.ai_truth_eligible_records is 'Human-origin accepted/validated records only. Rejected and unreviewed AI suggestions cannot surface as truth.';
