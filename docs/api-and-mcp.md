# Authenticated API & MCP Server

Status: **in progress** (started 2026-07-25)

Goal: expose read/write access to league data over an authenticated HTTP API and an
MCP server, scoped so **regular owners** can act on their own teams and **admins** can
act on anything. Auth is via **personal access tokens** (Path A) — users generate a
token in settings and paste it into their API/MCP client. No OAuth 2.1 authorization
server (that's a possible future Phase; see "Deferred" below).

## Why personal access tokens (not OAuth)

The MCP spec expects an OAuth 2.1 authorization server for one-click "connect" from
hosted clients. That's ~1-2 weeks of protocol plumbing (dynamic client registration,
consent, PKCE, discovery) and adds an OAuth dependency. Personal access tokens deliver
scoped read/write today, work with most MCP clients, and reuse everything we already
have. We can layer real OAuth on top later without rework — the token → user → ability
mapping stays the same.

## What we're building on (already exists)

- **Read-only API** at `/api/v1` — `lib/ex338_web/controllers/api/v1/`, JSON views, and
  `FallbackController`. Currently **unauthenticated**. Router: `router.ex:204`.
- **DB-backed tokens** — `users_tokens` table has a `context` column + sha256 hashing.
  `Ex338.Accounts.UserToken` already implements the build/verify pattern for session,
  confirm, reset-password, and change-email contexts. We add an `"api-token"` context.
- **Authorization** — `Ex338.Abilities` (`Canada.Can` impl): `admin: true` passes
  everything; otherwise ownership is checked via `owners.user_id`. This already encodes
  the exact owner/admin read/write policy we want. We reuse it unchanged.
- **Contexts** return `{:ok, struct}` / `{:error, changeset}` and own their changesets +
  Oban side-effects. API actions are thin wrappers over the same functions the HTML
  controllers call.

## Phases

### Phase 1 — Token foundation (auth plumbing) ✅ done
- [x] `UserToken`: `build_api_token/2` + `verify_api_token_query/1` for the `"api-token"`
      context (mirror the session-token functions). Validity window: 365 days. Token name
      stored in the existing `sent_to` column (no migration).
- [x] `Accounts`: `create_user_api_token/2` (returns raw token once), `get_user_by_api_token/1`,
      `delete_user_api_token/2` (user-scoped), `list_user_api_tokens/1`.
- [x] `Ex338Web.Plugs.ApiAuth`: read `Authorization: Bearer <token>`, assign `:current_user`,
      respond 401 JSON otherwise.
- [x] Router: `:api_authenticated` pipeline (`:api` + `ApiAuth`).
- [x] Capstone endpoint: `GET /api/v1/me` (returns id/name/email/admin) — lets a client verify
      its token and learn its scope; exercises the whole chain end-to-end.
- [x] Tests: token round-trip, expiry, revoke, user-scoping; plug 401 vs pass-through.

### Phase 2 — Token management UI
- [ ] Section in `UserSettingsLive` to generate + revoke tokens. Show raw token exactly once.
- [ ] Tests: LiveView generate/revoke flow.

### Phase 3 — Write API endpoints
- [ ] Add `create`/`update`/`delete` actions to relevant `Api.V1` controllers, delegating
      to existing context functions, authorized via `Ex338.Abilities`.
- [ ] Candidate first set: waivers, injured reserves, draft queues, trades, roster moves.
- [ ] Tests per endpoint: owner-scoped success, cross-owner 403, admin override, 401.

### Phase 4 — MCP server
- [ ] Add `hermes_mcp` (or hand-rolled JSON-RPC endpoint). Bearer token flows through the
      same `ApiAuth` + `Abilities` path — identical scoping to the REST API.
- [ ] Tools by scope: read (any authenticated user), write (owner-scoped), admin-only.
- [ ] Tests: tool list, a read tool, a write tool honoring ownership, admin-only gating.

## Deferred / future

- **OAuth 2.1 authorization server** (Path B) — needed only for frictionless one-click
  "connect" from hosted MCP clients. Would add `boruta`/`ex_oauth2_provider`, discovery,
  dynamic client registration, consent UI, and map OAuth scopes → Abilities. The
  token → user → ability core built here is reused as-is.

## Conventions / notes

- All DB access through contexts, never `Repo` from the web layer.
- `mix format` (Styler) before commit; CI enforces `--check-formatted` and
  `--warnings-as-errors`.
- Tokens: store only the sha256 hash; the raw token is shown to the user once and never
  recoverable, matching the existing email-token design.
