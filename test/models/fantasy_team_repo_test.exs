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
end
