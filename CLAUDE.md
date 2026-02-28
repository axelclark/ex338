# Ex338 - Fantasy Sports League Manager

Phoenix/LiveView app for managing the 338 Challenge fantasy sports league.
Live at https://the338challenge.com.

## Tech Stack

- **Elixir 1.18 / OTP 27**, Phoenix 1.7, LiveView 1.0, Ecto 3.12
- **PostgreSQL** (Postgrex), **Oban** for background jobs, **Swoosh** for email
- **Tailwind CSS 4**, esbuild, Alpine.js for lightweight JS interactivity
- **Auth**: bcrypt + session tokens (hand-rolled, not `phx.gen.auth` library)
- **Admin**: Kaffy dashboard at `/admin`, Oban Web at `/oban`
- **Deployment**: Render.com (`render.yaml`, `build.sh`)

## Quick Commands

```bash
mix setup                        # deps + DB + assets (full local setup)
mix phx.server                   # dev server at localhost:4000
mix test                         # run all tests
mix test path/to/test.exs:42     # run specific test/line
mix format                       # format code (line_length: 98)
mix format --check-formatted     # CI format check
mix compile --warnings-as-errors # CI compile check
mix ecto.reset                   # drop + create + migrate + seed
```

## Repo Structure

```
lib/ex338/                  # Business logic (Phoenix contexts)
lib/ex338_web/              # Web layer (router, controllers, LiveViews, components)
test/                       # Mirrors lib/ structure
  support/factory.ex        # ExMachina factories (30+ factories)
  support/conn_case.ex      # ConnCase with register_and_log_in_user/1 helper
  support/data_case.ex      # DataCase for Ecto tests
config/                     # config.exs, dev/test/prod.exs, runtime.exs
priv/repo/migrations/       # 100+ migrations (since 2016)
priv/repo/seeds.exs         # Dev seed data
assets/                     # JS (plain, no framework), CSS (Tailwind), vendor/
```

## Contexts (lib/ex338/)

Each context is the public API for its domain. Schemas are nested inside.

| Context             | Key Schemas                              | Purpose                                    |
|---------------------|------------------------------------------|--------------------------------------------|
| `Accounts`          | User, UserToken                          | Auth, registration, sessions               |
| `FantasyLeagues`    | FantasyLeague, FantasyLeagueDraft, HistoricalRecord | League config, standings, calendar |
| `FantasyTeams`      | FantasyTeam, Owner, Standings            | Teams, owners, points/winnings             |
| `FantasyPlayers`    | FantasyPlayer, SportsLeague              | Real-world players, sport categories       |
| `RosterPositions`   | RosterPosition                           | Player ownership on teams                  |
| `DraftPicks`        | DraftPick, FuturePick                    | Redraft picks, future pick trading         |
| `DraftQueues`       | DraftQueue                               | Team draft wish lists                      |
| `InSeasonDraftPicks`| InSeasonDraftPick                        | Mid-season championship drafts             |
| `Championships`     | Championship, ChampionshipResult, ChampionshipSlot | Scoring events, results, slots  |
| `Waivers`           | Waiver                                   | Add/drop requests with batch processing    |
| `Trades`            | Trade, TradeLineItem, TradeVote          | Multi-player trades with league voting     |
| `InjuredReserves`   | InjuredReserve                           | IR requests (pending/approved/returned)    |
| `Chats`             | Chat, Message                            | Draft chat rooms with PubSub               |

Several contexts have an `Admin` submodule for commissioner-level operations (e.g., `DraftPicks.Admin`, `Waivers.Admin`, `Trades.Admin`).

## Web Layer (lib/ex338_web/)

**Router** (`router.ex`): Routes are grouped by auth level — public, authenticated, admin.
Key plugs: `LoadUserTeams`, `LoadLeagues`, `CanonicalDomain`.

**LiveViews** (`live/`): Used for interactive pages — draft board, standings, team show/edit,
championship views, commissioner approvals. Pattern: `mount/3` + `handle_params/3` + `render/1`.

**Controllers** (`controllers/`): Traditional request/response for forms (waivers, trades, IR)
and simple pages. Each has a matching `*_html.ex` module with embedded `.heex` templates.

**Components** (`components/`):
- `core_components.ex` — Phoenix-generated UI primitives (modal, table, form, button)
- `fantasy_team.ex` — Roster tables, championship slots, team cards
- `fantasy_league.ex` — Standings tables
- `commish.ex` — Admin tabs and toggles
- `layouts.ex` — Sidebar/navbar helpers
- `layouts/*.html.heex` — Root, app, navbar, sidebar templates

**Notifiers** (`notifiers/`): Email modules per domain (trades, waivers, draft picks, etc.).
Uses Swoosh; AWS SES in production, local adapter in dev.

## Key Patterns

- **Context boundaries**: All DB access goes through context modules, never call Repo directly
  from web layer. Contexts return `{:ok, struct}` / `{:error, changeset}`.
- **PubSub**: Draft picks, in-season picks, and chat messages broadcast via `Phoenix.PubSub`.
  LiveViews subscribe in `mount/3`.
- **Authorization**: `Ex338.Abilities` module + `FantasyTeamAuthorizer`. Admin checks via
  `user.admin` boolean. ConnCase helpers: `register_and_log_in_user/1`, `register_and_log_in_admin/1`.
- **Background jobs**: Oban workers in `lib/ex338/workers/`. Single queue `default: 10`.
  Autodraft scheduling uses Oban. Test mode: `testing: :inline`.
- **Ecto enums**: Defined in `lib/ex338/ecto_enums.ex` using EctoEnum.
- **Verified routes**: `use Phoenix.VerifiedRoutes` throughout — compile-time route checking.
- **Styler**: Auto-formatter plugin that enforces consistent Elixir style on `mix format`.

## Testing

- **ExMachina factories** in `test/support/factory.ex` — use `insert(:user)`, `insert(:fantasy_league)`, etc.
- **ConnCase** for controller/LiveView tests, **DataCase** for context/schema tests.
- Tests tagged `@tag :pending` are excluded by default.
- CI runs: format check, compile with warnings-as-errors, ecto.create, ecto.migrate, mix test.
- CI services: PostgreSQL 14, Redis (for Oban).

## CI/CD

- **GitHub Actions** (`.github/workflows/main.yml`): Runs on push/PR to `main`.
- **Render** deployment: `build.sh` installs deps, compiles, builds assets, generates release.
  Start command: `_build/prod/rel/ex338/bin/server`.

## Workflow

- Branch from `main`, open PR, CI must pass. Repo uses **rebase merges only**.
- Render auto-deploys on merge to `main`.

## Common Pitfalls

- Run `mix format` before committing — CI enforces `--check-formatted`.
- Compilation warnings are errors in CI (`--warnings-as-errors`).
- Styler plugin (`.formatter.exs`) auto-rearranges aliases and module attrs on format — don't fight it.
- Always use DataCase/ConnCase for test setup (Ecto sandbox mode).
- LiveView tests need `live/2` from `Phoenix.LiveViewTest`, not `get/2`.
- Many contexts preload associations heavily — check existing query patterns before adding new ones.
- Seeds depend on CSV files in `priv/repo/csv_seed_data/`.
