defmodule Ex338.DraftPickEmailController do
  use Ex338.Web, :controller

  alias Ex338.{DraftPick, NotificationEmail, Mailer}

  def show(conn, %{"id" => id}) do
    draft_pick =
      DraftPick
      |> preload([:fantasy_league, :fantasy_team,
                 [fantasy_player: :sports_league]])
      |> Repo.get!(id)

    draft_pick
      |> NotificationEmail.draft_update
      |> Mailer.deliver
      |> case do
        {:ok, _result} ->
          conn
          |> put_flash(:info, "Email sent successfully")
          |> redirect(to: fantasy_league_draft_pick_path(conn, :index, draft_pick.fantasy_league_id))
        {:error, _reason} ->
          conn
          |> put_flash(:error, "There was an error while sending the email")
          |> redirect(to: fantasy_league_draft_pick_path(conn, :index, draft_pick.fantasy_league_id))
      end
  end
end
