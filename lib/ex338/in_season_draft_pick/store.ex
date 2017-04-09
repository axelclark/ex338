defmodule Ex338.InSeasonDraftPick.Store do
  alias Ex338.{InSeasonDraftPick, FantasyPlayer, Repo}

  def pick_with_assocs(pick_id) do
    InSeasonDraftPick
    |> InSeasonDraftPick.preload_assocs
    |> Repo.get(pick_id)
  end

  def changeset(pick) do
    InSeasonDraftPick.changeset(pick)
  end

  def available_players(%{championship: %{sports_league_id: sport_id},
    draft_pick_asset: %{fantasy_team: %{fantasy_league_id: league_id}}}) do

    FantasyPlayer.get_avail_players_for_champ(league_id, sport_id)
  end
end
