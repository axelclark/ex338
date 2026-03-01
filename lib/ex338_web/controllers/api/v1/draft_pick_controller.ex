defmodule Ex338Web.Api.V1.DraftPickController do
  use Ex338Web, :controller

  alias Ex338.DraftPicks

  def index(conn, %{"fantasy_league_id" => league_id}) do
    %{draft_picks: draft_picks} = DraftPicks.get_picks_for_league(league_id)
    render(conn, :index, draft_picks: draft_picks)
  end
end
