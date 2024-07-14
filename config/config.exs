# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# General application configuration
config :ex338,
  ecto_repos: [Ex338.Repo],
  slack_invite_url: System.get_env("SLACK_INVITE_URL"),
  mailer_default_from_name: "338 Commish",
  mailer_default_from_email: "commish@the338challenge.com"

# Configures the endpoint
config :ex338, Ex338Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rMId5sSgp3+wKTXMCXXl38I/lxPO8AWSF9PFKhmqj4N1cJyK5NmZn3QgqLT2NQd8",
  render_errors: [view: Ex338Web.ErrorHTML, accepts: ~w(html json)],
  pubsub_server: Ex338.PubSub,
  live_view: [
    signing_salt: "1x8pvVPmkNUIBfYNRPYEXLvj7L2u+1y+"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :canary, repo: Ex338.Repo

config :phoenix, :template_engines, md: PhoenixMarkdown.Engine

config :phoenix, :json_library, Jason

config :honeybadger, exclude_envs: [:dev, :test]

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :kaffy,
  otp_app: :ex338,
  admin_title: "338 Admin",
  ecto_repo: Ex338.Repo,
  router: Ex338Web.Router

config :ex338, Oban,
  repo: Ex338.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.20.0",
  ex338: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  ex338: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
