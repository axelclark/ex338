defmodule Ex338.Championship.StoreTest do
  use Ex338.ModelCase
  alias Ex338.Championship.Store

  describe "get all/1" do
    test "returns all championships" do
      insert_list(3, :championship)

      result = Store.get_all()

      assert Enum.count(result) == 3
    end
  end

  describe "get_championship_by_league/2" do
    test "returns a championship with assocs by league" do
      league = insert(:fantasy_league)
      championship = insert(:championship)

      result = Store.get_championship_by_league(championship.id, league.id)

      assert result.id == championship.id
    end
  end

  describe "preload_events_by_league/2" do
    test "preloads all events with assocs for a league" do
      league = insert(:fantasy_league)
      overall = insert(:championship)
      event = insert(:championship, overall: overall)

      %{events: [result]} =
        Store.preload_events_by_league(overall, league.id)

      assert result.id == event.id
    end
  end

  describe "get_slot_standings/2" do
    test "calculates points for each slot and team" do
      league = insert(:fantasy_league)
      overall = insert(:championship)
      event1 = insert(:championship, overall: overall)
      event2 = insert(:championship, overall: overall)

      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      pos = insert(:roster_position, fantasy_team: team,
        fantasy_player: player)
      insert(:championship_slot, championship: event1,
        roster_position: pos, slot: 1)
      insert(:championship_slot, championship: event2,
        roster_position: pos, slot: 1)
      insert(:championship_result, championship: event1, points: 5,
        fantasy_player: player)
      insert(:championship_result, championship: event2, points: 1,
        fantasy_player: player)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      pos_b = insert(:roster_position, fantasy_team: team_b,
        fantasy_player: player_b)
      insert(:championship_slot, championship: event1,
        roster_position: pos_b, slot: 1)
      insert(:championship_slot, championship: event2,
        roster_position: pos_b, slot: 1)
      insert(:championship_result, championship: event1, points: 8,
        fantasy_player: player_b)
      insert(:championship_result, championship: event2, points: 8,
        fantasy_player: player_b)

      result =
        Store.get_slot_standings(overall.id, league.id)

      assert result ==
        [%{points: 16, slot: 1, team_name: team_b.team_name},
         %{points: 6, slot: 1, team_name: team.team_name}]
    end
  end
end
