defmodule Ex338Web.Api.V1.WaiverController do
  use Ex338Web, :controller

  alias Ex338.Waivers

  def index(conn, %{"fantasy_league_id" => league_id}) do
    waivers = Waivers.get_all_waivers(league_id)
    render(conn, :index, waivers: waivers)
  end
end
