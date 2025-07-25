defmodule Ex338Web.DraftPickController do
  use Ex338Web, :controller

  import Canary.Plugs

  alias Ex338.AutoDraft
  alias Ex338.DraftPicks
  alias Ex338.DraftQueues
  alias Ex338.FantasyLeagues
  alias Ex338.FantasyPlayers
  alias Ex338Web.Authorization

  @autodraft_delay 1000 * 10

  plug(
    :load_and_authorize_resource,
    model: DraftPicks.DraftPick,
    only: [:edit, :update],
    preload: [fantasy_team: :owners],
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def edit(conn, %{"id" => _}) do
    draft_pick = %{fantasy_league_id: league_id} = conn.assigns.draft_pick
    fantasy_league = FantasyLeagues.get_fantasy_league!(league_id)

    if fantasy_league.draft_picks_locked? do
      conn
      |> put_flash(:error, "Draft picks are locked for this league.")
      |> redirect(to: ~p"/fantasy_leagues/#{league_id}/draft_picks")
    else
      render(
        conn,
        :edit,
        draft_pick: draft_pick,
        fantasy_league: fantasy_league,
        fantasy_players: FantasyPlayers.available_players(league_id),
        changeset: DraftPicks.DraftPick.owner_changeset(draft_pick)
      )
    end
  end

  def update(conn, %{"id" => _, "draft_pick" => params}) do
    draft_pick = %{fantasy_league_id: league_id} = conn.assigns.draft_pick
    fantasy_league = FantasyLeagues.get_fantasy_league!(league_id)

    if fantasy_league.draft_picks_locked? do
      conn
      |> put_flash(:error, "Draft picks are locked for this league.")
      |> redirect(to: ~p"/fantasy_leagues/#{league_id}/draft_picks")
    else
      case DraftPicks.draft_player(draft_pick, params) do
        {:ok, %{draft_pick: draft_pick}} ->
          Ex338Web.DraftPickNotifier.send_update(draft_pick)
          DraftQueues.reorder_for_league(league_id)
          Task.start(fn -> AutoDraft.make_picks_from_queues(draft_pick, [], @autodraft_delay) end)

          conn
          |> put_flash(:info, "Draft pick successfully submitted.")
          |> redirect(to: ~p"/fantasy_leagues/#{draft_pick.fantasy_league_id}/draft_picks")

        {:error, _, changeset, _} ->
          render(
            conn,
            :edit,
            draft_pick: draft_pick,
            fantasy_league: fantasy_league,
            fantasy_players: FantasyPlayers.available_players(league_id),
            changeset: changeset
          )
      end
    end
  end
end
