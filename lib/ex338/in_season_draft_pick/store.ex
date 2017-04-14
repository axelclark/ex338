defmodule Ex338.InSeasonDraftPick.Store do
  @moduledoc false

  import Ecto.Query, only: [limit: 2]

  alias Ex338.{InSeasonDraftPick, FantasyPlayer, Repo, Commish}

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
    draft_pick
    |> InSeasonDraftPick.Admin.update(params)
    |> Repo.transaction
  end

  def last_picks(fantasy_league_id, picks) do
    InSeasonDraftPick
    |> InSeasonDraftPick.reverse_order
    |> InSeasonDraftPick.preload_assocs_by_league(fantasy_league_id)
    |> InSeasonDraftPick.player_drafted
    |> limit(^picks)
    |> Repo.all
  end

  def next_picks(fantasy_league_id, picks) do
    InSeasonDraftPick
    |> InSeasonDraftPick.draft_order
    |> InSeasonDraftPick.preload_assocs_by_league(fantasy_league_id)
    |> InSeasonDraftPick.no_player_drafted
    |> limit(^picks)
    |> Repo.all
  end
end
