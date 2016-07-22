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

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :ex_admin,
  repo: Ex338.Repo,
  module: Ex338,
  modules: [
    Ex338.ExAdmin.Dashboard,
    Ex338.ExAdmin.FantasyLeague,
    Ex338.ExAdmin.FantasyTeam,
    Ex338.ExAdmin.SportsLeague,
    Ex338.ExAdmin.FantasyPlayer,
    Ex338.ExAdmin.RosterPosition,
    Ex338.ExAdmin.RosterTransaction,
    Ex338.ExAdmin.TransactionLineItem,
    Ex338.ExAdmin.DraftPick,
  ]

config :xain, :after_callback, {Phoenix.HTML, :raw}

