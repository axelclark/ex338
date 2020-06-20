defmodule Ex338.FantasyLeagues do
  @moduledoc false

  alias Ex338.{
    DraftPicks,
    FantasyLeagues.FantasyLeague,
    FantasyLeagues.HistoricalRecord,
    FantasyLeagues.HistoricalWinning,
    FantasyTeams,
    Repo
  }

  def create_future_picks_for_league(league_id, draft_rounds) do
    league_id
    |> FantasyTeams.list_teams_for_league()
    |> DraftPicks.create_future_picks(draft_rounds)
  end

  def get(id) do
    Repo.get(FantasyLeague, id)
  end

  def get_leagues_by_status(status) do
    Enum.map(list_leagues_by_status(status), &load_team_standings_data/1)
  end

  def list_all_winnings() do
    HistoricalWinning
    |> HistoricalWinning.order_by_amount()
    |> Repo.all()
  end

  def list_current_all_time_records() do
    HistoricalRecord
    |> HistoricalRecord.all_time_records()
    |> HistoricalRecord.current_records()
    |> HistoricalRecord.sorted_by_order()
    |> Repo.all()
  end

  def list_current_season_records() do
    HistoricalRecord
    |> HistoricalRecord.season_records()
    |> HistoricalRecord.current_records()
    |> HistoricalRecord.sorted_by_order()
    |> Repo.all()
  end

  def list_leagues_by_status(status) do
    FantasyLeague
    |> FantasyLeague.leagues_by_status(status)
    |> FantasyLeague.sort_most_recent()
    |> FantasyLeague.sort_by_division()
    |> Repo.all()
  end

  def list_fantasy_leagues() do
    FantasyLeague
    |> FantasyLeague.sort_most_recent()
    |> FantasyLeague.sort_by_division()
    |> Repo.all()
  end

  def load_team_standings_data(league) do
    teams = FantasyTeams.find_all_for_standings(league)
    %{league | fantasy_teams: teams}
  end
end
