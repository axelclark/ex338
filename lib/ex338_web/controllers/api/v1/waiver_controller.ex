defmodule Ex338Web.Api.V1.WaiverController do
  use Ex338Web, :controller

  alias Ex338.FantasyTeams
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.Waivers

  action_fallback Ex338Web.Api.V1.FallbackController

  def index(conn, %{"fantasy_league_id" => league_id}) do
    waivers = Waivers.get_all_waivers(league_id)
    render(conn, :index, waivers: waivers)
  end

  def create(conn, %{"fantasy_team_id" => team_id, "waiver" => waiver_params}) do
    user = conn.assigns.current_user

    with %FantasyTeam{} = team <- FantasyTeams.get_team_with_owners(team_id),
         true <- Canada.Can.can?(user, :create, team) || {:error, :forbidden},
         {:ok, waiver} <- Waivers.create_waiver(team, waiver_params) do
      Ex338Web.WaiverNotifier.waiver_submitted(waiver)

      conn
      |> put_status(:created)
      |> render(:show, waiver: Waivers.find_waiver(waiver.id))
    end
  end
end
