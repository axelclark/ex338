defmodule Ex338.FantasyTeam.StoreTest do
  use Ex338.ModelCase
  alias Ex338.FantasyTeam.Store

  describe "find_all_for_league/1" do
    test "returns only fantasy teams in a league with open positions added" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      _other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      insert(:roster_position, position: "Unassigned", fantasy_team: team)
      insert(:roster_position, status: "injured_reserve", fantasy_team: team)
      open_position = "CFB"

      teams = Store.find_all_for_league(league.id)
      %{roster_positions: positions} = List.first(teams)
      team = List.first(teams)

      assert Enum.map(teams, &(&1.team_name)) == ~w(Brown)
      assert Enum.any?(positions, &(&1.position) == "Unassigned")
      assert Enum.any?(positions, &(&1.position) == open_position)
      assert Enum.count(team.ir_positions) == 1
    end
  end

  describe "find/1" do
    test "returns team with assocs and calculated fields" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league,
                                   winnings_received: 75, dues_paid: 100)
      user = insert_user(%{name: "Axel"})
      insert(:owner, user: user, fantasy_team: team)
      player = insert(:fantasy_player, player_name: "Houston")
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
      assert Enum.count(team.roster_positions) == 21
    end
  end

  describe "find_for_edit" do
    test "gets a team for the edit form" do
      team = insert(:fantasy_team, team_name: "Brown")
      insert(:filled_roster_position, fantasy_team: team)

      result = Store.find_for_edit(team.id)

      assert result.team_name == team.team_name
      assert Enum.count(result.roster_positions) == 1
    end
  end

  describe "update_team/2" do
    test "updates a fantasy team and its roster positions" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      position = insert(:filled_roster_position, fantasy_team: team)
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
