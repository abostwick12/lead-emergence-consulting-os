'use client';

import { useState } from 'react';
import { Bot, Check, ChevronDown, CircleAlert, Clipboard, KeyRound, LockKeyhole, PlugZap, ShieldCheck, Unplug } from 'lucide-react';

export interface ConnectedAiGrant {
  clientId: string;
  name: string;
  website?: string;
  grantedAt: string;
}

export function McpConnectionCenter({ endpoint, readiness, grants }: { endpoint: string; readiness: { ready: boolean; label: string }; grants: ConnectedAiGrant[] }) {
  const [copied, setCopied] = useState<string | null>(null);
  async function copy(value: string, key: string) {
    await navigator.clipboard.writeText(value);
    setCopied(key);
    window.setTimeout(() => setCopied((current) => current === key ? null : current), 1800);
  }

  const vscodeConfig = JSON.stringify({ servers: { 'lead-emergence': { type: 'http', url: endpoint } } }, null, 2);
  return (
    <section className="mcp-connection-center" aria-labelledby="mcp-connections-heading">
      <header className="mcp-connection-hero">
        <div><p className="eyebrow">ONE SECURE CONNECTION</p><h2 id="mcp-connections-heading">Connect your AI assistant</h2><p>Use Lead Emergence from ChatGPT, Claude, or Copilot without sharing API keys. Paste one address, sign in with your Consulting OS account, and approve access.</p></div>
        <span className={readiness.ready ? 'status-chip' : 'status-chip gold'}>{readiness.ready ? <Check aria-hidden="true" /> : <CircleAlert aria-hidden="true" />}{readiness.label}</span>
      </header>

      <div className="mcp-endpoint-panel">
        <div><span>Secure MCP server address</span><code>{endpoint}</code></div>
        <button className="secondary-button compact" type="button" onClick={() => void copy(endpoint, 'endpoint')}>{copied === 'endpoint' ? <Check aria-hidden="true" /> : <Clipboard aria-hidden="true" />}{copied === 'endpoint' ? 'Copied' : 'Copy address'}</button>
      </div>

      {!readiness.ready && <p className="mcp-activation-note"><CircleAlert aria-hidden="true" /><span><strong>One owner step remains.</strong> OAuth and automatic client registration must be enabled in the project before assistants can connect. The platform code is ready; users should wait until this status reads “Ready to connect.”</span></p>}

      <div className="mcp-provider-grid">
        <ProviderCard name="ChatGPT" label="OpenAI" steps={['Open ChatGPT Settings, then Apps & Connectors.', 'Create a custom app/connector and paste the secure MCP server address.', 'Select Connect, sign in to Consulting OS, and approve the connection.']} />
        <ProviderCard name="Claude" label="Anthropic" steps={['Open Claude Settings, then Connectors.', 'Choose Add custom connector and paste the secure MCP server address.', 'Select Connect, sign in to Consulting OS, and approve the connection.']} />
        <ProviderCard name="Microsoft Copilot" label="Copilot Studio" steps={['Open the agent in Copilot Studio and go to Tools.', 'Add a Model Context Protocol tool, paste the server address, and choose dynamic OAuth discovery.', 'Create the connection, sign in to Consulting OS, and approve access.']} />
        <ProviderCard name="GitHub Copilot" label="VS Code or Visual Studio" steps={['Open MCP settings for your workspace.', 'Add a remote HTTP server using the configuration below.', 'Start the server, select Auth when prompted, sign in, and approve access.']} extra={<div className="mcp-config-snippet"><pre>{vscodeConfig}</pre><button type="button" onClick={() => void copy(vscodeConfig, 'vscode')}>{copied === 'vscode' ? <Check aria-hidden="true" /> : <Clipboard aria-hidden="true" />}{copied === 'vscode' ? 'Copied' : 'Copy configuration'}</button></div>} />
      </div>

      <section className="mcp-boundary-panel" aria-label="Connection safeguards">
        <div><ShieldCheck aria-hidden="true" /><span><strong>Existing access rules stay in force</strong><small>The assistant sees only organizations and engagements assigned to the signed-in consultant.</small></span></div>
        <div><KeyRound aria-hidden="true" /><span><strong>No API keys for users</strong><small>OAuth handles sign-in, approval, token expiry, refresh, and revocation.</small></span></div>
        <div><LockKeyhole aria-hidden="true" /><span><strong>Confirmation before writes</strong><small>Answers are saved only after the user explicitly confirms the exact response.</small></span></div>
      </section>

      <section className="mcp-connected-clients" aria-labelledby="connected-clients-heading">
        <div className="section-heading"><div><p className="eyebrow">AUTHORIZED CONNECTIONS</p><h3 id="connected-clients-heading">Connected assistants</h3></div><span className="count-pill">{grants.length}</span></div>
        {grants.length === 0 ? <div className="empty-state"><PlugZap aria-hidden="true" /><strong>No assistants connected yet</strong><p>Your approved ChatGPT, Claude, or Copilot connections will appear here.</p></div> : grants.map((grant) => (
          <article key={grant.clientId}>
            <Bot aria-hidden="true" />
            <span><strong>{grant.name}</strong><small>Connected {formatDate(grant.grantedAt)}{grant.website ? ` · ${safeHost(grant.website)}` : ''}</small></span>
            <form action="/api/oauth/grants/revoke" method="post"><input type="hidden" name="client_id" value={grant.clientId} /><button className="text-button" type="submit"><Unplug aria-hidden="true" />Disconnect</button></form>
          </article>
        ))}
      </section>

      <p className="mcp-policy-note"><CircleAlert aria-hidden="true" />Some employer-managed ChatGPT, Claude, Microsoft, or GitHub accounts require an administrator to allow custom MCP connections. That provider setting does not weaken or replace Consulting OS access controls.</p>
    </section>
  );
}

function ProviderCard({ name, label, steps, extra }: { name: string; label: string; steps: string[]; extra?: React.ReactNode }) {
  return <details className="mcp-provider-card"><summary><span className="mcp-provider-icon"><Bot aria-hidden="true" /></span><span><small>{label}</small><strong>{name}</strong></span><ChevronDown aria-hidden="true" /></summary><ol>{steps.map((step, index) => <li key={step}><span>{index + 1}</span>{step}</li>)}</ol>{extra}</details>;
}

function formatDate(value: string) {
  return new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric', year: 'numeric' }).format(new Date(value));
}

function safeHost(value: string) {
  try { return new URL(value).hostname; } catch { return 'registered client'; }
}
