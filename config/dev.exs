import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :ex338, Ex338Web.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# Watch static and templates for browser reloading.
config :ex338, Ex338Web.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{lib/ex338_web/views/.*(ex)$},
      ~r{lib/ex338_web/templates/.*(eex)$},
      ~r{lib/my_app_web/live/.*(ex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :ex338, Ex338.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ex338_dev",
  hostname: "localhost",
  pool_size: 10

config :ex338, Ex338Web.Mailer, adapter: Swoosh.Adapters.Local

config :ex338, Ex338Web.PowMailer, adapter: Swoosh.Adapters.Local

config :honeybadger, :environment_name, :dev

config :mixpanel_api_ex, Ex338.Mixpanel,
  project_token: "",
  http_adapter: Mixpanel.HTTP.NoOp
