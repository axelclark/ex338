defmodule Ex338.WaiverController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, FantasyTeam, FantasyPlayer, Waiver}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)

    waivers =
      Waiver
      |> Waiver.by_league(league_id)
      |> preload([:fantasy_team, :add_fantasy_player, :drop_fantasy_player])
      |> Repo.all

    render(conn, "index.html", fantasy_league: fantasy_league,
                               waivers: waivers)
  end

  def new(conn, %{"fantasy_team_id" => team_id}) do
    fantasy_team = FantasyTeam |> Repo.get(team_id)
    fantasy_league = FantasyLeague |> Repo.get(fantasy_team.fantasy_league_id)

    changeset =
      fantasy_team
      |> build_assoc(:waivers)
      |> Waiver.changeset


    owned_players = FantasyTeam.owned_players(team_id)
                    |> Repo.all

    avail_players = FantasyPlayer.available_players(fantasy_league.id)
                    |> Repo.all

    render(conn, "new.html", changeset: changeset,
                             fantasy_team: fantasy_team,
                             fantasy_league: fantasy_league,
                             owned_players: owned_players,
                             avail_players: avail_players
    )
  end

  def create(conn, %{"fantasy_team_id" => team_id, "waiver" => waiver_params}) do
    fantasy_team = FantasyTeam |> Repo.get(team_id)

    result = fantasy_team
             |> build_assoc(:waivers)
             |> Waiver.new_changeset(waiver_params)
             |> Repo.insert

    case result do
      {:ok, _waiver} ->
        conn
        |> put_flash(:info, "Waiver successfully submitted.")
        |> redirect(to: fantasy_team_path(conn, :show, team_id))
      {:error, changeset} ->
        fantasy_team = FantasyTeam
                        |> Repo.get(team_id)
        fantasy_league = FantasyLeague
                          |> Repo.get(fantasy_team.fantasy_league_id)
        owned_players = FantasyTeam.owned_players(team_id)
                        |> Repo.all

        avail_players = FantasyPlayer.available_players(fantasy_league.id)
                        |> Repo.all

        render(conn, "new.html",
          changeset: changeset,
          fantasy_team: fantasy_team,
          fantasy_league: fantasy_league,
          owned_players: owned_players,
          avail_players: avail_players
        )
    end
  end
end
