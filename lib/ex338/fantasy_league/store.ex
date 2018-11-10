defmodule Ex338.FantasyLeague.Store do
  @moduledoc false

  alias Ex338.{FantasyLeague, FantasyTeam, Repo}

  def get(id) do
    Repo.get(FantasyLeague, id)
  end

  def get_archived_leagues() do
    Enum.map(list_archived_leagues(), &load_team_standings_data/1)
  end

  def list_archived_leagues() do
    FantasyLeague
    |> FantasyLeague.archived_leagues()
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
