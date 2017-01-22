defmodule Ex338.RosterAdminTest do
  use Ex338.ModelCase
  alias Ex338.{RosterPosition.RosterAdmin, FantasyTeam}

  describe "primary_positions/1" do
    test "it returns only sports positions" do
      unassigned = build(:roster_position, position: "Unassigned")
      cfb = build(:roster_position, position: "CFB")
      flex = build(:roster_position, position: "Flex1")
      list = [unassigned, cfb, flex]

      result = RosterAdmin.primary_positions(list)
               |> Enum.map(&(&1.position))

      assert result == ~w(CFB)
    end
  end

  describe "flex_and_unassigned_positions/1" do
    test "it returns only sports positions" do
      unassigned = build(:roster_position, position: "Unassigned")
      cfb = build(:roster_position, position: "CFB")
      flex = build(:roster_position, position: "Flex1")
      list = [unassigned, cfb, flex]

      result = RosterAdmin.flex_and_unassigned_positions(list)
               |> Enum.map(&(&1.position))

      assert result == ~w(Flex1 Unassigned)
    end
  end

  describe "order_by_position/1" do
    test "sorts by primary positions then flex and unassigned" do
      team_a = insert(:fantasy_team)
      insert(:roster_position, position: "NFL", fantasy_team: team_a)
      insert(:roster_position, position: "CFB", fantasy_team: team_a)
      insert(:roster_position, position: "Unassigned", fantasy_team: team_a)
      insert(:roster_position, position: "Flex1",fantasy_team: team_a)

      team = FantasyTeam
            |> preload([[roster_positions: [fantasy_player: :sports_league]],
                        [owners: :user], :fantasy_league])
            |> Repo.get!(team_a.id)
            |> RosterAdmin.order_by_position

      assert Enum.map(team.roster_positions, &(&1.position)) ==
        ~w(CFB NFL Flex1 Unassigned)
    end
  end

  describe "unassigned_position?/1" do
    test "returns true if Unassigned" do
      position = "Unassigned"

      result = RosterAdmin.unassigned_position?(position)

      assert result == true
    end

    test "returns false if Unassigned" do
      position = "CFB"

      result = RosterAdmin.unassigned_position?(position)

      assert result == false
    end
  end

  describe "update_fantasy_team/2" do
    test "adds roster positions to a fantasy team" do
      fantasy_team = %{}
      positions = [%{position: "Unassigned"}, %{position: "CFB"}]

      result = RosterAdmin.update_fantasy_team(positions, fantasy_team)

      assert Enum.map(result.roster_positions, &(&1.position)) == ~w(Unassigned CFB)
    end
  end
end
