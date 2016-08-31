defmodule Ex338.Mixfile do
  use Mix.Project

  def project do
    [app: :ex338,
     version: "0.0.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Ex338, []},
     applications: [:cowboy, :logger, :gettext, :phoenix, :phoenix_pubsub,
                    :phoenix_html, :phoenix_ecto, :postgrex, :swoosh,
                    :phoenix_swoosh, :coherence]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:credo, "~> 0.4", only: [:dev, :test]},
     {:coherence, "~> 0.3.0"},
     {:cowboy, "~> 1.0"},
     {:csv, "~> 1.4.2"},
     {:ex_admin, github: "smpallen99/ex_admin"},
     {:ex_machina, "~> 1.0", only: :test},
     {:ecto, "~> 2.0.0"},
     {:gettext, "~> 0.11"},
     {:phoenix, "~> 1.2.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_swoosh, "~> 0.1.3"},
     {:postgrex, ">= 0.0.0"},
     {:swoosh, "~> 0.4.0"},
     {:wallaby, "~> 0.11.0"},
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
