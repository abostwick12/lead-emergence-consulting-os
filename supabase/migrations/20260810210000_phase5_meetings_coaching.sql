-- Lead Emergence Consulting OS — Phase 5 meetings and coaching.
-- Additive only. Production application remains a separately authorized operation.
-- Forward repair: add a later migration; do not rewrite after application.

create type consulting_os.meeting_type as enum ('CONSULTING', 'COACHING');
create type consulting_os.meeting_status as enum ('PLANNED', 'PREPARED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'ARCHIVED');
create type consulting_os.meeting_phase as enum ('PREPARE', 'MEET', 'CAPTURE', 'DECIDE', 'COMMIT', 'FOLLOW_UP');
create type consulting_os.meeting_participant_role as enum ('FACILITATOR', 'PARTICIPANT', 'OBSERVER');
create type consulting_os.meeting_note_kind as enum ('AGENDA', 'PREPARATION', 'SHARED_NOTE', 'FOLLOW_UP');
create type consulting_os.commitment_status as enum ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');
create type consulting_os.coaching_status as enum ('PLANNED', 'ACTIVE', 'PAUSED', 'COMPLETED', 'ARCHIVED');

create table consulting_os.meetings (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  meeting_type consulting_os.meeting_type not null,
  title text not null check (length(btrim(title)) > 0),
  purpose text not null check (length(btrim(purpose)) > 0),
  scheduled_start timestamptz not null,
  scheduled_end timestamptz,
  location_or_link text,
  status consulting_os.meeting_status not null default 'PLANNED',
  current_phase consulting_os.meeting_phase not null default 'PREPARE',
  agenda text not null default '',
  shared_summary text,
  follow_up text,
  next_meeting_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (next_meeting_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  check (scheduled_end is null or scheduled_end >= scheduled_start),
  unique (id, organization_id)
);

create table consulting_os.meeting_participants (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  meeting_id uuid not null,
  person_id uuid not null references consulting_os.people(id) on delete restrict,
  participant_role consulting_os.meeting_participant_role not null default 'PARTICIPANT',
  required_for_context boolean not null default true,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (meeting_id, organization_id) references consulting_os.meetings(id, organization_id) on delete restrict,
  unique (meeting_id, person_id),
  unique (id, organization_id)
);

create table consulting_os.meeting_notes (
  id uuid primary key,
  organization_id uuid not null,
  meeting_id uuid not null,
  note_kind consulting_os.meeting_note_kind not null,
  content text not null check (length(btrim(content)) > 0),
  author_person_id uuid not null references consulting_os.people(id) on delete restrict,
  corrected_by_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (meeting_id, organization_id) references consulting_os.meetings(id, organization_id) on delete restrict,
  foreign key (corrected_by_id, organization_id) references consulting_os.meeting_notes(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.coaching_relationships (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  coach_person_id uuid not null references consulting_os.people(id) on delete restrict,
  participant_person_id uuid not null references consulting_os.people(id) on delete restrict,
  purpose text not null check (length(btrim(purpose)) > 0),
  development_focus text not null check (length(btrim(development_focus)) > 0),
  confidentiality_statement text not null check (length(btrim(confidentiality_statement)) > 0),
  starts_on date not null,
  ends_on date,
  status consulting_os.coaching_status not null default 'PLANNED',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  check (coach_person_id <> participant_person_id),
  check (ends_on is null or ends_on >= starts_on),
  unique (id, organization_id)
);

create table consulting_os.coaching_sessions (
  id uuid primary key,
  organization_id uuid not null,
  coaching_relationship_id uuid not null,
  session_number integer not null check (session_number > 0),
  development_focus text,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id) references consulting_os.meetings(id, organization_id) on delete restrict,
  foreign key (coaching_relationship_id, organization_id) references consulting_os.coaching_relationships(id, organization_id) on delete restrict,
  unique (coaching_relationship_id, session_number),
  unique (id, organization_id)
);

create table consulting_os.commitments (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  source_meeting_id uuid not null,
  coaching_relationship_id uuid,
  owner_person_id uuid not null references consulting_os.people(id) on delete restrict,
  action text not null check (length(btrim(action)) > 0),
  due_on date,
  review_on date,
  status consulting_os.commitment_status not null default 'OPEN',
  completed_at timestamptz,
  completion_note text,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (source_meeting_id, organization_id) references consulting_os.meetings(id, organization_id) on delete restrict,
  foreign key (coaching_relationship_id, organization_id) references consulting_os.coaching_relationships(id, organization_id) on delete restrict,
  check ((status = 'COMPLETED') = (completed_at is not null)),
  unique (id, organization_id)
);

create table consulting_os.meeting_decisions (
  organization_id uuid not null,
  meeting_id uuid not null,
  decision_id uuid not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  primary key (meeting_id, decision_id),
  foreign key (meeting_id, organization_id) references consulting_os.meetings(id, organization_id) on delete restrict,
  foreign key (decision_id, organization_id) references consulting_os.decisions(id, organization_id) on delete restrict
);

create table consulting_os.meeting_context_items (
  organization_id uuid not null,
  meeting_id uuid not null,
  context_domain_object_id uuid not null,
  reason text not null check (length(btrim(reason)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  primary key (meeting_id, context_domain_object_id),
  foreign key (meeting_id, organization_id) references consulting_os.meetings(id, organization_id) on delete restrict,
  foreign key (context_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict
);

create table consulting_private.meeting_notes (
  id uuid primary key,
  organization_id uuid not null,
  meeting_id uuid not null,
  kind consulting_os.private_record_kind not null,
  subject_person_id uuid not null references consulting_os.people(id) on delete restrict,
  author_person_id uuid not null references consulting_os.people(id) on delete restrict,
  content text not null check (length(btrim(content)) > 0),
  created_at timestamptz not null default now(),
  corrected_by_id uuid,
  corrected_at timestamptz,
  foreign key (id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (meeting_id, organization_id) references consulting_os.meetings(id, organization_id) on delete restrict,
  foreign key (corrected_by_id, organization_id) references consulting_private.meeting_notes(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_private.coaching_promotions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  source_private_note_id uuid not null,
  derivative_domain_object_id uuid not null,
  chosen_visibility consulting_os.visibility_scope not null check (chosen_visibility in ('LEADERSHIP_RESTRICTED', 'ENGAGEMENT_SHARED', 'ORGANIZATION_SHARED')),
  abstraction_summary text not null check (length(btrim(abstraction_summary)) > 0),
  redaction_rationale text not null check (length(btrim(redaction_rationale)) > 0),
  authorized_by uuid not null references consulting_os.people(id) on delete restrict,
  authorized_at timestamptz not null default now(),
  foreign key (source_private_note_id, organization_id) references consulting_private.meeting_notes(id, organization_id) on delete restrict,
  foreign key (derivative_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  unique (source_private_note_id, derivative_domain_object_id)
);

create index meetings_org_time_idx on consulting_os.meetings(organization_id, scheduled_start desc);
create index meeting_participants_person_idx on consulting_os.meeting_participants(person_id, organization_id, meeting_id);
create index meeting_notes_meeting_idx on consulting_os.meeting_notes(organization_id, meeting_id, created_at);
create index coaching_relationships_people_idx on consulting_os.coaching_relationships(organization_id, coach_person_id, participant_person_id);
create index coaching_sessions_history_idx on consulting_os.coaching_sessions(organization_id, coaching_relationship_id, session_number desc);
create index commitments_owner_status_idx on consulting_os.commitments(organization_id, owner_person_id, status, due_on);
create index private_meeting_notes_author_idx on consulting_private.meeting_notes(organization_id, author_person_id, meeting_id);

create or replace function consulting_security.person_can_read_domain_object(
  p_person_id uuid,
  p_domain_object_id uuid,
  p_organization_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(exists (
    select 1
    from consulting_os.domain_objects d
    where d.id = p_domain_object_id
      and d.organization_id = p_organization_id
      and d.archived_at is null
      and (
        exists (
          select 1 from consulting_os.consultant_assignments ca
          where ca.organization_id = d.organization_id
            and ca.consultant_person_id = p_person_id
            and ca.status = 'ACTIVE'
            and ca.effective_from <= now()
            and (ca.effective_to is null or ca.effective_to > now())
        )
        or exists (
          select 1 from consulting_os.organization_memberships om
          where om.organization_id = d.organization_id
            and om.person_id = p_person_id
            and om.status = 'ACTIVE'
            and om.effective_from <= now()
            and (om.effective_to is null or om.effective_to > now())
        )
      )
      and case d.visibility_scope
        when 'CONSULTANT_PRIVATE' then d.owner_person_id = p_person_id or exists (
          select 1 from consulting_os.visibility_grants vg where vg.domain_object_id = d.id and vg.organization_id = d.organization_id and vg.grantee_person_id = p_person_id and vg.permission in ('READ','CONTRIBUTE','MANAGE')
        )
        when 'INDIVIDUAL_PRIVATE' then d.owner_person_id = p_person_id or exists (
          select 1 from consulting_os.visibility_grants vg where vg.domain_object_id = d.id and vg.organization_id = d.organization_id and vg.grantee_person_id = p_person_id and vg.permission in ('READ','CONTRIBUTE','MANAGE')
        )
        when 'COACHING_SHARED' then exists (
          select 1 from consulting_os.visibility_grants vg where vg.domain_object_id = d.id and vg.organization_id = d.organization_id and vg.grantee_person_id = p_person_id and vg.permission in ('READ','CONTRIBUTE','MANAGE')
        )
        when 'TEAM_SHARED' then exists (
          select 1 from consulting_os.visibility_grants vg where vg.domain_object_id = d.id and vg.organization_id = d.organization_id and vg.grantee_person_id = p_person_id and vg.permission in ('READ','CONTRIBUTE','MANAGE')
        )
        when 'LEADERSHIP_RESTRICTED' then exists (
          select 1 from consulting_os.organization_memberships om where om.organization_id = d.organization_id and om.person_id = p_person_id and om.status = 'ACTIVE' and om.platform_role in ('CLIENT_ADMIN','CLIENT_LEADER')
        ) or exists (
          select 1 from consulting_os.consultant_assignments ca where ca.organization_id = d.organization_id and ca.consultant_person_id = p_person_id and ca.status = 'ACTIVE'
        )
        when 'ENGAGEMENT_SHARED' then exists (
          select 1 from consulting_os.engagement_memberships em join consulting_os.organization_memberships om on om.id = em.organization_membership_id and om.organization_id = em.organization_id where em.organization_id = d.organization_id and em.engagement_id = d.engagement_id and em.status = 'ACTIVE' and om.person_id = p_person_id and om.status = 'ACTIVE'
        ) or exists (
          select 1 from consulting_os.consultant_assignments ca where ca.organization_id = d.organization_id and ca.consultant_person_id = p_person_id and ca.status = 'ACTIVE'
        )
        when 'ORGANIZATION_SHARED' then true
        else false
      end
  ), false)
$$;

create or replace function consulting_security.validate_meeting_participant()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare v_context record;
begin
  if not consulting_security.person_can_read_domain_object(new.person_id, new.meeting_id, new.organization_id) then
    raise exception 'meeting participant must be eligible to read the meeting' using errcode = '42501';
  end if;
  if new.required_for_context then
    for v_context in
      select context_domain_object_id
      from consulting_os.meeting_context_items
      where meeting_id = new.meeting_id and organization_id = new.organization_id
    loop
      if not consulting_security.person_can_read_domain_object(new.person_id, v_context.context_domain_object_id, new.organization_id) then
        raise exception 'required participant cannot read existing meeting context' using errcode = '42501';
      end if;
    end loop;
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_phase5_typed_record()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_type text;
  v_visibility consulting_os.visibility_scope;
  v_expected text;
begin
  select object_type, visibility_scope into v_type, v_visibility
  from consulting_os.domain_objects where id = new.id and organization_id = new.organization_id;
  v_expected := case tg_table_name
    when 'meetings' then case when to_jsonb(new)->>'meeting_type' = 'COACHING' then 'COACHING_SESSION' else 'MEETING' end
    when 'meeting_notes' then 'MEETING_NOTE'
    when 'coaching_relationships' then 'COACHING_RELATIONSHIP'
    when 'commitments' then 'COMMITMENT'
  end;
  if v_type is distinct from v_expected then
    raise exception '% requires registry object type %', tg_table_name, v_expected using errcode = '23514';
  end if;
  if tg_table_name = 'meeting_notes' and v_visibility in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE') then
    raise exception 'private meeting notes require consulting_private.meeting_notes' using errcode = '42501';
  end if;
  if tg_table_name = 'coaching_relationships' and v_visibility <> 'COACHING_SHARED' then
    raise exception 'coaching relationships require COACHING_SHARED visibility' using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_coaching_session()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare v_type consulting_os.meeting_type; v_coach uuid; v_participant uuid;
begin
  select meeting_type into v_type from consulting_os.meetings where id = new.id and organization_id = new.organization_id;
  select coach_person_id, participant_person_id into v_coach, v_participant from consulting_os.coaching_relationships where id = new.coaching_relationship_id and organization_id = new.organization_id;
  if v_type <> 'COACHING' then raise exception 'coaching session must specialize a COACHING meeting' using errcode = '23514'; end if;
  if not exists (select 1 from consulting_os.meeting_participants where meeting_id = new.id and organization_id = new.organization_id and person_id = v_coach)
    or not exists (select 1 from consulting_os.meeting_participants where meeting_id = new.id and organization_id = new.organization_id and person_id = v_participant)
  then raise exception 'coaching session must include the named coach and participant' using errcode = '23514'; end if;
  return new;
end
$$;

create or replace function consulting_security.validate_meeting_context()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare v_participant record;
begin
  for v_participant in select person_id from consulting_os.meeting_participants where meeting_id = new.meeting_id and organization_id = new.organization_id and required_for_context loop
    if not consulting_security.person_can_read_domain_object(v_participant.person_id, new.context_domain_object_id, new.organization_id) then
      raise exception 'meeting context must be visible to every required participant' using errcode = '42501';
    end if;
  end loop;
  return new;
end
$$;

create or replace function consulting_os.create_meeting(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_meeting_type consulting_os.meeting_type,
  p_title text,
  p_purpose text,
  p_scheduled_start timestamptz,
  p_agenda text,
  p_participant_person_id uuid,
  p_development_focus text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := consulting_security.current_person_id();
  v_meeting_id uuid := gen_random_uuid();
  v_relationship_id uuid;
  v_visibility consulting_os.visibility_scope;
begin
  if v_actor is null or not exists (
    select 1 from consulting_os.consultant_assignments ca
    where ca.organization_id = p_organization_id
      and ca.consultant_person_id = v_actor
      and ca.status = 'ACTIVE'
  ) then
    raise exception 'only an assigned consultant may create a meeting' using errcode = '42501';
  end if;
  if not exists (
    select 1 from consulting_os.engagements e
    where e.id = p_engagement_id and e.organization_id = p_organization_id and e.status = 'ACTIVE'
  ) then
    raise exception 'active engagement is required' using errcode = '23503';
  end if;
  if p_participant_person_id = v_actor or not (
    exists (
      select 1 from consulting_os.consultant_assignments ca
      where ca.organization_id = p_organization_id
        and ca.consultant_person_id = p_participant_person_id
        and ca.status = 'ACTIVE'
    )
    or exists (
      select 1
      from consulting_os.organization_memberships om
      join consulting_os.engagement_memberships em
        on em.organization_membership_id = om.id
       and em.organization_id = om.organization_id
      where om.organization_id = p_organization_id
        and om.person_id = p_participant_person_id
        and om.status = 'ACTIVE'
        and em.engagement_id = p_engagement_id
        and em.status = 'ACTIVE'
    )
  ) then
    raise exception 'selected participant is not eligible for this engagement' using errcode = '42501';
  end if;
  if p_meeting_type = 'COACHING' and nullif(btrim(p_development_focus), '') is null then
    raise exception 'coaching requires a development focus' using errcode = '23514';
  end if;

  v_visibility := case when p_meeting_type = 'COACHING' then 'COACHING_SHARED'::consulting_os.visibility_scope else 'ENGAGEMENT_SHARED'::consulting_os.visibility_scope end;
  insert into consulting_os.domain_objects (id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, origin, created_by)
  values (v_meeting_id, p_organization_id, p_engagement_id, case when p_meeting_type = 'COACHING' then 'COACHING_SESSION' else 'MEETING' end, v_visibility, case when p_meeting_type = 'COACHING' then v_actor else null end, 'HUMAN', v_actor);
  insert into consulting_os.meetings (id, organization_id, engagement_id, meeting_type, title, purpose, scheduled_start, agenda, created_by)
  values (v_meeting_id, p_organization_id, p_engagement_id, p_meeting_type, p_title, p_purpose, p_scheduled_start, p_agenda, v_actor);

  if p_meeting_type = 'COACHING' then
    v_relationship_id := gen_random_uuid();
    insert into consulting_os.domain_objects (id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, origin, created_by)
    values (v_relationship_id, p_organization_id, p_engagement_id, 'COACHING_RELATIONSHIP', 'COACHING_SHARED', v_actor, 'HUMAN', v_actor);
    insert into consulting_os.coaching_relationships (id, organization_id, engagement_id, coach_person_id, participant_person_id, purpose, development_focus, confidentiality_statement, starts_on, status, created_by)
    values (v_relationship_id, p_organization_id, p_engagement_id, v_actor, p_participant_person_id, p_purpose, p_development_focus, 'Shared coaching records remain limited to the named coach and participant. Private reflections remain separate.', p_scheduled_start::date, 'ACTIVE', v_actor);
    insert into consulting_os.visibility_grants (organization_id, domain_object_id, grantee_person_id, permission, created_by)
    select p_organization_id, domain_id, person_id, permission, v_actor
    from (values
      (v_meeting_id, v_actor, 'MANAGE'::consulting_os.grant_permission),
      (v_meeting_id, p_participant_person_id, 'CONTRIBUTE'::consulting_os.grant_permission),
      (v_relationship_id, v_actor, 'MANAGE'::consulting_os.grant_permission),
      (v_relationship_id, p_participant_person_id, 'CONTRIBUTE'::consulting_os.grant_permission)
    ) grants(domain_id, person_id, permission);
  end if;

  insert into consulting_os.meeting_participants (organization_id, meeting_id, person_id, participant_role, created_by)
  values
    (p_organization_id, v_meeting_id, v_actor, 'FACILITATOR', v_actor),
    (p_organization_id, v_meeting_id, p_participant_person_id, 'PARTICIPANT', v_actor);
  if p_meeting_type = 'COACHING' then
    insert into consulting_os.coaching_sessions (id, organization_id, coaching_relationship_id, session_number, development_focus, created_by)
    values (v_meeting_id, p_organization_id, v_relationship_id, 1, p_development_focus, v_actor);
  end if;
  insert into consulting_os.audit_events (organization_id, actor_person_id, event_type, target_table, target_id, operation, reason)
  values (p_organization_id, v_actor, 'MEETING_CREATED', 'consulting_os.meetings', v_meeting_id, 'INSERT', 'Atomic shared meeting-engine creation');
  return v_meeting_id;
end
$$;

create or replace function consulting_os.create_private_meeting_note(
  p_meeting_id uuid,
  p_kind consulting_os.private_record_kind,
  p_subject_person_id uuid,
  p_content text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare v_actor uuid := consulting_security.current_person_id(); v_org uuid; v_eng uuid; v_id uuid := gen_random_uuid(); v_scope consulting_os.visibility_scope;
begin
  select organization_id, engagement_id into v_org, v_eng from consulting_os.meetings where id = p_meeting_id;
  if v_actor is null or v_org is null or not consulting_security.can_read_domain_object(p_meeting_id, v_org) then raise exception 'meeting is not available' using errcode = '42501'; end if;
  if not exists (select 1 from consulting_os.meeting_participants where meeting_id = p_meeting_id and organization_id = v_org and person_id = v_actor) then raise exception 'only a named participant may create a private meeting note' using errcode = '42501'; end if;
  if length(btrim(p_content)) = 0 then raise exception 'private note content is required' using errcode = '23514'; end if;
  if p_kind = 'CONSULTANT_NOTE' then
    if not consulting_security.has_active_consultant_assignment(v_org) then raise exception 'only an assigned consultant may create a consultant-private note' using errcode = '42501'; end if;
    v_scope := 'CONSULTANT_PRIVATE';
  else
    if p_subject_person_id <> v_actor then raise exception 'individual reflection must be authored by its subject' using errcode = '42501'; end if;
    v_scope := 'INDIVIDUAL_PRIVATE';
  end if;
  insert into consulting_os.domain_objects (id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, origin, created_by)
  values (v_id, v_org, v_eng, 'MEETING_NOTE', v_scope, v_actor, 'HUMAN', v_actor);
  insert into consulting_private.meeting_notes (id, organization_id, meeting_id, kind, subject_person_id, author_person_id, content)
  values (v_id, v_org, p_meeting_id, p_kind, p_subject_person_id, v_actor, p_content);
  insert into consulting_os.audit_events (organization_id, actor_person_id, event_type, target_table, target_id, operation, reason)
  values (v_org, v_actor, 'PRIVATE_MEETING_NOTE_CREATED', 'consulting_private.meeting_notes', v_id, 'INSERT', 'Explicit private meeting-note action');
  return v_id;
end
$$;

create or replace function consulting_os.meeting_people_directory(p_organization_id uuid, p_engagement_id uuid)
returns table (person_id uuid, display_name text, relationship text)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, p.display_name, 'CONSULTANT'::text
  from consulting_os.consultant_assignments ca
  join consulting_os.people p on p.id = ca.consultant_person_id
  where ca.organization_id = p_organization_id
    and ca.status = 'ACTIVE'
    and consulting_security.can_access_organization(p_organization_id)
  union
  select p.id, p.display_name, 'CLIENT'::text
  from consulting_os.organization_memberships om
  join consulting_os.people p on p.id = om.person_id
  join consulting_os.engagement_memberships em on em.organization_membership_id = om.id and em.organization_id = om.organization_id
  where om.organization_id = p_organization_id
    and om.status = 'ACTIVE'
    and em.engagement_id = p_engagement_id
    and em.status = 'ACTIVE'
    and consulting_security.can_access_organization(p_organization_id)
$$;

create or replace function consulting_os.private_meeting_notes_for_meeting(p_meeting_id uuid)
returns table (note_id uuid, kind consulting_os.private_record_kind, content text, author_person_id uuid, created_at timestamptz)
language sql
stable
security definer
set search_path = ''
as $$
  select n.id, n.kind, n.content, n.author_person_id, n.created_at
  from consulting_private.meeting_notes n
  where n.meeting_id = p_meeting_id
    and (
      n.author_person_id = consulting_security.current_person_id()
      or (n.kind = 'INDIVIDUAL_REFLECTION' and n.subject_person_id = consulting_security.current_person_id())
    )
    and consulting_security.can_read_domain_object(n.id, n.organization_id)
  order by n.created_at
$$;

create or replace function consulting_os.add_shared_meeting_note(p_meeting_id uuid, p_content text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare v_actor uuid := consulting_security.current_person_id(); v_org uuid; v_eng uuid; v_scope consulting_os.visibility_scope; v_id uuid := gen_random_uuid();
begin
  select m.organization_id, m.engagement_id, d.visibility_scope into v_org, v_eng, v_scope
  from consulting_os.meetings m join consulting_os.domain_objects d on d.id = m.id and d.organization_id = m.organization_id where m.id = p_meeting_id;
  if v_actor is null or not exists (select 1 from consulting_os.meeting_participants where meeting_id = p_meeting_id and organization_id = v_org and person_id = v_actor) then raise exception 'only a named participant may add a shared note' using errcode = '42501'; end if;
  if length(btrim(p_content)) = 0 then raise exception 'shared note content is required' using errcode = '23514'; end if;
  insert into consulting_os.domain_objects (id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, origin, created_by)
  values (v_id, v_org, v_eng, 'MEETING_NOTE', v_scope, case when v_scope = 'COACHING_SHARED' then v_actor else null end, 'HUMAN', v_actor);
  if v_scope in ('COACHING_SHARED','TEAM_SHARED') then
    insert into consulting_os.visibility_grants (organization_id, domain_object_id, grantee_person_id, permission, created_by)
    select v_org, v_id, person_id, case when person_id = v_actor then 'MANAGE'::consulting_os.grant_permission else 'READ'::consulting_os.grant_permission end, v_actor
    from consulting_os.meeting_participants where meeting_id = p_meeting_id and organization_id = v_org;
  end if;
  insert into consulting_os.meeting_notes (id, organization_id, meeting_id, note_kind, content, author_person_id, created_by)
  values (v_id, v_org, p_meeting_id, 'SHARED_NOTE', p_content, v_actor, v_actor);
  return v_id;
end
$$;

create or replace function consulting_os.add_meeting_decision(
  p_meeting_id uuid,
  p_statement text,
  p_rationale text,
  p_intended_effect text,
  p_review_trigger text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := consulting_security.current_person_id();
  v_org uuid;
  v_eng uuid;
  v_scope consulting_os.visibility_scope;
  v_id uuid := gen_random_uuid();
begin
  select m.organization_id, m.engagement_id, d.visibility_scope into v_org, v_eng, v_scope
  from consulting_os.meetings m
  join consulting_os.domain_objects d on d.id = m.id and d.organization_id = m.organization_id
  where m.id = p_meeting_id;
  if v_actor is null or not exists (
    select 1 from consulting_os.meeting_participants
    where meeting_id = p_meeting_id and organization_id = v_org and person_id = v_actor
  ) then
    raise exception 'only a named participant may record a meeting decision' using errcode = '42501';
  end if;
  if nullif(btrim(p_statement), '') is null
    or nullif(btrim(p_rationale), '') is null
    or nullif(btrim(p_intended_effect), '') is null
    or nullif(btrim(p_review_trigger), '') is null
  then
    raise exception 'decision statement, rationale, intended effect, and review trigger are required' using errcode = '23514';
  end if;

  insert into consulting_os.domain_objects (id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, origin, created_by)
  values (v_id, v_org, v_eng, 'DECISION', v_scope, case when v_scope = 'COACHING_SHARED' then v_actor else null end, 'HUMAN', v_actor);
  if v_scope in ('COACHING_SHARED','TEAM_SHARED') then
    insert into consulting_os.visibility_grants (organization_id, domain_object_id, grantee_person_id, permission, created_by)
    select v_org, v_id, person_id, case when person_id = v_actor then 'MANAGE'::consulting_os.grant_permission else 'READ'::consulting_os.grant_permission end, v_actor
    from consulting_os.meeting_participants where meeting_id = p_meeting_id and organization_id = v_org;
  end if;
  insert into consulting_os.decisions (id, organization_id, statement, authority_person_id, rationale, intended_effect, review_trigger, decision_status, decided_at, created_by)
  values (v_id, v_org, p_statement, v_actor, p_rationale, p_intended_effect, p_review_trigger, 'APPROVED', now(), v_actor);
  insert into consulting_os.meeting_decisions (organization_id, meeting_id, decision_id, created_by)
  values (v_org, p_meeting_id, v_id, v_actor);
  insert into consulting_os.audit_events (organization_id, actor_person_id, event_type, target_table, target_id, operation, reason, metadata)
  values (v_org, v_actor, 'MEETING_DECISION_RECORDED', 'consulting_os.decisions', v_id, 'INSERT', p_rationale, jsonb_build_object('meeting_id', p_meeting_id));
  return v_id;
end
$$;

create or replace function consulting_os.add_meeting_commitment(p_meeting_id uuid, p_owner_person_id uuid, p_action text, p_due_on date default null)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare v_actor uuid := consulting_security.current_person_id(); v_org uuid; v_eng uuid; v_scope consulting_os.visibility_scope; v_relationship uuid; v_id uuid := gen_random_uuid();
begin
  select m.organization_id, m.engagement_id, d.visibility_scope, cs.coaching_relationship_id into v_org, v_eng, v_scope, v_relationship
  from consulting_os.meetings m join consulting_os.domain_objects d on d.id = m.id and d.organization_id = m.organization_id left join consulting_os.coaching_sessions cs on cs.id = m.id and cs.organization_id = m.organization_id where m.id = p_meeting_id;
  if v_actor is null or not exists (select 1 from consulting_os.meeting_participants where meeting_id = p_meeting_id and organization_id = v_org and person_id = v_actor) then raise exception 'only a named participant may add a commitment' using errcode = '42501'; end if;
  if not exists (select 1 from consulting_os.meeting_participants where meeting_id = p_meeting_id and organization_id = v_org and person_id = p_owner_person_id) then raise exception 'commitment owner must be a meeting participant' using errcode = '23514'; end if;
  if length(btrim(p_action)) = 0 then raise exception 'commitment action is required' using errcode = '23514'; end if;
  insert into consulting_os.domain_objects (id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, origin, created_by)
  values (v_id, v_org, v_eng, 'COMMITMENT', v_scope, p_owner_person_id, 'HUMAN', v_actor);
  if v_scope in ('COACHING_SHARED','TEAM_SHARED') then
    insert into consulting_os.visibility_grants (organization_id, domain_object_id, grantee_person_id, permission, created_by)
    select v_org, v_id, person_id, case when person_id = p_owner_person_id or person_id = v_actor then 'MANAGE'::consulting_os.grant_permission else 'READ'::consulting_os.grant_permission end, v_actor
    from consulting_os.meeting_participants where meeting_id = p_meeting_id and organization_id = v_org;
  end if;
  insert into consulting_os.commitments (id, organization_id, engagement_id, source_meeting_id, coaching_relationship_id, owner_person_id, action, due_on, created_by)
  values (v_id, v_org, v_eng, p_meeting_id, v_relationship, p_owner_person_id, p_action, p_due_on, v_actor);
  return v_id;
end
$$;

create or replace function consulting_os.record_coaching_promotion(
  p_source_private_note_id uuid,
  p_derivative_domain_object_id uuid,
  p_chosen_visibility consulting_os.visibility_scope,
  p_abstraction_summary text,
  p_redaction_rationale text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare v_actor uuid := consulting_security.current_person_id(); v_org uuid; v_author uuid; v_source_engagement uuid; v_derivative_engagement uuid; v_visibility consulting_os.visibility_scope; v_origin consulting_os.record_origin; v_owner uuid; v_object_type text; v_id uuid;
begin
  select n.organization_id, n.author_person_id, d.engagement_id into v_org, v_author, v_source_engagement
  from consulting_private.meeting_notes n join consulting_os.domain_objects d on d.id = n.id and d.organization_id = n.organization_id
  where n.id = p_source_private_note_id;
  select visibility_scope, origin, owner_person_id, engagement_id, object_type into v_visibility, v_origin, v_owner, v_derivative_engagement, v_object_type from consulting_os.domain_objects where id = p_derivative_domain_object_id and organization_id = v_org;
  if v_actor is null or v_actor <> v_author or not consulting_security.has_active_consultant_assignment(v_org) then raise exception 'only the authoring assigned consultant may promote an abstracted private note' using errcode = '42501'; end if;
  if p_derivative_domain_object_id = p_source_private_note_id or v_object_type = 'MEETING_NOTE' then raise exception 'promotion requires a separate abstracted organizational object' using errcode = '23514'; end if;
  if v_visibility <> 'CONSULTANT_PRIVATE' or v_origin <> 'HUMAN' or v_owner <> v_actor then raise exception 'promotion requires a consultant-private human-authored derivative owned by the authorizer' using errcode = '23514'; end if;
  if p_chosen_visibility not in ('LEADERSHIP_RESTRICTED','ENGAGEMENT_SHARED','ORGANIZATION_SHARED') then raise exception 'promotion requires an approved broader visibility' using errcode = '23514'; end if;
  if v_derivative_engagement is distinct from v_source_engagement then raise exception 'promotion derivative must remain in the source engagement context' using errcode = '23514'; end if;
  if length(btrim(p_abstraction_summary)) = 0 or length(btrim(p_redaction_rationale)) = 0 then raise exception 'promotion requires abstraction and redaction rationale' using errcode = '23514'; end if;
  update consulting_os.domain_objects set visibility_scope = p_chosen_visibility, updated_at = now()
  where id = p_derivative_domain_object_id and organization_id = v_org;
  insert into consulting_private.coaching_promotions (organization_id, source_private_note_id, derivative_domain_object_id, chosen_visibility, abstraction_summary, redaction_rationale, authorized_by)
  values (v_org, p_source_private_note_id, p_derivative_domain_object_id, p_chosen_visibility, p_abstraction_summary, p_redaction_rationale, v_actor) returning id into v_id;
  insert into consulting_os.audit_events (organization_id, actor_person_id, event_type, target_table, target_id, operation, reason, metadata)
  values (v_org, v_actor, 'COACHING_DERIVATIVE_PROMOTED', 'consulting_private.coaching_promotions', v_id, 'PROMOTE', p_redaction_rationale, jsonb_build_object('derivative_id', p_derivative_domain_object_id));
  return v_id;
end
$$;

create trigger meetings_validate before insert or update on consulting_os.meetings for each row execute function consulting_security.validate_phase5_typed_record();
create trigger meeting_participants_validate before insert or update on consulting_os.meeting_participants for each row execute function consulting_security.validate_meeting_participant();
create trigger meeting_notes_validate before insert or update on consulting_os.meeting_notes for each row execute function consulting_security.validate_phase5_typed_record();
create trigger coaching_relationships_validate before insert or update on consulting_os.coaching_relationships for each row execute function consulting_security.validate_phase5_typed_record();
create trigger commitments_validate before insert or update on consulting_os.commitments for each row execute function consulting_security.validate_phase5_typed_record();
create constraint trigger coaching_sessions_validate after insert or update on consulting_os.coaching_sessions deferrable initially deferred for each row execute function consulting_security.validate_coaching_session();
create trigger meeting_context_validate before insert or update on consulting_os.meeting_context_items for each row execute function consulting_security.validate_meeting_context();
create trigger meetings_updated before update on consulting_os.meetings for each row execute function consulting_security.set_updated_at();
create trigger meeting_notes_updated before update on consulting_os.meeting_notes for each row execute function consulting_security.set_updated_at();
create trigger coaching_relationships_updated before update on consulting_os.coaching_relationships for each row execute function consulting_security.set_updated_at();
create trigger commitments_updated before update on consulting_os.commitments for each row execute function consulting_security.set_updated_at();

alter table consulting_os.meetings enable row level security;
alter table consulting_os.meeting_participants enable row level security;
alter table consulting_os.meeting_notes enable row level security;
alter table consulting_os.coaching_relationships enable row level security;
alter table consulting_os.coaching_sessions enable row level security;
alter table consulting_os.commitments enable row level security;
alter table consulting_os.meeting_decisions enable row level security;
alter table consulting_os.meeting_context_items enable row level security;
alter table consulting_private.meeting_notes enable row level security;
alter table consulting_private.coaching_promotions enable row level security;

do $$ declare v_table text; begin
  foreach v_table in array array['meetings','meeting_notes','coaching_relationships','commitments'] loop
    execute format('create policy %I on consulting_os.%I for select to authenticated using (consulting_security.can_read_domain_object(id, organization_id))', v_table || '_select_visible', v_table);
    execute format('create policy %I on consulting_os.%I for insert to authenticated with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(id, organization_id))', v_table || '_insert_authorized', v_table);
    execute format('create policy %I on consulting_os.%I for update to authenticated using (consulting_security.can_manage_domain_object(id, organization_id)) with check (consulting_security.can_manage_domain_object(id, organization_id))', v_table || '_update_authorized', v_table);
  end loop;
end $$;

create policy meeting_participants_select_visible on consulting_os.meeting_participants for select to authenticated using (consulting_security.can_read_domain_object(meeting_id, organization_id));
create policy meeting_participants_insert_authorized on consulting_os.meeting_participants for insert to authenticated with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(meeting_id, organization_id));
create policy meeting_participants_update_authorized on consulting_os.meeting_participants for update to authenticated using (consulting_security.can_manage_domain_object(meeting_id, organization_id)) with check (consulting_security.can_manage_domain_object(meeting_id, organization_id));
create policy coaching_sessions_select_visible on consulting_os.coaching_sessions for select to authenticated using (consulting_security.can_read_domain_object(id, organization_id) and consulting_security.can_read_domain_object(coaching_relationship_id, organization_id));
create policy coaching_sessions_insert_authorized on consulting_os.coaching_sessions for insert to authenticated with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(id, organization_id) and consulting_security.can_manage_domain_object(coaching_relationship_id, organization_id));
create policy meeting_decisions_select_visible on consulting_os.meeting_decisions for select to authenticated using (consulting_security.can_read_domain_object(meeting_id, organization_id) and consulting_security.can_read_domain_object(decision_id, organization_id));
create policy meeting_decisions_insert_authorized on consulting_os.meeting_decisions for insert to authenticated with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(meeting_id, organization_id) and consulting_security.can_read_domain_object(decision_id, organization_id));
create policy meeting_context_select_visible on consulting_os.meeting_context_items for select to authenticated using (consulting_security.can_read_domain_object(meeting_id, organization_id) and consulting_security.can_read_domain_object(context_domain_object_id, organization_id));
create policy meeting_context_insert_authorized on consulting_os.meeting_context_items for insert to authenticated with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(meeting_id, organization_id));

drop policy commitments_update_authorized on consulting_os.commitments;
create policy commitments_update_authorized on consulting_os.commitments for update to authenticated
using (consulting_security.can_manage_domain_object(id, organization_id) or owner_person_id = consulting_security.current_person_id())
with check (consulting_security.can_manage_domain_object(id, organization_id) or owner_person_id = consulting_security.current_person_id());

do $$ declare v_table text; begin
  foreach v_table in array array['meetings','meeting_notes','coaching_relationships','commitments'] loop
    execute format('revoke all on consulting_os.%I from public, anon, authenticated', v_table);
    execute format('grant select, insert, update on consulting_os.%I to authenticated', v_table);
    execute format('grant all on consulting_os.%I to service_role', v_table);
  end loop;
  foreach v_table in array array['meeting_participants','coaching_sessions','meeting_decisions','meeting_context_items'] loop
    execute format('revoke all on consulting_os.%I from public, anon, authenticated', v_table);
    execute format('grant select, insert, update on consulting_os.%I to authenticated', v_table);
    execute format('grant all on consulting_os.%I to service_role', v_table);
  end loop;
end $$;

-- Shared meeting notes are append-oriented. Commitment owners may update only
-- completion state; changing the action, owner, or provenance remains a managed action.
revoke update on consulting_os.meeting_notes from authenticated;
revoke update on consulting_os.commitments from authenticated;
grant update (status, completed_at, completion_note) on consulting_os.commitments to authenticated;

revoke all on consulting_private.meeting_notes, consulting_private.coaching_promotions from public, anon, authenticated;
grant all on consulting_private.meeting_notes, consulting_private.coaching_promotions to service_role;
revoke all on function consulting_security.validate_meeting_participant() from public, anon, authenticated;
revoke all on function consulting_security.person_can_read_domain_object(uuid, uuid, uuid) from public, anon, authenticated;
revoke all on function consulting_os.create_meeting(uuid, uuid, consulting_os.meeting_type, text, text, timestamptz, text, uuid, text) from public, anon;
revoke all on function consulting_os.create_private_meeting_note(uuid, consulting_os.private_record_kind, uuid, text) from public, anon;
revoke all on function consulting_os.record_coaching_promotion(uuid, uuid, consulting_os.visibility_scope, text, text) from public, anon;
revoke all on function consulting_os.meeting_people_directory(uuid, uuid) from public, anon;
revoke all on function consulting_os.private_meeting_notes_for_meeting(uuid) from public, anon;
revoke all on function consulting_os.add_shared_meeting_note(uuid, text) from public, anon;
revoke all on function consulting_os.add_meeting_decision(uuid, text, text, text, text) from public, anon;
revoke all on function consulting_os.add_meeting_commitment(uuid, uuid, text, date) from public, anon;
grant execute on function consulting_os.create_private_meeting_note(uuid, consulting_os.private_record_kind, uuid, text) to authenticated, service_role;
grant execute on function consulting_os.create_meeting(uuid, uuid, consulting_os.meeting_type, text, text, timestamptz, text, uuid, text) to authenticated, service_role;
grant execute on function consulting_os.record_coaching_promotion(uuid, uuid, consulting_os.visibility_scope, text, text) to authenticated, service_role;
grant execute on function consulting_os.meeting_people_directory(uuid, uuid) to authenticated, service_role;
grant execute on function consulting_os.private_meeting_notes_for_meeting(uuid) to authenticated, service_role;
grant execute on function consulting_os.add_shared_meeting_note(uuid, text) to authenticated, service_role;
grant execute on function consulting_os.add_meeting_decision(uuid, text, text, text, text) to authenticated, service_role;
grant execute on function consulting_os.add_meeting_commitment(uuid, uuid, text, date) to authenticated, service_role;

create or replace view consulting_os.meeting_workflow_overview with (security_invoker = true) as
select m.*, count(distinct mp.person_id) as participant_count, count(distinct c.id) filter (where c.status <> 'CANCELLED') as commitment_count
from consulting_os.meetings m
left join consulting_os.meeting_participants mp on mp.meeting_id = m.id and mp.organization_id = m.organization_id
left join consulting_os.commitments c on c.source_meeting_id = m.id and c.organization_id = m.organization_id
group by m.id;

create or replace view consulting_os.coaching_history with (security_invoker = true) as
select cs.organization_id, cs.coaching_relationship_id, cs.id as meeting_id, cs.session_number,
  m.title, m.scheduled_start, m.status, m.current_phase, m.shared_summary, m.follow_up
from consulting_os.coaching_sessions cs
join consulting_os.meetings m on m.id = cs.id and m.organization_id = cs.organization_id;

create or replace view consulting_os.phase5_organizational_intelligence_sources with (security_invoker = true) as
select d.* from consulting_os.domain_objects d
where d.visibility_scope not in ('CONSULTANT_PRIVATE','INDIVIDUAL_PRIVATE','COACHING_SHARED')
  and d.object_type not in ('COACHING_RELATIONSHIP','COACHING_SESSION')
  and not exists (
    select 1 from consulting_os.meeting_notes mn
    join consulting_os.coaching_sessions cs on cs.id = mn.meeting_id and cs.organization_id = mn.organization_id
    where mn.id = d.id and mn.organization_id = d.organization_id
  );

grant select on consulting_os.meeting_workflow_overview, consulting_os.coaching_history, consulting_os.phase5_organizational_intelligence_sources to authenticated, service_role;

comment on table consulting_private.meeting_notes is 'Physically partitioned consultant-private meeting notes and individual-private reflections; no ordinary table grants.';
comment on table consulting_private.coaching_promotions is 'Explicit human-authorized abstraction/redaction boundary from private coaching content to a separate broader derivative.';
comment on view consulting_os.phase5_organizational_intelligence_sources is 'Permission-filtered candidates that exclude private, coaching-shared, and direct coaching-session material by default.';
