defmodule Ex338Web.Plugs.RequireApiLeagueAccess do
  @moduledoc """
  Protects API reads for private leagues while leaving public leagues public.

  Anonymous callers receive 401 for a private league. Authenticated users who
  do not own a team in the league receive 403; league members and admins pass.
  """

  import Phoenix.Controller
  import Plug.Conn

  alias Ex338.FantasyLeagues
  alias Ex338Web.Api.V1.ErrorJSON

  def init(options), do: options

  def call(conn, _opts) do
    league_id = conn.path_params["fantasy_league_id"] || conn.path_params["id"]

    with {:ok, id} <- cast_id(league_id),
         league when not is_nil(league) <- FantasyLeagues.get(id) do
      if FantasyLeagues.can_access_league?(league, conn.assigns[:current_user]) do
        assign(conn, :fantasy_league, league)
      else
        deny_access(conn)
      end
    else
      _ -> respond(conn, :not_found, "Not found")
    end
  end

  defp cast_id(id) when is_integer(id), do: {:ok, id}

  defp cast_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, ""} -> {:ok, int}
      _ -> :error
    end
  end

  defp cast_id(_id), do: :error

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
