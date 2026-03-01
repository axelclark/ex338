defmodule Ex338Web.Api.V1.ChampionshipController do
  use Ex338Web, :controller

  alias Ex338.Championships

  def index(conn, %{"fantasy_league_id" => league_id}) do
    championships = Championships.all_for_league(league_id)
    render(conn, :index, championships: championships)
  end

  def show(conn, %{"fantasy_league_id" => league_id, "id" => id}) do
    championship = Championships.get_championship_by_league(id, league_id)
    render(conn, :show, championship: championship)
  end
end
