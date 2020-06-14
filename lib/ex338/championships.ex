defmodule Ex338.Championships do
  @moduledoc false

  alias Ex338.{
    Championships.Championship,
    Championships.CreateSlot,
    FantasyTeams,
    Repo,
    InSeasonDraftPicks.InSeasonDraftPick
  }

  def all_for_league(fantasy_league_id) do
    Championship
    |> Championship.all_for_league(fantasy_league_id)
    |> Championship.preload_assocs_by_league(fantasy_league_id)
    |> Championship.earliest_first()
    |> Repo.all()
    |> Enum.map(&Championship.add_deadline_statuses/1)
  end

  def create_slots_for_league(championship_id, league_id) do
    championship_id = String.to_integer(championship_id)

    %{sports_league_id: sport_id} = Repo.get(Championship, championship_id)
    teams = FantasyTeams.find_all_for_league_sport(league_id, sport_id)

    CreateSlot.create_slots_from_positions(teams, championship_id)
  end

  def get_championship_by_league(id, fantasy_league_id) do
    Championship
    |> Championship.preload_assocs_by_league(fantasy_league_id)
    |> Repo.get!(id)
    |> Championship.add_deadline_statuses()
    |> update_next_in_season_pick
    |> preload_events_by_league(fantasy_league_id)
    |> get_slot_standings(fantasy_league_id)
  end

  def preload_events_by_league(championship, league_id) do
    events =
      Championship
      |> Championship.preload_assocs_by_league(league_id)
      |> Championship.earliest_first()

    championship
    |> Repo.preload(events: events)
    |> filter_roster_positions()
  end

  def get_slot_standings(%{events: []} = championship, _) do
    championship
  end

  def get_slot_standings(championship, league_id) do
    slots =
      Championship
      |> Championship.sum_slot_points(championship.id, league_id)
      |> Repo.all()
      |> rank_slots

    Map.put(championship, :slot_standings, slots)
  end

  ## Helpers

  ## preload_events_by_league

  defp filter_roster_positions(%{events: []} = championship), do: championship

  defp filter_roster_positions(%{events: events} = championship) do
    events = do_filter_roster_positions(events)
    %{championship | events: events}
  end

  defp do_filter_roster_positions(events) do
    Enum.map(events, &update_championship_results/1)
  end

  defp update_championship_results(%{championship_results: []} = championship), do: championship

  defp update_championship_results(championship) do
    %{
      championship_at: championship_at,
      championship_results: results
    } = championship

    results = Enum.map(results, &update_result(&1, championship_at))

    put_in(championship.championship_results, results)
  end

  defp update_result(%{fantasy_player: %{roster_positions: positions}} = result, championship_at) do
    position =
      positions
      |> Enum.reject(&owned_after_championship?(&1, championship_at))
      |> Enum.reject(&released_before_championship?(&1, championship_at))

    put_in(result.fantasy_player.roster_positions, position)
  end

  defp owned_after_championship?(%{active_at: active_at}, championship_at) do
    DateTime.compare(active_at, championship_at) == :gt
  end

  defp released_before_championship?(%{released_at: nil}, _championship_at), do: false

  defp released_before_championship?(%{released_at: released_at}, championship_at) do
    DateTime.compare(championship_at, released_at) == :gt
  end

  ## get_slot_standings

  defp rank_slots(slots) do
    slots
    |> remove_nonscoring_slots
    |> sort_by_points
    |> add_rank_to_slots
  end

  defp remove_nonscoring_slots(slots) do
    Enum.reject(slots, &is_nil(&1.points))
  end

  defp sort_by_points(slots) do
    Enum.sort(slots, &(&1.points >= &2.points))
  end

  defp add_rank_to_slots(slots) do
    {ranked_slots, _} = Enum.map_reduce(slots, 1, &add_rank/2)

    ranked_slots
  end

  defp add_rank(%{points: points} = slot, acc) when points >= 0 do
    {Map.put(slot, :rank, acc), acc + 1}
  end

  defp add_rank(slot, acc) do
    {Map.put(slot, :rank, "-"), acc + 1}
  end

  def update_next_in_season_pick(%{in_season_draft_picks: picks} = championship) do
    updated_picks = InSeasonDraftPick.update_next_pick(picks)

    %{championship | in_season_draft_picks: updated_picks}
  end
end
