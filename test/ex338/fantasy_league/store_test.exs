defmodule Ex338.FantasyLeague.StoreTest do
  use Ex338.DataCase
  alias Ex338.FantasyLeague

  describe "get_archived_leagues/0" do
    test "returns archived leagues with data for standings" do
      league = insert(:fantasy_league, year: 2018, division: "B", navbar_display: "archived")
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)
      championship = insert(:championship, sports_league: sport, year: 2018)

      team_1 =
        insert(:fantasy_team, fantasy_league: league, winnings_adj: 20.00)
      insert(:roster_position, fantasy_team: team_1, fantasy_player: player)
      insert(:championship_result, points: 8, rank: 1, fantasy_player: player, championship: championship)
      insert(
        :champ_with_events_result,
        points: 8.0,
        rank: 1,
        winnings: 25.00,
        fantasy_team: team_1
      )
      team_1_points = 16.0
      team_1_winnings = 70

      _team_2 = insert(:fantasy_team, fantasy_league: league)

      league2 = insert(:fantasy_league, year: 2018, division: "A", navbar_display: "archived")
      sport2 = insert(:sports_league)
      player2 = insert(:fantasy_player, sports_league: sport2)
      championship2 = insert(:championship, sports_league: sport2, year: 2018)

      team_3 =
        insert(:fantasy_team, fantasy_league: league2)
      insert(:roster_position, fantasy_team: team_3, fantasy_player: player2)
      insert(:championship_result, points: 5, rank: 2, fantasy_player: player2, championship: championship2)
      team_3_points = 5

      team_4 = insert(:fantasy_team, fantasy_league: league2, winnings_adj: 50.00)
      insert(
        :champ_with_events_result,
        points: 8.0,
        rank: 1,
        winnings: 25.00,
        fantasy_team: team_4
      )
      team_4_points = 8.0
      team_4_winnings = 75

      league3 = insert(:fantasy_league, year: 2017, navbar_display: "archived")

      [result_a, result_b, result_c] = FantasyLeague.Store.get_archived_leagues()

      %{fantasy_teams: [team_4_result, team_3_result]} = result_a
      %{fantasy_teams: [team_1_result, _]} = result_b

      assert team_4_result.id == team_4.id
      assert team_4_result.points == team_4_points
      assert team_4_result.winnings == team_4_winnings
      assert team_3_result.points == team_3_points
      assert team_1_result.id == team_1.id
      assert team_1_result.points == team_1_points
      assert team_1_result.winnings == team_1_winnings
      assert result_c.id == league3.id
    end
  end

  describe "get_league/1" do
    test "returns league from id" do
      league = insert(:fantasy_league)

      result = FantasyLeague.Store.get(league.id)

      assert result.fantasy_league_name == league.fantasy_league_name
    end
  end

  describe "list_archived_leagues/0" do
    test "returns archived fantasy leagues" do
      insert(:fantasy_league, navbar_display: "primary")
      insert(:fantasy_league, year: 2016, division: "A", navbar_display: "archived")
      insert(:fantasy_league, year: 2017, division: "A", navbar_display: "archived")
      insert(:fantasy_league, year: 2017, division: "B", navbar_display: "archived")

      results = FantasyLeague.Store.list_archived_leagues()

      assert Enum.map(results, &(&1.year)) == [2017, 2017, 2016]
      assert Enum.map(results, &(&1.division)) == ["A", "B", "A"]
    end
  end

  describe "list_fantasy_leagues/0" do
    test "returns league from id" do
      insert_list(3, :fantasy_league)

      result = FantasyLeague.Store.list_fantasy_leagues()

      assert Enum.count(result) == 3
    end
  end

  describe "load_team_standings_data/1" do
    test "loads fantasy teams with league data" do
      league = insert(:fantasy_league, year: 2018, division: "B",  navbar_display: "archived")
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)
      championship = insert(:championship, sports_league: sport, year: 2018)
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      team_1 =
        insert(:fantasy_team, fantasy_league: league, winnings_adj: 20.00)
      insert(:roster_position, fantasy_team: team_1, fantasy_player: player)
      insert(:championship_result, points: 8, rank: 1, fantasy_player: player, championship: championship)
      insert(
        :champ_with_events_result,
        points: 8.0,
        rank: 1,
        winnings: 25.00,
        fantasy_team: team_1
      )
      team_1_points = 16.0
      team_1_winnings = 70

      _team_2 = insert(:fantasy_team, fantasy_league: league)

      %{fantasy_teams: [team_1_result, _]} = FantasyLeague.Store.load_team_standings_data(league)

      assert team_1_result.points == team_1_points
      assert team_1_result.winnings == team_1_winnings
    end
  end
end
