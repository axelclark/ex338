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
      applications: [
        :cowboy,
        :logger,
        :gettext,
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :phoenix_ecto,
        :postgrex,
        :swoosh,
        :calendar,
        :phoenix_swoosh,
        :coherence,
        :honeybadger,
        :scrivener_ecto,
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
      {:coherence, "~> 0.5.0"},
      {:cowboy, "~> 1.0"},
      {:csv, "~> 2.0.0"},
      {:ecto, "~> 2.2.6", override: true},
      {:ecto_enum, "~> 1.1"},
      {:ex_admin, github: "smpallen99/ex_admin"},
      {:ex_machina, "~> 2.1.0", only: :test},
      {:gettext, "~> 0.13"},
      {:honeybadger, "~> 0.6.1"},
      {:phoenix, "~> 1.3.0"},
      {:phoenix_ecto, "~> 3.3.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.1.3", only: :dev},
      {:phoenix_markdown, "~> 0.1"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_swoosh, "~> 0.2.0"},
      {:postgrex, "~> 0.13.0"},
      {:swoosh, "~> 0.8.0"},
      {:wallaby, "~> 0.20.0", [runtime: false, only: :test]}
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
