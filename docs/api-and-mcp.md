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

### Phase 2 — Token management UI ✅ done
- [x] Section in `UserSettingsLive` to generate + revoke tokens. Raw token shown exactly once
      in a callout; existing tokens listed by name + created date with a Revoke button.
- [x] Tests: generate (shown once + persisted), list, revoke, and per-user scoping.

### Phase 3 — Write API endpoints 🚧 pattern established
Shared write infrastructure (done, reused by every future write endpoint):
- [x] `FallbackController` handles `{:error, :forbidden}` → 403 and
      `{:error, %Ecto.Changeset{}}` → 422.
- [x] `ErrorJSON.changeset_error/1` renders field-level validation errors.
- [x] `FantasyTeams.get_team_with_owners/1` — loads a team with owners for the
      `Ex338.Abilities` owner check.
- [x] Authorization pattern in the controller `with` chain:
      `Canada.Can.can?(user, :create, team) || {:error, :forbidden}` (admin passes via
      `Ex338.Abilities`, owners via `owners.user_id`).

Reference endpoint (done):
- [x] `POST /api/v1/fantasy_teams/:fantasy_team_id/waivers` — `Api.V1.WaiverController.create`,
      delegating to `Waivers.create_waiver/2` + notifier. Tests cover owner 201, admin
      override, non-owner 403, invalid 422, missing team 404, no token 401.

Resources (each: shared `ApiActions` fn → REST endpoint + MCP tool, audited):
- [x] Waivers — `POST …/waivers` + `create_waiver` tool
- [x] Injured reserves — `POST …/injured_reserves` + `create_injured_reserve` tool
- [x] MCP read tools now scoped by league access (`FantasyLeagues.can_access_league?/2`)
      so private leagues stay private: `list_league_waivers`, `list_league_injured_reserves`
- [ ] Draft queues — `DraftQueues` update
- [ ] Trades — `Trades` create + votes (deferred: nested trade_line_items need a
      considered request shape for JSON/MCP)
- [ ] Roster moves / other team actions as needed

Note: the pre-existing unauthenticated `GET /api/v1/...` REST index/show endpoints are
still public and NOT league-scoped — a separate decision from the authenticated MCP reads.

### Phase 4 — MCP server ✅ done (hand-rolled JSON-RPC)
Decision: hand-rolled, no new dependency. Stateless Streamable HTTP transport
(request/response JSON-RPC 2.0), authenticated by the same `ApiAuth` plug — identical
scoping to the REST API.
- [x] `POST /api/v1/mcp` (`Api.V1.McpController`) handling `initialize`, `ping`,
      `tools/list`, `tools/call`; notifications (no `id`) → 202; supports JSON-RPC batches.
- [x] `Api.V1.Mcp.Tools` — tool definitions (with JSON Schema) + execution. Tools:
      `whoami` (read), `list_league_waivers` (read), `create_waiver` (owner/admin write).
- [x] Error mapping: domain outcomes (forbidden, not_found, validation) → tool results with
      `isError: true` so the model can react; protocol misuse (unknown tool/method, missing
      name) → JSON-RPC errors (-32601/-32602).
- [x] Tests: initialize, tools/list, whoami, create_waiver owner success + non-owner isError
      + validation isError, unknown tool/method, notification 202, 401 without token.

Adding a tool: add a map to `Tools.list/0` and a `Tools.call/3` clause delegating to a
context, authorized with `Canada.Can.can?/3` — same pattern as the REST write endpoints.

### Phase 5 — Audit logging ✅ done (API + MCP writes)
DB-backed audit trail so every write through the authenticated API/MCP is attributable —
important now that AI agents act under user tokens.
- [x] `audit_logs` table + `Ex338.Audit.AuditLog` schema (append-only): who (`user_id`,
      `api_token_id`), how (`source`: web/api/mcp), what (`action`, `resource_type`,
      `resource_id`), outcome (success/denied/error), `fantasy_league_id`, `metadata` jsonb.
- [x] `Ex338.Audit` context: best-effort `log/1` (never raises into the request),
      `outcome_for/1`, and `list_recent`/`list_for_user`/`list_for_resource` queries.
      Metadata keys normalized to strings for read consistency.
- [x] Token attribution: `ApiAuth` assigns `:current_api_token`; entries record the token id
      and its name (via `metadata.token_name`), so you can answer "what did this token do?"
      and revoke a misbehaving one.
- [x] `Ex338Web.ApiActions` — shared authorized-write layer both REST and MCP call, so the
      auth check + context call + notifier + audit entry live in one place per action
      (source "api" vs "mcp" is the only difference). Waiver create migrated onto it.
- [x] Denials and validation failures are logged too, not just successes.
- [x] Tests: Audit context (validation, queries, outcome mapping) + audit assertions in the
      REST and MCP waiver tests (success + denied). Verified live end-to-end.

Coverage is API + MCP for now. HTML controllers and background jobs (Oban) can be
instrumented later by calling `Ex338.Audit.log/1` (source "web") from those paths.

New write actions should go through `Ex338Web.ApiActions` so they are authorized and
audited uniformly.

## Client setup notes

- Base URL: `POST https://the338challenge.com/api/v1/mcp`
- Auth: `Authorization: Bearer <personal access token>` (generate under Account Settings →
  API Tokens). The token carries the user's scope: owners act on their own teams, admins on
  any team.

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
