defmodule Ex338.FantasyPlayer.StoreTest do

  use Ex338.ModelCase

  alias Ex338.{CalendarAssistant}
  alias Ex338.FantasyPlayer.Store

  describe "all_plyrs_for_lg/1" do
    test "returns players grouped by sports league" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "Axel", fantasy_league: league)

      league_a = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: league_a)
      league_b = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: league_b)

      player_a = insert(:fantasy_player, sports_league: league_a)
      player_b = insert(:fantasy_player, sports_league: league_b)
      _unowned = insert(:fantasy_player, sports_league: league_b)

      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      result = Store.all_plyrs_for_lg(league.id)
      league_a_result = result[league_a.league_name]
      league_b_result = result[league_b.league_name]

      assert Enum.count(league_a_result) == 1
      assert Enum.count(league_b_result) == 2
    end
  end

  describe "available_players/1" do
    test "returns available players in league" do
      league_a = insert(:sports_league, abbrev: "A")
      league_b = insert(:sports_league, abbrev: "B")
      league_c = insert(:sports_league, abbrev: "C")
      insert(:championship, sports_league: league_a,
        waiver_deadline_at: CalendarAssistant.days_from_now(5))
      insert(:championship, sports_league: league_b,
        waiver_deadline_at: CalendarAssistant.days_from_now(5))
      insert(:championship, sports_league: league_b,
        waiver_deadline_at: CalendarAssistant.days_from_now(-5))
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      player_a = insert(:fantasy_player, sports_league: league_a)
      player_b = insert(:fantasy_player, sports_league: league_a)
      player_c = insert(:fantasy_player, sports_league: league_b)
      _player_d = insert(:fantasy_player, sports_league: league_b)
      _player_e = insert(:fantasy_player, sports_league: league_c)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_c,
                               status: "dropped")

      result = Store.available_players(f_league_a.id)

      assert Enum.count(result) == 3
    end
  end
end
