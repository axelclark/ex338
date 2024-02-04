defmodule Ex338.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex338,
      version: "0.0.1",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      xref: [exclude: [:mnesia]]
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
      {:bcrypt_elixir, "~> 3.0"},
      {:calendar, "~> 1.0.0"},
      {:canary, "~> 1.1.0"},
      {:cowboy, "~> 2.10"},
      {:csv, "~> 3.0.5"},
      {:ecto, "~> 3.11.0"},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.11.0"},
      {:ex_machina, "~> 2.7.0", only: :test},
      {:exgravatar, "~> 2.0.0"},
      {:floki, "~> 0.34.3", only: :test},
      {:gen_smtp, "~> 1.0"},
      {:gettext, "~> 0.13"},
      {:honeybadger, "~> 0.12"},
      {:jason, "~> 1.0"},
      {:kaffy, "~> 0.9.1"},
      {:mixpanel_api_ex, "~> 1.0.1"},
      {:number, "~> 1.0.0"},
      {:oban, "~> 2.13"},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:phoenix_ecto, "~> 4.4.0"},
      {:phoenix_html, "~> 3.2"},
      {:phoenix_live_reload, "~> 1.3.0", only: :dev},
      {:phoenix_markdown, "~> 1.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_pubsub_redis, "~> 3.0.0"},
      {:phoenix_live_view, "~> 0.19.0"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_swoosh, "~> 1.2.0"},
      {:plug_cowboy, "~> 2.7"},
      {:postgrex, "~> 0.16.0"},
      {:pow, "== 1.0.28"},
      {:redix, "~> 1.2.3"},
      {:styler, "~> 0.11", only: [:dev, :test], runtime: false},
      {:swoosh, "~> 1.15.1"},
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
