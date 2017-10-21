defmodule Ex338Web.DraftPickController do
  use Ex338Web, :controller
  require Logger

  alias Ex338.{FantasyLeague, DraftPick, FantasyPlayer, Owner, User}
  alias Ex338Web.{NotificationEmail, Mailer, Authorization}
  import Canary.Plugs

  plug :load_and_authorize_resource, model: DraftPick, only: [:edit, :update],
    preload: [fantasy_team: :owners],
    unauthorized_handler: {Authorization, :handle_unauthorized}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)

    draft_picks = DraftPick
                  |> FantasyLeague.by_league(league_id)
                  |> preload([:fantasy_league, [fantasy_team: :owners],
                             [fantasy_player: :sports_league]])
                  |> DraftPick.ordered_by_position
                  |> Repo.all

    render(conn, "index.html", fantasy_league: fantasy_league,
                               draft_picks: draft_picks)
  end

  def edit(conn, %{"id" => _}) do

    draft_pick = conn.assigns.draft_pick

    players =
      FantasyPlayer.Store.available_players(draft_pick.fantasy_league_id)

    changeset = DraftPick.owner_changeset(draft_pick)

    render(conn, "edit.html", draft_pick: draft_pick,
                              fantasy_players: players,
                              changeset: changeset)
  end

  def update(conn, %{"id" => _, "draft_pick" => params}) do

    draft_pick = conn.assigns.draft_pick

    result = draft_pick
             |> DraftPick.DraftAdmin.draft_player(params)
             |> Repo.transaction

    case result do
      {:ok,  %{draft_pick: draft_pick}} ->
        conn
        |> email_notification(draft_pick)
        |> put_flash(:info, "Draft pick successfully submitted.")
        |> redirect(to: fantasy_league_draft_pick_path(conn, :index,
                    draft_pick.fantasy_league_id))
      {:error, _, changeset, _} ->

        players =
          FantasyPlayer.Store.available_players(draft_pick.fantasy_league_id)

        render(conn, "edit.html", draft_pick: draft_pick,
                                  fantasy_players: players,
                                  changeset: changeset)
    end
  end

  defp email_notification(conn, %{fantasy_league_id: id}) do
    league = FantasyLeague |> Repo.get(id)
    emails = Owner |> Owner.email_recipients_for_league(id) |> Repo.all
    admin = User.admin_emails |> Repo.all
    last_picks = DraftPick |> DraftPick.last_picks(id) |> Repo.all
    next_picks = DraftPick |> DraftPick.next_picks(id) |> Repo.all

    NotificationEmail.draft_update(conn, league, last_picks, next_picks,
                                   emails, admin)
      |> Mailer.deliver
      |> case do
        {:ok, _result} ->
          Logger.info "Sent notification email"
          conn
        {:error, _reason} ->
          Logger.error "Error sending email"
          conn
      end
  end
end
