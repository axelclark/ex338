defmodule Ex338.DraftPick.Store do
  @moduledoc false

  alias Ex338.{DraftPick, Repo}

  @topic "draft_pick"

  def draft_player(draft_pick, params) do
    draft_pick
    |> DraftPick.DraftAdmin.draft_player(params)
    |> Repo.transaction()
    |> broadcast_change([:draft_pick, :draft_player])
  end

  def get_last_picks(fantasy_league_id, picks \\ 5) do
    DraftPick
    |> DraftPick.last_picks(fantasy_league_id, picks)
    |> Repo.all()
  end

  def get_next_picks(fantasy_league_id, picks \\ 5) do
    DraftPick
    |> DraftPick.next_picks(fantasy_league_id, picks)
    |> Repo.all()
  end

  def get_picks_for_league(fantasy_league_id) do
    draft_picks =
      DraftPick
      |> DraftPick.by_league(fantasy_league_id)
      |> DraftPick.ordered_by_position()
      |> DraftPick.preload_assocs()
      |> Repo.all()
      |> DraftPick.Clock.update_seconds_on_the_clock()

    fantasy_teams = DraftPick.Clock.calculate_team_data(draft_picks)

    updated_draft_picks = DraftPick.Clock.update_teams_in_picks(draft_picks, fantasy_teams)

    %{draft_picks: updated_draft_picks, fantasy_teams: fantasy_teams}
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Ex338.PubSub, @topic)
  end

  ## Helpers

  ## draft_player

  defp broadcast_change({:ok, %{draft_pick: draft_pick}} = result, event) do
    Phoenix.PubSub.broadcast(Ex338.PubSub, @topic, {@topic, event, draft_pick})

    result
  end

  defp broadcast_change(error, _), do: error
end
