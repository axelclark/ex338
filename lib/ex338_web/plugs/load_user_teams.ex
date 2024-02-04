defmodule Ex338Web.LoadUserTeams do
  @moduledoc """
  Preloads all fantasy teams into conn assigns current user
  """

  import Plug.Conn

  alias Ex338.Accounts

  def init(options) do
    # initialize options

    options
  end

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      nil ->
        conn

      current_user ->
        user = Accounts.load_user_teams(current_user)
        assign(conn, :current_user, user)
    end
  end
end
