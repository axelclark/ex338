defmodule Ex338Web.DraftPickController do
  use Ex338Web, :controller

  import Canary.Plugs

  alias Ex338.{AutoDraft, DraftPick, DraftQueue, FantasyLeague, FantasyPlayer}
  alias Ex338Web.{Authorization, DraftEmail}

  @autodraft_delay 1000 * 10

  plug(
    :load_and_authorize_resource,
    model: DraftPick,
    only: [:edit, :update],
    preload: [fantasy_team: :owners],
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def index(conn, %{"fantasy_league_id" => league_id}) do
    %{draft_picks: picks, fantasy_teams: teams} = DraftPick.Store.get_picks_for_league(league_id)

    render(
      conn,
      "index.html",
      fantasy_league: FantasyLeague.Store.get(league_id),
      draft_picks: picks,
      fantasy_teams: teams
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
        DraftQueue.Store.reorder_for_league(league_id)
        Task.start(fn -> AutoDraft.make_picks_from_queues(draft_pick, [], @autodraft_delay) end)

        conn
        |> put_flash(:info, "Draft pick successfully submitted.")
        |> redirect(
          to: Routes.fantasy_league_draft_pick_path(conn, :index, draft_pick.fantasy_league_id)
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
end
