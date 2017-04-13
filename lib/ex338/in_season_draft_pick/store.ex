defmodule Ex338.InSeasonDraftPick.Store do
  @moduledoc false

  alias Ex338.{InSeasonDraftPick, FantasyPlayer, Repo}
  alias Ecto.Multi

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

  def draft_player(draft_pick, params) do
    Multi.new
    |> Multi.update(:in_season_draft_pick,
       InSeasonDraftPick.owner_changeset(draft_pick, params))
    |> Repo.transaction
  end
end
