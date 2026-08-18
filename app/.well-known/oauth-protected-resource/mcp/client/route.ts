import { CLIENT_MCP_PATH } from '@/lib/mcp/configuration';
import { protectedResourceResponse } from '@/lib/mcp/metadata-response';

export const dynamic = 'force-dynamic';
export function GET(request: Request) { return protectedResourceResponse(request, CLIENT_MCP_PATH); }
export function OPTIONS(request: Request) { return protectedResourceResponse(request, CLIENT_MCP_PATH); }