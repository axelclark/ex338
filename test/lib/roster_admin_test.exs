defmodule Ex338.RosterAdminTest do
  use Ex338.ModelCase, async: true
  alias Ex338.{RosterAdmin, FantasyTeam}

  describe "add_open_positions_to_teams/1" do
    test "adds position for any position without a player in a collection" do
      team_a = insert(:fantasy_team)
      team_b = insert(:fantasy_team)
      insert(:filled_roster_position, position: "Unassigned",
                                      fantasy_team: team_a)
      insert(:filled_roster_position, position: "CFB",
                                      fantasy_team: team_b)

      [a, b] = FantasyTeam
               |> preload(roster_positions: [fantasy_player: :sports_league])
               |> FantasyTeam.alphabetical
               |> Repo.all
               |> RosterAdmin.add_open_positions_to_teams

      assert Enum.count(a.roster_positions) == 21
      assert Enum.count(b.roster_positions) == 20
    end
  end

  describe "add_open_positions_to_team/1" do
    test "adds position for any position without a player for a team" do
      team_a = insert(:fantasy_team)
      insert(:filled_roster_position, position: "Unassigned",
                                      fantasy_team: team_a)
      insert(:filled_roster_position, position: "Unassigned",
                                      fantasy_team: team_a)
      insert(:filled_roster_position, position: "CFB",
                                      fantasy_team: team_a)

      team = FantasyTeam
            |> preload([[roster_positions: [fantasy_player: :sports_league]],
                        [owners: :user], :fantasy_league])
            |> Repo.get!(team_a.id)
            |> RosterAdmin.add_open_positions_to_team

      assert Enum.count(team.roster_positions) == 22
    end
  end

  describe "primary_positions/1" do
    test "it returns only sports positions" do
      unassigned = build(:filled_roster_position, position: "Unassigned")
      cfb = build(:filled_roster_position, position: "CFB")
      flex = build(:filled_roster_position, position: "Flex1")
      list = [unassigned, cfb, flex]

      result = RosterAdmin.primary_positions(list)
               |> Enum.map(&(&1.position))

      assert result == ~w(CFB)
    end
  end

  describe "flex_and_unassigned_positions/1" do
    test "it returns only sports positions" do
      unassigned = build(:filled_roster_position, position: "Unassigned")
      cfb = build(:filled_roster_position, position: "CFB")
      flex = build(:filled_roster_position, position: "Flex1")
      list = [unassigned, cfb, flex]

      result = RosterAdmin.flex_and_unassigned_positions(list)
               |> Enum.map(&(&1.position))

      assert result == ~w(Flex1 Unassigned)
    end
  end
end
