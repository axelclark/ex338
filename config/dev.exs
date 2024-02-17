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
    esbuild: {Esbuild, :install_and_run, [:ex338, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:ex338, ~w(--watch)]}
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
      ~r{lib/my_app_web/live/.*(ex)$},
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/ex338_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Include HEEx debug annotations as HTML comments in rendered markup
config :phoenix_live_view, :debug_heex_annotations, true

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
