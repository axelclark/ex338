defmodule Ex338.WaiverController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, Waiver}

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
end
