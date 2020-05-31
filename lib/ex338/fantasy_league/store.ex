defmodule Ex338.FantasyLeague.Store do
  @moduledoc false

  alias Ex338.{DraftPicks, FantasyLeague, FantasyTeam, Repo}

  def create_future_picks_for_league(league_id, draft_rounds) do
    league_id
    |> FantasyTeam.Store.list_teams_for_league()
    |> DraftPicks.create_future_picks(draft_rounds)
  end

  def get(id) do
    Repo.get(FantasyLeague, id)
  end

  def get_leagues_by_status(status) do
    Enum.map(list_leagues_by_status(status), &load_team_standings_data/1)
  end

  def list_leagues_by_status(status) do
    FantasyLeague
    |> FantasyLeague.leagues_by_status(status)
    |> FantasyLeague.sort_most_recent()
    |> FantasyLeague.sort_by_division()
    |> Repo.all()
  end

  def list_fantasy_leagues() do
    Repo.all(FantasyLeague)
  end

  def load_team_standings_data(league) do
    teams = FantasyTeam.Store.find_all_for_standings(league)
    %{league | fantasy_teams: teams}
  end
end
