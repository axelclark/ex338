defmodule Ex338.FantasyTeamRepoTest do
  use Ex338.DataCase
  alias Ex338.FantasyTeam

  describe "alphabetical/1" do
    test "returns fantasy teams in alphabetical order" do
      insert(:fantasy_team, team_name: "a")
      insert(:fantasy_team, team_name: "b")
      insert(:fantasy_team, team_name: "c")

      query = FantasyTeam.alphabetical(FantasyTeam)
      query = from f in query, select: f.team_name

      assert Repo.all(query) == ~w(a b c)
    end
  end

  describe "by_league/2" do
    test "returns fantasy teams in a fantasy league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      _team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      _other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)

      query = FantasyTeam.by_league(FantasyTeam, league.id)
      query = from f in query, select: f.team_name

      assert Repo.all(query) == ~w(Brown)
    end
  end

  describe "find_team/2" do
    test "returns a fantasy team" do
      team = insert(:fantasy_team)
      insert(:fantasy_team)

      result = FantasyTeam
               |> FantasyTeam.find_team(team.id)
               |> Repo.one

      assert result.id == team.id
    end
  end

  describe "order_by_waiver_position/1" do
    test "orders teams by waiver position" do
      insert(:fantasy_team, team_name: "a", waiver_position: 2)
      insert(:fantasy_team, team_name: "b", waiver_position: 3)
      insert(:fantasy_team, team_name: "c", waiver_position: 1)

      query = FantasyTeam.order_by_waiver_position(FantasyTeam)
      query = from f in query, select: f.team_name

      assert Repo.all(query) == ~w(c a b)
    end
  end

  describe "owned_players/1" do
    test "returns all active players on a team for select option" do
      league = insert(:sports_league, abbrev: "A")
      player_a = insert(:fantasy_player, sports_league: league)
      player_b = insert(:fantasy_player, sports_league: league)
      player_c = insert(:fantasy_player, sports_league: league)
      player_d = insert(:fantasy_player, sports_league: league)
      _player_e = insert(:fantasy_player, sports_league: league)
      f_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: f_league)
      team_b = insert(:fantasy_team, fantasy_league: f_league)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a,
                               status: "active")
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b,
                               status: "active")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_c,
                               status: "released")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_d,
                               status: "injured_reserve")

      query = FantasyTeam.owned_players(FantasyTeam)

      assert Repo.all(query) == [
        %{player_name: player_a.player_name, league_abbrev: league.abbrev,
          id: player_a.id},
        %{player_name: player_b.player_name, league_abbrev: league.abbrev,
          id: player_b.id}
      ]
    end
  end

  describe "preload_active_positions_for_sport/2" do
    test "returns all positions for a sports league" do
      league = insert(:sports_league)
      other_league = insert(:sports_league)
      team = insert(:fantasy_team)
      player_a = insert(:fantasy_player, sports_league: league)
      player_b = insert(:fantasy_player, sports_league: other_league)
      player_c = insert(:fantasy_player, sports_league: league)
      pos = insert(:roster_position, fantasy_player: player_a, status: "active",
        fantasy_team: team)
      insert(:roster_position, fantasy_player: player_b, status: "active",
        fantasy_team: team)
      insert(:roster_position, fantasy_player: player_c, status: "traded",
        fantasy_team: team)

      %{roster_positions: [result]} =
        FantasyTeam
        |> FantasyTeam.preload_active_positions_for_sport(league.id)
        |> Repo.one

      assert result.id == pos.id
    end
  end

  describe "preload_assocs_by_league/2" do
    test "returns active and injured reserve roster positions" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team, fantasy_player: player,
        status: "active")
      insert(:roster_position, fantasy_team: team, fantasy_player: player,
        status: "injured_reserve")
      insert(:roster_position, fantasy_team: team, fantasy_player: player,
        status: "dropped")

      %{roster_positions: results} =
        FantasyTeam
        |> FantasyTeam.preload_assocs_by_league(league)
        |> Repo.one

      assert Enum.count(results, &(&1.status == "active")) == 1
      assert Enum.count(results, &(&1.status == "injured_reserve")) == 1
      assert Enum.count(results, &(&1.status == "dropped")) == 0
    end

    test "returns correct championship results" do
      s_league = insert(:sports_league)
      player_a =
        insert(:fantasy_player, player_name: "A", sports_league: s_league)

      league = insert(:fantasy_league, year: 2018)
      insert(:league_sport, fantasy_league: league, sports_league: s_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a,
        status: "active")

      championship = insert(:championship, category: "overall", year: 2018)
      event_champ = insert(:championship, category: "event", year: 2018)
      new_champ_result =
        insert(:championship_result, championship: championship,
          fantasy_player: player_a, rank: 1, points: 8)
      _event_result =
        insert(:championship_result, championship: event_champ,
          fantasy_player: player_a, rank: 1, points: 8)
      old_championship = insert(:championship, category: "overall", year: 2017)
      _old_champ_result =
        insert(:championship_result, championship: old_championship,
          fantasy_player: player_a, rank: 1, points: 8)

      result =
        FantasyTeam
        |> FantasyTeam.preload_assocs_by_league(league)
        |> Repo.get!(team_a.id)

      %{roster_positions: [%{fantasy_player:
         %{championship_results: [champ_result]}
       }]} = result

      assert champ_result.id == new_champ_result.id
    end

    test "returns team with no results this year" do
      s_league = insert(:sports_league)
      player_a =
        insert(:fantasy_player, player_name: "A", sports_league: s_league)

      league = insert(:fantasy_league, year: 2018)
      insert(:league_sport, fantasy_league: league, sports_league: s_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      pos =
        insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a,
          status: "active")

      old_championship = insert(:championship, category: "overall", year: 2017)
      _old_champ_result =
        insert(:championship_result, championship: old_championship,
          fantasy_player: player_a, rank: 1, points: 8)

      result =
        FantasyTeam
        |> FantasyTeam.preload_assocs_by_league(league)
        |> Repo.get!(team_a.id)

      %{roster_positions: [pos_result]} = result

      assert pos_result.id == pos.id
    end
  end

  describe "right_join_players_by_league/1" do
    test "returns all players with rank and any owners in a league" do
      s_league = insert(:sports_league)
      player_a =
        insert(:fantasy_player, player_name: "A", sports_league: s_league)
      player_b =
        insert(:fantasy_player, player_name: "B", sports_league: s_league)
      _player_c =
        insert(:fantasy_player, player_name: "C", sports_league: s_league)
      player_d =
        insert(:fantasy_player, player_name: "D", sports_league: s_league)
      _player_e =
        insert(:fantasy_player, player_name: "E", sports_league: s_league,
          start_year: 2016, end_year: 2016)

      f_league_a = insert(:fantasy_league, year: 2018)
      insert(:league_sport, fantasy_league: f_league_a, sports_league: s_league)
      f_league_b = insert(:fantasy_league, year: 2018)
      insert(:league_sport, fantasy_league: f_league_b, sports_league: s_league)

      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a,
        status: "active")
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b,
        status: "active")
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_d,
        status: "injured_reserve")

      championship = insert(:championship, category: "overall", year: 2018)
      event_champ = insert(:championship, category: "event", year: 2018)
      _champ_result =
        insert(:championship_result, championship: championship,
          fantasy_player: player_a, rank: 1, points: 8)
      _event_result =
        insert(:championship_result, championship: event_champ,
          fantasy_player: player_b, rank: 1, points: 8)
      old_championship = insert(:championship, category: "overall", year: 2017)
      _old_champ_result =
        insert(:championship_result, championship: old_championship,
          fantasy_player: player_b, rank: 1, points: 8)

      results =
        f_league_a
        |> FantasyTeam.right_join_players_by_league
        |> Repo.all

      assert Enum.map(results, &(&1.player_name)) == ~w(A B C D)
      assert Enum.map(results, &(&1.team_name)) ==
        [team_a.team_name, nil, nil, team_a.team_name]
      assert Enum.map(results, &(&1.rank)) == [1, nil, nil, nil]
    end

    test "returns sports associated with a fantasy league" do
      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)
      player_a =
        insert(:fantasy_player, sports_league: sport_a)
      _player_b =
        insert(:fantasy_player, sports_league: sport_b)

      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: league_a, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league_b, sports_league: sport_b)

      [result] =
        league_a
        |> FantasyTeam.right_join_players_by_league
        |> Repo.all

      assert result.player_name == player_a.player_name
    end
  end

  describe "update_league_waiver_positions/2" do
    test "moves up waiver position for teams in league with higher priority" do
      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      _team_1 = insert(:fantasy_team, waiver_position: 1,
                                      fantasy_league: league_a)
      team_2 = insert(:fantasy_team,  waiver_position: 2,
                                      fantasy_league: league_a)
      _team_3 = insert(:fantasy_team, waiver_position: 3,
                                      fantasy_league: league_a)
      _team_4 = insert(:fantasy_team, waiver_position: 4,
                                      fantasy_league: league_b)

      result = FantasyTeam
               |> FantasyTeam.update_league_waiver_positions(team_2)
               |> Repo.update_all([])
      teams = FantasyTeam
              |> Repo.all
              |> Enum.sort(&(&1.waiver_position <= &2.waiver_position))
              |> Enum.map(&(&1.waiver_position))

      assert result == {1, nil}
      assert teams == [1, 2, 2, 4]
    end
  end

  describe "with_league/1" do
    test "returns a fantasy league associated with a team" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)

      result = FantasyTeam
               |> FantasyTeam.with_league
               |> Repo.get!(team.id)

      assert result.fantasy_league.id == league.id
    end
  end
end
