defmodule Ex338Web.Plugs.RequireLeagueAccess do
  @moduledoc """
  Blocks access to a fantasy league's pages when the current user is not allowed
  to see it. Public leagues are open to everyone, admins see everything, and
  private leagues are limited to users who own a team in them.
  """
  use Phoenix.VerifiedRoutes, endpoint: Ex338Web.Endpoint, router: Ex338Web.Router

  import Phoenix.Controller
  import Plug.Conn

  alias Ex338.FantasyLeagues

  def init(options), do: options

  def call(conn, _opts) do
    league_id = conn.params["fantasy_league_id"]
    league = league_id && FantasyLeagues.get(league_id)

    if league && FantasyLeagues.can_access_league?(league, conn.assigns[:current_user]) do
      conn
    else
      conn
      |> put_flash(:error, "You don't have access to that league.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
