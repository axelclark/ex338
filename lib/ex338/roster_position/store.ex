defmodule Ex338.RosterPosition.Store do
  @moduledoc false

  alias Ex338.{RosterPosition, Repo}

  def positions_for_draft(fantasy_league_id, championship_id) do
    RosterPosition
    |> RosterPosition.all_active
    |> RosterPosition.all_draft_picks
    |> RosterPosition.from_league(fantasy_league_id)
    |> RosterPosition.sport_from_champ(championship_id)
    |> RosterPosition.preload_assocs
    |> Repo.all
  end
end
