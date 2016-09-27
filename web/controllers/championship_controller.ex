defmodule Ex338.ChampionshipController do
  use Ex338.Web, :controller
  alias Ex338.{Championship, Repo, FantasyLeague}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    championships = Championship
                    |> preload(:sports_league)
                    |> Championship.earliest_first
                    |> Repo.all

    fantasy_league = FantasyLeague |> Repo.get(league_id)

    render(conn, "index.html", championships: championships,
                               fantasy_league: fantasy_league)
  end
end
