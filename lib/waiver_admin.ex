defmodule Ex338.WaiverAdmin do
  alias Ecto.Multi
  import Ecto.Query
  alias Ex338.{Waiver, RosterPosition, FantasyTeam, Repo}

  def process_waiver(waiver, %{"status" => "successful"} = params) do

    Multi.new
    |> update_waiver_status(waiver, params)
    |> insert_new_position(waiver)
    |> drop_roster_position(waiver)
    |> update_league_waivers(waiver)
    |> update_team_waiver_position(waiver)
    |> Repo.transaction
  end

  def process_waiver(waiver, params) do

    Multi.new
    |> update_waiver_status(waiver, params)
    |> Repo.transaction
  end

  defp update_waiver_status(multi, waiver, params) do
    multi
    |> Multi.update(:waiver, Waiver.changeset(waiver, params))
  end

  defp insert_new_position(multi, %Waiver{add_fantasy_player_id: nil}) do
    multi
  end

  defp insert_new_position(multi, waiver) do
    position_params = Map.new
                      |> Map.put("fantasy_team_id", waiver.fantasy_team_id)
                      |> Map.put("fantasy_player_id", waiver.add_fantasy_player_id)

    changeset = RosterPosition.changeset(%RosterPosition{},position_params)

    Multi.insert(multi, :new_roster_position, changeset)
  end

  defp drop_roster_position(multi, %Waiver{drop_fantasy_player: nil}) do
    multi
  end

  defp drop_roster_position(multi, waiver) do
    dropped_position =
      RosterPosition
      |> Repo.get_by!(%{fantasy_team_id: waiver.fantasy_team_id,
                        fantasy_player_id: waiver.drop_fantasy_player.id})

    changeset = RosterPosition.changeset(
      dropped_position, %{status: "dropped", released_at: Ecto.DateTime.utc})

    multi
    |> Multi.update(:delete_roster_position, changeset)
  end

  defp update_league_waivers(multi, %Waiver{add_fantasy_player: nil}) do
    multi
  end

  defp update_league_waivers(multi, %Waiver{fantasy_team: fantasy_team}) do
    changeset = update_league_waiver_positions(fantasy_team)

    multi
    |> Multi.update_all(:league_waiver_update, changeset, [])
  end

  def update_league_waiver_positions(
    %FantasyTeam{waiver_position: position, fantasy_league_id: league_id}) do
     from f in FantasyTeam,
       where: f.waiver_position > ^position,
       where: f.fantasy_league_id == ^league_id,
       update: [inc: [waiver_position: -1]]
  end

  defp update_team_waiver_position(multi, %Waiver{add_fantasy_player: nil}) do
    multi
  end

  defp update_team_waiver_position(multi, %Waiver{fantasy_team: fantasy_team}) do
    team_count = league_teams_count(fantasy_team)
    changeset = Ecto.Changeset.change(fantasy_team, waiver_position: team_count)

    multi
    |> Multi.update(:team_waiver_update, changeset)
  end

  defp league_teams_count(%FantasyTeam{fantasy_league_id: league_id}) do
    query = from f in FantasyTeam, where: f.fantasy_league_id == ^league_id
    Repo.aggregate(query, :count, :id)
  end
end
