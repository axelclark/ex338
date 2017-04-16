defmodule Ex338.RosterPosition.StoreTest do
  use Ex338.ModelCase
  alias Ex338.{RosterPosition.Store}

  describe "positions_for_draft/2" do
    test "returns all positions for a championship in a league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: other_league)

      sport = insert(:sports_league)
      other_sport = insert(:sports_league)
      championship =
        insert(:championship, category: "overall", sports_league: sport)

      player_1 =
        insert(:fantasy_player, sports_league: sport, draft_pick: true)
      player_2 =
        insert(:fantasy_player, sports_league: other_sport, draft_pick: true)
      player_3 =
        insert(:fantasy_player, sports_league: sport, draft_pick: false)
      player_4 =
        insert(:fantasy_player, sports_league: sport, draft_pick: true)

      pos =
        insert(:roster_position, fantasy_player: player_1, fantasy_team: team_a,
          status: "active")
      insert(:roster_position, fantasy_player: player_1, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_2, fantasy_team: team_a)
      insert(:roster_position, fantasy_player: player_3, fantasy_team: team_a)
      insert(:roster_position, fantasy_player: player_4, fantasy_team: team_a,
        status: "traded")

      [result] = Store.positions_for_draft(league.id, championship.id)

      assert result.id == pos.id
      assert result.fantasy_player.player_name == player_1.player_name
    end
  end
end
