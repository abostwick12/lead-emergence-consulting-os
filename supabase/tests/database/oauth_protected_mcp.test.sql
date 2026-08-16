begin;
create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;
select plan(14);

select has_table('consulting_os', 'guided_record_responses', 'guided responses table exists');
select has_table('consulting_os', 'mcp_tool_audit', 'content-free MCP audit table exists');
select ok((select relrowsecurity from pg_class where oid = 'consulting_os.guided_record_responses'::regclass), 'guided responses use RLS');
select ok((select relrowsecurity from pg_class where oid = 'consulting_os.mcp_tool_audit'::regclass), 'MCP audit uses RLS');
select has_function('consulting_security', 'guided_record_exists', array['uuid','uuid','text','uuid'], 'record integrity helper exists');
select has_index('consulting_os', 'guided_record_responses', 'guided_responses_org_engagement_idx', 'guided responses use tenant-first lookup index');
select has_index('consulting_os', 'mcp_tool_audit', 'mcp_tool_audit_org_time_idx', 'MCP audit uses tenant-first time index');
select has_index('consulting_os', 'guided_record_responses', 'guided_responses_confirmed_by_idx', 'guided response person foreign key is indexed');
select has_index('consulting_os', 'guided_record_responses', 'guided_responses_engagement_tenant_fk_idx', 'guided response engagement foreign key is indexed');
select has_index('consulting_os', 'mcp_tool_audit', 'mcp_tool_audit_engagement_tenant_fk_idx', 'MCP audit engagement foreign key is indexed');
select has_index('consulting_os', 'mcp_tool_audit', 'mcp_tool_audit_person_idx', 'MCP audit person foreign key is indexed');
select ok(has_table_privilege('authenticated', 'consulting_os.guided_record_responses', 'SELECT'), 'authenticated users may read authorized guided responses');
select ok(not has_table_privilege('authenticated', 'consulting_os.mcp_tool_audit', 'SELECT'), 'authenticated users cannot read the trusted MCP audit table directly');
select ok(has_table_privilege('service_role', 'consulting_os.mcp_tool_audit', 'INSERT'), 'trusted server may append MCP audit rows');

select * from finish();
rollback;
