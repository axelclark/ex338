defmodule Ex338.FantasyTeamController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyTeam, FantasyLeague}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)

    fantasy_teams = FantasyTeam
                    |> FantasyTeam.by_league(league_id)
                    |> preload(roster_positions: [fantasy_player: :sports_league])
                    |> Repo.all

    render(conn, "index.html", fantasy_league: fantasy_league, 
                               fantasy_teams: fantasy_teams)
  end
end
