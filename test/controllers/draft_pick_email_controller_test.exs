defmodule Ex338.DraftPickEmailControllerTest do
  use Ex338.ConnCase

  describe "index/2" do
    test "send email with current draft status for league", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: league)
      player = insert(:fantasy_player)
      _last_pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team,
                                 fantasy_league: league, fantasy_player: player)
      _next_pick = insert(:draft_pick, draft_position: 1.02,
                                       fantasy_team: other_team,
                                       fantasy_league: league)

      conn = get conn, fantasy_league_draft_pick_email_path(conn, :index, league.id)

      assert html_response(conn, 302) =~ ~r/draft_picks/
    end
  end
end
