defmodule Ex338Web.Plugs.RequireApiTeamAccess do
  @moduledoc """
  Protects API team reads according to the team's fantasy league visibility.
  """

  import Phoenix.Controller
  import Plug.Conn

  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeams
  alias Ex338Web.Api.V1.ErrorJSON

  def init(options), do: options

  def call(conn, _opts) do
    case FantasyTeams.get_team_with_owners(conn.path_params["id"]) do
      nil ->
        respond(conn, :not_found, "Not found")

      team ->
        if FantasyLeagues.can_access_league?(team.fantasy_league, conn.assigns[:current_user]) do
          assign(conn, :fantasy_team, team)
        else
          deny_access(conn)
        end
    end
  end

  defp deny_access(%{assigns: %{current_user: _user}} = conn) do
    respond(conn, :forbidden, "You are not authorized to view this private league")
  end

  defp deny_access(conn) do
    respond(conn, :unauthorized, "An API token is required to view this private league")
  end

  defp respond(conn, status, message) do
    conn
    |> put_status(status)
    |> put_view(json: ErrorJSON)
    |> render(:error, message: message)
    |> halt()
  end
end
