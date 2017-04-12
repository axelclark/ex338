defmodule Ex338.Championship.StoreTest do
  use Ex338.ModelCase
  alias Ex338.Championship.Store
  alias Ex338.{InSeasonDraftPick, Championship}

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

  describe "update_next_in_season_pick/1" do
    test "update in season draft picks with next pick " do
      completed_pick = %InSeasonDraftPick{position: 1, drafted_player_id: 1}
      next_pick = %InSeasonDraftPick{position: 2, drafted_player_id: nil}
      future_pick = %InSeasonDraftPick{position: 3, drafted_player_id: nil}
      picks = [completed_pick, next_pick, future_pick]

      championship =
        %Championship{in_season_draft: true, in_season_draft_picks: picks}

      result = Store.update_next_in_season_pick(championship)
      [complete, next, future] = result.in_season_draft_picks

      assert complete.next_pick == false
      assert next.next_pick == true
      assert future.next_pick == false
    end

    test "returns championship when no draft picks" do
      championship = %Championship{in_season_draft_picks: []}

      result = Store.update_next_in_season_pick(championship)

      assert result == championship
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
    test "return championship if it has no events" do
      league = insert(:fantasy_league)
      overall = insert(:championship)
      overall_without_events = Map.put(overall, :events, [])

      result =
        Store.get_slot_standings(overall_without_events, league.id)

      assert Map.has_key?(result, :slot_standings) == false
    end

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
      insert(:championship_result, championship: event1, points: -1,
        fantasy_player: player)
      insert(:championship_result, championship: event2, points: -1,
        fantasy_player: player)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)
      pos_b = insert(:roster_position, fantasy_team: team_b,
        fantasy_player: player_b)
      pos_c = insert(:roster_position, fantasy_team: team_b,
        fantasy_player: player_c)
      insert(:championship_slot, championship: event1,
        roster_position: pos_b, slot: 1)
      insert(:championship_slot, championship: event2,
        roster_position: pos_b, slot: 1)
      insert(:championship_slot, championship: event2,
        roster_position: pos_c, slot: 2)
      insert(:championship_result, championship: event1, points: 8,
        fantasy_player: player_b)
      insert(:championship_result, championship: event2, points: 8,
        fantasy_player: player_b)

      result =
        Store.get_slot_standings(overall, league.id)

      assert result.slot_standings ==
        [%{points: 16, rank: 1, slot: 1, team_name: team_b.team_name},
         %{points: -2, rank: "-", slot: 1, team_name: team.team_name}]
    end
  end
end
