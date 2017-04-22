defmodule Ex338.Championship.Store do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{Championship, Repo, InSeasonDraftPick}

  def all_for_lg_sport(fantasy_league_id) do
    Championship
    |> Championship.by_league_sport(fantasy_league_id)
    |> Championship.preload_assocs
    |> Championship.earliest_first
    |> Repo.all
  end

  def get_championship_by_league(id, league_id) do
    Championship
    |> Championship.preload_assocs_by_league(league_id)
    |> Repo.get!(id)
    |> update_next_in_season_pick
    |> preload_events_by_league(league_id)
    |> get_slot_standings(league_id)
  end

  def preload_events_by_league(championship, league_id) do
    events =
      Championship
      |> Championship.preload_assocs_by_league(league_id)
      |> Championship.earliest_first

    Repo.preload(championship, events: events)
  end

  def get_slot_standings(%{events: []} = championship, _) do
    championship
  end

  def get_slot_standings(championship, league_id) do
    slots =
      Championship
      |> Championship.sum_slot_points(championship.id, league_id)
      |> Repo.all
      |> rank_slots

    Map.put(championship, :slot_standings, slots)
  end

  defp rank_slots(slots) do
    slots
    |> remove_nonscoring_slots
    |> sort_by_points
    |> add_rank_to_slots
  end

  defp remove_nonscoring_slots(slots) do
    Enum.reject(slots, &(is_nil(&1.points)))
  end

  defp sort_by_points(slots) do
    Enum.sort(slots, &(&1.points >= &2.points))
  end

  defp add_rank_to_slots(slots) do
    {ranked_slots, _} = Enum.map_reduce slots, 1, &add_rank/2

    ranked_slots
  end

  defp add_rank(%{points: points} = slot, acc) when points >= 0 do
     {Map.put(slot, :rank, acc), acc + 1}
  end

  defp add_rank(slot, acc) do
     {Map.put(slot, :rank, "-"), acc + 1}
  end

  def update_next_in_season_pick(
    %{in_season_draft_picks: picks} = championship) do

    updated_picks = InSeasonDraftPick.update_next_pick(picks)

    %{championship | in_season_draft_picks: updated_picks}
  end
end
