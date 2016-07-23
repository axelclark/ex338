defmodule Ex338.FantasyPlayerController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, FantasyTeam}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)

    fantasy_players = FantasyTeam
                      |> FantasyTeam.right_join_players_by_league(league_id)
                      |> Repo.all
                      |> Enum.group_by(fn %{league_name: league_name} -> league_name end)

    render(conn, "index.html", fantasy_league: fantasy_league,
                               fantasy_players: fantasy_players)
  end
end
