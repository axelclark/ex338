defmodule Ex338.InSeasonDraftPicks do
  @moduledoc false

  import Ecto.Query, only: [limit: 2]

  alias Ex338.Championships
  alias Ex338.FantasyPlayers
  alias Ex338.InSeasonDraftPicks
  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick
  alias Ex338.Repo
  alias Ex338.RosterPositions

  @topic "in_season_draft_pick"

  def available_players(%{
        championship: %{sports_league_id: sport_id},
        draft_pick_asset: %{fantasy_team: %{fantasy_league_id: league_id}}
      }) do
    FantasyPlayers.get_avail_players_for_sport(league_id, sport_id)
  end

  def available_picks(fantasy_league_id, championship) do
    fantasy_league_id
    |> all_picks_with_status(championship)
    |> Enum.filter(& &1.available_to_pick?)
  end

  def all_picks_with_status(fantasy_league_id, championship) do
    fantasy_league_id
    |> by_league_and_sport(championship.sports_league_id)
    |> InSeasonDraftPicks.Clock.update_in_season_draft_picks(championship)
  end

  def by_league_and_sport(fantasy_league_id, sports_league_id) do
    InSeasonDraftPick
    |> InSeasonDraftPick.draft_order()
    |> InSeasonDraftPick.preload_assocs_by_league(fantasy_league_id)
    |> InSeasonDraftPick.by_sport(sports_league_id)
    |> Repo.all()
  end

  def changeset(pick) do
    InSeasonDraftPick.changeset(pick)
  end

  def create_picks_for_league(league_id, champ_id) do
    schedule_autodraft(league_id, champ_id)

    league_id
    |> RosterPositions.positions_for_draft(champ_id)
    |> InSeasonDraftPicks.Admin.generate_picks(champ_id)
    |> Repo.transaction()
  end

  def draft_player(draft_pick, params) do
    draft_pick
    |> InSeasonDraftPicks.Admin.update(params)
    |> Repo.transaction()
    |> broadcast_change([:in_season_draft_pick, :draft_player])
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

  def schedule_autodraft(fantasy_league_id, championship_id) do
    championship = Championships.get_championship_by_league(championship_id, fantasy_league_id)
    scheduled_at = calculate_scheduled_at(championship)

    %{fantasy_league_id: fantasy_league_id, championship_id: championship_id}
    |> Ex338.Workers.InSeasonAutodraftWorker.new(scheduled_at: scheduled_at)
    |> Oban.insert()
  end

  def sort_by_drafted_at(picks) do
    Enum.sort(picks, fn pick, next_pick ->
      case DateTime.compare(pick.drafted_at, next_pick.drafted_at) do
        :lt -> true
        _ -> false
      end
    end)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Ex338.PubSub, @topic)
  end

  ## Helpers

  ## draft_player

  defp broadcast_change({:ok, %{update_pick: draft_pick}} = result, event) do
    Phoenix.PubSub.broadcast(Ex338.PubSub, @topic, {@topic, event, draft_pick})

    result
  end

  defp broadcast_change(error, _), do: error

  ## schedule_autodraft

  defp calculate_scheduled_at(championship) do
    %{draft_starts_at: draft_starts_at} = championship
    now = DateTime.utc_now()

    case DateTime.compare(draft_starts_at, now) do
      :gt -> draft_starts_at
      _ -> now
    end
  end
end
