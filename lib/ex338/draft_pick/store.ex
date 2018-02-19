defmodule Ex338.DraftPick.Store do
  @moduledoc false

  alias Ex338.{DraftPick, Repo}

  def draft_player(draft_pick, params) do
    draft_pick
    |> DraftPick.DraftAdmin.draft_player(params)
    |> Repo.transaction()
  end

  def get_last_picks(fantasy_league_id) do
    DraftPick
    |> DraftPick.last_picks(fantasy_league_id)
    |> Repo.all()
  end

  def get_next_picks(fantasy_league_id) do
    DraftPick
    |> DraftPick.next_picks(fantasy_league_id)
    |> Repo.all()
  end

  def get_picks_for_league(fantasy_league_id) do
    DraftPick
    |> DraftPick.by_league(fantasy_league_id)
    |> DraftPick.ordered_by_position()
    |> DraftPick.preload_assocs()
    |> Repo.all()
  end
end
