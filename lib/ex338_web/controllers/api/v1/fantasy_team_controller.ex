defmodule Ex338Web.Api.V1.FantasyTeamController do
  use Ex338Web, :controller

  alias Ex338.FantasyTeams

  action_fallback Ex338Web.Api.V1.FallbackController

  def show(conn, %{"id" => id}) do
    if FantasyTeams.exists?(id) do
      team = FantasyTeams.find(id)
      render(conn, :show, fantasy_team: team)
    else
      {:error, :not_found}
    end
  end
end
