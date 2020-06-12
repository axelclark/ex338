defmodule Ex338.RosterPositionTest do
  use Ex338.DataCase, async: true

  alias Ex338.RosterPositions.RosterPosition

  describe "changeset/2" do
    @valid_attrs %{position: "some content", fantasy_team_id: 12}
    test "changeset with valid attributes" do
      changeset = RosterPosition.changeset(%RosterPosition{}, @valid_attrs)
      assert changeset.valid?
    end

    @invalid_attrs %{status: "active"}
    test "changeset must include fantasy_team_id" do
      changeset = RosterPosition.changeset(%RosterPosition{}, @invalid_attrs)
      refute changeset.valid?
    end

    @invalid_attrs %{status: "Active", fantasy_team_id: 12}
    test "changeset must use proper form of option" do
      changeset = RosterPosition.changeset(%RosterPosition{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "invalid if position is not unique for a fantasy team" do
      team = insert(:fantasy_team)
      player = insert(:fantasy_player)
      insert(:roster_position, position: "Flex1", fantasy_team: team)
      attrs = %{fantasy_team_id: team.id, position: "Flex1", fantasy_player: player.id}

      changeset = RosterPosition.changeset(%RosterPosition{}, attrs)
      {:error, changeset} = Repo.insert(changeset)

      refute changeset.valid?

      assert changeset.errors == [
               position:
                 {"Already have a player in this position",
                  [
                    constraint: :unique,
                    constraint_name: "roster_positions_position_fantasy_team_id_index"
                  ]}
             ]
    end

    test "check constraint if position is null" do
      position = insert(:roster_position)

      position =
        RosterPosition
        |> preload([:fantasy_team, :fantasy_player, :championship_slots, :in_season_draft_picks])
        |> Repo.get!(position.id)

      changeset = RosterPosition.changeset(position, %{position: nil})
      {:error, result} = Repo.insert(changeset)

      assert result.errors == [
               position:
                 {"Position cannot be blank or remain Unassigned",
                  [constraint: :check, constraint_name: "position_not_null"]}
             ]
    end
  end

  describe "flex_positions/1" do
    test "changeset with valid attributes" do
      num_positions = 6

      result = RosterPosition.flex_positions(num_positions)

      assert result == ["Flex1", "Flex2", "Flex3", "Flex4", "Flex5", "Flex6"]
    end
  end
end
