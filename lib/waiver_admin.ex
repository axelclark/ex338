defmodule Ex338.WaiverAdmin do
  @moduledoc false

  alias Ecto.Multi
  alias Ex338.{Waiver, RosterPosition, FantasyTeam, Repo, FantasyLeague}

  def process_waiver(waiver, %{"status" => "successful"} = params) do

    Multi.new
    |> update_waiver_status(waiver, params)
    |> insert_new_position(waiver)
    |> drop_roster_position(waiver)
    |> update_league_waivers(waiver)
    |> update_team_waiver_position(waiver)
  end

  def process_waiver(waiver, params) do

    Multi.new
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
    position_params = Map.new
                      |> Map.put("fantasy_team_id", waiver.fantasy_team_id)
                      |> Map.put("fantasy_player_id", waiver.add_fantasy_player_id)

    changeset = RosterPosition.changeset(%RosterPosition{},position_params)

    Multi.insert(multi, :new_roster_position, changeset)
  end

  def drop_roster_position(multi, %Waiver{drop_fantasy_player_id: nil}) do
    multi
  end

  def drop_roster_position(multi, waiver) do
    Multi.update_all(multi, :delete_roster_position,
      RosterPosition.update_position_status(RosterPosition,
                                            waiver.fantasy_team_id,
                                            waiver.drop_fantasy_player_id,
                                            waiver.process_at,
                                            "dropped"), [])
  end

  def update_league_waivers(multi, %Waiver{add_fantasy_player_id: nil}) do
    multi
  end

  def update_league_waivers(multi, %Waiver{fantasy_team: fantasy_team}) do
    Multi.update_all(multi, :league_waiver_update,
      FantasyTeam.update_league_waiver_positions(FantasyTeam, fantasy_team), [])
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

  def set_datetime_to_process(
    %{"add_fantasy_player_id" => player_id} = params, team_id)
    when player_id != "" do

    datetime_to_process =
      get_existing_waiver_date(team_id, player_id) || three_days_from_now

    Map.put(params, "process_at", datetime_to_process)
  end

  def set_datetime_to_process(params, _team_id) do
    Map.put(params, "process_at", Ecto.DateTime.utc)
  end

  defp get_existing_waiver_date(fantasy_team_id, add_player_id) do
    league_id = Repo.get!(FantasyTeam, fantasy_team_id).fantasy_league_id

    waiver =
      Waiver
      |> Waiver.pending_waivers_for_player(add_player_id, league_id)
      |> Repo.one

    case waiver do
      nil    -> false
      waiver -> waiver.process_at
    end
  end

  defp three_days_from_now do
    three_days = (86_400 * 3)
    now = Ecto.DateTime.utc
          |> Ecto.DateTime.to_erl
          |> Calendar.DateTime.from_erl!("UTC")

    now
    |> Calendar.DateTime.add!(three_days)
    |> Calendar.DateTime.to_erl
    |> Ecto.DateTime.from_erl
  end
end
