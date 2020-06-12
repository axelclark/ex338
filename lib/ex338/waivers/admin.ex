defmodule Ex338.Waivers.Admin do
  @moduledoc false

  alias Ecto.Multi
  alias Ex338.{Waivers.Waiver, RosterPositions.RosterPosition, FantasyTeam, Repo, FantasyLeague}

  def process_waiver(waiver, %{"status" => "successful"} = params) do
    Multi.new()
    |> update_waiver_status(waiver, params)
    |> insert_new_position(waiver)
    |> drop_roster_position(waiver)
    |> update_league_waivers(waiver)
    |> update_team_waiver_position(waiver)
  end

  def process_waiver(waiver, params) do
    Multi.new()
    |> update_waiver_status(waiver, params)
  end

  def update_waiver_status(multi, waiver, params) do
    multi
    |> Multi.update(:waiver, Waiver.changeset(waiver, params))
  end

  def insert_new_position(multi, %Waiver{add_fantasy_player_id: nil}) do
    multi
  end

  def insert_new_position(multi, waiver) do
    position_params =
      Map.new()
      |> Map.put("fantasy_team_id", waiver.fantasy_team_id)
      |> Map.put("fantasy_player_id", waiver.add_fantasy_player_id)
      |> Map.put("active_at", waiver.process_at)
      |> Map.put("acq_method", "waiver")

    changeset = RosterPosition.changeset(%RosterPosition{}, position_params)

    Multi.insert(multi, :new_roster_position, changeset)
  end

  def drop_roster_position(multi, %Waiver{drop_fantasy_player_id: nil}) do
    multi
  end

  def drop_roster_position(multi, waiver) do
    Multi.update_all(
      multi,
      :delete_roster_position,
      RosterPosition.update_position_status(
        RosterPosition,
        waiver.fantasy_team_id,
        waiver.drop_fantasy_player_id,
        waiver.process_at,
        "dropped"
      ),
      []
    )
  end

  def update_league_waivers(multi, %Waiver{add_fantasy_player_id: nil}) do
    multi
  end

  def update_league_waivers(multi, %Waiver{fantasy_team: fantasy_team}) do
    Multi.update_all(
      multi,
      :league_waiver_update,
      FantasyTeam.update_league_waiver_positions(FantasyTeam, fantasy_team),
      []
    )
  end

  def update_team_waiver_position(multi, %Waiver{add_fantasy_player_id: nil}) do
    multi
  end

  def update_team_waiver_position(multi, %Waiver{fantasy_team: fantasy_team}) do
    team_count = league_teams_count(fantasy_team)
    changeset = Ecto.Changeset.change(fantasy_team, waiver_position: team_count)

    multi
    |> Multi.update(:team_waiver_update, changeset)
  end

  defp league_teams_count(%FantasyTeam{fantasy_league_id: league_id}) do
    query = FantasyLeague.by_league(FantasyTeam, league_id)
    Repo.aggregate(query, :count, :id)
  end
end
