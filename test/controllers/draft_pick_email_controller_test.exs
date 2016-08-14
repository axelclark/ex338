defmodule Ex338.DraftPickEmailControllerTest do
  use Ex338.ConnCase

  import Swoosh.TestAssertions

  describe "create/2" do
    test "send email with draft information update", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      player = insert(:fantasy_player)
      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team,
                                 fantasy_league: league, fantasy_player: player)

      conn = get conn, draft_pick_email_path(conn, :show, pick.id)

      assert_email_sent Ex338.NotificationEmail.draft_update(pick)
    end
  end
end
