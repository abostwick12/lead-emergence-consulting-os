import 'server-only';

import { McpServer, type AuthInfo } from '@modelcontextprotocol/server';
import { z } from 'zod';
import { clientMessage, isAppError, logError, validationError } from '@/lib/errors';
import { getClientWorkspace, getMyGuidedRecord, listMyGuidedRecords, normalizeClientRecordKind, saveMyConfirmedGuidedResponse } from './client-tools';
import { auditMcpToolCall } from './audit';
import { listClientMcpEngagements, resolveClientMcpContext, type ClientMcpContext, type McpEngagementSelection } from './session';

const selectionShape = {
  organizationId: z.string().uuid().optional().describe('Optional authorized organization UUID.'),
  engagementId: z.string().uuid().optional().describe('Optional authorized engagement UUID. Select one when more than one is available.'),
};
const securityMeta = { securitySchemes: [{ type: 'oauth2', scopes: ['openid', 'email', 'profile'] }] };

export function createLeadEmergenceClientMcpServer(authInfo: AuthInfo) {
  const server = new McpServer(
    { name: 'Lead Emergence Client Workspace', version: '1.0.0' },
    { instructions: 'Use the client’s authorized Lead Emergence workspace. Read authoritative state before asking the client to repeat information. Preserve confirmed wording. Do not turn inference into organizational fact, expose consultant-private material, advance engagement stages, or make decisions. Ask one guided question at a time and save consequential answers only after explicit confirmation.' },
  );

  server.registerTool('open_workspace', {
    title: 'Open Lead Emergence workspace',
    description: 'Use when beginning or resuming Lead Emergence client work. Resolves the authenticated client’s authorized engagement and returns compact current work, progress, and next action. It never creates an organization, engagement, or membership.',
    inputSchema: z.object(selectionShape),
    annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async (input) => runClientTool(authInfo, 'client_open_workspace', input, async (resolution) => getClientWorkspace(resolution)));

  server.registerTool('list_my_engagements', {
    title: 'List my Lead Emergence engagements',
    description: 'Lists only active consulting engagements in which the authenticated client has active organization and engagement membership. Use this when workspace selection is required.',
    inputSchema: z.object({}),
    annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async () => runClientTool(authInfo, 'client_list_my_engagements', {}, async () => ({ status: 'ready', engagements: await listClientMcpEngagements() })));

  server.registerTool('list_my_guided_records', {
    title: 'List my assigned guided work',
    description: 'Lists only guided audits or interviews explicitly assigned to the authenticated client in the selected engagement. It does not expose consultant records or other participants’ work.',
    inputSchema: z.object(selectionShape),
    annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async (input) => runReadyClientTool(authInfo, 'client_list_my_guided_records', input, listMyGuidedRecords));

  server.registerTool('get_guided_record', {
    title: 'Read my assigned guided work',
    description: 'Use when continuing an assigned guided interview or written audit. Returns previously confirmed responses and the next unanswered authoritative question.',
    inputSchema: z.object({ ...selectionShape, recordKind: z.enum(['AUDIT', 'INTERVIEW']), recordId: z.string().uuid() }),
    annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async (input) => runReadyClientTool(authInfo, 'client_get_guided_record', input, (context) => getMyGuidedRecord(context, { recordKind: normalizeClientRecordKind(input.recordKind), recordId: input.recordId })));

  server.registerTool('save_confirmed_response', {
    title: 'Save one confirmed guided response',
    description: 'Use only after the client explicitly confirms the exact response that should become part of the assigned Lead Emergence record. Preserve their wording and do not infer omitted information.',
    inputSchema: z.object({ ...selectionShape, recordKind: z.enum(['AUDIT', 'INTERVIEW']), recordId: z.string().uuid(), questionId: z.string().min(1).max(80), answer: z.string().min(1).max(12000), confirmed: z.literal(true) }),
    annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async (input) => runReadyClientTool(authInfo, 'client_save_confirmed_response', input, (context) => saveMyConfirmedGuidedResponse(context, { recordKind: normalizeClientRecordKind(input.recordKind), recordId: input.recordId, questionId: input.questionId, answer: input.answer })));

  return server;
}

async function runReadyClientTool<T>(authInfo: AuthInfo, toolName: string, input: Record<string, unknown>, operation: (context: ClientMcpContext) => Promise<T>) {
  return runClientTool(authInfo, toolName, input, async (resolution) => {
    if (resolution.status !== 'ready') throw validationError('Select an authorized Lead Emergence engagement before continuing guided work.');
    return operation(resolution.context);
  });
}

async function runClientTool<T>(authInfo: AuthInfo, toolName: string, input: Record<string, unknown>, operation: (resolution: Awaited<ReturnType<typeof resolveClientMcpContext>>) => Promise<T>) {
  const selection: McpEngagementSelection = {
    organizationId: typeof input.organizationId === 'string' ? input.organizationId : undefined,
    engagementId: typeof input.engagementId === 'string' ? input.engagementId : undefined,
  };
  let resolution: Awaited<ReturnType<typeof resolveClientMcpContext>> | undefined;
  try {
    resolution = await resolveClientMcpContext(selection);
    const result = await operation(resolution);
    if (resolution.status === 'ready') await auditMcpToolCall({ session: resolution.context, oauthClientId: authInfo.clientId, toolName, succeeded: true });
    return { content: [{ type: 'text' as const, text: JSON.stringify(result, null, 2) }], structuredContent: { result: jsonValue(result) } };
  } catch (error) {
    if (resolution?.status === 'ready') await auditMcpToolCall({ session: resolution.context, oauthClientId: authInfo.clientId, toolName, succeeded: false, errorKind: isAppError(error) ? error.kind : 'UNEXPECTED' });
    logError(`mcp.client.${toolName}`, error);
    return { isError: true, content: [{ type: 'text' as const, text: clientMessage(error, 'The Lead Emergence client tool could not complete the request.') }] };
  }
}

function jsonValue(value: unknown): null | boolean | number | string | Array<unknown> | Record<string, unknown> {
  if (value === undefined) return null;
  return JSON.parse(JSON.stringify(value)) as null | boolean | number | string | Array<unknown> | Record<string, unknown>;
}