defmodule Ex338Web.OwnerController do
  use Ex338Web, :controller

  alias Ex338.FantasyLeagues.FantasyLeague
  alias Ex338.FantasyTeams.Owner

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = Repo.get(FantasyLeague, league_id)

    owners =
      Owner
      |> Owner.by_league(league_id)
      |> preload([:fantasy_team, :user])
      |> Repo.all()

    render(
      conn,
      :index,
      fantasy_league: fantasy_league,
      owners: owners
    )
  end
end
