defmodule Ex338.DraftPickEmailController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, DraftPick, NotificationEmail, Mailer, Owner}

  def show(conn, %{"id" => id}) do
    draft_pick =
      DraftPick
      |> preload([:fantasy_league, :fantasy_team,
                 [fantasy_player: :sports_league]])
      |> Repo.get!(id)

    draft_pick
      |> NotificationEmail.draft_pick_update
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

  def index(conn, %{"fantasy_league_id" => league_id}) do
    league = FantasyLeague |> Repo.get(league_id)

    recipients =
      Owner
      |> Owner.by_league(league_id)
      |> join(:inner, [o], u in assoc(o, :user))
      |> select([o,f,u], {u.name, u.email})
      |> Repo.all

    last_picks =
      DraftPick
      |> FantasyLeague.by_league(league_id)
      |> preload([:fantasy_league, :fantasy_team, [fantasy_player: :sports_league]])
      |> DraftPick.reverse_ordered_by_position
      |> where([d], not is_nil(d.fantasy_player_id))
      |> limit(5)
      |> Repo.all

    next_picks =
      DraftPick
      |> FantasyLeague.by_league(league_id)
      |> preload([:fantasy_league, :fantasy_team, [fantasy_player: :sports_league]])
      |> DraftPick.ordered_by_position
      |> where([d], is_nil(d.fantasy_player_id))
      |> limit(5)
      |> Repo.all

    NotificationEmail.draft_update(conn, league, last_picks, next_picks, recipients)
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
