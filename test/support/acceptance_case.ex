defmodule Ex338.AcceptanceCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      import Ecto.Model
      import Ecto.Query, only: [from: 2]
      import Ex338.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ex338.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Ex338.Repo, {:shared, self()})
    end
    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Ex338.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
