defmodule Ex338Web.DraftPickEmailController do
  use Ex338Web, :controller

  alias Ex338.{FantasyLeague, DraftPick, NotificationEmail, Mailer, Owner, User}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    league = FantasyLeague |> Repo.get(league_id)

    recipients =
      Owner
      |> Owner.email_recipients_for_league(league_id)
      |> Repo.all

    last_picks =
      DraftPick
      |> DraftPick.last_picks(league_id)
      |> Repo.all

    next_picks =
      DraftPick
      |> DraftPick.next_picks(league_id)
      |> Repo.all

    admins = User.admin_emails |> Repo.all

    NotificationEmail.draft_update(conn, league, last_picks, next_picks,
                                   recipients, admins)
      |> Mailer.deliver
      |> case do
        {:ok, _result} ->
          conn
          |> put_flash(:info, "Email sent successfully")
          |> redirect(to: fantasy_league_draft_pick_path(conn, :index, league_id))
        {:error, _reason} ->
          conn
          |> put_flash(:error, "There was an error while sending the email")
          |> redirect(to: fantasy_league_draft_pick_path(conn, :index, league_id))
      end
  end
end
