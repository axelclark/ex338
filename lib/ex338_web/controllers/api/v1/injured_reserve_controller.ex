defmodule Ex338Web.Api.V1.InjuredReserveController do
  use Ex338Web, :controller

  alias Ex338.InjuredReserves
  alias Ex338Web.ApiActions

  action_fallback Ex338Web.Api.V1.FallbackController

  def index(conn, %{"fantasy_league_id" => league_id}) do
    injured_reserves = InjuredReserves.list_irs_for_league(league_id)
    render(conn, :index, injured_reserves: injured_reserves)
  end

  def create(conn, %{"fantasy_team_id" => team_id, "injured_reserve" => params}) do
    actor = %{user: conn.assigns.current_user, api_token: conn.assigns[:current_api_token]}

    with {:ok, injured_reserve} <-
           ApiActions.create_injured_reserve(actor, "api", team_id, params) do
      conn
      |> put_status(:created)
      |> render(:show, injured_reserve: injured_reserve)
    end
  end
end
