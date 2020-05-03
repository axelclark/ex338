defmodule Ex338.Application do
  @moduledoc false

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    redix_uri =
      :ex338
      |> Application.get_env(:pow_redis, uri: "redis://localhost:6379")
      |> Keyword.fetch!(:uri)

    pow_redix_opts = [name: Ex338Web.Pow.RedisCache.name()]

    pubsub_options =
      case Mix.env() do
        :test ->
          [name: Ex338.PubSub]

        _ ->
          [
            name: Ex338.PubSub,
            adapter: Phoenix.PubSub.Redis,
            url: System.get_env("REDIS_URL") || "redis://localhost:6379",
            node_name: System.get_env("NODE") || "name"
          ]
      end

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Ex338.Repo, []),
      {Phoenix.PubSub, pubsub_options},
      # Start the endpoint when the application starts
      supervisor(Ex338Web.Endpoint, []),
      # Start your own worker by calling: Ex338.Worker.start_link(arg1, arg2)
      # worker(Ex338.Worker, [arg1, arg2, arg3]),
      worker(Redix, [redix_uri, pow_redix_opts])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ex338.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Ex338Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
