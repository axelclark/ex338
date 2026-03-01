defmodule Ex338Web.Api.V1.InjuredReserveController do
  use Ex338Web, :controller

  alias Ex338.InjuredReserves

  def index(conn, %{"fantasy_league_id" => league_id}) do
    injured_reserves = InjuredReserves.list_irs_for_league(league_id)
    render(conn, :index, injured_reserves: injured_reserves)
  end
end
