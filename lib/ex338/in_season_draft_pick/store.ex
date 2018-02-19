defmodule Ex338.InSeasonDraftPick.Store do
  @moduledoc false

  import Ecto.Query, only: [limit: 2]

  alias Ex338.{InSeasonDraftPick, FantasyPlayer, Repo, RosterPosition}

  def available_players(%{
        championship: %{sports_league_id: sport_id},
        draft_pick_asset: %{fantasy_team: %{fantasy_league_id: league_id}}
      }) do
    FantasyPlayer.Store.get_avail_players_for_champ(league_id, sport_id)
  end

  def changeset(pick) do
    InSeasonDraftPick.changeset(pick)
  end

  def create_picks_for_league(league_id, champ_id) do
    league_id
    |> RosterPosition.Store.positions_for_draft(champ_id)
    |> InSeasonDraftPick.Admin.generate_picks(champ_id)
    |> Repo.transaction()
  end

  def draft_player(draft_pick, params) do
    draft_pick
    |> InSeasonDraftPick.Admin.update(params)
    |> Repo.transaction()
  end

  def last_picks(fantasy_league_id, sports_league_id, picks) do
    InSeasonDraftPick
    |> InSeasonDraftPick.reverse_order()
    |> InSeasonDraftPick.preload_assocs_by_league(fantasy_league_id)
    |> InSeasonDraftPick.player_drafted()
    |> InSeasonDraftPick.by_sport(sports_league_id)
    |> limit(^picks)
    |> Repo.all()
  end

  def next_picks(fantasy_league_id, sports_league_id, picks) do
    InSeasonDraftPick
    |> InSeasonDraftPick.draft_order()
    |> InSeasonDraftPick.preload_assocs_by_league(fantasy_league_id)
    |> InSeasonDraftPick.no_player_drafted()
    |> InSeasonDraftPick.by_sport(sports_league_id)
    |> limit(^picks)
    |> Repo.all()
  end

  def pick_with_assocs(pick_id) do
    InSeasonDraftPick
    |> InSeasonDraftPick.preload_assocs()
    |> Repo.get(pick_id)
  end
end
