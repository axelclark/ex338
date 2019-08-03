# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ex338,
  ecto_repos: [Ex338.Repo],
  slack_invite_url: System.get_env("SLACK_INVITE_URL")

# Configures the endpoint
config :ex338, Ex338Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rMId5sSgp3+wKTXMCXXl38I/lxPO8AWSF9PFKhmqj4N1cJyK5NmZn3QgqLT2NQd8",
  render_errors: [view: Ex338Web.ErrorView, accepts: ~w(html json)],
  pubsub: [
    name: Ex338.PubSub,
    adapter: Phoenix.PubSub.Redis,
    url: System.get_env("REDIS_URL") || "redis://localhost:6379",
    node_name: System.get_env("NODE") || "name"
  ],
  live_view: [
    signing_salt: "1x8pvVPmkNUIBfYNRPYEXLvj7L2u+1y+"
  ]

config :ex338, Ex338Web.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ex_admin,
  repo: Ex338.Repo,
  module: Ex338Web,
  modules: [
    Ex338Web.ExAdmin.Dashboard,
    Ex338Web.ExAdmin.FantasyLeague,
    Ex338Web.ExAdmin.FantasyTeam,
    Ex338Web.ExAdmin.Owner,
    Ex338Web.ExAdmin.User,
    Ex338Web.ExAdmin.FantasyPlayer,
    Ex338Web.ExAdmin.SportsLeague,
    Ex338Web.ExAdmin.LeagueSport,
    Ex338Web.ExAdmin.FantasyLeagueChampionship,
    Ex338Web.ExAdmin.Championship,
    Ex338Web.ExAdmin.ChampWithEventsResult,
    Ex338Web.ExAdmin.ChampionshipResult,
    Ex338Web.ExAdmin.ChampionshipSlot,
    Ex338Web.ExAdmin.RosterPosition,
    Ex338Web.ExAdmin.InjuredReserve,
    Ex338Web.ExAdmin.Waiver,
    Ex338Web.ExAdmin.Trade,
    Ex338Web.ExAdmin.TradeLineItem,
    Ex338Web.ExAdmin.TradeVote,
    Ex338Web.ExAdmin.DraftPick,
    Ex338Web.ExAdmin.InSeasonDraftPick,
    Ex338Web.ExAdmin.DraftQueue,
    Ex338Web.ExAdmin.HistoricalRecord,
    Ex338Web.ExAdmin.HistoricalWinning
  ]

config :xain, :after_callback, {Phoenix.HTML, :raw}

config :canary, repo: Ex338.Repo

config :phoenix, :template_engines, md: PhoenixMarkdown.Engine

config :phoenix, :json_library, Jason

config :honeybadger, exclude_envs: [:dev, :test]

config :ex338, :pow,
  user: Ex338.User,
  repo: Ex338.Repo,
  web_module: Ex338Web,
  extensions: [PowResetPassword, PowPersistentSession, PowInvitation],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: Ex338Web.PowMailer,
  cache_store_backend: Ex338Web.PowRedisCache

config :ex338, Ex338Web.PowMailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
