defmodule Ex338.DraftPickController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, DraftPick, FantasyTeam}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)

    draft_picks = DraftPick
                    |> FantasyTeam.by_league(league_id)
                    |> preload([:fantasy_league, :fantasy_team, [fantasy_player: :sports_league]])
                    |> Repo.all

    render(conn, "index.html", fantasy_league: fantasy_league, 
                               draft_picks: draft_picks)
  end
end
