defmodule Ex338Web.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Ex338Web, :verified_routes

      # Import conveniences for testing with connections
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Ex338.Factory
      import Ex338Web.ConnCase
      import Phoenix.ConnTest
      import Plug.Conn

      alias Ex338.Repo
      alias Ex338Web.Router.Helpers, as: Routes
      alias Phoenix.Flash

      # The default endpoint for testing
      @endpoint Ex338Web.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ex338.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Ex338.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = Ex338.AccountsFixtures.user_fixture()

    conn =
      conn
      |> log_in_user(user)
      |> Plug.Conn.assign(:current_user, user)

    %{conn: conn, user: user}
  end

  @doc """
  Setup helper that registers and logs in admins.

      setup :register_and_log_in_admin

  It stores an updated connection and a registered user admin in the
  test context.
  """
  def register_and_log_in_admin(%{conn: conn}) do
    user = Ex338.AccountsFixtures.user_fixture(%{admin: true})

    conn =
      conn
      |> log_in_user(user)
      |> Plug.Conn.assign(:current_user, user)

    %{conn: conn, user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Ex338.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end
end
