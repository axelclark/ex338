defmodule Ex338.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex338,
      version: "0.0.1",
      elixir: "~> 1.7",
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
        :runtime_tools
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:calendar, "~> 0.17.0"},
      {:canary, "~> 1.1.0"},
      {:comeonin, "~> 3.0"},
      {:cowboy, "~> 2.0"},
      {:csv, "~> 2.3.1"},
      {:ecto, "~> 2.2.6", override: true},
      {:ecto_enum, "~> 1.1"},
      {:ex_admin, github: "sublimecoder/ex_admin"},
      {:ex_machina, "~> 2.3.0", only: :test},
      {:exgravatar, "~> 2.0.0"},
      {:gettext, "~> 0.13"},
      {:honeybadger, "~> 0.12"},
      {:jason, "~> 1.0"},
      {:mixpanel_api_ex, "~> 1.0.1"},
      {:number, "~> 1.0.0"},
      {:phoenix, "~> 1.4.8"},
      {:phoenix_ecto, "~> 3.3.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2.1", only: :dev},
      {:phoenix_markdown, "~> 1.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:phoenix_swoosh, "~> 0.2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, "~> 0.13.0"},
      {:pow, "~> 1.0.9"},
      {:redix, "~> 0.10.2"},
      {:swoosh, "~> 0.23.1"}
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
