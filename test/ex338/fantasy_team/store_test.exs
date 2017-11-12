defmodule Ex338.FantasyTeam.StoreTest do
  use Ex338.DataCase
  alias Ex338.FantasyTeam.Store

  describe "find_all_for_league/1" do
    test "returns only fantasy teams in a league with open positions added" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      _other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)

      sport = insert(:sports_league, abbrev: "CFB")
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      insert(:roster_position, position: "Unassigned", fantasy_team: team)
      insert(:roster_position, status: "injured_reserve", fantasy_team: team)
      open_position = "CFB"

      teams = Store.find_all_for_league(league)
      %{roster_positions: positions} = List.first(teams)
      team = List.first(teams)

      assert Enum.map(teams, &(&1.team_name)) == ~w(Brown)
      assert Enum.any?(positions, &(&1.position) == "Unassigned")
      assert Enum.any?(positions, &(&1.position) == open_position)
      assert Enum.count(team.ir_positions) == 1
    end
  end

  describe "find_all_for_standings/1" do
    test "returns only fantasy teams in a league sorted by points" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      _other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      insert(:roster_position, position: "Unassigned", fantasy_team: team)
      insert(:roster_position, status: "injured_reserve", fantasy_team: team)

      teams = Store.find_all_for_standings(league)

      assert Enum.map(teams, &(&1.team_name)) == ~w(Brown)
      assert Enum.map(teams, &(&1.points)) == [0]
    end
  end

  describe "find_all_for_league_sport/2" do
    test "returns teams in a league with active positions for a sport" do
      fantasy_league = insert(:fantasy_league)
      other_fantasy_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: fantasy_league)
      other_team = insert(:fantasy_team, fantasy_league: other_fantasy_league)
      league = insert(:sports_league)
      other_league = insert(:sports_league)
      player_a = insert(:fantasy_player, sports_league: league)
      player_b = insert(:fantasy_player, sports_league: other_league)
      player_c = insert(:fantasy_player, sports_league: league)
      pos = insert(:roster_position, fantasy_player: player_a, status: "active",
        fantasy_team: team)
      insert(:roster_position, fantasy_player: player_b, status: "active",
        fantasy_team: team)
      insert(:roster_position, fantasy_player: player_c, status: "active",
        fantasy_team: other_team)

      [%{roster_positions: [result]}] =
        Store.find_all_for_league_sport(fantasy_league.id, league.id)

      assert result.id == pos.id
    end
  end

  describe "find/1" do
    test "returns team with assocs and calculated fields" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league,
                                   winnings_received: 75.00, dues_paid: 100.00)
      user = insert_user(%{name: "Axel"})
      insert(:owner, user: user, fantasy_team: team)

      sport = insert(:sports_league, abbrev: "CFB")
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      player =
        insert(:fantasy_player, player_name: "Houston", sports_league: sport)
      dropped_player = insert(:fantasy_player)
      ir_player = insert(:fantasy_player)

      insert(:roster_position, position: "Unassigned", fantasy_team: team,
                                          fantasy_player: player)
      insert(:roster_position, fantasy_team: team,
                               fantasy_player: dropped_player,
                               status: "dropped")
      insert(:roster_position, fantasy_team: team,
                               fantasy_player: ir_player,
                               status: "injured_reserve")

      team = Store.find(team.id)

      assert %{team_name: "Brown"} = team
      assert Enum.count(team.roster_positions) == 8
    end
  end

  describe "find_for_edit/1" do
    test "gets a team for the edit form" do
      team = insert(:fantasy_team, team_name: "Brown")
      insert(:roster_position, fantasy_team: team)

      result = Store.find_for_edit(team.id)

      assert result.team_name == team.team_name
      assert Enum.count(result.roster_positions) == 1
    end
  end

  describe "find_owned_players/1" do
    test "returns all owned players for a team" do
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      _player_c = insert(:fantasy_player)
      player_d = insert(:fantasy_player)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a,
                               status: "active")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_b,
                               status: "released")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_d,
                               status: "injured_reserve")

      [result] = Store.find_owned_players(team.id)

      assert result.id == player_a.id
    end
  end

  describe "list_teams_for_league/1" do
    test "returns all teams for a league" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, team_name: "A")
      team_b = insert(:fantasy_team, fantasy_league: league, team_name: "B")
      other_league = insert(:fantasy_league)
      _other_team = insert(:fantasy_team, fantasy_league: other_league)

      results = Store.list_teams_for_league(league.id)

      assert Enum.map(results, &(&1.id)) == [team.id, team_b.id]
    end
  end

  describe "owned_players_for_league/1" do
    test "returns all owned players for a league" do
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)
      _player_d = insert(:fantasy_player)
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a,
                               status: "active")
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b,
                               status: "active")
      insert(:roster_position, fantasy_team: other_team, fantasy_player: player_c,
                               status: "active")

      results = Store.owned_players_for_league(league.id)

      assert Enum.map(results, &(&1.id)) == [player_a.id, player_b.id]
    end
  end


  describe "update_team/2" do
    test "updates a fantasy team and its roster positions" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      position = insert(:roster_position, fantasy_team: team)
      team = Store.find_for_edit(team.id)
      attrs = %{
        "team_name" => "Cubs",
        "roster_positions" => %{
          "0" => %{"id" => position.id, "position" => "Flex1"}}
      }

      {:ok, team} = Store.update_team(team, attrs)

      assert team.team_name == "Cubs"
      assert Enum.map(team.roster_positions, &(&1.position)) == ~w(Flex1)
    end
  end
end
