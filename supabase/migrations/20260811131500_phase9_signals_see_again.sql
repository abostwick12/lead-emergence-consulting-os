-- Lead Emergence Consulting OS — Phase 9 Signals / SEE AGAIN
-- Additive migration. Signals remain descriptive and human-reviewed; this is not drift diagnosis.
-- Private coaching content is excluded from longitudinal intelligence unless separately promoted by an authorized human workflow.

create type consulting_os.signal_type as enum (
  'REPORTED_CHANGE', 'MEASURED_CHANGE', 'OPERATING_CHANGE',
  'RELATIONSHIP_CHANGE', 'CONTEXT_CHANGE'
);
create type consulting_os.signal_status as enum ('NEW', 'REVIEWED', 'REENTERED', 'ARCHIVED');
create type consulting_os.trend_direction as enum ('INCREASED', 'DECREASED', 'STABLE', 'MIXED');
create type consulting_os.assumption_review_schedule_status as enum ('SCHEDULED', 'DUE', 'COMPLETED', 'CANCELLED');
create type consulting_os.emerging_question_status as enum ('OPEN', 'ANSWERED', 'ARCHIVED');

create table consulting_os.signals (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('SIGNAL'::text) stored,
  statement text not null check (length(btrim(statement)) > 0),
  signal_type consulting_os.signal_type not null,
  detected_at timestamptz not null,
  context text not null check (length(btrim(context)) > 0),
  primary_evidence_id uuid not null,
  baseline_snapshot_id uuid,
  initial_review_state consulting_os.epistemic_review_state not null default 'DRAFT',
  status consulting_os.signal_status not null default 'NEW',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id)
    references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (primary_evidence_id, organization_id)
    references consulting_os.evidence_items(id, organization_id) on delete restrict,
  foreign key (baseline_snapshot_id, organization_id)
    references consulting_os.baseline_snapshots(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (statement !~* '(drift detected|emergence detected|autonomous diagnosis|organizational diagnosis|caused by)')
);

create table consulting_os.descriptive_trends (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  engagement_id uuid not null,
  baseline_measurement_id uuid not null,
  current_measurement_id uuid not null,
  direction consulting_os.trend_direction not null,
  statement text not null check (length(btrim(statement)) > 0),
  comparison_basis text not null check (length(btrim(comparison_basis)) > 0),
  limitations text not null check (length(btrim(limitations)) > 0),
  visibility_scope consulting_os.visibility_scope not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (engagement_id, organization_id)
    references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (baseline_measurement_id, organization_id)
    references consulting_os.measurements(id, organization_id) on delete restrict,
  foreign key (current_measurement_id, organization_id)
    references consulting_os.measurements(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (baseline_measurement_id, current_measurement_id),
  check (baseline_measurement_id <> current_measurement_id),
  check (statement !~* '(drift detected|emergence detected|autonomous diagnosis|organizational diagnosis|caused by)')
);

create table consulting_os.assumption_review_schedules (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  engagement_id uuid not null,
  assumption_id uuid not null,
  scheduled_for date not null,
  trigger_context text not null check (length(btrim(trigger_context)) > 0),
  status consulting_os.assumption_review_schedule_status not null default 'SCHEDULED',
  completed_at timestamptz,
  completed_by uuid references consulting_os.people(id) on delete restrict,
  review_note text,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (engagement_id, organization_id)
    references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (assumption_id, organization_id)
    references consulting_os.assumptions(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (
    (status = 'COMPLETED' and completed_at is not null and completed_by is not null and length(btrim(coalesce(review_note, ''))) > 0)
    or (status <> 'COMPLETED' and completed_at is null and completed_by is null)
  )
);
create unique index assumption_review_one_open_idx
  on consulting_os.assumption_review_schedules(organization_id, assumption_id)
  where status in ('SCHEDULED', 'DUE');

create table consulting_os.emerging_questions (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('EMERGING_QUESTION'::text) stored,
  question text not null check (length(btrim(question)) > 0 and right(btrim(question), 1) = '?'),
  source_signal_id uuid,
  source_assumption_id uuid,
  initial_review_state consulting_os.epistemic_review_state not null default 'DRAFT',
  status consulting_os.emerging_question_status not null default 'OPEN',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id)
    references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (source_signal_id, organization_id)
    references consulting_os.signals(id, organization_id) on delete restrict,
  foreign key (source_assumption_id, organization_id)
    references consulting_os.assumptions(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (source_signal_id is not null or source_assumption_id is not null),
  check (question !~* '(drift detected|emergence detected|autonomous diagnosis|organizational diagnosis)')
);

create index signals_engagement_time_idx on consulting_os.signals(organization_id, engagement_id, detected_at desc);
create index descriptive_trends_engagement_idx on consulting_os.descriptive_trends(organization_id, engagement_id, created_at desc);
create index assumption_reviews_due_idx on consulting_os.assumption_review_schedules(organization_id, scheduled_for)
  where status in ('SCHEDULED', 'DUE');
create index emerging_questions_engagement_idx on consulting_os.emerging_questions(organization_id, engagement_id, status);

create or replace function consulting_security.validate_phase9_signal()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_registry consulting_os.domain_objects%rowtype;
  v_evidence consulting_os.domain_objects%rowtype;
begin
  select * into v_registry from consulting_os.domain_objects
  where id = new.id and organization_id = new.organization_id;
  select * into v_evidence from consulting_os.domain_objects
  where id = new.primary_evidence_id and organization_id = new.organization_id;

  if v_registry.id is null or v_registry.object_type <> 'SIGNAL'
    or v_registry.engagement_id is distinct from new.engagement_id
    or v_registry.created_by <> new.created_by then
    raise exception 'Signal must match its domain registry tenant, engagement, type, and creator' using errcode = '23514';
  end if;
  if v_registry.visibility_scope in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE','COACHING_SHARED','TEAM_SHARED','PLATFORM_RESTRICTED')
    or v_evidence.id is null or v_evidence.object_type <> 'EVIDENCE'
    or v_evidence.engagement_id is distinct from new.engagement_id
    or v_evidence.visibility_scope in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE','COACHING_SHARED','TEAM_SHARED','PLATFORM_RESTRICTED')
    or not consulting_security.visibility_can_contain(v_registry.visibility_scope, v_evidence.visibility_scope) then
    raise exception 'Signals may only use same-engagement evidence eligible for shared longitudinal intelligence' using errcode = '42501';
  end if;
  if new.baseline_snapshot_id is not null and not exists (
    select 1 from consulting_os.baseline_snapshots b
    join consulting_os.domain_objects d on d.id = b.id and d.organization_id = b.organization_id
    where b.id = new.baseline_snapshot_id and b.organization_id = new.organization_id
      and d.visibility_scope not in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE','COACHING_SHARED','TEAM_SHARED','PLATFORM_RESTRICTED')
  ) then
    raise exception 'Signal baseline must be visible, immutable, and in the same organization' using errcode = '42501';
  end if;
  if v_registry.origin = 'AI' and new.initial_review_state <> 'SUGGESTED' then
    raise exception 'AI-originated Signals must remain SUGGESTED until human review' using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_descriptive_trend()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_base record;
  v_current record;
begin
  select m.organization_id, m.engagement_id, m.measured_at, i.logical_id, i.definition, i.direction, coalesce(i.unit, '') as unit_value, d.visibility_scope
    into v_base
  from consulting_os.measurements m
  join consulting_os.indicators i on i.id = m.indicator_id and i.organization_id = m.organization_id
  join consulting_os.domain_objects d on d.id = m.id and d.organization_id = m.organization_id
  where m.id = new.baseline_measurement_id and m.organization_id = new.organization_id;

  select m.organization_id, m.engagement_id, m.measured_at, i.logical_id, i.definition, i.direction, coalesce(i.unit, '') as unit_value, d.visibility_scope
    into v_current
  from consulting_os.measurements m
  join consulting_os.indicators i on i.id = m.indicator_id and i.organization_id = m.organization_id
  join consulting_os.domain_objects d on d.id = m.id and d.organization_id = m.organization_id
  where m.id = new.current_measurement_id and m.organization_id = new.organization_id;

  if v_base.organization_id is null or v_current.organization_id is null
    or v_base.engagement_id <> new.engagement_id or v_current.engagement_id <> new.engagement_id then
    raise exception 'Trend measurements must belong to the same tenant and engagement' using errcode = '23514';
  end if;
  if v_base.logical_id <> v_current.logical_id
    or v_base.definition <> v_current.definition
    or v_base.direction <> v_current.direction
    or lower(v_base.unit_value) <> lower(v_current.unit_value) then
    raise exception 'Trend comparison requires compatible indicator identity, definition, direction, and unit' using errcode = '23514';
  end if;
  if v_current.measured_at <= v_base.measured_at then
    raise exception 'Current trend measurement must follow the baseline measurement' using errcode = '23514';
  end if;
  if v_base.visibility_scope <> new.visibility_scope or v_current.visibility_scope <> new.visibility_scope
    or new.visibility_scope in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE','COACHING_SHARED','TEAM_SHARED','PLATFORM_RESTRICTED') then
    raise exception 'Trend visibility must match both permission-eligible measurements' using errcode = '42501';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_phase9_question()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_registry consulting_os.domain_objects%rowtype;
  v_source_scope consulting_os.visibility_scope;
begin
  select * into v_registry from consulting_os.domain_objects
  where id = new.id and organization_id = new.organization_id;
  if v_registry.id is null or v_registry.object_type <> 'EMERGING_QUESTION'
    or v_registry.engagement_id is distinct from new.engagement_id
    or v_registry.created_by <> new.created_by
    or v_registry.visibility_scope in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE','COACHING_SHARED','TEAM_SHARED','PLATFORM_RESTRICTED') then
    raise exception 'Emerging Question must match a shared domain registry record' using errcode = '23514';
  end if;
  if new.source_signal_id is not null then
    select d.visibility_scope into v_source_scope from consulting_os.domain_objects d
    where d.id = new.source_signal_id and d.organization_id = new.organization_id;
  else
    select d.visibility_scope into v_source_scope from consulting_os.domain_objects d
    where d.id = new.source_assumption_id and d.organization_id = new.organization_id;
  end if;
  if v_source_scope is null or not consulting_security.visibility_can_contain(v_registry.visibility_scope, v_source_scope) then
    raise exception 'Emerging Question may not widen source visibility' using errcode = '42501';
  end if;
  if v_registry.origin = 'AI' and new.initial_review_state <> 'SUGGESTED' then
    raise exception 'AI-originated Emerging Questions must remain SUGGESTED' using errcode = '23514';
  end if;
  return new;
end
$$;

create trigger signals_phase9_validate before insert on consulting_os.signals
for each row execute function consulting_security.validate_phase9_signal();
create trigger signals_set_updated_at before update on consulting_os.signals
for each row execute function consulting_security.set_updated_at();
create trigger descriptive_trends_phase9_validate before insert or update on consulting_os.descriptive_trends
for each row execute function consulting_security.validate_descriptive_trend();
create trigger emerging_questions_phase9_validate before insert on consulting_os.emerging_questions
for each row execute function consulting_security.validate_phase9_question();

insert into consulting_security.relationship_type_rules(relationship_type, source_type, target_type, rationale)
values ('REENTERS_AS','SIGNAL','OBSERVATION','A human-reviewed Signal explicitly becomes a new evidence-backed Observation for renewed inquiry.');

create or replace function consulting_os.create_signal(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_primary_evidence_id uuid,
  p_statement text,
  p_signal_type consulting_os.signal_type,
  p_context text,
  p_detected_at timestamptz default now(),
  p_baseline_snapshot_id uuid default null,
  p_visibility_scope consulting_os.visibility_scope default 'ENGAGEMENT_SHARED'
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := consulting_security.current_person_id();
  v_signal_id uuid := gen_random_uuid();
begin
  if v_actor is null or not consulting_security.can_manage_organization(p_organization_id)
    or not consulting_security.has_engagement_access(p_organization_id, p_engagement_id) then
    raise exception 'authorized human management access is required to create a Signal' using errcode = '42501';
  end if;
  if nullif(btrim(p_statement), '') is null or nullif(btrim(p_context), '') is null then
    raise exception 'Signal statement and context are required' using errcode = '23514';
  end if;
  if p_detected_at is null or p_detected_at > now() then
    raise exception 'Signal detected time must be present and cannot be in the future' using errcode = '22007';
  end if;
  if p_visibility_scope in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE','COACHING_SHARED','TEAM_SHARED','PLATFORM_RESTRICTED')
    or not consulting_security.can_create_visibility(p_organization_id, p_engagement_id, p_visibility_scope, null) then
    raise exception 'Signal visibility is not eligible for longitudinal intelligence' using errcode = '42501';
  end if;

  insert into consulting_os.domain_objects(
    id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by
  ) values (
    v_signal_id, p_organization_id, p_engagement_id, 'SIGNAL', p_visibility_scope, 'HUMAN', v_actor
  );
  insert into consulting_os.signals(
    id, organization_id, engagement_id, statement, signal_type, detected_at, context,
    primary_evidence_id, baseline_snapshot_id, initial_review_state, status, created_by
  ) values (
    v_signal_id, p_organization_id, p_engagement_id, btrim(p_statement), p_signal_type,
    p_detected_at, btrim(p_context), p_primary_evidence_id, p_baseline_snapshot_id,
    'DRAFT', 'NEW', v_actor
  );
  insert into consulting_os.audit_events(
    organization_id, actor_person_id, event_type, target_table, target_id, operation, reason, metadata
  ) values (
    p_organization_id, v_actor, 'SIGNAL_CREATED', 'consulting_os.signals', v_signal_id,
    'INSERT', 'Human recorded a descriptive change for review.',
    jsonb_build_object('engagement_id', p_engagement_id, 'signal_type', p_signal_type)
  );
  return v_signal_id;
end
$$;

create or replace function consulting_os.reenter_signal_as_observation(
  p_signal_id uuid,
  p_observation_statement text,
  p_context text,
  p_observed_at timestamptz default now()
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := consulting_security.current_person_id();
  v_signal consulting_os.signals%rowtype;
  v_registry consulting_os.domain_objects%rowtype;
  v_observation_id uuid := gen_random_uuid();
begin
  select * into v_signal from consulting_os.signals where id = p_signal_id;
  select * into v_registry from consulting_os.domain_objects
    where id = p_signal_id and organization_id = v_signal.organization_id;
  if v_actor is null or v_signal.id is null
    or not consulting_security.can_manage_domain_object(p_signal_id, v_signal.organization_id) then
    raise exception 'authorized human Signal management is required for re-entry' using errcode = '42501';
  end if;
  if v_signal.status in ('REENTERED','ARCHIVED') then
    raise exception 'Signal has already been re-entered or archived' using errcode = '23514';
  end if;
  if nullif(btrim(p_observation_statement), '') is null or nullif(btrim(p_context), '') is null then
    raise exception 'Observation statement and context are required' using errcode = '23514';
  end if;
  if p_observed_at is null or p_observed_at > now() then
    raise exception 'Observation time must be present and cannot be in the future' using errcode = '22007';
  end if;

  insert into consulting_os.domain_objects(
    id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by
  ) values (
    v_observation_id, v_signal.organization_id, v_signal.engagement_id,
    'OBSERVATION', v_registry.visibility_scope, 'HUMAN', v_actor
  );
  insert into consulting_os.observations(
    id, organization_id, statement, observation_type, observed_at, context,
    primary_evidence_id, initial_review_state, created_by
  ) values (
    v_observation_id, v_signal.organization_id, btrim(p_observation_statement),
    'DIRECT_OBSERVATION', p_observed_at, btrim(p_context),
    v_signal.primary_evidence_id, 'DRAFT', v_actor
  );
  insert into consulting_os.entity_relationships(
    organization_id, engagement_id, relationship_type, source_type, source_id,
    target_type, target_id, origin, review_status, rationale, evidence_summary,
    validated_by, validated_at, created_by, effective_from
  ) values (
    v_signal.organization_id, v_signal.engagement_id, 'REENTERS_AS', 'SIGNAL', v_signal.id,
    'OBSERVATION', v_observation_id, 'HUMAN', 'ACCEPTED',
    'Authorized human moved this descriptive Signal into renewed SEE REALITY inquiry.',
    'The new Observation retains the Signal primary Evidence and explicit re-entry context.',
    v_actor, now(), v_actor, now()
  );
  update consulting_os.signals set status = 'REENTERED' where id = v_signal.id;
  insert into consulting_os.audit_events(
    organization_id, actor_person_id, event_type, target_table, target_id, operation, reason, metadata
  ) values (
    v_signal.organization_id, v_actor, 'SIGNAL_REENTERED_AS_OBSERVATION',
    'consulting_os.signals', v_signal.id, 'PROMOTE', btrim(p_context),
    jsonb_build_object('observation_id', v_observation_id, 'relationship_type', 'REENTERS_AS')
  );
  return v_observation_id;
end
$$;

create or replace function consulting_os.complete_assumption_review(
  p_schedule_id uuid,
  p_review_note text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := consulting_security.current_person_id();
  v_schedule consulting_os.assumption_review_schedules%rowtype;
begin
  select * into v_schedule from consulting_os.assumption_review_schedules where id = p_schedule_id;
  if v_actor is null or v_schedule.id is null
    or not consulting_security.can_manage_domain_object(v_schedule.assumption_id, v_schedule.organization_id) then
    raise exception 'authorized human assumption management is required' using errcode = '42501';
  end if;
  if v_schedule.status in ('COMPLETED','CANCELLED') or nullif(btrim(p_review_note), '') is null then
    raise exception 'an open schedule and review note are required' using errcode = '23514';
  end if;
  update consulting_os.assumption_review_schedules
  set status = 'COMPLETED', completed_at = now(), completed_by = v_actor, review_note = btrim(p_review_note)
  where id = p_schedule_id;
  return p_schedule_id;
end
$$;

create or replace view consulting_os.current_assumptions_due with (security_invoker = true) as
select
  s.id, s.organization_id, s.engagement_id, s.assumption_id, a.statement,
  a.assumption_status, a.review_trigger, s.scheduled_for, s.trigger_context,
  case when s.scheduled_for <= current_date then 'DUE' else 'UPCOMING' end as due_state
from consulting_os.assumption_review_schedules s
join consulting_os.assumptions a on a.id = s.assumption_id and a.organization_id = s.organization_id
join consulting_os.domain_objects d on d.id = a.id and d.organization_id = a.organization_id
where s.status in ('SCHEDULED','DUE')
  and a.effective_to is null and a.assumption_status <> 'SUPERSEDED'
  and d.visibility_scope not in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE','COACHING_SHARED','TEAM_SHARED','PLATFORM_RESTRICTED');

create or replace view consulting_os.current_signal_set with (security_invoker = true) as
select s.organization_id, s.engagement_id, 'NEW_OBSERVATION'::text item_type, s.id item_id,
  s.signal_type::text title, s.statement detail, s.detected_at item_at, s.status::text status,
  d.visibility_scope
from consulting_os.signals s
join consulting_os.domain_objects d on d.id = s.id and d.organization_id = s.organization_id
where s.status <> 'ARCHIVED'
union all
select t.organization_id, t.engagement_id, 'TREND', t.id,
  t.direction::text, t.statement, t.created_at, 'DESCRIPTIVE', t.visibility_scope
from consulting_os.descriptive_trends t
union all
select a.organization_id, a.engagement_id, 'ASSUMPTION_TO_REVISIT', a.id,
  a.due_state, a.statement, a.scheduled_for::timestamptz, a.assumption_status::text, d.visibility_scope
from consulting_os.current_assumptions_due a
join consulting_os.domain_objects d on d.id = a.assumption_id and d.organization_id = a.organization_id
union all
select q.organization_id, q.engagement_id, 'EMERGING_QUESTION', q.id,
  q.status::text, q.question, q.created_at, q.initial_review_state::text, d.visibility_scope
from consulting_os.emerging_questions q
join consulting_os.domain_objects d on d.id = q.id and d.organization_id = q.organization_id
where q.status = 'OPEN'
union all
select b.organization_id, coalesce(b.next_engagement_id, b.engagement_id), 'BASELINE', b.id,
  'IMMUTABLE', b.scope, b.snapshot_at, 'CURRENT', d.visibility_scope
from consulting_os.baseline_snapshots b
join consulting_os.domain_objects d on d.id = b.id and d.organization_id = b.organization_id
where d.visibility_scope not in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE','COACHING_SHARED','TEAM_SHARED','PLATFORM_RESTRICTED');

alter table consulting_os.signals enable row level security;
alter table consulting_os.descriptive_trends enable row level security;
alter table consulting_os.assumption_review_schedules enable row level security;
alter table consulting_os.emerging_questions enable row level security;

create policy signals_select_visible on consulting_os.signals for select to authenticated
using (consulting_security.can_read_domain_object(id, organization_id));
create policy descriptive_trends_select_visible on consulting_os.descriptive_trends for select to authenticated
using (
  consulting_security.can_access_organization(organization_id)
  and consulting_security.has_engagement_access(organization_id, engagement_id)
  and consulting_security.can_read_domain_object(baseline_measurement_id, organization_id)
  and consulting_security.can_read_domain_object(current_measurement_id, organization_id)
);
create policy assumption_review_schedules_select_visible on consulting_os.assumption_review_schedules for select to authenticated
using (consulting_security.can_read_domain_object(assumption_id, organization_id));
create policy emerging_questions_select_visible on consulting_os.emerging_questions for select to authenticated
using (consulting_security.can_read_domain_object(id, organization_id));

revoke all on consulting_os.signals, consulting_os.descriptive_trends,
  consulting_os.assumption_review_schedules, consulting_os.emerging_questions
from public, anon, authenticated;
grant select on consulting_os.signals, consulting_os.descriptive_trends,
  consulting_os.assumption_review_schedules, consulting_os.emerging_questions
to authenticated;
grant all on consulting_os.signals, consulting_os.descriptive_trends,
  consulting_os.assumption_review_schedules, consulting_os.emerging_questions
to service_role;

revoke all on consulting_os.current_assumptions_due, consulting_os.current_signal_set from public, anon;
grant select on consulting_os.current_assumptions_due, consulting_os.current_signal_set to authenticated, service_role;

revoke all on function consulting_os.create_signal(uuid,uuid,uuid,text,consulting_os.signal_type,text,timestamptz,uuid,consulting_os.visibility_scope) from public, anon;
revoke all on function consulting_os.reenter_signal_as_observation(uuid,text,text,timestamptz) from public, anon;
revoke all on function consulting_os.complete_assumption_review(uuid,text) from public, anon;
grant execute on function consulting_os.create_signal(uuid,uuid,uuid,text,consulting_os.signal_type,text,timestamptz,uuid,consulting_os.visibility_scope) to authenticated, service_role;
grant execute on function consulting_os.reenter_signal_as_observation(uuid,text,text,timestamptz) to authenticated, service_role;
grant execute on function consulting_os.complete_assumption_review(uuid,text) to authenticated, service_role;
