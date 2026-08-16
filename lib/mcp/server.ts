import 'server-only';

import { McpServer, type AuthInfo } from '@modelcontextprotocol/server';
import { z } from 'zod';
import { clientMessage, isAppError, logError } from '@/lib/errors';
import { executeOperationalMcpTool } from '@/lib/operational-ai/mcp-tools';
import { auditMcpToolCall } from './audit';
import { listMcpEngagements, resolveMcpSession, type McpEngagementSelection } from './session';

const selectionShape = {
  organizationId: z.string().uuid().optional().describe('Optional assigned organization UUID.'),
  engagementId: z.string().uuid().optional().describe('Optional assigned engagement UUID. Use list_available_engagements to choose.'),
};
const securityMeta = { securitySchemes: [{ type: 'oauth2', scopes: ['openid', 'email', 'profile'] }] };

export function createLeadEmergenceMcpServer(authInfo: AuthInfo) {
  const server = new McpServer(
    { name: 'Lead Emergence Consulting OS', version: '1.0.0' },
    {
      instructions: [
        'Use only sanitized, authorized process-level information.',
        'Never request, retain, or transform classified, CUI, operationally sensitive mission data, targets, coordinates, frequencies, callsigns, intelligence, or operational timelines.',
        'Read the authoritative record or instrument before asking questions. Ask one question at a time and preserve the user’s wording.',
        'Never save a response until the user explicitly confirms the exact answer. Never promote evidence into diagnosis, decision, or causation.',
      ].join(' '),
    },
  );

  server.registerTool('list_available_engagements', {
    title: 'List available Consulting OS engagements',
    description: 'Lists only the organizations and engagements assigned to the authenticated consultant. Use this before working when more than one engagement is available.',
    inputSchema: z.object({}),
    annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async () => runTool(authInfo, 'list_available_engagements', {}, async () => listMcpEngagements()));

  server.registerTool('list_engagement_records', {
    title: 'List Consulting OS engagement records',
    description: 'Lists sanitized products, written audits, or interviews for one assigned engagement.',
    inputSchema: z.object({ ...selectionShape, recordKind: z.enum(['PRODUCT', 'AUDIT', 'INTERVIEW']) }),
    annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async (input) => runOperationalTool(authInfo, 'list_engagement_records', input));

  server.registerTool('get_guided_record', {
    title: 'Read a guided Consulting OS record',
    description: 'Returns the selected record, its exact guided questions, saved responses, progress, and next unanswered question.',
    inputSchema: z.object({ ...selectionShape, recordKind: z.enum(['PRODUCT', 'AUDIT', 'INTERVIEW']), recordId: z.string().min(1) }),
    annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async (input) => runOperationalTool(authInfo, 'get_guided_record', input));

  server.registerTool('save_guided_response', {
    title: 'Save one confirmed guided response',
    description: 'Saves the user’s exact sanitized response only after explicit confirmation. Never infer, rewrite, or silently summarize an answer.',
    inputSchema: z.object({
      ...selectionShape,
      recordKind: z.enum(['PRODUCT', 'AUDIT', 'INTERVIEW']),
      recordId: z.string().min(1),
      questionId: z.string().min(1),
      answer: z.string().min(1).max(12000),
      confirmed: z.literal(true).describe('Must be true only after the user explicitly confirms the exact answer.'),
    }),
    annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async (input) => runOperationalTool(authInfo, 'save_guided_response', input));

  server.registerTool('list_assessment_instruments', {
    title: 'List authoritative assessment instruments',
    description: 'Lists the complete versioned Mission Product assessment instruments available to the selected engagement.',
    inputSchema: z.object(selectionShape),
    annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async (input) => runOperationalTool(authInfo, 'list_assessment_instruments', input));

  server.registerTool('get_assessment_instrument', {
    title: 'Read an authoritative assessment instrument',
    description: 'Returns every authoritative section, item, checklist option, matrix column, and response contract for one immutable instrument version.',
    inputSchema: z.object({ ...selectionShape, slug: z.string().min(1) }),
    annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async (input) => runOperationalTool(authInfo, 'get_assessment_instrument', input));

  server.registerTool('start_assessment_administration', {
    title: 'Start a guided assessment administration',
    description: 'Creates a tenant-scoped administration of the exact authoritative instrument after the consultant asks to begin it.',
    inputSchema: z.object({ ...selectionShape, slug: z.string().min(1), confirmed: z.literal(true).describe('Confirms that the consultant asked to start this administration.') }),
    annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: false },
    _meta: securityMeta,
  }, async (input) => runOperationalTool(authInfo, 'start_assessment_administration', input));

  server.registerTool('save_assessment_response', {
    title: 'Save one confirmed assessment response',
    description: 'Saves one structured response after exact confirmation. Never infer omitted fields, score the instrument, or convert a response into diagnosis.',
    inputSchema: z.object({
      ...selectionShape,
      participantToken: z.string().min(1),
      itemId: z.string().min(1),
      response: z.unknown(),
      confirmed: z.literal(true).describe('Must be true only after the participant explicitly confirms the exact response.'),
    }),
    annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    _meta: securityMeta,
  }, async (input) => runOperationalTool(authInfo, 'save_assessment_response', input));

  return server;
}

async function runOperationalTool(authInfo: AuthInfo, toolName: string, input: Record<string, unknown>) {
  const selection: McpEngagementSelection = {
    organizationId: typeof input.organizationId === 'string' ? input.organizationId : undefined,
    engagementId: typeof input.engagementId === 'string' ? input.engagementId : undefined,
  };
  return runTool(authInfo, toolName, selection, async (session) => executeOperationalMcpTool(session, toolName, input));
}

async function runTool(
  authInfo: AuthInfo,
  toolName: string,
  selection: McpEngagementSelection,
  operation: (session: Awaited<ReturnType<typeof resolveMcpSession>>) => Promise<unknown>,
) {
  let session: Awaited<ReturnType<typeof resolveMcpSession>> | undefined;
  try {
    session = await resolveMcpSession(selection);
    const result = await operation(session);
    await auditMcpToolCall({ session, oauthClientId: authInfo.clientId, toolName, succeeded: true });
    return {
      content: [{ type: 'text' as const, text: JSON.stringify(result, null, 2) }],
      structuredContent: { result: toJsonValue(result) },
    };
  } catch (error) {
    if (!session) {
      try { session = await resolveMcpSession({}); } catch { /* No authorized Consulting context exists to receive an audit row. */ }
    }
    if (session) await auditMcpToolCall({ session, oauthClientId: authInfo.clientId, toolName, succeeded: false, errorKind: isAppError(error) ? error.kind : 'UNEXPECTED' });
    logError(`mcp.tool.${toolName}`, error);
    return {
      isError: true,
      content: [{ type: 'text' as const, text: clientMessage(error, 'The Consulting OS tool could not complete the request.') }],
    };
  }
}

function toJsonValue(value: unknown): null | boolean | number | string | Array<unknown> | Record<string, unknown> {
  if (value === undefined) return null;
  return JSON.parse(JSON.stringify(value)) as null | boolean | number | string | Array<unknown> | Record<string, unknown>;
}
