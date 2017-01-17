defmodule Ex338.RosterPositionTest do
  use Ex338.ModelCase, async: true

  alias Ex338.RosterPosition

  @valid_attrs %{position: "some content", fantasy_team_id: 12}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RosterPosition.changeset(%RosterPosition{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RosterPosition.changeset(%RosterPosition{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "invalid if position is not unique for a fantasy team" do
    team = insert(:fantasy_team)
    player = insert(:fantasy_player)
    insert(:roster_position, position: "Flex1", fantasy_team: team)
    attrs = %{fantasy_team_id: team.id, position: "Flex1",
              fantasy_player: player.id}

    changeset = RosterPosition.changeset(%RosterPosition{}, attrs)
    {:error, changeset} = Repo.insert(changeset)

    refute changeset.valid?
    assert changeset.errors ==
      [position: {"Already have a player in this position", []}]
  end

  test "check constraint if position is null" do
    position = insert(:roster_position)
    position = RosterPosition
               |> preload([:fantasy_team, :fantasy_player, :championship_slots])
               |> Repo.get!(position.id)

    changeset = RosterPosition.changeset(position, %{position: nil})
    {:error, result} = Repo.insert(changeset)

    assert result.errors == [position:
     {"Position cannot be blank or remain Unassigned", []}]
  end
end
