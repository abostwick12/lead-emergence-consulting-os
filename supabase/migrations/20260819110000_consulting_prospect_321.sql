-- Consulting-only prospect intake and human-reviewed 3-2-1 workflow.
-- Additive migration. This does not create global identity, product entitlement,
-- Ministry/Personal access, or an email transport.

create type consulting_os.prospect_status as enum ('NEW','AI_DRAFT_READY','IN_REVIEW','NEEDS_FOLLOW_UP','APPROVED','SENT','CONTACTED','CONVERTED','CLOSED');
create type consulting_os.prospect_follow_up_status as enum ('NOT_CONTACTED','FOLLOW_UP_DUE','CONTACTED','AWAITING_RESPONSE','MEETING_SCHEDULED','TRIAL_STARTED','CONVERTED','NOT_NOW','CLOSED');
create type consulting_os.prospect_revision_origin as enum ('AI','CONSULTANT');
create type consulting_os.prospect_delivery_status as enum ('PREVIEW_READY','READY_TO_SEND','SENT','FAILED','NOT_SENT');
create type consulting_os.prospect_conversion_status as enum ('NOT_CONVERTED','PENDING','CONVERTED','CANCELLED');
create type consulting_os.canonical_identity_link_status as enum ('PENDING_VERIFICATION','LINKED','REVOKED');

create table consulting_os.prospects (
  id uuid primary key default gen_random_uuid(),
  first_name text not null check (length(btrim(first_name)) > 0),
  email text not null check (email = lower(email) and email ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
  organization_name text,
  role_title text,
  intake_route text not null default 'CONSULTING' check (intake_route = 'CONSULTING'),
  status consulting_os.prospect_status not null default 'NEW',
  assigned_consultant_person_id uuid references consulting_os.people(id) on delete restrict,
  last_contact_at timestamptz,
  next_follow_up_at timestamptz,
  follow_up_status consulting_os.prospect_follow_up_status not null default 'NOT_CONTACTED',
  newsletter_opted_in_at timestamptz,
  newsletter_source text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table consulting_os.prospect_intakes (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null unique references consulting_os.prospects(id) on delete restrict,
  intake_version text not null default 'consulting-v1',
  idempotency_key uuid not null unique,
  submitted_at timestamptz not null default now(),
  source text not null default 'PUBLIC_CONSULTING_INTAKE',
  created_at timestamptz not null default now()
);

create table consulting_os.prospect_intake_responses (
  id uuid primary key default gen_random_uuid(),
  intake_id uuid not null references consulting_os.prospect_intakes(id) on delete restrict,
  question_key text not null check (question_key ~ '^[a-z][a-z0-9_]*$'),
  prompt_snapshot text not null check (length(btrim(prompt_snapshot)) > 0),
  answer text not null check (length(btrim(answer)) > 0),
  ordinal smallint not null check (ordinal > 0),
  created_at timestamptz not null default now(),
  unique (intake_id, question_key),
  unique (intake_id, ordinal)
);

create table consulting_os.prospect_321_revisions (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references consulting_os.prospects(id) on delete restrict,
  parent_revision_id uuid references consulting_os.prospect_321_revisions(id) on delete restrict,
  revision_number integer not null check (revision_number > 0),
  origin consulting_os.prospect_revision_origin not null,
  signals jsonb not null check (jsonb_typeof(signals) = 'array' and jsonb_array_length(signals) = 3),
  possibilities jsonb not null check (jsonb_typeof(possibilities) = 'array' and jsonb_array_length(possibilities) = 2),
  first_move text not null check (length(btrim(first_move)) > 0),
  limitations text not null check (length(btrim(limitations)) > 0),
  created_by uuid references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (prospect_id, revision_number)
);

alter table consulting_os.prospect_321_revisions add constraint prospect_321_revisions_id_prospect_unique unique (id, prospect_id);

create table consulting_os.prospect_321_response_links (
  revision_id uuid not null references consulting_os.prospect_321_revisions(id) on delete restrict,
  response_id uuid not null references consulting_os.prospect_intake_responses(id) on delete restrict,
  component_kind text not null check (component_kind in ('SIGNAL','POSSIBILITY','FIRST_MOVE')),
  component_ordinal smallint not null check (component_ordinal > 0),
  note text not null default 'Reported intake information; not a validated organizational observation.',
  primary key (revision_id, response_id, component_kind, component_ordinal)
);

create table consulting_os.prospect_321_approvals (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null unique references consulting_os.prospects(id) on delete restrict,
  approved_revision_id uuid not null unique,
  approved_by uuid not null references consulting_os.people(id) on delete restrict,
  approved_at timestamptz not null default now(),
  approval_note text
  ,foreign key (approved_revision_id, prospect_id) references consulting_os.prospect_321_revisions(id, prospect_id) on delete restrict
);

create table consulting_os.prospect_321_deliveries (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references consulting_os.prospects(id) on delete restrict,
  approved_revision_id uuid not null,
  recipient_email text not null check (recipient_email = lower(recipient_email)),
  subject_snapshot text not null,
  body_snapshot text not null,
  template_version text not null default '321-v1',
  status consulting_os.prospect_delivery_status not null default 'PREVIEW_READY',
  sent_at timestamptz,
  delivery_error text,
  created_by uuid references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (approved_revision_id, prospect_id) references consulting_os.prospect_321_revisions(id, prospect_id) on delete restrict,
  check ((status = 'SENT') = (sent_at is not null))
);

create or replace function consulting_security.enforce_prospect_delivery_approval()
returns trigger language plpgsql security invoker set search_path = '' as $$
begin
  if not exists (
    select 1 from consulting_os.prospect_321_approvals approval
    where approval.prospect_id = new.prospect_id
      and approval.approved_revision_id = new.approved_revision_id
  ) then
    raise exception 'Only an explicitly approved 3-2-1 revision may be prepared or sent.' using errcode = '42501';
  end if;
  return new;
end $$;

create trigger prospect_delivery_requires_approval before insert or update on consulting_os.prospect_321_deliveries
for each row execute function consulting_security.enforce_prospect_delivery_approval();

create table consulting_os.prospect_follow_ups (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references consulting_os.prospects(id) on delete restrict,
  owner_person_id uuid references consulting_os.people(id) on delete restrict,
  status consulting_os.prospect_follow_up_status not null default 'NOT_CONTACTED',
  follow_up_type text not null default 'EMAIL' check (follow_up_type in ('EMAIL','CALL','MEETING','REVIEW','OTHER')),
  due_at timestamptz,
  completed_at timestamptz,
  notes text not null default '',
  outcome text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table consulting_os.prospect_events (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references consulting_os.prospects(id) on delete restrict,
  event_type text not null check (event_type ~ '^[A-Z][A-Z0-9_]*$'),
  actor_person_id uuid references consulting_os.people(id) on delete restrict,
  occurred_at timestamptz not null default now(),
  detail text not null default '',
  metadata jsonb not null default '{}'::jsonb
);

create table consulting_private.prospect_notes (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references consulting_os.prospects(id) on delete restrict,
  author_person_id uuid not null references consulting_os.people(id) on delete restrict,
  content text not null check (length(btrim(content)) > 0),
  created_at timestamptz not null default now(),
  corrected_at timestamptz,
  corrected_by_id uuid references consulting_private.prospect_notes(id) on delete restrict
);

create table consulting_os.prospect_conversions (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null unique references consulting_os.prospects(id) on delete restrict,
  status consulting_os.prospect_conversion_status not null default 'NOT_CONVERTED',
  target_organization_id uuid references consulting_os.organizations(id) on delete restrict,
  target_engagement_id uuid,
  authorized_by uuid references consulting_os.people(id) on delete restrict,
  authorized_at timestamptz,
  note text not null default 'Reported prospect input and AI suggestions are not validated Consulting evidence.',
  created_at timestamptz not null default now(),
  foreign key (target_engagement_id, target_organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  check ((status = 'CONVERTED') = (authorized_at is not null and authorized_by is not null and target_organization_id is not null))
);

create table consulting_os.canonical_identity_links (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null unique references consulting_os.people(id) on delete restrict,
  canonical_user_id uuid not null unique,
  status consulting_os.canonical_identity_link_status not null default 'PENDING_VERIFICATION',
  proof_type text not null default 'FUTURE_ENTRY_HANDOFF',
  linked_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  check ((status = 'LINKED') = (linked_at is not null))
);

create or replace function consulting_security.validate_canonical_identity_link()
returns trigger language plpgsql security invoker set search_path = '' as $$
begin
  if new.status = 'REVOKED' and new.revoked_at is null then
    raise exception 'A revoked canonical identity link requires a revocation timestamp.' using errcode = '23514';
  end if;
  if new.status <> 'REVOKED' and new.revoked_at is not null then
    raise exception 'Only a revoked canonical identity link may retain a revocation timestamp.' using errcode = '23514';
  end if;
  return new;
end $$;
create trigger canonical_identity_links_validate before insert or update on consulting_os.canonical_identity_links
for each row execute function consulting_security.validate_canonical_identity_link();

create index prospects_queue_idx on consulting_os.prospects(status, next_follow_up_at, created_at desc);
create index prospect_events_timeline_idx on consulting_os.prospect_events(prospect_id, occurred_at desc);
create index prospect_follow_ups_due_idx on consulting_os.prospect_follow_ups(status, due_at);

create or replace function consulting_security.is_active_consultant()
returns boolean language sql stable security definer set search_path = '' as $$
  select coalesce(exists (
    select 1 from consulting_os.consultant_assignments ca
    where ca.consultant_person_id = consulting_security.current_person_id()
      and ca.status = 'ACTIVE' and ca.effective_from <= now()
      and (ca.effective_to is null or ca.effective_to > now())
  ), false)
$$;

create or replace function consulting_security.prevent_prospect_source_mutation()
returns trigger language plpgsql security invoker set search_path = '' as $$
begin
  raise exception 'Raw intake responses and 3-2-1 revisions are immutable; create a new revision instead.' using errcode = '55000';
end $$;

create trigger prospect_intake_responses_immutable before update or delete on consulting_os.prospect_intake_responses
for each row execute function consulting_security.prevent_prospect_source_mutation();
create trigger prospect_321_revisions_immutable before update or delete on consulting_os.prospect_321_revisions
for each row execute function consulting_security.prevent_prospect_source_mutation();

create or replace function consulting_os.submit_public_consulting_intake(
  p_idempotency_key uuid, p_first_name text, p_email text, p_organization_name text,
  p_role_title text, p_newsletter_opt_in boolean, p_responses jsonb
) returns uuid language plpgsql security definer set search_path = '' as $$
declare v_prospect_id uuid; v_intake_id uuid; v_row jsonb; v_index integer := 0;
begin
  if jsonb_typeof(p_responses) <> 'array' or jsonb_array_length(p_responses) not between 5 and 8 then
    raise exception 'A complete intake requires five to eight responses.' using errcode = '23514';
  end if;
  select prospect_id into v_prospect_id from consulting_os.prospect_intakes where idempotency_key = p_idempotency_key;
  if v_prospect_id is not null then return v_prospect_id; end if;
  insert into consulting_os.prospects(first_name,email,organization_name,role_title,newsletter_opted_in_at,newsletter_source)
  values (btrim(p_first_name), lower(btrim(p_email)), nullif(btrim(p_organization_name),''), nullif(btrim(p_role_title),''),
    case when p_newsletter_opt_in then now() else null end, case when p_newsletter_opt_in then 'PUBLIC_CONSULTING_INTAKE' else null end)
  returning id into v_prospect_id;
  insert into consulting_os.prospect_intakes(prospect_id,idempotency_key) values(v_prospect_id,p_idempotency_key) returning id into v_intake_id;
  for v_row in select value from jsonb_array_elements(p_responses) loop
    v_index := v_index + 1;
    insert into consulting_os.prospect_intake_responses(intake_id,question_key,prompt_snapshot,answer,ordinal)
    values(v_intake_id, v_row->>'questionKey', v_row->>'prompt', v_row->>'answer', v_index);
  end loop;
  insert into consulting_os.prospect_events(prospect_id,event_type,detail)
  values(v_prospect_id,'INTAKE_COMPLETED','Anonymous Consulting prospect intake completed.');
  return v_prospect_id;
end $$;

revoke all on function consulting_os.submit_public_consulting_intake(uuid,text,text,text,text,boolean,jsonb) from public;
grant execute on function consulting_os.submit_public_consulting_intake(uuid,text,text,text,text,boolean,jsonb) to anon, authenticated, service_role;

alter table consulting_os.prospects enable row level security;
alter table consulting_os.prospect_intakes enable row level security;
alter table consulting_os.prospect_intake_responses enable row level security;
alter table consulting_os.prospect_321_revisions enable row level security;
alter table consulting_os.prospect_321_response_links enable row level security;
alter table consulting_os.prospect_321_approvals enable row level security;
alter table consulting_os.prospect_321_deliveries enable row level security;
alter table consulting_os.prospect_follow_ups enable row level security;
alter table consulting_os.prospect_events enable row level security;
alter table consulting_os.prospect_conversions enable row level security;
alter table consulting_os.canonical_identity_links enable row level security;

create policy prospect_consultant_read on consulting_os.prospects for select to authenticated using (consulting_security.is_active_consultant());
create policy prospect_consultant_update on consulting_os.prospects for update to authenticated using (consulting_security.is_active_consultant()) with check (consulting_security.is_active_consultant());
create policy prospect_consultant_read on consulting_os.prospect_intakes for select to authenticated using (consulting_security.is_active_consultant());
create policy prospect_consultant_read on consulting_os.prospect_intake_responses for select to authenticated using (consulting_security.is_active_consultant());
create policy prospect_revision_consultant_all on consulting_os.prospect_321_revisions for all to authenticated using (consulting_security.is_active_consultant()) with check (consulting_security.is_active_consultant());
create policy prospect_links_consultant_all on consulting_os.prospect_321_response_links for all to authenticated using (consulting_security.is_active_consultant()) with check (consulting_security.is_active_consultant());
create policy prospect_approvals_consultant_all on consulting_os.prospect_321_approvals for all to authenticated using (consulting_security.is_active_consultant()) with check (consulting_security.is_active_consultant());
create policy prospect_delivery_consultant_all on consulting_os.prospect_321_deliveries for all to authenticated using (consulting_security.is_active_consultant()) with check (consulting_security.is_active_consultant());
create policy prospect_followup_consultant_all on consulting_os.prospect_follow_ups for all to authenticated using (consulting_security.is_active_consultant()) with check (consulting_security.is_active_consultant());
create policy prospect_event_consultant_all on consulting_os.prospect_events for all to authenticated using (consulting_security.is_active_consultant()) with check (consulting_security.is_active_consultant());
create policy prospect_conversion_consultant_all on consulting_os.prospect_conversions for all to authenticated using (consulting_security.is_active_consultant()) with check (consulting_security.is_active_consultant());
create policy canonical_identity_link_self_or_consultant on consulting_os.canonical_identity_links for select to authenticated using (person_id = consulting_security.current_person_id() or consulting_security.is_active_consultant());

grant select, update on consulting_os.prospects to authenticated;
grant select on consulting_os.prospect_intakes, consulting_os.prospect_intake_responses to authenticated;
grant select, insert on consulting_os.prospect_321_revisions, consulting_os.prospect_321_response_links, consulting_os.prospect_321_approvals, consulting_os.prospect_321_deliveries, consulting_os.prospect_follow_ups, consulting_os.prospect_events, consulting_os.prospect_conversions to authenticated;
grant select on consulting_os.canonical_identity_links to authenticated;

revoke all on consulting_private.prospect_notes from public, anon, authenticated;
grant select, insert on consulting_private.prospect_notes to service_role;
