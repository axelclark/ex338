defmodule Ex338Web.Api.V1.WaiverController do
  use Ex338Web, :controller

  alias Ex338.Waivers
  alias Ex338Web.ApiActions

  action_fallback Ex338Web.Api.V1.FallbackController

  def index(conn, %{"fantasy_league_id" => league_id}) do
    waivers = Waivers.get_all_waivers(league_id)
    render(conn, :index, waivers: waivers)
  end

  def create(conn, %{"fantasy_team_id" => team_id, "waiver" => waiver_params}) do
    actor = %{user: conn.assigns.current_user, api_token: conn.assigns[:current_api_token]}

    with {:ok, waiver} <- ApiActions.create_waiver(actor, "api", team_id, waiver_params) do
      conn
      |> put_status(:created)
      |> render(:show, waiver: waiver)
    end
  end
end
