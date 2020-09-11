defmodule Ex338Web.InjuredReserveController do
  use Ex338Web, :controller
  require Logger
  import Canary.Plugs

  alias Ex338.{FantasyLeagues, FantasyTeams, FantasyPlayers, InjuredReserves}
  alias Ex338Web.{Authorization}

  plug(
    :load_and_authorize_resource,
    model: FantasyTeams.FantasyTeam,
    only: [:create, :new],
    preload: [:owners, :fantasy_league],
    persisted: true,
    id_name: "fantasy_team_id",
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(
      conn,
      "index.html",
      fantasy_league: FantasyLeagues.get(league_id),
      injured_reserves: InjuredReserves.list_irs_for_league(league_id)
    )
  end

  def new(conn, %{"fantasy_team_id" => _id}) do
    team = conn.assigns.fantasy_team

    render(
      conn,
      "new.html",
      changeset: InjuredReserves.change_injured_reserve(%InjuredReserves.InjuredReserve{}),
      fantasy_team: team,
      fantasy_league: team.fantasy_league,
      owned_players: FantasyTeams.find_owned_players(team.id),
      avail_players: FantasyPlayers.available_players(team.fantasy_league_id)
    )
  end

  def update(conn, %{
        "fantasy_league_id" => league_id,
        "id" => id,
        "injured_reserve" => params
      }) do
    injured_reserve = InjuredReserves.get_ir!(id)

    case InjuredReserves.update_injured_reserve(injured_reserve, params) do
      {:ok, %{injured_reserve: _ir}} ->
        conn
        |> put_flash(:info, "IR successfully processed")
        |> redirect(to: Routes.fantasy_league_injured_reserve_path(conn, :index, league_id))

      {:error, _action, error, _} ->
        conn
        |> put_flash(:error, parse_errors(error))
        |> redirect(to: Routes.fantasy_league_injured_reserve_path(conn, :index, league_id))
    end
  end

  # Helpers

  defp parse_errors(error) when is_binary(error), do: error

  defp parse_errors(changeset) do
    Enum.reduce(changeset.errors, "", fn {_field, {error, _details}}, message ->
      error <> " " <> message
    end)
  end
end
