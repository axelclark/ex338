defmodule Ex338Web.Api.V1.FantasyLeagueController do
  use Ex338Web, :controller

  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeams

  action_fallback Ex338Web.Api.V1.FallbackController

  def index(conn, _params) do
    fantasy_leagues =
      "primary"
      |> FantasyLeagues.list_leagues_by_status()
      |> FantasyLeagues.filter_visible_leagues(conn.assigns[:current_user])

    render(conn, :index, fantasy_leagues: fantasy_leagues)
  end

  def show(conn, %{"id" => id}) do
    league = FantasyLeagues.get(id)

    with %{} <- league do
      standings = FantasyTeams.find_all_for_standings(league)
      render(conn, :show, fantasy_league: league, standings: standings)
    end
  end
end
