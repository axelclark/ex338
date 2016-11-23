defmodule Ex338.FantasyTeamRepoTest do
  use Ex338.ModelCase
  alias Ex338.FantasyTeam

  describe "get_all_teams/1" do
    test "returns only fantasy teams in a league with all positions" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      _other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      insert(:roster_position, position: "Unassigned", fantasy_team: team)

      teams = FantasyTeam.get_all_teams(league.id)
      %{roster_positions: positions} = List.first(teams)

      assert Enum.map(teams, &(&1.team_name)) == ~w(Brown)
      assert Enum.any?(positions, &(&1.position) == "Unassigned")
    end
  end

  describe "get_team/1" do
    test "returns team with fantasy player details" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league,
                                   winnings_received: 75, dues_paid: 100)
      user = insert_user(%{name: "Axel"})
      insert(:owner, user: user, fantasy_team: team)
      player = insert(:fantasy_player, player_name: "Houston")
      dropped_player = insert(:fantasy_player)
      insert(:roster_position, position: "Unassigned", fantasy_team: team,
                                          fantasy_player: player)
      insert(:roster_position, fantasy_team: team,
                               fantasy_player: dropped_player,
                               status: "dropped")

      team = FantasyTeam.get_team(team.id)

      assert %{team_name: "Brown"} = team
      assert Enum.count(team.roster_positions) == 21
    end
  end

  describe "get_team_to_update" do
    test "gets a team for the edit form" do
      team = insert(:fantasy_team, team_name: "Brown")
      insert(:filled_roster_position, fantasy_team: team)

      team = FantasyTeam.get_team_to_update(team.id)

      assert team.team_name == team.team_name
      assert Enum.count(team.roster_positions) == 1
    end
  end

  describe "update_team/2" do
    test "updates a fantasy team and its roster positions" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      position = insert(:filled_roster_position, fantasy_team: team)
      team = FantasyTeam.get_team_to_update(team.id)
      attrs = %{
        "team_name" => "Cubs",
        "roster_positions" => %{
          "0" => %{"id" => position.id, "position" => "Flex1"}}
      }

      {:ok, team} = FantasyTeam.update_team(team, attrs)

      assert team.team_name == "Cubs"
      assert Enum.map(team.roster_positions, &(&1.position)) == ~w(Flex1)
    end
  end

  describe "alphabetical/1" do
    test "returns fantasy teams in alphabetical order" do
      league = insert(:fantasy_league)
      insert(:fantasy_team, team_name: "a", fantasy_league: league)
      insert(:fantasy_team, team_name: "b", fantasy_league: league)
      insert(:fantasy_team, team_name: "c", fantasy_league: league)

      query = FantasyTeam |> FantasyTeam.alphabetical
      query = from f in query, select: f.team_name

      assert Repo.all(query) == ~w(a b c)
    end
  end
  describe "right_join_players_by_league/1" do
    test "returns all players with rank and any owners in a league" do
      player_a = insert(:fantasy_player, player_name: "A")
      player_b = insert(:fantasy_player, player_name: "B")
      _player_c = insert(:fantasy_player, player_name: "C")
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)
      championship = insert(:championship, category: "overall")
      event_champ = insert(:championship, category: "event")
      _champ_result = insert(:championship_result, championship: championship,
                                                   fantasy_player: player_a,
                                                   rank: 1,
                                                   points: 8)
      _event_result = insert(:championship_result, championship: event_champ,
                                                   fantasy_player: player_b,
                                                   rank: 1,
                                                   points: 8)

      results = FantasyTeam.right_join_players_by_league(f_league_a.id)
                |> Repo.all

      assert Enum.map(results, &(&1.player_name)) == ~w(A B C)
      assert Enum.map(results, &(&1.team_name)) == [team_a.team_name, nil, nil]
      assert Enum.map(results, &(&1.rank)) == [1, nil, nil]
    end
  end

  describe "get_owned_players/1" do
    test "returns all owned players for a team" do
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      _player_c = insert(:fantasy_player)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a,
                               status: "active")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_b,
                               status: "released")

      result = FantasyTeam.get_owned_players(team.id)

      assert Enum.count(result) == 1
    end
  end

  describe "owned_players/2" do
    test "returns all active players on a team for select option" do
      league = insert(:sports_league, abbrev: "A")
      player_a = insert(:fantasy_player, sports_league: league)
      player_b = insert(:fantasy_player, sports_league: league)
      _player_c = insert(:fantasy_player, sports_league: league)
      f_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: f_league)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a,
                               status: "active")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_b,
                               status: "released")

      query = FantasyTeam.owned_players(team.id)

      assert Repo.all(query) == [
        %{player_name: player_a.player_name, league_abbrev: league.abbrev,
          id: player_a.id}
      ]
    end
  end

  describe "preload_active_positions/1" do
    test "only returns active roster positions" do
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)
      team = insert(:fantasy_team, team_name: "A")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a,
                               status: "active")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_b,
                               status: "dropped")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_c,
                               status: "traded")

      query = FantasyTeam |> FantasyTeam.preload_active_positions
      result = Repo.one!(query)

      assert Enum.count(result.roster_positions) == 1
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
end
