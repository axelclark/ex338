defmodule Ex338.DraftPicks do
  @moduledoc """
  The DraftPicks context.
  """

  import Ecto.Query, warn: false

  alias Ex338.Chats
  alias Ex338.DraftPicks
  alias Ex338.DraftPicks.DraftPick
  alias Ex338.DraftPicks.FuturePick
  alias Ex338.FantasyLeagues
  alias Ex338.Repo

  # future_pick

  def change_future_pick(%FuturePick{} = future_pick, attrs \\ %{}) do
    FuturePick.changeset(future_pick, attrs)
  end

  def create_future_pick(attrs \\ %{}) do
    %FuturePick{}
    |> FuturePick.changeset(attrs)
    |> Repo.insert()
  end

  def create_future_picks(teams, rounds) do
    for round <- 1..rounds, team <- teams do
      attrs = %{round: round, original_team_id: team.id, current_team_id: team.id}
      {:ok, pick} = create_future_pick(attrs)
      pick
    end
  end

  def list_future_picks_by_league(fantasy_league_id) do
    FuturePick
    |> FuturePick.by_league(fantasy_league_id)
    |> FuturePick.preload_assocs()
    |> FuturePick.sort_by_round_and_team()
    |> Repo.all()
  end

  def get_future_pick!(id), do: Repo.get!(FuturePick, id)

  def get_future_pick_by(clauses), do: Repo.get_by(FuturePick, clauses)

  def update_future_pick(%FuturePick{} = future_pick, attrs) do
    future_pick
    |> FuturePick.changeset(attrs)
    |> Repo.update()
  end

  # draft_pick

  def draft_player(draft_pick, params) do
    draft_pick
    |> DraftPicks.Admin.draft_player(params)
    |> Repo.transaction()
    |> broadcast_change([:draft_pick, :draft_player])
    |> tap(&maybe_create_chat_message/1)
  end

  def get_draft_pick!(id) do
    DraftPick
    |> DraftPick.preload_assocs()
    |> Repo.get!(id)
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

  def get_picks_available_with_skips(fantasy_league_id) do
    %{draft_picks: draft_picks} = get_picks_for_league(fantasy_league_id)

    DraftPick.picks_available_with_skips(draft_picks)
  end

  def get_picks_for_league(fantasy_league_id) do
    draft_picks =
      DraftPick
      |> DraftPick.by_league(fantasy_league_id)
      |> DraftPick.ordered_by_position()
      |> DraftPick.preload_assocs()
      |> Repo.all()
      |> DraftPick.add_pick_numbers()
      |> DraftPicks.Clock.update_seconds_on_the_clock()

    fantasy_teams = DraftPicks.Clock.calculate_team_data(draft_picks)

    updated_draft_picks =
      draft_picks
      |> DraftPicks.Clock.update_teams_in_picks(fantasy_teams)
      |> DraftPick.update_available_to_pick?()

    %{draft_picks: updated_draft_picks, fantasy_teams: fantasy_teams}
  end

  @topic "draft_pick"

  def subscribe do
    Phoenix.PubSub.subscribe(Ex338.PubSub, @topic)
  end

  ## Helpers

  ## draft_player

  defp broadcast_change({:ok, %{draft_pick: draft_pick}} = result, event) do
    draft_pick = get_draft_pick!(draft_pick.id)
    Phoenix.PubSub.broadcast(Ex338.PubSub, @topic, {@topic, event, draft_pick})

    result
  end

  defp broadcast_change(error, _), do: error

  defp maybe_create_chat_message({:ok, %{draft_pick: draft_pick}}) do
    fantasy_league_draft =
      FantasyLeagues.get_draft_with_chat_by_league(draft_pick.fantasy_league_id)

    # had to reload because otherwise the drafted player is nil and doesn't get preloaded
    if fantasy_league_draft do
      draft_pick =
        draft_pick
        |> Repo.reload!()
        |> Repo.preload([:fantasy_team, :fantasy_player])

      message_params = %{
        chat_id: fantasy_league_draft.chat_id,
        content:
          "#{draft_pick.fantasy_team.team_name} drafted #{draft_pick.fantasy_player.player_name} with pick ##{draft_pick.draft_position}"
      }

      Chats.create_message(message_params)
    end
  end

  defp maybe_create_chat_message(_result), do: nil
end
