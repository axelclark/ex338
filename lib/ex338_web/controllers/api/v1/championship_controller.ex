defmodule Ex338Web.Api.V1.ChampionshipController do
  use Ex338Web, :controller

  alias Ex338.Championships
  alias Ex338.Championships.Championship

  action_fallback Ex338Web.Api.V1.FallbackController

  def index(conn, %{"fantasy_league_id" => league_id}) do
    championships = Championships.all_for_league(league_id)
    render(conn, :index, championships: championships)
  end

  def show(conn, %{"fantasy_league_id" => league_id, "id" => id}) do
    with %Championship{} = championship <- Championships.get_championship_by_league(id, league_id) do
      render(conn, :show, championship: championship)
    end
  end
end
