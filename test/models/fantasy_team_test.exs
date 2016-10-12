defmodule Ex338.FantasyTeamTest do
  @moduledoc false

  use Ex338.ModelCase, async: true

  alias Ex338.FantasyTeam

  @valid_attrs %{team_name: "some content", waiver_position: 42}
  @invalid_attrs %{team_name: nil}

  test "changeset with valid attributes" do
    changeset = FantasyTeam.changeset(%FantasyTeam{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = FantasyTeam.changeset(%FantasyTeam{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset invalid with long team_name" do
    changeset = FantasyTeam.changeset(%FantasyTeam{},
     %{team_name: "17lettersxxxxxxxx"})
    refute changeset.valid?
  end

  test "owner_changeset with valid attributes" do
    changeset = FantasyTeam.owner_changeset(%FantasyTeam{}, @valid_attrs)
    assert changeset.valid?
  end

  test "owner_changeset doesn't allow waiver update" do
    changeset = FantasyTeam.owner_changeset(%FantasyTeam{}, @valid_attrs)
    assert changeset.changes == %{team_name: "some content"}
  end

  test "owner_changeset with invalid attributes" do
    changeset = FantasyTeam.owner_changeset(%FantasyTeam{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "owner_changeset invalid with long team_name" do
    changeset = FantasyTeam.owner_changeset(%FantasyTeam{},
     %{team_name: "17lettersxxxxxxxx"})
    refute changeset.valid?
  end
end
