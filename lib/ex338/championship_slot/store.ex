defmodule Ex338.ChampionshipSlot.Store do
  @moduledoc false

  alias Ex338.{Championship, FantasyTeam, Repo, ChampionshipSlot.CreateSlot}

  def create_slots_for_league(championship_id, league_id) do
    championship_id = String.to_integer(championship_id)

    %{sports_league_id: sport_id} = Repo.get(Championship, championship_id)
    teams =
      FantasyTeam.Store.find_all_for_league_sport(league_id, sport_id)

    CreateSlot.create_slots_from_positions(teams, championship_id)
  end
end

