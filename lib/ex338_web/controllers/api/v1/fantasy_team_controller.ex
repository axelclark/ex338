defmodule Ex338Web.Api.V1.FantasyTeamController do
  use Ex338Web, :controller

  alias Ex338.FantasyTeams

  action_fallback Ex338Web.Api.V1.FallbackController

  def show(conn, %{"id" => id}) do
    team = FantasyTeams.find(id)

    with %{} <- team do
      render(conn, :show, fantasy_team: team)
    end
  end
end
