import { protectedResourceResponse } from '@/lib/mcp/metadata-response';

export const dynamic = 'force-dynamic';
export function GET(request: Request) { return protectedResourceResponse(request); }
export function OPTIONS(request: Request) { return protectedResourceResponse(request); }
