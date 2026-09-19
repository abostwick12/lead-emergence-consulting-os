# Canonical Lead Emergence Control Plane

Before any diagnosis, implementation, branch/worktree creation, or code change in this repository, read the private canonical control plane:

- Repository: `abostwick12/lead-emergence-control-plane` (default branch `main`)
- Shared agent mandate: `AGENTS.md`
- Canonical roadmap: `docs/ROADMAP.md`
- Canonical production state: `docs/status/PRODUCTION_STATE.md`
- Durable decisions: `docs/DECISIONS.md`
- Backlog: `docs/BACKLOG.md`
- Protocols: `agent-skills/`

The control-plane `AGENTS.md` and Software Factory V1 workflow govern shared development behavior. This repository's rules below remain in force unless they directly conflict with that shared workflow; otherwise preserve the stricter rule.

Do **not** create an independent editable copy of `ROADMAP.md` or `PRODUCTION_STATE.md` in this repository. If you cannot access the private control-plane repository, stop and report that access failure to Andrew rather than working from a stale copy or prior handoff.

---

# Lead Emergence Consulting OS — Repository-Specific Agent Instructions

<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->
