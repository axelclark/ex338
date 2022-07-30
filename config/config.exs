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
  render_errors: [view: Ex338Web.ErrorView, accepts: ~w(html json)],
  pubsub_server: Ex338.PubSub,
  live_view: [
    signing_salt: "1x8pvVPmkNUIBfYNRPYEXLvj7L2u+1y+"
  ]

config :ex338, Ex338Web.Mailer,
  adapter: Swoosh.Adapters.AmazonSES,
  region: "us-east-1",
  access_key: System.get_env("AWS_SES_ACCESS_KEY"),
  secret: System.get_env("AWS_SES_SECRET")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :canary, repo: Ex338.Repo

config :phoenix, :template_engines, md: PhoenixMarkdown.Engine

config :phoenix, :json_library, Jason

config :honeybadger, exclude_envs: [:dev, :test]

config :ex338, :pow,
  user: Ex338.Accounts.User,
  repo: Ex338.Repo,
  web_module: Ex338Web,
  extensions: [PowResetPassword, PowPersistentSession, PowInvitation],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: Ex338Web.PowMailer,
  cache_store_backend: Ex338Web.Pow.RedisCache

config :ex338, Ex338Web.PowMailer,
  adapter: Swoosh.Adapters.AmazonSES,
  region: "us-east-1",
  access_key: System.get_env("AWS_SES_ACCESS_KEY"),
  secret: System.get_env("AWS_SES_SECRET")

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :kaffy,
  otp_app: :ex338,
  admin_title: "338 Admin",
  ecto_repo: Ex338.Repo,
  router: Ex338Web.Router

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
