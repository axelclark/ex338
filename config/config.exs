# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ex338,
  ecto_repos: [Ex338.Repo]

# Configures the endpoint
config :ex338, Ex338.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rMId5sSgp3+wKTXMCXXl38I/lxPO8AWSF9PFKhmqj4N1cJyK5NmZn3QgqLT2NQd8",
  render_errors: [view: Ex338.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ex338.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :ex338, Ex338.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ex_admin,
  repo: Ex338.Repo,
  module: Ex338,
  modules: [
    Ex338.ExAdmin.Dashboard,
    Ex338.ExAdmin.FantasyLeague,
    Ex338.ExAdmin.FantasyTeam,
    Ex338.ExAdmin.SportsLeague,
    Ex338.ExAdmin.Championship,
    Ex338.ExAdmin.ChampionshipResult,
    Ex338.ExAdmin.FantasyPlayer,
    Ex338.ExAdmin.InjuredReserve,
    Ex338.ExAdmin.RosterPosition,
    Ex338.ExAdmin.Waiver,
    Ex338.ExAdmin.DraftPick,
    Ex338.ExAdmin.Trade,
    Ex338.ExAdmin.TradeLineItem,
    Ex338.ExAdmin.Owner,
    Ex338.ExAdmin.User,
  ]

config :xain, :after_callback, {Phoenix.HTML, :raw}


# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Ex338.User,
  repo: Ex338.Repo,
  module: Ex338,
  logged_out_url: "/",
  email_from_name: "338 Admin",
  email_from_email: "no-reply@the338challenge.com",
  rememberable_cookie_expire_hours: (90*24),
  opts: [
    :rememberable,
    :authenticatable,
    :recoverable,
    :lockable,
    :trackable,
    :unlockable_with_token,
    :invitable,
  ]

config :coherence, Ex338.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY")
# %% End Coherence Configuration %%

config :canary, repo: Ex338.Repo

config :phoenix, :template_engines,
  md: PhoenixMarkdown.Engine

config :honeybadger, exclude_envs: [:dev, :test]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
