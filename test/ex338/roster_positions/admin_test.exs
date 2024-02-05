defmodule Ex338.RosterPositions.AdminTest do
  use Ex338.DataCase, async: true

  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.RosterPositions.Admin

  describe "primary_positions/1" do
    test "it returns only sports positions" do
      unassigned = build(:roster_position, position: "Unassigned")
      cfb = build(:roster_position, position: "CFB")
      flex = build(:roster_position, position: "Flex1")
      list = [unassigned, cfb, flex]

      result =
        list
        |> Admin.primary_positions()
        |> Enum.map(& &1.position)

      assert result == ~w(CFB)
    end
  end

  describe "flex_and_unassigned_positions/1" do
    test "it returns only sports positions" do
      unassigned = build(:roster_position, position: "Unassigned")
      cfb = build(:roster_position, position: "CFB")
      flex = build(:roster_position, position: "Flex1")
      list = [unassigned, cfb, flex]

      result =
        list
        |> Admin.flex_and_unassigned_positions()
        |> Enum.map(& &1.position)

      assert result == ~w(Flex1 Unassigned)
    end
  end

  describe "order_by_position/1" do
    test "sorts by primary positions then flex and unassigned" do
      team_a = insert(:fantasy_team)
      insert(:roster_position, position: "NFL", fantasy_team: team_a)
      insert(:roster_position, position: "CFB", fantasy_team: team_a)
      insert(:roster_position, position: "Unassigned", fantasy_team: team_a)
      insert(:roster_position, position: "Flex1", fantasy_team: team_a)

      team =
        FantasyTeam
        |> preload([
          [roster_positions: [fantasy_player: :sports_league]],
          [owners: :user],
          :fantasy_league
        ])
        |> Repo.get!(team_a.id)
        |> Admin.order_by_position()

      assert Enum.map(team.roster_positions, & &1.position) == ~w(CFB NFL Flex1 Unassigned)
    end
  end

  describe "unassigned_position?/1" do
    test "returns true if Unassigned" do
      position = "Unassigned"

      result = Admin.unassigned_position?(position)

      assert result == true
    end

    test "returns false if Unassigned" do
      position = "CFB"

      result = Admin.unassigned_position?(position)

      assert result == false
    end
  end

  describe "update_fantasy_team/2" do
    test "adds roster positions to a fantasy team" do
      fantasy_team = %{}
      positions = [%{position: "Unassigned"}, %{position: "CFB"}]

      result = Admin.update_fantasy_team(positions, fantasy_team)

      assert Enum.map(result.roster_positions, & &1.position) == ~w(Unassigned CFB)
    end
  end
end
