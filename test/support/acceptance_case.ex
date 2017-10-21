defmodule Ex338Web.AcceptanceCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias Ex338.Repo
      import Ecto
      import Ecto.{Changeset, Query}

      import Ex338.{Factory}
      import Ex338Web.{Router.Helpers}
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
