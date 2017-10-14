{:ok, _} = Application.ensure_all_started(:wallaby)
{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.configure(exclude: [pending: true])
ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Ex338.Repo, :manual)

Application.put_env(:wallaby, :base_url, Ex338Web.Endpoint.url)
