defmodule Ex338Web.DraftPickController do
  use Ex338Web, :controller
  require Logger

  alias Ex338.{AutoDraft, DraftPick, DraftQueue, FantasyLeague, FantasyPlayer}
  alias Ex338Web.{DraftEmail, Authorization}
  import Canary.Plugs

  plug(
    :load_and_authorize_resource,
    model: DraftPick,
    only: [:edit, :update],
    preload: [fantasy_team: :owners],
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(
      conn,
      "index.html",
      fantasy_league: FantasyLeague.Store.get(league_id),
      draft_picks: DraftPick.Store.get_picks_for_league(league_id)
    )
  end

  def edit(conn, %{"id" => _}) do
    draft_pick = %{fantasy_league_id: league_id} = conn.assigns.draft_pick

    render(
      conn,
      "edit.html",
      draft_pick: draft_pick,
      fantasy_players: FantasyPlayer.Store.available_players(league_id),
      changeset: DraftPick.owner_changeset(draft_pick)
    )
  end

  def update(conn, %{"id" => _, "draft_pick" => params}) do
    draft_pick = %{fantasy_league_id: league_id} = conn.assigns.draft_pick

    case DraftPick.Store.draft_player(draft_pick, params) do
      {:ok, %{draft_pick: draft_pick}} ->
        DraftEmail.send_update(draft_pick)
        autodraft_picks = AutoDraft.make_picks_from_queues(draft_pick)
        DraftQueue.Store.reorder_for_league(league_id)

        conn
        |> put_flash(:info, update_message(autodraft_picks))
        |> redirect(
          to: fantasy_league_draft_pick_path(conn, :index, draft_pick.fantasy_league_id)
        )

      {:error, _, changeset, _} ->
        render(
          conn,
          "edit.html",
          draft_pick: draft_pick,
          fantasy_players: FantasyPlayer.Store.available_players(league_id),
          changeset: changeset
        )
    end
  end

  defp update_message([]), do: "Draft pick successfully submitted."

  defp update_message(autodraft_picks) do
    "Draft pick successfully submitted. Drafted #{Enum.count(autodraft_picks)} pick(s) from queues."
  end
end
