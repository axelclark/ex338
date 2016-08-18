defmodule Ex338.OwnerController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, Owner}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)

    owners =
      Owner
      |> Owner.by_league(league_id)
      |> preload([:fantasy_team, :user])
      |> Repo.all

    render(conn, "index.html", fantasy_league: fantasy_league,
                               owners: owners)
  end
end
