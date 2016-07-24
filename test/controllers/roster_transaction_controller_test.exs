defmodule Ex338.RosterTransactionControllerTest do
  use Ex338.ConnCase

  describe "index/2" do
    test "lists all roster transactions in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player = insert(:fantasy_player)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      insert(:roster_transaction, category: "Waiver Claim") 
      insert(:transaction_line_item, fantasy_team: team, fantasy_player: player)
      insert(:roster_transaction, category: "Waiver Claim") 
      insert(:transaction_line_item, fantasy_team: other_team, 
                                     fantasy_player: player)

      conn = get conn, fantasy_league_roster_transaction_path(conn, :index,
                                                              league.id)

      assert html_response(conn, 200) =~ ~r/Transactions/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player.player_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end
end
