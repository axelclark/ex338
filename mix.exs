defmodule Ex338.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex338,
      version: "0.0.1",
      elixir: "~> 1.18",
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
      {:bcrypt_elixir, "~> 3.2"},
      {:canary, "~> 1.2.0"},
      {:cowboy, "~> 2.13"},
      {:csv, "~> 3.2.2"},
      {:ecto, "~> 3.12.0"},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.12.0"},
      {:esbuild, "~> 0.9", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:ex_machina, "~> 2.8.0", only: :test},
      {:exgravatar, "~> 2.0.0"},
      {:floki, "~> 0.37.1", only: :test},
      {:gen_smtp, "~> 1.2"},
      {:gettext, "~> 0.26"},
      {:honeybadger, "~> 0.23"},
      {:jason, "~> 1.4"},
      {:kaffy, "~> 0.10.2"},
      {:nimble_publisher, "~> 1.1.1"},
      {:number, "~> 1.0.5"},
      {:oban, "~> 2.19"},
      {:phoenix, "~> 1.7.11"},
      {:phoenix_live_dashboard, "~> 0.8.6"},
      {:phoenix_ecto, "~> 4.6.3"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_pubsub, "~> 2.1"},
      {:phoenix_pubsub_redis, "~> 3.0.0"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_view, "~> 2.0"},
      {:plug_cowboy, "~> 2.7"},
      {:postgrex, "~> 0.20.0"},
      {:styler, "~> 1.4", only: [:dev, :test], runtime: false},
      {:swoosh, "~> 1.18"},
      {:telemetry_poller, "~> 0.5"},
      {:telemetry_metrics, "~> 1.1"},
      {:tzdata, "~> 1.1"},
      {:vega_lite, "~> 0.1.11"},
      {:oban_web, "~> 2.11"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind ex338", "esbuild ex338"],
      "assets.deploy": [
        "tailwind ex338 --minify",
        "esbuild ex338 --minify",
        "phx.digest"
      ]
    ]
  end
end
