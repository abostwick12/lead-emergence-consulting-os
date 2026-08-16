-- Follow-up hardening for the OAuth MCP persistence layer.
-- The audit table remains service-role only; the explicit false policy makes
-- that deny-by-default intent inspectable to database advisors and reviewers.

create index if not exists guided_responses_confirmed_by_idx
  on consulting_os.guided_record_responses (confirmed_by);
create index if not exists guided_responses_engagement_tenant_fk_idx
  on consulting_os.guided_record_responses (engagement_id, organization_id);
create index if not exists mcp_tool_audit_engagement_tenant_fk_idx
  on consulting_os.mcp_tool_audit (engagement_id, organization_id);
create index if not exists mcp_tool_audit_person_idx
  on consulting_os.mcp_tool_audit (person_id);

drop policy if exists mcp_tool_audit_deny_authenticated on consulting_os.mcp_tool_audit;
create policy mcp_tool_audit_deny_authenticated on consulting_os.mcp_tool_audit
  for all to authenticated
  using (false)
  with check (false);
