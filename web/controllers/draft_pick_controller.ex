defmodule Ex338.DraftPickController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, DraftPick, DraftPickAdmin, FantasyPlayer}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)

    draft_picks = DraftPick
                  |> FantasyLeague.by_league(league_id)
                  |> preload([:fantasy_league, :fantasy_team,
                             [fantasy_player: :sports_league]])
                  |> DraftPick.ordered_by_position
                  |> Repo.all

    render(conn, "index.html", fantasy_league: fantasy_league,
                               draft_picks: draft_picks)
  end

  def edit(conn, %{"id" => id}) do
    fantasy_players = FantasyPlayer
                      |> FantasyPlayer.alphabetical_by_league
                      |> FantasyPlayer.names_and_ids
                      |> Repo.all

    draft_pick = DraftPick
                 |> preload([:fantasy_team])
                 |> Repo.get!(id)
    changeset = DraftPick.changeset(draft_pick)
    render(conn, "edit.html", draft_pick: draft_pick,
                              fantasy_players: fantasy_players,
                              changeset: changeset)
  end

  def update(conn, %{"id" => id, "draft_pick" => params}) do
    draft_pick = DraftPick
                 |> preload([:fantasy_team])
                 |> Repo.get!(id)

    result = draft_pick
             |> DraftPickAdmin.draft_player(params)
             |> Repo.transaction

    case result do
      {:ok,  %{draft_pick: draft_pick}} ->
        conn
        |> put_flash(:info, "Draft pick successfully submitted.")
        |> redirect(to: fantasy_league_draft_pick_path(conn, :index,
                    draft_pick.fantasy_league_id))
      {:error, _, changeset, _} ->
        fantasy_players = FantasyPlayer
                          |> FantasyPlayer.alphabetical_by_league
                          |> FantasyPlayer.names_and_ids
                          |> Repo.all

        render(conn, "edit.html", draft_pick: draft_pick,
                                  fantasy_players: fantasy_players,
                                  changeset: changeset)
    end
  end
end
