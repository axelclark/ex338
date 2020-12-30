defmodule Ex338.ChampionshipsTest do
  use Ex338.DataCase, async: true

  alias Ex338.{
    CalendarAssistant,
    Championships,
    Championships.ChampionshipSlot,
    Championships.Championship,
    InSeasonDraftPicks.InSeasonDraftPick
  }

  describe "all_for_league/1" do
    test "returns all championships by league and year" do
      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)

      _champ_a = insert(:championship, sports_league: sport_a)
      _champ_b = insert(:championship, sports_league: sport_b)

      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)

      insert(:league_sport, fantasy_league: league_a, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league_b, sports_league: sport_b)

      result = Championships.all_for_league(league_a.id)

      assert Enum.count(result) == 1
    end
  end

  describe "create_slots_for_league/2" do
    test "admin creates roster slots for a championship" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      other_sport = insert(:sports_league)
      championship = insert(:championship, category: "event", sports_league: sport)
      _other_championship = insert(:championship, category: "event", sports_league: other_sport)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)
      player_c = insert(:fantasy_player, sports_league: sport)
      other_player = insert(:fantasy_player, sports_league: other_sport)
      team = insert(:fantasy_team, fantasy_league: league)

      primary =
        insert(
          :roster_position,
          fantasy_player: player_a,
          fantasy_team: team,
          status: "active",
          position: "CBB"
        )

      flex =
        insert(
          :roster_position,
          fantasy_player: player_b,
          fantasy_team: team,
          status: "active",
          position: "Flex1"
        )

      insert(:roster_position, fantasy_player: player_c, fantasy_team: team, status: "traded")
      insert(:roster_position, fantasy_player: other_player, fantasy_team: team, status: "active")

      Championships.create_slots_for_league(Integer.to_string(championship.id), league.id)
      results = Repo.all(ChampionshipSlot)

      assert Enum.map(results, & &1.roster_position_id) == [primary.id, flex.id]
    end
  end

  describe "get_championship_by_league/2" do
    test "returns a championship with assocs by league" do
      league = insert(:fantasy_league)
      championship = insert(:championship)

      result = Championships.get_championship_by_league(championship.id, league.id)

      assert result.id == championship.id
    end

    test "preloads all events with roster positions with assocs for a league" do
      league = insert(:fantasy_league)
      overall = insert(:championship)

      event =
        insert(:championship,
          overall: overall,
          championship_at: CalendarAssistant.days_from_now(-30)
        )

      event_b =
        insert(:championship,
          overall: overall,
          championship_at: CalendarAssistant.days_from_now(-2)
        )

      team = insert(:fantasy_team, fantasy_league: league, team_name: "A")
      team_b = insert(:fantasy_team, fantasy_league: league, team_name: "B")
      team_c = insert(:fantasy_team, fantasy_league: league, team_name: "C")
      player = insert(:fantasy_player)

      insert(:championship_result, championship: event, rank: 1, points: 8, fantasy_player: player)

      insert(:championship_result,
        championship: event_b,
        rank: 1,
        points: 8,
        fantasy_player: player
      )

      pos =
        insert(
          :roster_position,
          fantasy_team: team,
          fantasy_player: player,
          active_at: CalendarAssistant.days_from_now(-60),
          released_at: CalendarAssistant.days_from_now(-15),
          status: "dropped"
        )

      _pos_b =
        insert(
          :roster_position,
          fantasy_team: team_b,
          fantasy_player: player,
          active_at: CalendarAssistant.days_from_now(-10),
          released_at: CalendarAssistant.days_from_now(-1),
          status: "dropped"
        )

      _pos_c =
        insert(
          :roster_position,
          fantasy_team: team_c,
          fantasy_player: player,
          active_at: CalendarAssistant.days_from_now(0),
          released_at: nil,
          status: "active"
        )

      result = Championships.get_championship_by_league(event.id, league.id)

      assert result.id == event.id

      %{championship_results: [%{fantasy_player: %{roster_positions: [position]}}]} = result

      assert position.id == pos.id
    end

    test "preloads roster position with assocs for a league" do
      league = insert(:fantasy_league)
      overall = insert(:championship)

      event =
        insert(:championship,
          overall: overall,
          championship_at: CalendarAssistant.days_from_now(-30)
        )

      event_b =
        insert(:championship,
          overall: overall,
          championship_at: CalendarAssistant.days_from_now(-2)
        )

      team = insert(:fantasy_team, fantasy_league: league, team_name: "A")
      team_b = insert(:fantasy_team, fantasy_league: league, team_name: "B")
      team_c = insert(:fantasy_team, fantasy_league: league, team_name: "C")
      player = insert(:fantasy_player)

      insert(:championship_result, championship: event, rank: 1, points: 8, fantasy_player: player)

      insert(:championship_result,
        championship: event_b,
        rank: 1,
        points: 8,
        fantasy_player: player
      )

      pos =
        insert(
          :roster_position,
          fantasy_team: team,
          fantasy_player: player,
          active_at: CalendarAssistant.days_from_now(-60),
          released_at: CalendarAssistant.days_from_now(-15),
          status: "dropped"
        )

      _pos_b =
        insert(
          :roster_position,
          fantasy_team: team_b,
          fantasy_player: player,
          active_at: CalendarAssistant.days_from_now(-10),
          released_at: CalendarAssistant.days_from_now(-1),
          status: "dropped"
        )

      _pos_c =
        insert(
          :roster_position,
          fantasy_team: team_c,
          fantasy_player: player,
          active_at: CalendarAssistant.days_from_now(0),
          released_at: nil,
          status: "active"
        )

      %{events: [result, _result_b]} =
        Championships.get_championship_by_league(overall.id, league.id)

      assert result.id == event.id

      %{championship_results: [%{fantasy_player: %{roster_positions: [position]}}]} = result

      assert position.id == pos.id
    end
  end

  describe "update_next_in_season_pick/1" do
    test "update in season draft picks with next pick " do
      completed_pick = %InSeasonDraftPick{position: 1, drafted_player_id: 1}
      next_pick = %InSeasonDraftPick{position: 2, drafted_player_id: nil}
      future_pick = %InSeasonDraftPick{position: 3, drafted_player_id: nil}
      picks = [completed_pick, next_pick, future_pick]

      championship = %Championship{in_season_draft: true, in_season_draft_picks: picks}

      result = Championships.update_next_in_season_pick(championship)
      [complete, next, future] = result.in_season_draft_picks

      assert complete.next_pick == false
      assert next.next_pick == true
      assert future.next_pick == false
    end

    test "returns championship when no draft picks" do
      championship = %Championship{in_season_draft_picks: []}

      result = Championships.update_next_in_season_pick(championship)

      assert result == championship
    end
  end

  describe "preload_events_by_league/2" do
    test "preloads all events with assocs for a league" do
      league = insert(:fantasy_league)
      overall = insert(:championship)
      event = insert(:championship, overall: overall)

      %{events: [result]} = Championships.preload_events_by_league(overall, league.id)

      assert result.id == event.id
    end

    test "preloads all events and roster positions with assocs for a league" do
      league = insert(:fantasy_league)
      overall = insert(:championship)

      event =
        insert(:championship,
          overall: overall,
          championship_at: CalendarAssistant.days_from_now(-30)
        )

      event_b =
        insert(:championship,
          overall: overall,
          championship_at: CalendarAssistant.days_from_now(-2)
        )

      team = insert(:fantasy_team, fantasy_league: league, team_name: "A")
      team_b = insert(:fantasy_team, fantasy_league: league, team_name: "B")
      team_c = insert(:fantasy_team, fantasy_league: league, team_name: "C")
      player = insert(:fantasy_player)
      player2 = insert(:fantasy_player)

      insert(:championship_result, championship: event, rank: 1, points: 8, fantasy_player: player)

      _2nd_place =
        insert(:championship_result,
          championship: event,
          rank: 2,
          points: 5,
          fantasy_player: player2
        )

      insert(:championship_result,
        championship: event_b,
        rank: 1,
        points: 8,
        fantasy_player: player
      )

      pos =
        insert(
          :roster_position,
          fantasy_team: team,
          fantasy_player: player,
          active_at: CalendarAssistant.days_from_now(-60),
          released_at: CalendarAssistant.days_from_now(-15),
          status: "dropped"
        )

      _pos_b =
        insert(
          :roster_position,
          fantasy_team: team_b,
          fantasy_player: player,
          active_at: CalendarAssistant.days_from_now(-10),
          released_at: CalendarAssistant.days_from_now(-1),
          status: "dropped"
        )

      _pos_b =
        insert(
          :roster_position,
          fantasy_team: team_c,
          fantasy_player: player,
          active_at: CalendarAssistant.days_from_now(0),
          released_at: nil,
          status: "active"
        )

      %{events: [result, _result_b]} = Championships.preload_events_by_league(overall, league.id)
      assert result.id == event.id

      %{
        championship_results: [
          %{fantasy_player: %{roster_positions: [position]}},
          _2nd_place
        ]
      } = result

      assert pos.id == position.id
    end
  end

  describe "get_slot_standings/2" do
    test "return championship if it has no events" do
      league = insert(:fantasy_league)
      overall = insert(:championship)
      overall_without_events = Map.put(overall, :events, [])

      result = Championships.get_slot_standings(overall_without_events, league.id)

      assert Map.has_key?(result, :slot_standings) == false
    end

    test "calculates points for each slot and team" do
      league = insert(:fantasy_league)
      overall = insert(:championship)
      event1 = insert(:championship, overall: overall)
      event2 = insert(:championship, overall: overall)

      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)

      pos =
        insert(
          :roster_position,
          fantasy_team: team,
          fantasy_player: player
        )

      insert(:championship_slot, championship: event1, roster_position: pos, slot: 1)
      insert(:championship_slot, championship: event2, roster_position: pos, slot: 1)
      insert(:championship_result, championship: event1, points: -1, fantasy_player: player)
      insert(:championship_result, championship: event2, points: -1, fantasy_player: player)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)

      pos_b =
        insert(
          :roster_position,
          fantasy_team: team_b,
          fantasy_player: player_b
        )

      pos_c =
        insert(
          :roster_position,
          fantasy_team: team_b,
          fantasy_player: player_c
        )

      insert(:championship_slot, championship: event1, roster_position: pos_b, slot: 1)
      insert(:championship_slot, championship: event2, roster_position: pos_b, slot: 1)
      insert(:championship_slot, championship: event2, roster_position: pos_c, slot: 2)
      insert(:championship_result, championship: event1, points: 8, fantasy_player: player_b)
      insert(:championship_result, championship: event2, points: 8, fantasy_player: player_b)

      result = Championships.get_slot_standings(overall, league.id)

      assert result.slot_standings ==
               [
                 %{points: 16, rank: 1, slot: 1, team_name: team_b.team_name},
                 %{points: -2, rank: "-", slot: 1, team_name: team.team_name}
               ]
    end
  end
end
