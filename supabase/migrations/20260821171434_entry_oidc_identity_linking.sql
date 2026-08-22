-- Durable Entry OIDC identity mapping. Entry proves canonical identity only;
-- Consulting remains the sole authority for people, roles, memberships,
-- engagements, visibility, and RLS.

alter table consulting_os.canonical_identity_links
  add column auth_user_id uuid references auth.users(id) on delete restrict,
  add column provider_identifier text,
  add column provider_subject text,
  add column provider_identity_id uuid;

alter table consulting_os.canonical_identity_links
  add constraint canonical_identity_links_auth_user_unique unique (auth_user_id),
  add constraint canonical_identity_links_provider_subject_unique unique (provider_identifier, provider_subject),
  add constraint canonical_identity_links_provider_identity_unique unique (provider_identity_id),
  add constraint canonical_identity_links_provider_identifier_format
    check (provider_identifier is null or provider_identifier ~ '^custom:[a-z0-9][a-z0-9:-]{1,49}$'),
  add constraint canonical_identity_links_subject_matches_canonical
    check (provider_subject is null or provider_subject = canonical_user_id::text),
  add constraint canonical_identity_links_linked_proof_complete
    check (
      status <> 'LINKED'
      or (
        auth_user_id is not null
        and provider_identifier is not null
        and provider_subject is not null
        and provider_identity_id is not null
      )
    );

create or replace function consulting_os.link_entry_oidc_identity(
  p_auth_user_id uuid,
  p_canonical_user_id uuid,
  p_provider_identifier text,
  p_provider_subject text,
  p_provider_identity_id uuid,
  p_display_name text,
  p_existing_account_link boolean default false
) returns table(person_id uuid, link_id uuid, created_person boolean)
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_person_id uuid;
  v_link_id uuid;
  v_link_person_id uuid;
  v_link_status consulting_os.canonical_identity_link_status;
  v_created_person boolean := false;
  v_created_link boolean := false;
begin
  if current_user not in ('service_role', 'postgres') then
    raise exception 'Trusted server identity is required.' using errcode = '42501';
  end if;
  if p_provider_identifier is null or p_provider_identifier !~ '^custom:[a-z0-9][a-z0-9:-]{1,49}$' then
    raise exception 'A configured custom provider is required.' using errcode = '22023';
  end if;
  if p_provider_subject is distinct from p_canonical_user_id::text then
    raise exception 'Provider subject does not match canonical identity.' using errcode = '22023';
  end if;
  if p_provider_identity_id is null then
    raise exception 'Provider identity identifier is required.' using errcode = '22023';
  end if;

  select p.id into v_person_id
  from consulting_os.people p
  where p.auth_user_id = p_auth_user_id;

  select cil.id, cil.person_id, cil.status
  into v_link_id, v_link_person_id, v_link_status
  from consulting_os.canonical_identity_links cil
  where cil.canonical_user_id = p_canonical_user_id
     or (cil.provider_identifier = p_provider_identifier and cil.provider_subject = p_provider_subject)
  for update;

  if v_link_id is not null then
    if v_link_status = 'REVOKED' then
      raise exception 'The canonical identity link is revoked.' using errcode = '42501';
    end if;
    if v_person_id is null or v_person_id is distinct from v_link_person_id then
      raise exception 'Canonical identity belongs to a different Consulting person.' using errcode = '23505';
    end if;
    update consulting_os.canonical_identity_links
    set status = 'LINKED',
        auth_user_id = p_auth_user_id,
        provider_identifier = p_provider_identifier,
        provider_subject = p_provider_subject,
        provider_identity_id = p_provider_identity_id,
        proof_type = 'ENTRY_OIDC_PROVIDER_SUBJECT',
        linked_at = coalesce(linked_at, now()),
        revoked_at = null
    where id = v_link_id;
  else
    if v_person_id is not null and not p_existing_account_link then
      raise exception 'Existing Consulting accounts require explicit identity linking.' using errcode = '42501';
    end if;
    if v_person_id is null then
      insert into consulting_os.people(auth_user_id, display_name)
      values (p_auth_user_id, left(coalesce(nullif(btrim(p_display_name), ''), 'Lead Emergence member'), 200))
      returning id into v_person_id;
      v_created_person := true;
    end if;
    insert into consulting_os.canonical_identity_links(
      person_id, canonical_user_id, status, proof_type, linked_at,
      auth_user_id, provider_identifier, provider_subject, provider_identity_id
    ) values (
      v_person_id, p_canonical_user_id, 'LINKED', 'ENTRY_OIDC_PROVIDER_SUBJECT', now(),
      p_auth_user_id, p_provider_identifier, p_provider_subject, p_provider_identity_id
    ) returning id into v_link_id;
    v_created_link := true;
  end if;

  insert into consulting_os.audit_events(
    actor_auth_user_id, actor_person_id, event_type, target_table, target_id,
    operation, reason, metadata
  ) values (
    p_auth_user_id,
    v_person_id,
    case when v_created_link then 'ENTRY_IDENTITY_LINK_CREATED' else 'ENTRY_SSO_IDENTITY_VERIFIED' end,
    'consulting_os.canonical_identity_links',
    v_link_id,
    case when v_created_link then 'INSERT' else 'UPDATE' end,
    'Verified custom OIDC provider subject; no Consulting authorization was created.',
    jsonb_build_object(
      'provider_identifier', p_provider_identifier,
      'provider_subject', p_provider_subject,
      'provider_identity_id', p_provider_identity_id,
      'created_person', v_created_person,
      'existing_account_link', p_existing_account_link
    )
  );

  return query select v_person_id, v_link_id, v_created_person;
end;
$$;

revoke all on function consulting_os.link_entry_oidc_identity(uuid,uuid,text,text,uuid,text,boolean)
  from public, anon, authenticated;
grant select, insert, update on consulting_os.canonical_identity_links to service_role;
grant execute on function consulting_os.link_entry_oidc_identity(uuid,uuid,text,text,uuid,text,boolean)
  to service_role;

comment on function consulting_os.link_entry_oidc_identity(uuid,uuid,text,text,uuid,text,boolean)
  is 'Atomically links a verified Entry OIDC subject to a Consulting Auth user/person without creating local authorization.';
