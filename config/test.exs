import Config

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

config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1

config :ex338, Ex338Web.Mailer, adapter: Swoosh.Adapters.Test

config :honeybadger, :environment_name, :test

config :ex338, Ex338Web.PowMailer, adapter: Swoosh.Adapters.Test

config :mixpanel_api_ex, Ex338.Mixpanel, nil

config :ex338, Oban, testing: :inline
