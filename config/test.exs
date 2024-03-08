import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex338, Ex338Web.Endpoint,
  http: [port: 4001],
  server: false,
  pubsub_server: Ex338.PubSub

# Print only warnings and errors during test
config :logger, level: :warning

# Configure your database
config :ex338, Ex338.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ex338_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :ex338, Ex338Web.Mailer, adapter: Swoosh.Adapters.Test

config :honeybadger, :environment_name, :test

config :ex338, Oban, testing: :inline

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :floki, :encode_raw_html, false
