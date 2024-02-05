defmodule Ex338.FantasyLeaguesTest do
  use Ex338.DataCase, async: true

  alias Ex338.FantasyLeagues
  alias Ex338.FantasyLeagues.FantasyLeague

  test "change_fantasy_league/1 returns a fantasy_league changeset" do
    fantasy_league = insert(:fantasy_league)
    assert %Ecto.Changeset{} = FantasyLeagues.change_fantasy_league(fantasy_league)
  end

  test "create_future_picks/2 create future picks for teams" do
    league = insert(:fantasy_league)
    insert_list(3, :fantasy_team, fantasy_league: league)
    picks = 2

    results = FantasyLeagues.create_future_picks_for_league(league.id, picks)

    assert Enum.map(results, & &1.round) == [1, 1, 1, 2, 2, 2]
  end

  describe "get_archived_leagues/0" do
    test "returns archived leagues with data for standings" do
      league = insert(:fantasy_league, year: 2018, division: "B", navbar_display: "archived")
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)
      championship = insert(:championship, sports_league: sport, year: 2018)

      team_1 = insert(:fantasy_team, fantasy_league: league, winnings_adj: 20.00)
      insert(:roster_position, fantasy_team: team_1, fantasy_player: player)

      insert(:championship_result,
        points: 8,
        rank: 1,
        fantasy_player: player,
        championship: championship
      )

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

      team_3 = insert(:fantasy_team, fantasy_league: league2)
      insert(:roster_position, fantasy_team: team_3, fantasy_player: player2)

      insert(:championship_result,
        points: 5,
        rank: 2,
        fantasy_player: player2,
        championship: championship2
      )

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

      [result_a, result_b, result_c] = FantasyLeagues.get_leagues_by_status("archived")

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

      result = FantasyLeagues.get(league.id)

      assert result.fantasy_league_name == league.fantasy_league_name
    end
  end

  describe "get_fantasy_league!" do
    test "returns the fantasy_league with given id" do
      fantasy_league = insert(:fantasy_league)
      assert FantasyLeagues.get_fantasy_league!(fantasy_league.id) == fantasy_league
    end
  end

  describe "list_all_winnings/0" do
    test "returns all winnings" do
      insert_list(2, :historical_winning)

      result = FantasyLeagues.list_all_winnings()

      assert Enum.count(result) == 2
    end
  end

  describe "list_current_all_time_records/0" do
    test "only returns current all time records" do
      _all_time3 = insert(:historical_record, type: "all_time", archived: false, order: 3.0)
      _all_time1 = insert(:historical_record, type: "all_time", archived: false, order: 1.0)
      _all_time2 = insert(:historical_record, type: "all_time", archived: false, order: 2.0)
      insert(:historical_record, type: "season", order: 4.0)
      insert(:historical_record, type: "all_time", archived: true, order: 5.0)

      results = FantasyLeagues.list_current_all_time_records()

      assert Enum.map(results, & &1.order) == [1.0, 2.0, 3.0]
    end
  end

  describe "list_current_season_records/0" do
    test "only returns current single season records" do
      _season1 = insert(:historical_record, type: "season", archived: false, order: 3.0)
      _season2 = insert(:historical_record, type: "season", archived: false, order: 1.0)
      _season3 = insert(:historical_record, type: "season", archived: false, order: 2.0)
      insert(:historical_record, type: "all_time", order: 4.0)
      insert(:historical_record, type: "season", archived: true, order: 5.0)

      results = FantasyLeagues.list_current_season_records()

      assert Enum.map(results, & &1.order) == [1.0, 2.0, 3.0]
    end
  end

  describe "list_leagues_by_status/1" do
    test "returns fantasy leagues by status" do
      insert(:fantasy_league, navbar_display: "primary")
      insert(:fantasy_league, year: 2016, division: "A", navbar_display: "archived")
      insert(:fantasy_league, year: 2017, division: "A", navbar_display: "archived")
      insert(:fantasy_league, year: 2017, division: "B", navbar_display: "archived")

      results = FantasyLeagues.list_leagues_by_status("archived")

      assert Enum.map(results, & &1.year) == [2017, 2017, 2016]
      assert Enum.map(results, & &1.division) == ["A", "B", "A"]
    end
  end

  describe "list_fantasy_leagues/0" do
    test "returns league from id" do
      insert_list(3, :fantasy_league)

      result = FantasyLeagues.list_fantasy_leagues()

      assert Enum.count(result) == 3
    end
  end

  describe "load_team_standings_data/1" do
    test "loads fantasy teams with league data" do
      league = insert(:fantasy_league, year: 2018, division: "B", navbar_display: "archived")
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)
      championship = insert(:championship, sports_league: sport, year: 2018)
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      team_1 = insert(:fantasy_team, fantasy_league: league, winnings_adj: 20.00)
      insert(:roster_position, fantasy_team: team_1, fantasy_player: player)

      insert(:championship_result,
        points: 8,
        rank: 1,
        fantasy_player: player,
        championship: championship
      )

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

      %{fantasy_teams: [team_1_result, _]} = FantasyLeagues.load_team_standings_data(league)

      assert team_1_result.points == team_1_points
      assert team_1_result.winnings == team_1_winnings
    end
  end

  @update_attrs %{
    championships_end_at: "2011-05-18T15:01:01Z",
    championships_start_at: "2011-05-18T15:01:01Z",
    division: "some updated division",
    draft_method: "redraft",
    fantasy_league_name: "some updated fantasy_league_name",
    max_draft_hours: 43,
    max_flex_spots: 43,
    must_draft_each_sport?: false,
    navbar_display: "primary",
    only_flex?: false,
    year: 43
  }
  @invalid_attrs %{
    championships_end_at: nil,
    championships_start_at: nil,
    division: nil,
    draft_method: nil,
    fantasy_league_name: nil,
    max_draft_hours: nil,
    max_flex_spots: nil,
    must_draft_each_sport?: nil,
    navbar_display: nil,
    only_flex?: nil,
    year: nil
  }

  describe "update_fantasy_league/2" do
    test "update_fantasy_league/2 with valid data updates the fantasy_league" do
      fantasy_league = insert(:fantasy_league)

      assert {:ok, %FantasyLeague{} = fantasy_league} =
               FantasyLeagues.update_fantasy_league(fantasy_league, @update_attrs)

      assert fantasy_league.championships_end_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert fantasy_league.championships_start_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert fantasy_league.division == "some updated division"
      assert fantasy_league.draft_method == :redraft
      assert fantasy_league.fantasy_league_name == "some updated fantasy_league_name"
      assert fantasy_league.max_draft_hours == 43
      assert fantasy_league.max_flex_spots == 43
      assert fantasy_league.must_draft_each_sport? == false
      assert fantasy_league.navbar_display == :primary
      assert fantasy_league.only_flex? == false
      assert fantasy_league.year == 43
    end

    test "update_fantasy_league/2 with invalid data returns error changeset" do
      fantasy_league = insert(:fantasy_league)

      assert {:error, %Ecto.Changeset{}} =
               FantasyLeagues.update_fantasy_league(fantasy_league, @invalid_attrs)

      assert fantasy_league == FantasyLeagues.get_fantasy_league!(fantasy_league.id)
    end
  end
end
