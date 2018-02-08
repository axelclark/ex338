defmodule Ex338Web.DraftPickController do
  use Ex338Web, :controller
  require Logger

  alias Ex338.{FantasyLeague, DraftPick, FantasyPlayer, User}
  alias Ex338Web.{NotificationEmail, Mailer, Authorization}
  import Canary.Plugs

  plug :load_and_authorize_resource, model: DraftPick, only: [:edit, :update],
    preload: [fantasy_team: :owners],
    unauthorized_handler: {Authorization, :handle_unauthorized}

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
      {:ok,  %{draft_pick: draft_pick}} ->
        email_notification(conn, draft_pick)

        conn
        |> put_flash(:info, "Draft pick successfully submitted.")
        |> redirect(to: fantasy_league_draft_pick_path(conn, :index,
                    draft_pick.fantasy_league_id))

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

  defp email_notification(conn, %{fantasy_league_id: league_id}) do
    league = FantasyLeague.Store.get(league_id)
    recipients = User.Store.get_league_and_admin_emails(league_id)
    last_picks = DraftPick.Store.get_last_picks(league_id)
    next_picks = DraftPick.Store.get_next_picks(league_id)

    conn
    |> NotificationEmail.draft_update(league, last_picks, next_picks, recipients)
    |> Mailer.deliver
    |> Mailer.handle_delivery
  end
end
