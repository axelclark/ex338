defmodule Ex338Web.DraftQueueController do
  use Ex338Web, :controller

  alias Ex338.{FantasyTeam, FantasyPlayers, DraftQueue}
  alias Ex338Web.{Authorization}

  import Canary.Plugs

  plug(
    :load_and_authorize_resource,
    model: FantasyTeam,
    only: [:create, :new],
    preload: [:owners, :fantasy_league],
    persisted: true,
    id_name: "fantasy_team_id",
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def new(conn, %{"fantasy_team_id" => _id}) do
    team = %{fantasy_league: fantasy_league} = conn.assigns.fantasy_team

    available_players = get_available_players(fantasy_league)

    changeset = DraftQueue.changeset(%DraftQueue{})

    render(
      conn,
      "new.html",
      fantasy_league: team.fantasy_league,
      fantasy_team: team,
      available_players: available_players,
      changeset: changeset
    )
  end

  def create(conn, %{"fantasy_team_id" => team_id, "draft_queue" => params}) do
    updated_params = Map.put(params, "fantasy_team_id", team_id)

    case DraftQueue.Store.create_draft_queue(updated_params) do
      {:ok, _draft_queue} ->
        conn
        |> put_flash(:info, "Draft queue created successfully.")
        |> redirect(to: Routes.fantasy_team_path(conn, :show, team_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        team = %{fantasy_league: fantasy_league} = conn.assigns.fantasy_team
        players = get_available_players(fantasy_league)

        render(
          conn,
          "new.html",
          fantasy_team: team,
          available_players: players,
          changeset: changeset
        )
    end
  end

  ## Helpers

  ## Implementations

  defp get_available_players(%{id: id, sport_draft_id: nil}) do
    FantasyPlayers.available_players(id)
  end

  defp get_available_players(%{id: id, sport_draft_id: sport_id}) do
    FantasyPlayers.get_avail_players_for_sport(id, sport_id)
  end
end
