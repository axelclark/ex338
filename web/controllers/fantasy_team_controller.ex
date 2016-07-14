defmodule Ex338.FantasyTeamController do
  use Ex338.Web, :controller

  alias Ex338.FantasyTeam

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_teams = FantasyTeam
                    |> FantasyTeam.by_league(league_id)
                    |> Repo.all

    render(conn, "index.html", fantasy_teams: fantasy_teams)
  end
end
