defmodule Ex338.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex338,
      version: "0.0.1",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.

  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Ex338.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :os_mon
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:bcrypt_elixir, "~> 2.0"},
      {:calendar, "~> 1.0.0"},
      {:canary, "~> 1.1.0"},
      {:cowboy, "~> 2.0"},
      {:csv, "~> 2.4.1"},
      {:ecto, "~> 3.4.4"},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.4.4"},
      {:ex_machina, "~> 2.4.0", only: :test},
      {:exgravatar, "~> 2.0.0"},
      {:floki, "~> 0.30.0", only: :test},
      {:gettext, "~> 0.13"},
      {:honeybadger, "~> 0.12"},
      {:jason, "~> 1.0"},
      {:kaffy, "~> 0.9"},
      {:mixpanel_api_ex, "~> 1.0.1"},
      {:number, "~> 1.0.0"},
      {:phoenix, "~> 1.5.1"},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:phoenix_ecto, "~> 4.2.0"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_reload, "~> 1.3.0", only: :dev},
      {:phoenix_markdown, "~> 1.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_pubsub_redis, "~> 3.0.0"},
      {:phoenix_live_view, "~> 0.13.0"},
      {:phoenix_swoosh, "~> 0.2.0"},
      {:plug_cowboy, "~> 2.2"},
      {:postgrex, "~> 0.15.0"},
      {:pow, "~> 1.0.20"},
      {:redix, "~> 0.10.0"},
      {:swoosh, "~> 0.25.4"},
      {:telemetry_poller, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
