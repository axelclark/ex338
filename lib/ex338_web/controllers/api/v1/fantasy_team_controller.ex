defmodule Ex338Web.Api.V1.FantasyTeamController do
  use Ex338Web, :controller

  alias Ex338.FantasyTeams
  alias Ex338.FantasyTeams.FantasyTeam

  action_fallback Ex338Web.Api.V1.FallbackController

  def show(conn, %{"id" => id}) do
    with %FantasyTeam{} = team <- FantasyTeams.find(id) do
      render(conn, :show, fantasy_team: team)
    end
  end
end
