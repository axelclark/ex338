defmodule Ex338.FantasyTeamRepoTest do
  use Ex338.ModelCase
  alias Ex338.FantasyTeam

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
    test "returns all players and any owners in a league" do
      player_a = insert(:fantasy_player, player_name: "A")
      player_b = insert(:fantasy_player, player_name: "B")
      _player_c = insert(:fantasy_player, player_name: "C")
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      results = FantasyTeam.right_join_players_by_league(f_league_a.id)
                |> Repo.all

      assert Enum.map(results, &(&1.player_name)) == ~w(A B C)
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
