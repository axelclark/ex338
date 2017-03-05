defmodule Ex338.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex338,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Ex338, []},
     applications: [:cowboy, :logger, :gettext, :phoenix, :phoenix_pubsub,
                    :phoenix_html, :phoenix_ecto, :postgrex, :swoosh,
                    :calendar, :phoenix_swoosh, :coherence, :honeybadger,
                    :scrivener_ecto]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
     {:calendar, "~> 0.17.0"},
     {:canary, "~> 1.1.0"},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:coherence, "~> 0.3.1"},
     {:cowboy, "~> 1.0"},
     {:csv, "~> 1.4.2"},
     {:ecto, "~> 2.1.0"},
     {:ex_admin, github: "smpallen99/ex_admin"},
     {:ex_machina, "~> 1.0.2", only: :test},
     {:excoveralls, "~> 0.6", only: :test},
     {:gettext, "~> 0.13"},
     {:honeybadger, "~> 0.6.1"},
     {:phoenix, "~> 1.2.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:phoenix_markdown, "~> 0.1"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_swoosh, "~> 0.1.3"},
     {:postgrex, "~> 0.13.0"},
     {:swoosh, "~> 0.5.0"},
     {:wallaby, "~> 0.15.0"},
   ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
