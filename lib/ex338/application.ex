defmodule Ex338.Application do
  @moduledoc false

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # host = Application.get_env(:ex338, :pow_redis, host: "localhost")
    # name = [name: Ex338Web.PowRedisCache.name()]
    # pow_redix_opts = Keyword.merge(host, name)

    # IO.inspect(pow_redix_opts)

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Ex338.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Ex338Web.Endpoint, []),
      # Start your own worker by calling: Ex338.Worker.start_link(arg1, arg2)
      # worker(Ex338.Worker, [arg1, arg2, arg3]),
      {Redix, name: :redix}
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
