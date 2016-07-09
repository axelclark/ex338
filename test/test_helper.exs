{:ok, _} = Application.ensure_all_started(:wallaby)

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Ex338.Repo, :manual)

Application.put_env(:wallaby, :base_url, Ex338.Endpoint.url)

