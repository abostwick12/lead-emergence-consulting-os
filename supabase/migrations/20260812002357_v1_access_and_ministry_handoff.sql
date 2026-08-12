-- Lead Emergence Consulting OS — V1 access and Ministry handoff
-- Additive migration. Production application requires a separately selected target.

create type consulting_os.invitation_status as enum (
  'PENDING', 'SENT', 'ACCEPTED', 'REVOKED', 'DELIVERY_FAILED', 'EXPIRED'
);
create type consulting_os.participant_link_status as enum (
  'ACTIVE', 'USED', 'REVOKED', 'EXPIRED'
);
create type consulting_os.ministry_handoff_status as enum (
  'DRAFT', 'READY_FOR_REVIEW', 'READY_FOR_SETUP', 'COMPLETED'
);
create type consulting_os.ministry_readiness as enum (
  'NOT_ASSESSED', 'FOUNDATIONAL', 'PREPARING', 'READY', 'OPERATING'
);

create table consulting_os.client_invitations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  engagement_id uuid not null,
  email text not null check (email = lower(email) and email ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
  display_name text not null check (length(btrim(display_name)) > 0),
  platform_role consulting_os.platform_role not null check (platform_role in ('CLIENT_ADMIN', 'CLIENT_LEADER', 'CLIENT_MEMBER')),
  auth_user_id uuid references auth.users(id) on delete restrict,
  invitation_status consulting_os.invitation_status not null default 'PENDING',
  expires_at timestamptz not null,
  sent_at timestamptz,
  accepted_at timestamptz,
  revoked_at timestamptz,
  failure_reason text,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (expires_at > created_at),
  check (invitation_status <> 'SENT' or (auth_user_id is not null and sent_at is not null)),
  check (invitation_status <> 'ACCEPTED' or accepted_at is not null),
  check (invitation_status <> 'REVOKED' or revoked_at is not null)
);

create table consulting_private.assessment_participant_links (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  engagement_id uuid not null,
  administration_id uuid not null,
  token_hash text not null unique check (token_hash ~ '^[0-9a-f]{64}$'),
  confidentiality consulting_os.assessment_confidentiality not null,
  respondent_person_id uuid references consulting_os.people(id) on delete restrict,
  recipient_name text,
  recipient_email text,
  link_status consulting_os.participant_link_status not null default 'ACTIVE',
  expires_at timestamptz not null,
  used_at timestamptz,
  revoked_at timestamptz,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (administration_id, organization_id) references consulting_os.assessment_administrations(id, organization_id) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (expires_at > created_at),
  check (confidentiality <> 'ANONYMOUS' or (respondent_person_id is null and recipient_name is null and recipient_email is null)),
  check (link_status <> 'USED' or used_at is not null),
  check (link_status <> 'REVOKED' or revoked_at is not null)
);

create table consulting_os.ministry_setup_handoffs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  engagement_id uuid not null,
  church_name text not null check (length(btrim(church_name)) > 0),
  authorized_admin_name text not null default '',
  authorized_admin_email text not null default '',
  ministry_areas_and_leaders text not null default '',
  priorities text not null default '',
  meeting_and_planning_rhythm text not null default '',
  events_and_workflows text not null default '',
  readiness consulting_os.ministry_readiness not null default 'NOT_ASSESSED',
  handoff_status consulting_os.ministry_handoff_status not null default 'DRAFT',
  ministry_product_url text not null default 'https://ministry.leademergence.com',
  boundary_note text not null default 'Consultant-guided handoff only. Consulting OS does not write to the Ministry product database.',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  updated_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  unique (organization_id, engagement_id),
  unique (id, organization_id),
  check (authorized_admin_email = '' or authorized_admin_email = lower(authorized_admin_email)),
  check (ministry_product_url ~ '^https://')
);

create table consulting_os.ministry_setup_checklist_items (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  handoff_id uuid not null,
  item_key text not null check (item_key ~ '^[A-Z][A-Z0-9_]*$'),
  label text not null check (length(btrim(label)) > 0),
  is_complete boolean not null default false,
  ordinal integer not null check (ordinal > 0),
  completed_at timestamptz,
  completed_by uuid references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (handoff_id, organization_id) references consulting_os.ministry_setup_handoffs(id, organization_id) on delete cascade,
  unique (handoff_id, item_key),
  unique (handoff_id, ordinal),
  check (is_complete = (completed_at is not null and completed_by is not null))
);

create index client_invitations_scope_idx on consulting_os.client_invitations(organization_id, engagement_id, invitation_status, created_at desc);
create index assessment_participant_links_scope_idx on consulting_private.assessment_participant_links(organization_id, administration_id, link_status, expires_at);
create index ministry_handoffs_scope_idx on consulting_os.ministry_setup_handoffs(organization_id, engagement_id);
create index ministry_checklist_handoff_idx on consulting_os.ministry_setup_checklist_items(organization_id, handoff_id, ordinal);

create trigger client_invitations_updated_at before update on consulting_os.client_invitations
for each row execute function consulting_security.set_updated_at();
create trigger ministry_handoffs_updated_at before update on consulting_os.ministry_setup_handoffs
for each row execute function consulting_security.set_updated_at();
create trigger ministry_checklist_updated_at before update on consulting_os.ministry_setup_checklist_items
for each row execute function consulting_security.set_updated_at();

create or replace function consulting_security.validate_client_invitation_transition()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.invitation_status = 'ACCEPTED' and old.invitation_status <> 'ACCEPTED'
    and (auth.uid() is null or auth.uid() is distinct from new.auth_user_id)
  then raise exception 'only the verified invited user may accept access' using errcode = '42501'; end if;
  return new;
end
$$;
revoke all on function consulting_security.validate_client_invitation_transition() from public, anon, authenticated;
create trigger client_invitation_transition before update on consulting_os.client_invitations
for each row execute function consulting_security.validate_client_invitation_transition();

create or replace function consulting_os.accept_client_invitation(p_invitation_id uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_invitation consulting_os.client_invitations%rowtype;
  v_person_id uuid;
  v_membership_id uuid;
  v_email text;
begin
  if auth.uid() is null then raise exception 'authenticated user required' using errcode = '42501'; end if;
  select lower(email) into v_email from auth.users where id = auth.uid();
  select * into v_invitation from consulting_os.client_invitations where id = p_invitation_id for update;
  if v_invitation.id is null or v_invitation.auth_user_id is distinct from auth.uid() or v_invitation.email <> v_email then
    raise exception 'invitation does not belong to the authenticated user' using errcode = '42501';
  end if;
  if v_invitation.invitation_status <> 'SENT' or v_invitation.expires_at <= now() then
    raise exception 'invitation is not active' using errcode = '22023';
  end if;

  insert into consulting_os.people(auth_user_id, display_name)
  values (auth.uid(), v_invitation.display_name)
  on conflict (auth_user_id) do update set display_name = excluded.display_name
  returning id into v_person_id;

  insert into consulting_os.organization_memberships(organization_id, person_id, platform_role, status, created_by)
  values (v_invitation.organization_id, v_person_id, v_invitation.platform_role, 'ACTIVE', v_invitation.created_by)
  on conflict (organization_id, person_id) do update
  set platform_role = excluded.platform_role, status = 'ACTIVE', effective_to = null
  returning id into v_membership_id;

  insert into consulting_os.engagement_memberships(organization_id, engagement_id, organization_membership_id, status, created_by)
  values (v_invitation.organization_id, v_invitation.engagement_id, v_membership_id, 'ACTIVE', v_invitation.created_by)
  on conflict (engagement_id, organization_membership_id) do update set status = 'ACTIVE'
  ;

  update consulting_os.client_invitations set invitation_status = 'ACCEPTED', accepted_at = now(), failure_reason = null
  where id = v_invitation.id;
  return case when v_invitation.platform_role = 'CLIENT_ADMIN' then '/client' else '/client' end;
end
$$;

revoke all on function consulting_os.accept_client_invitation(uuid) from public, anon;
grant execute on function consulting_os.accept_client_invitation(uuid) to authenticated;

create or replace function consulting_os.issue_assessment_participant_link(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_administration_id uuid,
  p_token_hash text,
  p_respondent_person_id uuid,
  p_recipient_name text,
  p_recipient_email text,
  p_expires_at timestamptz,
  p_created_by uuid
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
  v_confidentiality consulting_os.assessment_confidentiality;
begin
  if coalesce(current_setting('request.jwt.claim.role', true), '') <> 'service_role' then raise exception 'service role context required' using errcode = '42501'; end if;
  select confidentiality into v_confidentiality from consulting_os.assessment_administrations
  where id = p_administration_id and organization_id = p_organization_id and engagement_id = p_engagement_id;
  if v_confidentiality is null then raise exception 'assessment administration is outside the verified scope' using errcode = '23503'; end if;
  if v_confidentiality = 'ANONYMOUS' and (p_respondent_person_id is not null or nullif(btrim(p_recipient_name), '') is not null or nullif(btrim(p_recipient_email), '') is not null) then raise exception 'anonymous links cannot retain identity' using errcode = '23514'; end if;
  insert into consulting_private.assessment_participant_links(
    organization_id, engagement_id, administration_id, token_hash, confidentiality,
    respondent_person_id, recipient_name, recipient_email, expires_at, created_by
  ) values (
    p_organization_id, p_engagement_id, p_administration_id, p_token_hash, v_confidentiality,
    p_respondent_person_id, nullif(btrim(p_recipient_name), ''), nullif(lower(btrim(p_recipient_email)), ''), p_expires_at, p_created_by
  ) returning id into v_id;
  update consulting_os.assessment_administrations set administration_status = 'OPEN'
  where id = p_administration_id and administration_status = 'DRAFT';
  return v_id;
end
$$;

create or replace function consulting_os.resolve_assessment_participant_link(p_token_hash text)
returns table (
  link_id uuid, organization_name text, instrument_name text, administration_id uuid,
  item_id uuid, prompt text, response_type text, response_options jsonb,
  confidentiality consulting_os.assessment_confidentiality, closes_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select l.id, o.name, i.name, a.id, q.id, q.prompt, q.response_type, q.response_options, a.confidentiality, a.closes_at
  from consulting_private.assessment_participant_links l
  join consulting_os.organizations o on o.id = l.organization_id
  join consulting_os.assessment_administrations a on a.id = l.administration_id and a.organization_id = l.organization_id
  join consulting_os.assessment_instrument_versions v on v.id = a.instrument_version_id and v.organization_id = a.organization_id
  join consulting_os.assessment_instruments i on i.id = v.instrument_id and i.organization_id = v.organization_id
  join consulting_os.assessment_items q on q.instrument_version_id = v.id and q.organization_id = v.organization_id
  where l.token_hash = p_token_hash and l.link_status = 'ACTIVE' and l.expires_at > now()
    and a.administration_status = 'OPEN' and a.opens_at <= now() and a.closes_at > now()
  order by q.ordinal
$$;

create or replace function consulting_os.submit_assessment_participant_response(p_token_hash text, p_item_id uuid, p_response jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_link consulting_private.assessment_participant_links%rowtype;
  v_admin consulting_os.assessment_administrations%rowtype;
  v_response_id uuid := gen_random_uuid();
  v_fragment_id uuid;
  v_content text := p_response::text;
begin
  if coalesce(current_setting('request.jwt.claim.role', true), '') <> 'service_role' then raise exception 'service role context required' using errcode = '42501'; end if;
  select * into v_link from consulting_private.assessment_participant_links where token_hash = p_token_hash for update;
  if v_link.id is null or v_link.link_status <> 'ACTIVE' or v_link.expires_at <= now() then raise exception 'assessment link is no longer active' using errcode = '22023'; end if;
  select * into v_admin from consulting_os.assessment_administrations where id = v_link.administration_id and organization_id = v_link.organization_id;
  if v_admin.administration_status <> 'OPEN' or v_admin.opens_at > now() or v_admin.closes_at <= now() then raise exception 'assessment is not accepting responses' using errcode = '22023'; end if;
  if not exists (select 1 from consulting_os.assessment_items where id = p_item_id and organization_id = v_link.organization_id and instrument_version_id = v_admin.instrument_version_id) then raise exception 'assessment item is outside administration' using errcode = '23503'; end if;

  insert into consulting_os.evidence_fragments(
    organization_id, evidence_source_id, locator_kind, locator, content_text, content_sha256,
    captured_context, directness, relevance, source_reliability, context_completeness, quality_rationale, created_by
  ) values (
    v_link.organization_id, v_admin.evidence_source_id, 'ASSESSMENT_ITEM', jsonb_build_object('item_id', p_item_id, 'participant_link_id', v_link.id),
    v_content, encode(extensions.digest(convert_to(v_content, 'UTF8'), 'sha256'), 'hex'), 'Participant response submitted through an expiring assessment link.',
    'HIGH', 'HIGH', 'MODERATE', 'MODERATE', 'Response is evidence and has not been interpreted or diagnosed.', v_admin.created_by
  ) returning id into v_fragment_id;

  insert into consulting_os.domain_objects(
    id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, origin, created_by
  ) values (
    v_response_id, v_link.organization_id, v_link.engagement_id, 'ASSESSMENT_RESPONSE',
    'LEADERSHIP_RESTRICTED'::consulting_os.visibility_scope,
    case when v_link.confidentiality = 'IDENTIFIED' then v_link.respondent_person_id else null end,
    'HUMAN', v_admin.created_by
  );
  insert into consulting_private.assessment_responses(
    id, organization_id, administration_id, item_id, respondent_person_id, participant_token_hash,
    response_value, evidence_fragment_id, submitted_at, created_by
  ) values (
    v_response_id, v_link.organization_id, v_link.administration_id, p_item_id,
    case when v_link.confidentiality = 'IDENTIFIED' then v_link.respondent_person_id else null end,
    p_token_hash, p_response, v_fragment_id, now(), v_admin.created_by
  );
  update consulting_private.assessment_participant_links set link_status = 'USED', used_at = now() where id = v_link.id;
  return v_response_id;
end
$$;

revoke all on function consulting_os.issue_assessment_participant_link(uuid, uuid, uuid, text, uuid, text, text, timestamptz, uuid) from public, anon, authenticated;
revoke all on function consulting_os.resolve_assessment_participant_link(text) from public, anon, authenticated;
revoke all on function consulting_os.submit_assessment_participant_response(text, uuid, jsonb) from public, anon, authenticated;
grant execute on function consulting_os.issue_assessment_participant_link(uuid, uuid, uuid, text, uuid, text, text, timestamptz, uuid) to service_role;
grant execute on function consulting_os.resolve_assessment_participant_link(text) to service_role;
grant execute on function consulting_os.submit_assessment_participant_response(text, uuid, jsonb) to service_role;

create or replace function consulting_os.save_ministry_setup_handoff(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_church_name text,
  p_authorized_admin_name text,
  p_authorized_admin_email text,
  p_ministry_areas_and_leaders text,
  p_priorities text,
  p_meeting_and_planning_rhythm text,
  p_events_and_workflows text,
  p_readiness consulting_os.ministry_readiness,
  p_handoff_status consulting_os.ministry_handoff_status,
  p_checklist jsonb
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_actor uuid := consulting_security.current_person_id();
  v_handoff_id uuid;
  v_item jsonb;
begin
  if not consulting_security.can_manage_organization(p_organization_id) then raise exception 'consultant organization access required' using errcode = '42501'; end if;
  if not exists (select 1 from consulting_os.engagements where id = p_engagement_id and organization_id = p_organization_id) then raise exception 'engagement is outside organization' using errcode = '23503'; end if;
  insert into consulting_os.ministry_setup_handoffs(
    organization_id, engagement_id, church_name, authorized_admin_name, authorized_admin_email,
    ministry_areas_and_leaders, priorities, meeting_and_planning_rhythm, events_and_workflows,
    readiness, handoff_status, created_by, updated_by
  ) values (
    p_organization_id, p_engagement_id, btrim(p_church_name), btrim(p_authorized_admin_name), lower(btrim(p_authorized_admin_email)),
    btrim(p_ministry_areas_and_leaders), btrim(p_priorities), btrim(p_meeting_and_planning_rhythm), btrim(p_events_and_workflows),
    p_readiness, p_handoff_status, v_actor, v_actor
  ) on conflict (organization_id, engagement_id) do update set
    church_name = excluded.church_name,
    authorized_admin_name = excluded.authorized_admin_name,
    authorized_admin_email = excluded.authorized_admin_email,
    ministry_areas_and_leaders = excluded.ministry_areas_and_leaders,
    priorities = excluded.priorities,
    meeting_and_planning_rhythm = excluded.meeting_and_planning_rhythm,
    events_and_workflows = excluded.events_and_workflows,
    readiness = excluded.readiness,
    handoff_status = excluded.handoff_status,
    updated_by = v_actor
  returning id into v_handoff_id;

  for v_item in select value from jsonb_array_elements(coalesce(p_checklist, '[]'::jsonb)) loop
    insert into consulting_os.ministry_setup_checklist_items(organization_id, handoff_id, item_key, label, is_complete, ordinal, completed_at, completed_by)
    values (
      p_organization_id, v_handoff_id, v_item->>'key', v_item->>'label', coalesce((v_item->>'complete')::boolean, false),
      (v_item->>'ordinal')::integer,
      case when coalesce((v_item->>'complete')::boolean, false) then now() else null end,
      case when coalesce((v_item->>'complete')::boolean, false) then v_actor else null end
    ) on conflict (handoff_id, item_key) do update set
      label = excluded.label, is_complete = excluded.is_complete, ordinal = excluded.ordinal,
      completed_at = excluded.completed_at, completed_by = excluded.completed_by;
  end loop;
  return v_handoff_id;
end
$$;

revoke all on function consulting_os.save_ministry_setup_handoff(uuid, uuid, text, text, text, text, text, text, text, consulting_os.ministry_readiness, consulting_os.ministry_handoff_status, jsonb) from public, anon;
grant execute on function consulting_os.save_ministry_setup_handoff(uuid, uuid, text, text, text, text, text, text, text, consulting_os.ministry_readiness, consulting_os.ministry_handoff_status, jsonb) to authenticated, service_role;

alter table consulting_os.client_invitations enable row level security;
alter table consulting_private.assessment_participant_links enable row level security;
alter table consulting_os.ministry_setup_handoffs enable row level security;
alter table consulting_os.ministry_setup_checklist_items enable row level security;

create policy client_invitations_select_managers on consulting_os.client_invitations for select to authenticated
using (consulting_security.can_manage_organization(organization_id));
create policy client_invitations_insert_managers on consulting_os.client_invitations for insert to authenticated
with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_organization(organization_id));
create policy client_invitations_update_managers on consulting_os.client_invitations for update to authenticated
using (consulting_security.can_manage_organization(organization_id))
with check (consulting_security.can_manage_organization(organization_id));

create policy ministry_handoffs_select_authorized on consulting_os.ministry_setup_handoffs for select to authenticated
using (consulting_security.has_engagement_access(organization_id, engagement_id));
create policy ministry_handoffs_insert_managers on consulting_os.ministry_setup_handoffs for insert to authenticated
with check (consulting_security.can_manage_organization(organization_id));
create policy ministry_handoffs_update_managers on consulting_os.ministry_setup_handoffs for update to authenticated
using (consulting_security.can_manage_organization(organization_id))
with check (consulting_security.can_manage_organization(organization_id));
create policy ministry_checklist_select_authorized on consulting_os.ministry_setup_checklist_items for select to authenticated
using (exists (select 1 from consulting_os.ministry_setup_handoffs h where h.id = consulting_os.ministry_setup_checklist_items.handoff_id and h.organization_id = consulting_os.ministry_setup_checklist_items.organization_id and consulting_security.has_engagement_access(h.organization_id, h.engagement_id)));
create policy ministry_checklist_manage_authorized on consulting_os.ministry_setup_checklist_items for all to authenticated
using (consulting_security.can_manage_organization(organization_id))
with check (consulting_security.can_manage_organization(organization_id));

revoke all on consulting_os.client_invitations from public, anon, authenticated;
revoke all on consulting_private.assessment_participant_links from public, anon, authenticated;
revoke all on consulting_os.ministry_setup_handoffs from public, anon, authenticated;
revoke all on consulting_os.ministry_setup_checklist_items from public, anon, authenticated;
grant select, insert, update on consulting_os.client_invitations to authenticated;
grant select, insert, update on consulting_os.ministry_setup_handoffs to authenticated;
grant select, insert, update on consulting_os.ministry_setup_checklist_items to authenticated;
grant all on consulting_os.client_invitations to service_role;
grant all on consulting_private.assessment_participant_links to service_role;
grant all on consulting_os.ministry_setup_handoffs to service_role;
grant all on consulting_os.ministry_setup_checklist_items to service_role;

comment on table consulting_os.client_invitations is 'Engagement-bound client access invitation; authorization activates only after verified acceptance.';
comment on table consulting_private.assessment_participant_links is 'Hashed, expiring assessment participation capability. Anonymous links contain no identity reference.';
comment on table consulting_os.ministry_setup_handoffs is 'Consultant-guided Ministry product setup brief. It creates no cross-product database dependency.';
