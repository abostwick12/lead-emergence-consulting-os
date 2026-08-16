-- Shared hosted-project integration.
-- Preserve every Ministry-owned Data API schema and append only consulting_os.
-- consulting_security and consulting_private must remain unexposed.
-- Rollback: remove only consulting_os from authenticator's pgrst.db_schemas value,
-- preserve the other comma-separated schemas, then notify PostgREST to reload.

do $$
declare
  v_schemas text;
begin
  select replace(setting, 'pgrst.db_schemas=', '')
    into v_schemas
  from unnest(
    coalesce(
      (select rolconfig from pg_roles where rolname = 'authenticator'),
      array[]::text[]
    )
  ) as setting
  where setting like 'pgrst.db_schemas=%'
  limit 1;

  -- Fresh local Supabase stacks do not persist this role setting. In that
  -- environment, start from Supabase's standard API schemas. Hosted targets
  -- retain their complete existing value from pg_roles above.
  if v_schemas is null or btrim(v_schemas) = '' then
    v_schemas := 'public,graphql_public';
  end if;

  if not ('consulting_os' = any(string_to_array(v_schemas, ','))) then
    execute format(
      'alter role authenticator set pgrst.db_schemas = %L',
      v_schemas || ',consulting_os'
    );
  end if;
end
$$;

notify pgrst, 'reload config';
